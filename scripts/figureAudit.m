function report = figureAudit(C, varargin)
%FIGUREAUDIT  Contrast and grayscale-separation audit for a colour set.
%
%   report = figureAudit(C)
%   report = figureAudit(C, 'Background', [1 1 1])
%   report = figureAudit(C, 'Role', 'text')        % 4.5:1 threshold
%   report = figureAudit(C, 'Role', 'graphical')   % 3:1 threshold (default)
%   report = figureAudit(C, 'MinDeltaL', 10)
%   figureAudit(figurePalette('okabe_ito_on_white'))
%
%   C is n-by-3 RGB in [0 1] - exactly what figurePalette returns.
%
%   What this reports
%     - WCAG 2.2 sRGB contrast of each colour against the background.
%     - Pairwise contrast between colours.
%     - CIE L* of each colour and pairwise |delta L*|, i.e. what survives
%       when hue is removed (a grayscale photocopy or a monochrome print).
%
%   What this does NOT do
%     It is not a colour-vision simulation, not a proof of WCAG conformance,
%     and not a print preview. The 10-unit delta L* screen is a heuristic
%     from the source skill, not a WCAG threshold. Contrast depends on line
%     width, adjacency, and the actual rendered size - look at the exported
%     figure before believing any number here.
%
%   WCAG 2.2 targets used: 4.5:1 normal text, 3:1 large text and for
%   graphical objects required to understand the content (SC 1.4.3, 1.4.11).
%
%   See also figurePalette, figureStyle.

p = inputParser;
p.addParameter('Background', [1 1 1], @(v) isnumeric(v) && numel(v) == 3);
p.addParameter('Role', 'graphical', @(v) ischar(v) || isstring(v));
p.addParameter('MinDeltaL', 10, @(v) isnumeric(v) && isscalar(v));
p.parse(varargin{:});

bg       = p.Results.Background(:)';
role     = lower(char(p.Results.Role));
minDL    = p.Results.MinDeltaL;

switch role
    case 'text'
        threshold = 4.5;
    case {'largetext', 'large-text', 'large'}
        threshold = 3.0;
    case {'graphical', 'graphic', 'objects'}
        threshold = 3.0;
    otherwise
        error('figureAudit:badRole', ...
            'Role must be ''text'', ''large'', or ''graphical''.');
end

if ~isnumeric(C) || size(C, 2) ~= 3
    error('figureAudit:badInput', 'C must be an n-by-3 RGB array in [0 1].');
end

n   = size(C, 1);
Lbg = luminance(bg);

%...Per-colour contrast against the background
contrastBg = zeros(n, 1);
Lstar      = zeros(n, 1);
for k = 1:n
    contrastBg(k) = wcagContrast(C(k, :), bg);
    Lstar(k)      = cieLstar(C(k, :));
end

%...Pairwise contrast and grayscale separation
pairContrast = nan(n);
pairDeltaL   = nan(n);
for i = 1:n
    for j = i+1:n
        pairContrast(i, j) = wcagContrast(C(i, :), C(j, :));
        pairDeltaL(i, j)   = abs(Lstar(i) - Lstar(j));
    end
end

tooLowContrast = contrastBg < threshold;
[pairsI, pairsJ] = find(tril(pairDeltaL < minDL, -1));
grayscaleClash = [pairsI, pairsJ];

report = struct();
report.colours          = C;
report.background       = bg;
report.role             = role;
report.threshold        = threshold;
report.contrastOnBg     = contrastBg;
report.cieLstar         = Lstar;
report.pairwiseContrast = pairContrast;
report.pairwiseDeltaL   = pairDeltaL;
report.belowThreshold   = find(tooLowContrast).';
report.grayscaleClash   = grayscaleClash;
report.backgroundLum    = Lbg;

printReport(report);
end


% -------------------------------------------------------------------------
function printReport(r)
n = size(r.colours, 1);
fprintf('\n=== Palette audit (n = %d, role = %s, threshold %.1f:1) ===\n', ...
        n, r.role, r.threshold);

fprintf('%-4s %-20s %-9s %-8s %s\n', '#', 'RGB', 'contrast', 'L*', 'verdict');
for k = 1:n
    if k <= numel(r.belowThreshold) && any(r.belowThreshold == k)
        verdict = 'BELOW threshold';
    else
        verdict = 'ok';
    end
    fprintf('%-4d %-20s %-9.2f %-8.1f %s\n', k, ...
            sprintf('%.2f %.2f %.2f', r.colours(k, :)), ...
            r.contrastOnBg(k), r.cieLstar(k), verdict);
end

if isempty(r.belowThreshold)
    fprintf('\nAll colours clear %.1f:1 against the background.\n', r.threshold);
else
    fprintf(['\n%d colour(s) fall below %.1f:1. For thin lines and markers ' ...
             'on this background, remove them or add an outline.\n'], ...
            numel(r.belowThreshold), r.threshold);
end

if isempty(r.grayscaleClash)
    fprintf('Grayscale screen: all pairs differ by more than the threshold.\n');
else
    fprintf('Grayscale screen: these pairs collapse when hue is removed:\n');
    for k = 1:size(r.grayscaleClash, 1)
        i = r.grayscaleClash(k, 1);
        j = r.grayscaleClash(k, 2);
        fprintf('  #%d vs #%d  (delta L* = %.1f)\n', i, j, r.pairwiseDeltaL(i, j));
    end
    fprintf(['Give these series different markers or line styles - that is ' ...
             'the redundant cue that survives a photocopy.\n']);
end

worst = min(r.contrastOnBg);
fprintf(['\nSmallest background contrast: %.2f:1. This is a screen, not a ' ...
         'certification: check the exported figure at final size.\n\n'], worst);
end


% -------------------------------------------------------------------------
function Y = luminance(rgb)
% Relative luminance per WCAG 2.2, sRGB transfer function.
lin = sRGBtoLinear(rgb);
Y   = 0.2126*lin(1) + 0.7152*lin(2) + 0.0722*lin(3);
end

function v = sRGBtoLinear(c)
c = min(max(c, 0), 1);
v = c / 12.92;
mask = c > 0.04045;
v(mask) = ((c(mask) + 0.055) / 1.055) .^ 2.4;
end

function ratio = wcagContrast(a, b)
La = luminance(a);
Lb = luminance(b);
hi = max(La, Lb);
lo = min(La, Lb);
ratio = (hi + 0.05) / (lo + 0.05);
end

function L = cieLstar(rgb)
Y  = luminance(rgb);
Yn = 1.0;
e  = (6/29)^3;
if Y > e
    f = (Y / Yn)^(1/3);
else
    f = Y / (3*(6/29)^2) + 4/29;
end
L = 116*f - 16;
end