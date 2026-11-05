function report = figureExport(fig, base, varargin)
%FIGUREEXPORT  Write vector and raster copies of a figure, then measure them.
%
%   report = figureExport(fig, 'outputs/fig1')
%   report = figureExport(fig, 'outputs/fig1', 'Formats', {'pdf','png'}, ...
%                         'WidthMM', 89, 'DPI', 300, ...
%                         'Provenance', struct('raw_data', 'data/obs.csv', ...
%                                              'transformations', 'group mean'))
%
%   Name-value options
%     'Formats'     cellstr; any of pdf, eps, svg, png, tif. Default {'pdf','png'}.
%     'WidthMM'     physical width in mm. Height follows the figure's aspect
%                   ratio unless 'HeightMM' is given.
%     'HeightMM'    physical height in mm.
%     'DPI'         raster resolution. Default 300.
%     'Overwrite'   false by default: an existing file is an error, not a
%                   silent replacement. Pass true when you mean it.
%     'Provenance'  struct describing raw data, transformations, uncertainty,
%                   and missing-data handling. Written into the manifest.
%     'Manifest'    true (default) to write <base>_manifest.json.
%
%   Why refuse implicit overwrite: a silently replaced figure makes it
%   impossible to tell which data version a manuscript used. The manifest and
%   the refusal together keep the evidence chain.
%
%   Physical size
%     Vector output goes through print() with PaperSize/PaperPosition set, so
%     the PDF page really is WidthMM wide. Raster output goes through
%     exportgraphics() at the requested DPI, giving
%     pixels = WidthMM / 25.4 * DPI.
%     Both are measured afterwards with figureMetadata; a >2% deviation is
%     reported, not hidden.
%
%   See also figureStyle, figureMetadata.

p = inputParser;
p.addParameter('Formats', {'pdf', 'png'}, @(v) iscellstr(v) || isstring(v) || ischar(v));
p.addParameter('WidthMM', [], @(v) isempty(v) || (isnumeric(v) && isscalar(v)));
p.addParameter('HeightMM', [], @(v) isempty(v) || (isnumeric(v) && isscalar(v)));
p.addParameter('DPI', 300, @(v) isnumeric(v) && isscalar(v) && v > 0);
p.addParameter('Overwrite', false, @(v) islogical(v) || isnumeric(v));
p.addParameter('Provenance', struct(), @(v) isstruct(v));
p.addParameter('Manifest', true, @(v) islogical(v) || isnumeric(v));
p.parse(varargin{:});
o = p.Results;

if ~ishghandle(fig) || ~strcmp(get(fig, 'Type'), 'figure')
    error('figureExport:badFigure', 'First argument must be a figure handle.');
end
if ~ischar(base) && ~isstring(base)
    error('figureExport:badBase', 'base must be a path without an extension.');
end
base = char(base);

outDir = fileparts(base);
if ~isempty(outDir) && ~isfolder(outDir)
    mkdir(outDir);
end

formats = normalizeFormats(o.Formats);

%...Refuse to clobber before doing any work
targets = cell(1, numel(formats));
for k = 1:numel(formats)
    targets{k} = [base '.' formats{k}];
    if isfile(targets{k}) && ~o.Overwrite
        error('figureExport:exists', ...
            ['%s already exists. Pass ''Overwrite'', true if replacing it ' ...
             'is intended - a silent replacement breaks the link between a ' ...
             'figure and the data version that produced it.'], targets{k});
    end
end

setPhysicalSize(fig, o.WidthMM, o.HeightMM);

report = struct();
report.base    = base;
report.formats = formats;
report.files   = cell(1, numel(formats));
report.bytes   = zeros(1, numel(formats));
report.metrics = cell(1, numel(formats));

for k = 1:numel(formats)
    fmt  = formats{k};
    file = targets{k};
    switch fmt
        case {'pdf', 'eps'}
            print(fig, ['-d' fmt], '-r0', '-painters', file);
        case 'svg'
            exportgraphics(fig, file, 'ContentType', 'vector', ...
                           'BackgroundColor', 'white');
        case {'png', 'tif', 'tiff', 'jpg', 'jpeg'}
            % print() honours PaperPosition, so the pixel count is
            % width_mm/25.4*DPI. exportgraphics crops to content instead,
            % which silently shrinks the delivered physical width.
            print(fig, ['-d' fmt], sprintf('-r%d', round(o.DPI)), file);
        otherwise
            error('figureExport:badFormat', 'Unsupported format "%s".', fmt);
    end
    d = dir(file);
    report.files{k} = file;
    report.bytes(k) = d.bytes;

    %...Measure what was written instead of trusting the request.
    try
        report.metrics{k} = figureMetadata(file, ...
            'TargetWidthMM', o.WidthMM, 'MinDPI', o.DPI);
    catch ME
        report.metrics{k} = struct('error', ME.message);
    end
end

if o.Manifest
    manifestPath = [base '_manifest.json'];
    m = struct();
    m.created      = char(datetime('now', 'Format', 'yyyy-MM-dd''T''HH:mm:ss'));
    m.matlab       = version;
    m.figure       = base;
    m.formats      = formats;
    m.dpi          = o.DPI;
    m.width_mm     = o.WidthMM;
    m.height_mm    = o.HeightMM;
    m.files        = {report.files};
    m.provenance   = o.Provenance;
    m.notice       = ['Provenance is only as complete as what was supplied. ' ...
                      'This manifest is not a publisher-compliance record.'];
    fid = fopen(manifestPath, 'w', 'n', 'UTF-8');
    if fid == -1
        warning('figureExport:manifest', 'Could not write %s.', manifestPath);
    else
        fwrite(fid, jsonencode(m, 'PrettyPrint', true));
        fclose(fid);
        report.manifest = manifestPath;
    end
end

printSummary(report);
end


% -------------------------------------------------------------------------
function formats = normalizeFormats(v)
if ischar(v) || isstring(v)
    v = cellstr(v);
end
v = cellfun(@(s) lower(strtrim(char(s))), v, 'UniformOutput', false);
v = v(~cellfun(@isempty, v));
[~, ia] = unique(v, 'stable');
formats = v(sort(ia));
end


% -------------------------------------------------------------------------
function setPhysicalSize(fig, wMM, hMM)
set(fig, 'Units', 'centimeters');
pos = get(fig, 'Position');
w = pos(3);
h = pos(4);
if ~isempty(wMM)
    w = wMM / 10;
    if isempty(hMM)
        h = w * pos(4) / pos(3);     % keep the aspect ratio
    end
end
if ~isempty(hMM)
    h = hMM / 10;
end
set(fig, 'Position', [pos(1) pos(2) w h]);
set(fig, 'PaperUnits', 'centimeters');
set(fig, 'PaperSize', [w h]);
set(fig, 'PaperPositionMode', 'manual');
set(fig, 'PaperPosition', [0 0 w h]);
end


% -------------------------------------------------------------------------
function printSummary(r)
fprintf('\n=== Export ===\n');
for k = 1:numel(r.files)
    m = r.metrics{k};
    fprintf('  %-40s %8.1f kB', r.files{k}, r.bytes(k) / 1024);
    if isfield(m, 'pixels')
        fprintf('  %dx%d px', m.pixels(1), m.pixels(2));
    end
    fprintf('\n');
    if isfield(m, 'error')
        fprintf('    ! metadata check failed: %s\n', m.error);
    end
    if isfield(m, 'warnings')
        for q = 1:numel(m.warnings)
            fprintf('    ! %s\n', m.warnings{q});
        end
    end
end
if isfield(r, 'manifest')
    fprintf('  manifest: %s\n', r.manifest);
end
fprintf('\n');
end