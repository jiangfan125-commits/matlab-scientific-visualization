# Colour, Contrast, and Palette Selection (MATLAB)

Reviewed 2026-11-05. Ported from Scientific Agent Skills `scientific-visualization` v1.4.
Source IDs resolve in `sources.md`.

A named "colourblind-safe" palette does not guarantee an accessible figure. Background, line
width, adjacency, text, category count, and print conversion all matter.

## Start with data semantics

- **Qualitative** — unordered categories. Hue separates groups; lightness must not imply rank.
- **Sequential** — ordered magnitude. Use monotonic perceived lightness.
- **Diverging** — departure around a meaningful centre. Neutral midpoint, documented norm.
- **Cyclic** — periodic values where the ends meet.

Do not use a diverging map merely because values contain negatives; the centre must mean
something. Do not use `jet` as a generic ordered scale: it creates false boundaries where the
colour wheel wraps and has no inherent order.

MATLAB couples colour mapping and scaling less cleanly than Matplotlib. `caxis`/`clim` sets
the limits; there is no built-in `TwoSlopeNorm`. For a diverging map with an off-centre zero,
build the map explicitly so the centre lands at the right value:

```matlab
c = [figureColormap('cividis',128); flipud(figureColormap('magma',128))];
caxis([-2 5]);                       % NOT symmetric: zero is not at the map centre
```

If zero must land mid-map, make the limits symmetric (`[-5 5]`) and say so, or construct a
piecewise map. Either way, label the colourbar with units and the transformed scale.

## Okabe-Ito / Wong

The eight colours reproduced from Wong, *Nature Methods* 8, 441 (2011):

```matlab
C = figurePalette('okabe_ito');      % 8x3, values in [0 1]
```

| name | hex | note |
|---|---|---|
| orange | `#E69F00` | below 3:1 on white |
| sky blue | `#56B4E9` | below 3:1 on white |
| bluish green | `#009E73` | |
| yellow | `#F0E442` | invisible as a thin line on white |
| blue | `#0072B2` | |
| vermillion | `#D55E00` | |
| reddish purple | `#CC79A7` | |
| black | `#000000` | |

For thin lines or markers on white, start from the five that clear 3:1:

```matlab
C = figurePalette('okabe_ito_on_white');   % blue, vermillion, green, purple, black
```

This subset is derived by WCAG sRGB contrast calculation. It is not a published palette and
not a compliance certification.

## Paul Tol qualitative schemes

Tol's technical note SRON/EPS/TN/09-002, issue 3.2 (2021-08-18), states the bright,
high-contrast, vibrant, muted, and medium-contrast schemes are colour-blind safe under its
design assumptions. It also states that most multi-colour qualitative schemes do not remain
fully separable in greyscale.

```matlab
figurePalette('list')                 % names, sizes, and caveats
C = figurePalette('tol_muted', 9);    % largest scheme available here
```

Maximum intended series counts: bright 7, high-contrast 3, vibrant 7, muted 9,
medium-contrast 6. `figurePalette` errors rather than interpolating a qualitative palette
past its intended size — interpolation invents colours nobody tested.

## Continuous maps

```matlab
colormap(figureColormap('viridis'))
colormap(figureColormap('cividis'))    % designed with colour-vision deficiency in mind
```

`viridis`, `plasma`, `magma` are perceptually uniform sequential families. `cividis` is built
for colour-vision deficiency. `parula` (MATLAB's own default) is acceptable for ordered data
and is a genuinely better default than `jet`. `turbo` is a smoother rainbow: still a rainbow.

No list is universally safe. A uniform map can still lose a narrow feature at small printed
size, or collapse during RGB-to-CMYK conversion.

## WCAG contrast: what to test

WCAG 2.2 is normative for web content:

- normal text 4.5:1 against its background (SC 1.4.3 AA);
- large text 3:1 (SC 1.4.3 AA);
- graphical objects required to understand the content 3:1 against adjacent colours
  (SC 1.4.11 AA);
- colour must not be the only means of conveying information (SC 1.4.1 A).

```matlab
figureAudit(figurePalette('okabe_ito_on_white'), 'Background', [1 1 1], 'Role', 'graphical')
```

The audit reports:

- exact WCAG sRGB contrast against the chosen background;
- pairwise contrast;
- pairwise CIE L\* separation after removing hue.

The default greyscale threshold (ΔL\* 10) is a heuristic from the source skill. It is not a
WCAG threshold and does not simulate every colour-vision deficiency, printer, or viewing
condition.

## Redundant encoding in MATLAB

```matlab
C   = figurePalette('okabe_ito_on_white', 3);
sty = {'-', '--', '-.'};
mk  = {'o', 's', '^'};
for k = 1:3
    plot(ax, x, y{k}, sty{k}, 'Color', C(k,:), 'Marker', mk{k}, ...
         'MarkerSize', 4, 'MarkerFaceColor', C(k,:), ...
         'MarkerIndices', 1:20:numel(x), 'DisplayName', labels{k});
end
```

For bars, use edge contrast (`EdgeColor`, `LineWidth`) and direct labels. For images, consider
accessible channel combinations plus separate greyscale panels. Direct labels often beat a
distant legend, especially in multi-panel figures.

## Missing and out-of-range values

MATLAB handles NaN in `plot` by breaking the line, which is usually what you want:

```matlab
y(y == -9999) = NaN;      % sentinel -> explicit gap, not a dropped point
plot(x, y)
```

For images, set the axes colormap and an explicit "bad" colour rather than letting missing
values sit at the low end of the scale:

```matlab
cmap = figureColormap('cividis', 256);
cmap(end+1,:) = [0.47 0.47 0.47];   % grey = no data
colormap(cmap); caxis([0 1]);        % reserve the top bin for missing
```

Label the missing state in the caption or colourbar. Never let missing values default to the
low end of a quantitative scale.

## Colour management

- Work in sRGB unless the publisher or a calibrated workflow requires otherwise.
- Preview print conversion when the publisher converts RGB to CMYK.
- Do not alter raw intensity data to obtain attractive colours.
- Record channel mappings, colour limits, and normalization.
- Avoid transparency when blending with an unknown background can change contrast.

## Review checklist

- [ ] Palette type matches data semantics.
- [ ] Centre, limits, and missing-value colour are explicit.
- [ ] Foreground/background contrast audited at final size.
- [ ] Colour is redundant with shape, line style, hatching, or labels.
- [ ] Greyscale was inspected, without treating it as a complete accessibility test.
- [ ] Palette and category mapping are consistent across figures.
- [ ] Underlying values and a table alternative are available.