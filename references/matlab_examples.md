# Runnable MATLAB Patterns

Nothing here needs a toolbox. Each block assumes the toolbox is on the path:

```matlab
home = getenv('USERPROFILE');
if isempty(home), home = getenv('HOME'); end
addpath(fullfile(home, '.claude', 'skills', 'matlab-scientific-visualization', 'scripts'))
```

## 1. Single panel, redundant encoding

Colour, line style, and marker all carry the series identity, so the figure survives
greyscale printing and a reader with colour-vision deficiency.

```matlab
C   = figurePalette('okabe_ito_on_white', 3);
sty = {'-','--','-.'};
mk  = {'o','s','^'};

f  = figure('Color','w','Visible','off');
ax = axes(f); hold(ax,'on')
for k = 1:3
    y = ydata{k};
    plot(ax, x, y, sty{k}, 'Color', C(k,:), 'LineWidth', 1.5, ...
         'Marker', mk{k}, 'MarkerSize', 4, ...
         'MarkerFaceColor', C(k,:), 'MarkerEdgeColor', C(k,:), ...
         'MarkerIndices', 1:25:numel(x), 'DisplayName', labels{k});
end
hold(ax,'off')
xlabel(ax,'Time (s)'); ylabel(ax,'Response (unit)')
legend(ax, 'Location','eastoutside')
figureStyle('publication', ax, 'WidthMM', 89, 'HeightMM', 60, 'Grid','on')
figureExport(f, 'outputs/fig_line', 'Formats', {'pdf','png'}, 'WidthMM', 89, 'DPI', 300)
```

## 2. Multi-panel with a shared colourbar

`tiledlayout` keeps the panels aligned and gives one colourbar for the whole figure. `subplot`
plus a manual `Position` tweak is the older route and drifts as soon as a label changes size.

```matlab
f  = figure('Color','w','Visible','off');
tlo = tiledlayout(f, 1, 2, 'TileSpacing','compact', 'Padding','compact');
axList = gobjects(1, 2);

for k = 1:2
    axList(k) = nexttile(tlo);              % one call per tile, no more
    imagesc(axList(k), Z(:,:,k))
    axis(axList(k), 'xy', 'tight')
    title(axList(k), sprintf('(%c) %s', 'a'+k-1, titles{k}), 'FontWeight','normal')
end

cb = colorbar(axList(end));    % attach to an axes, not to the layout
ylabel(cb, 'Concentration (mol m^{-3})')
colormap(f, figureColormap('cividis', 256))

figureStyle('publication', findall(f,'Type','axes'), 'WidthMM', 180, 'HeightMM', 80)
figureExport(f, 'outputs/fig_panels', 'Formats', {'pdf','png'}, ...
             'WidthMM', 180, 'DPI', 300)
```

For a **single shared** colourbar next to both tiles:

```matlab
cb = colorbar(tlo);          % figure-level colourbar (R2020b+)
cb.Layout.Tile = 'east';
```

## 3. Uncertainty band

Name the interval in the caption and state `n`. Do not let the band imply more than you
computed.

```matlab
ax = axes(f); hold(ax,'on')
fill(ax, [x fliplr(x)], [ylo fliplr(yhi)], C(1,:), ...
     'FaceAlpha', 0.20, 'EdgeColor','none', 'HandleVisibility','off');
plot(ax, x, y, '-', 'Color', C(1,:), 'LineWidth', 1.5, ...
     'DisplayName', 'Mean \pm SD (n = 6)');
hold(ax,'off')
```

`FaceAlpha` forces a rasterized result in some vector exports. If the PDF must stay vector,
use a light solid fill instead of alpha.

## 4. Raw observations plus a summary

```matlab
ax = axes(f); hold(ax,'on')
swarmchart(ax, repmat(categorical(groups), 1, 1), values, 20, C(1,:), 'filled');
plot(ax, 1:numel(groups), means, 'k-', 'LineWidth', 1.2);
errorbar(ax, 1:numel(groups), means, sds, 'k', 'LineStyle','none', 'LineWidth', 1);
hold(ax,'off')
ylabel(ax, 'Response (unit)')
```

Jitter reveals spread; it must not blur which category a point belongs to.

## 5. 3-D orbit or trajectory

A single oblique view hides geometry. Give the azimuth and elevation in the caption, and
consider a second panel with a different view.

```matlab
ax = axes(f); hold(ax,'on')
[X,Y,Z] = sphere(60);
surf(ax, Re*X, Re*Y, Re*Z, 'FaceColor',[0.73 0.83 0.95], ...
     'EdgeColor','none', 'DisplayName','Earth');
plot3(ax, r(:,1), r(:,2), r(:,3), '-', 'Color', C(1,:), ...
      'LineWidth', 1.5, 'DisplayName','Orbit');
plot3(ax, r(1:40:end,1), r(1:40:end,2), r(1:40:end,3), 'o', ...
      'Color', C(1,:), 'MarkerFaceColor', C(1,:), 'MarkerSize', 4, ...
      'HandleVisibility','off');
hold(ax,'off')
axis(ax,'equal'); view(ax, 135, 25)
xlabel(ax,'X (km)'); ylabel(ax,'Y (km)'); zlabel(ax,'Z (km)')
legend(ax, 'Location','eastoutside')
figureStyle('publication', ax, 'Box','on', 'WidthMM', 140, 'HeightMM', 110, 'Grid','on')
```

`axis equal` on a small 3-D panel is the usual cause of a figure that is mostly whitespace.
If the geometry does not need true scale, use `daspect` or drop `equal` and say so.

## 6. Diverging map with a stated centre

```matlab
cmap = [figureColormap('cividis',128); flipud(figureColormap('magma',128))];
imagesc(ax, D); axis(ax,'xy')
colormap(ax, cmap)
caxis(ax, [-5 5])        % symmetric, so the map centre is zero
cb = colorbar(ax); ylabel(cb, '\Delta T (K)')
```

If the data is asymmetric around zero, either keep the symmetric limits (honest but
low-contrast) or build a piecewise map and document it. Do not let a diverging map imply a
centre the data does not have.

## 7. Missing data as a gap

```matlab
y(y == -9999) = NaN;     % explicit sentinel -> visible gap
plot(ax, x, y, '-', 'Color', C(1,:));
legend(ax, {'Observed (gaps = no measurement)'})
```

Do not let `plot` bridge the gap, and do not let missing values fall to the bottom of a
colour scale.

## 8. Log axis with a declared policy

```matlab
semilogy(ax, x, y, '-', 'Color', C(1,:))
set(ax, 'YScale','log')
ylabel(ax, 'Count (log scale)')
% Non-positive values are excluded by the log scale; state that in the caption
% or plot them on a separate linear panel.
```

## 9. Chinese labels

```matlab
figureStyle('publication', ax, 'FontName','Microsoft YaHei')
title(ax, '观测几何与轨道三维视图')
ylabel(ax, '斜距 \rho (km)')
```

Arial and Helvetica carry no CJK glyphs; MATLAB substitutes a fallback at export time and the
PDF can differ from the screen. Export and look at the result.

Negative numbers: write `\minus`-style text (`'$-$'` interpreter) or use `sprintf('%g', v)`
rather than typing a hyphen. A hyphen is short and sits high; a minus sign is not.

## 10. Reviewing an existing figure

When a figure already exists and the question is "why does this look bad":

```matlab
figureMetadata('fig_compare.png', 'TargetWidthMM', 89, 'MinDPI', 300)
```

Then read the plotting code for these, in order:

```matlab
% 1. Is anything clipped?
for k = 1:numel(axList)
    a = axList(k);
    fprintf('XLim found data range %.3g..%.3g, limits %.3g..%.3g\n', ...
        min(xdata), max(xdata), a.XLim(1), a.XLim(2));
end

% 2. Where did the legend land?
lgd = findobj(f, 'Type','legend');
disp({lgd.Location})

% 3. How much of the axes box is empty?
%    (eyeball the exported raster at final size - a pixel count cannot tell you this)

% 4. Which colours are actually used?
lines = findobj(ax, 'Type','line');
for k = 1:numel(lines)
    fprintf('series %d colour %s, style %s\n', k, ...
        mat2str(lines(k).Color, 3), lines(k).LineStyle);
end
```

Report findings as concrete edits, not taste: `ax.XLim`, `'Location','eastoutside'`,
`figureStyle(..., 'Grid','on')`. A recommendation the reader cannot apply is not a review.

## 11. Style preview

Generate a contact sheet of the four presets to choose one before committing:

```matlab
out = 'outputs/style-preview';
if ~isfolder(out), mkdir(out); end
for name = ["default","publication","nature","presentation"]
    f = figure('Color','w','Visible','off');
    ax = axes(f);
    plot(ax, 0:0.1:2*pi, sin(0:0.1:2*pi), '-', 'LineWidth', 1.5);
    hold(ax,'on'); plot(ax, 0:0.1:2*pi, cos(0:0.1:2*pi), '--', 'LineWidth', 1.5); hold(ax,'off')
    xlabel(ax,'Time (s)'); ylabel(ax,'Response (unit)')
    title(ax, char(name)); legend(ax, {'Observed','Model'}, 'Location','eastoutside')
    figureStyle(char(name), ax, 'WidthMM', 89, 'HeightMM', 60, 'Grid','on')
    figureExport(f, fullfile(out, char(name)), 'Formats', {'png'}, ...
                 'WidthMM', 89, 'DPI', 200, 'Overwrite', true)
    close(f)
end
```