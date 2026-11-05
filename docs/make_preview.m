%MAKE_PREVIEW  Regenerate docs/before-after.png.
%
%   Left panel  : what MATLAB gives you with no styling at all.
%   Right panel : the same data through figurePalette + figureStyle + figureExport.
%
%   Run from the skill root:  make_preview

home = getenv('USERPROFILE');
if isempty(home), home = getenv('HOME'); end
skillDir = fullfile(home, '.claude', 'skills', 'matlab-scientific-visualization');
addpath(fullfile(skillDir, 'scripts'));

outDir = fullfile(skillDir, 'docs');
if ~isfolder(outDir), mkdir(outDir); end

t  = linspace(0, 2*pi, 300);
Y  = [sin(t); cos(t).*exp(-0.15*t); 0.5*sin(2*t) + 0.15];
labels = {'Observed', 'Model', 'Residual'};

f = figure('Color','w','Visible','off');
tlo = tiledlayout(f, 1, 2, 'TileSpacing','compact', 'Padding','compact');

%... (a) untouched defaults: default colour cycle, grid off, legend on the data
ax1 = nexttile(tlo);
hold(ax1,'on')
for k = 1:3
    plot(ax1, t, Y(k,:), 'LineWidth', 1);
end
hold(ax1,'off')
xlabel(ax1,'t'); ylabel(ax1,'y');
legend(ax1, labels, 'Location','best');
title(ax1,'(a) MATLAB defaults');

%... (b) colour + line style + marker, light grid, legend outside
ax2 = nexttile(tlo);
C   = figurePalette('okabe_ito_on_white', 3);
sty = {'-','--','-.'};
mk  = {'o','s','^'};
hold(ax2,'on')
for k = 1:3
    plot(ax2, t, Y(k,:), sty{k}, 'Color', C(k,:), 'LineWidth', 1.5, ...
         'Marker', mk{k}, 'MarkerSize', 4, 'MarkerFaceColor', C(k,:), ...
         'MarkerIndices', 1:30:numel(t), 'DisplayName', labels{k});
end
hold(ax2,'off')
xlabel(ax2,'Time (s)'); ylabel(ax2,'Response (unit)');
legend(ax2, 'Location','eastoutside');
title(ax2,'(b) figurePalette + figureStyle');

% Style and resize only panel (b); panel (a) must stay untouched.
figureStyle('publication', ax2, 'WidthMM', 180, 'HeightMM', 72, 'Grid','on');
title(tlo, 'Same data, two ways', 'FontWeight','bold');

figureExport(f, fullfile(outDir,'before-after'), ...
             'Formats', {'png'}, 'WidthMM', 180, 'DPI', 220, 'Overwrite', true);
close(f)
fprintf('Wrote %s\n', fullfile(outDir,'before-after.png'));