function info = figureMetadata(file, varargin)
%FIGUREMETADATA  Read back a delivered figure and check it against the brief.
%
%   info = figureMetadata('outputs/fig1.png')
%   info = figureMetadata('outputs/fig1.tif', 'TargetWidthMM', 89, 'MinDPI', 300)
%
%   Name-value options
%     'TargetWidthMM'  intended printed width, used to compute the effective
%                      resolution the reader will actually see.
%     'MinDPI'         required resolution; anything below is flagged.
%
%   Measured, not assumed. A PNG can carry XResolution 300 while being 900 px
%   wide, which prints at 216 dpi across 106 mm - the metadata number and the
%   usable number disagree. This function reports both.
%
%   Raster formats go through imfinfo. PDF and EPS are reported by size only:
%   MATLAB cannot read a PDF page box without an external tool, so a vector
%   file's physical size is NOT verified here. Check it once with your
%   publisher's preflight or Acrobat, and trust figureExport's PaperPosition
%   settings for the rest.
%
%   See also figureExport, figureAudit.

p = inputParser;
p.addParameter('TargetWidthMM', [], @(v) isempty(v) || (isnumeric(v) && isscalar(v)));
p.addParameter('MinDPI', [], @(v) isempty(v) || (isnumeric(v) && isscalar(v)));
p.parse(varargin{:});
o = p.Results;

if ~isfile(file)
    error('figureMetadata:missing', 'File not found: %s', file);
end

d = dir(file);
info = struct();
info.file  = file;
info.bytes = d.bytes;
info.warnings = {};

[~, ~, ext] = fileparts(file);
ext = lower(ext);

switch ext
    case {'.png', '.tif', '.tiff', '.jpg', '.jpeg', '.bmp', '.gif'}
        f = imfinfo(file);
        info.format     = ext(2:end);
        info.pixels     = [f(1).Width, f(1).Height];
        info.bitDepth   = f(1).BitDepth;
        info.colorType  = f(1).ColorType;
        if isfield(f(1), 'Compression')
            info.compression = f(1).Compression;
        end
        [dpiX, dpiUnit] = readResolution(f(1));
        info.dpi         = dpiX;
        info.dpiUnit     = dpiUnit;
        info.hasAlpha    = any(strcmpi(f(1).ColorType, ...
                             {'truecolor with alpha', 'grayscale with alpha'}));

        if ~isempty(o.TargetWidthMM)
            widthIn        = o.TargetWidthMM / 25.4;
            info.effectiveDPI = f(1).Width / widthIn;
            info.printedWidthMM = o.TargetWidthMM;
            if ~isnan(dpiX) && abs(dpiX - info.effectiveDPI) / max(dpiX, eps) > 0.02
                info.warnings{end+1} = sprintf( ...
                    ['Embedded metadata says %.0f dpi, but at %g mm wide the ' ...
                     'image is %.0f dpi. The reader sees the lower number.'], ...
                    dpiX, o.TargetWidthMM, info.effectiveDPI);
            end
        elseif ~isnan(dpiX) && dpiX > 0
            info.effectiveDPI = dpiX;
            info.printedWidthMM = f(1).Width / dpiX * 25.4;
        end

        % Rounding a pixel count to an integer moves the effective dpi by a
        % fraction; do not call 299.99 dpi a failure against a 300 dpi target.
        if ~isempty(o.MinDPI) && isfield(info, 'effectiveDPI') ...
                && info.effectiveDPI < o.MinDPI - 0.5
            info.warnings{end+1} = sprintf( ...
                'Effective resolution %.0f dpi is below the %.0f dpi target.', ...
                info.effectiveDPI, o.MinDPI);
        end

        if info.hasAlpha
            info.warnings{end+1} = [ ...
                'File carries an alpha channel. Unless the destination ' ...
                'requires transparency, flatten onto white - an unexpected ' ...
                'background changes apparent contrast.'];
        end

    case {'.pdf', '.eps', '.ps'}
        info.format = ext(2:end);
        info.vector = true;
        box = readPdfPageBox(file);
        if ~isempty(box)
            % PDF user space is 1/72 inch.
            info.pageMM = box(3:4) / 72 * 25.4;
            info.printedWidthMM = info.pageMM(1);
            if ~isempty(o.TargetWidthMM)
                dev = abs(info.pageMM(1) - o.TargetWidthMM) / o.TargetWidthMM;
                if dev > 0.02
                    info.warnings{end+1} = sprintf( ...
                        ['Page is %.1f mm wide but %g mm was requested ' ...
                         '(%.1f%% off). Check PaperPosition.'], ...
                        info.pageMM(1), o.TargetWidthMM, dev*100);
                end
            end
        else
            info.note = [ ...
                'Page box not readable (compressed object stream). Verify ' ...
                'the delivered size with the publisher preflight tool.'];
        end
        if d.bytes > 20e6
            info.warnings{end+1} = sprintf( ...
                ['File is %.1f MB. Large vector files usually mean a dense ' ...
                 'scatter or an embedded raster; consider rasterizing that ' ...
                 'artist only.'], d.bytes / 1e6);
        end

    otherwise
        error('figureMetadata:badFormat', 'Unsupported file type: %s', ext);
end

printInfo(info);
end


% -------------------------------------------------------------------------
function box = readPdfPageBox(file)
% Best-effort read of the first MediaBox. A PDF that stores page objects in
% a compressed object stream returns empty, and the caller says so rather
% than inventing a number.
box = [];
fid = fopen(file, 'r', 'n', 'latin1');
if fid == -1
    return
end
txt = fread(fid, Inf, 'uint8=>char').';
fclose(fid);
tok = regexp(txt, 'MediaBox\s*\[\s*([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s+([-\d.]+)\s*\]', ...
             'tokens', 'once');
if isempty(tok)
    return
end
if iscell(tok) && isscalar(tok) && iscell(tok{1})
    tok = tok{1};
end
vals = str2double(tok);
if numel(vals) == 4
    box = vals;
end
end


% -------------------------------------------------------------------------
function [dpi, unitName] = readResolution(f)
dpi = NaN;
unitName = 'unknown';
if isfield(f, 'XResolution') && isnumeric(f.XResolution) ...
        && ~isempty(f.XResolution) && f.XResolution > 0
    unitName = 'inch';
    if isfield(f, 'ResolutionUnit')
        u = lower(char(f.ResolutionUnit));
        if contains(u, 'meter')
            unitName = 'meter';
        elseif contains(u, 'centimeter')
            unitName = 'centimeter';
        elseif contains(u, 'none')
            unitName = 'none';
        end
    end
    switch unitName
        case 'inch'
            dpi = f.XResolution;
        case 'centimeter'
            dpi = f.XResolution * 2.54;
        case 'meter'
            % MATLAB writes pixels per metre; 1 m = 39.3701 in.
            dpi = f.XResolution * 0.0254;
        otherwise
            dpi = NaN;
    end
end
end


% -------------------------------------------------------------------------
function printInfo(i)
fprintf('\n=== %s ===\n', i.file);
fprintf('  format      : %s\n', i.format);
fprintf('  size        : %.1f kB\n', i.bytes / 1024);
if isfield(i, 'pixels')
    fprintf('  pixels      : %d x %d\n', i.pixels(1), i.pixels(2));
    fprintf('  bit depth   : %d\n', i.bitDepth);
    fprintf('  colour type : %s\n', i.colorType);
end
if isfield(i, 'pageMM')
    fprintf('  page        : %.2f x %.2f mm\n', i.pageMM(1), i.pageMM(2));
end
if isfield(i, 'effectiveDPI')
    fprintf('  effective   : %.0f dpi over %.1f mm\n', ...
            i.effectiveDPI, i.printedWidthMM);
elseif isfield(i, 'dpi') && ~isnan(i.dpi)
    fprintf('  embedded dpi: %.0f\n', i.dpi);
end
if isfield(i, 'note')
    fprintf('  note        : %s\n', i.note);
end
for k = 1:numel(i.warnings)
    fprintf('  ! %s\n', i.warnings{k});
end
fprintf('\n');
end