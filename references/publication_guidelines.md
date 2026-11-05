# Publication Figure Principles (MATLAB)

Reviewed 2026-11-05. Ported from Scientific Agent Skills `scientific-visualization` v1.4.
These are general scientific-communication principles, not publisher requirements.
Date-sensitive rules live in `journal_requirements.md`.

## Preserve evidence before styling

Keep three layers separate:

1. **Raw/source data** — immutable originals, acquisition metadata, exclusions, missing codes.
2. **Transformation record** — the `.m` or a machine-readable log of filtering, normalization,
   aggregation, estimation, and seeds.
3. **Presentation output** — the figure plus the export manifest `figureExport` writes.

Do not overwrite raw `.mat` files. Keep native-resolution images. Upsampling changes pixel
count, not information; Nature, Science, Cell Press, PLOS, Elsevier, and IEEE all warn
against presenting it as improved quality.

For experimental or observational images:

- apply brightness/contrast/colour adjustments to the whole image consistently;
- never selectively erase, obscure, clone, or enhance features;
- preserve background and non-specific signal;
- mark and explain splices, omitted lanes, composites, or stitched fields;
- retain originals and the exact processing steps.

The manifest records what you supplied. It cannot confirm the provenance is complete.

## Avoid visual deception

### Baselines and context

- **Bars and filled areas** encode length from a baseline: normally show zero.
- **Points and lines** encode position: non-zero limits can be valid, but show context and
  disclose breaks.
- Use common limits for panels meant to be compared. MATLAB's `linkaxes(ax,'xy')` keeps them
  locked while zooming.
- Do not extend axes far beyond the data merely to suppress visible variation.

### Uncertainty and raw observations

- Do not add error bars mechanically. Show uncertainty when an estimate is displayed, and
  spread when the distribution is the question.
- Name the interval precisely: SD, SE, percentile, parametric CI, bootstrap CI, posterior.
- State sample size, unit of replication, estimator, and interval level.
- Show raw observations when feasible. `swarmchart` or a light `jitter` beats a bare mean bar,
  but do not jitter so far that the category becomes ambiguous.
- Significance stars are not uncertainty. Add them only for a reported analysis, state the
  test, and give exact values where practical.

### Missing, excluded, and censored data

- Keep missing distinct from zero, from below-detection values, and from excluded points.
- Do not let interpolation bridge a gap. Insert `NaN` so `plot` breaks the line.
- Give missing values a dedicated legend entry or a neutral colour.
- Record exclusions outside the plotting code, in the caption or methods.

### Area, volume, and 3-D

- Prefer position on a common scale.
- If area encodes magnitude, scale the **area**, not the radius. Same for volume.
- Avoid perspective 3-D bars, pies, and surfaces for simple comparisons; occlusion distorts
  values.
- A true 3-D scientific structure (orbit, field, trajectory) is legitimate — but add a second
  orthogonal view or a projected panel, state the viewing azimuth/elevation, and mark the
  scale. A single rotating view that hides the geometry is not a figure.

### Logarithms and transforms

- Label the transformed scale and base (`semilogy`, `loglog`, `set(ax,'YScale','log')`).
- Declare the policy for zero and negative values. `YScale = 'log'` silently drops
  non-positive points; say so, or plot them separately.
- Interpret equal distances as ratios, not additive differences.

### Binning, smoothing, and aggregation

- Record bin edges, inclusion convention, bandwidth or window, smoothing method, and whether
  the choice was made before seeing the result.
- Show sensitivity when a conclusion depends on the bin or bandwidth.
- Do not use `smoothdata` or `fit` to imply observations between measured points.
- Preserve and, where practical, expose the underlying observations.

### Normalization and colour limits

- State the formula and reference: per-capita, percent of baseline, z-score, min-max.
- Fit normalization parameters on the appropriate partition; avoid leakage.
- Use the same normalization and colour limits across directly compared panels.
- A diverging map needs a meaningful centre; MATLAB has no built-in centred norm, so set the
  limits and the map deliberately (see `color_palettes.md`).
- Always label colourbars with units and the transformed scale.

### Dual axes

Prefer aligned panels or normalized displays. `yyaxis` allows each side's range to be tuned
independently, which can manufacture an apparent correlation. If unavoidable:

- justify the shared x-domain and the distinct units;
- label each axis and each series directly;
- do not use matching colours as the only association cue;
- choose limits independently of the relationship you want to show;
- provide the underlying data.

### Images

- Inspect histograms and clipped-pixel counts before and after `imadjust`.
- Apply comparable processing to images being compared.
- State channel assignment, lookup table, projection, denoising, thresholding, contrast limits.
- Use scale bars based on calibration, not magnification text.
- Do not rely on red/green identity alone.

## Encoding and colour

Match the palette to the data: qualitative for unordered categories, sequential for ordered
magnitude, diverging only around a meaningful centre, cyclic for periodic variables. Use hue
consistently across a manuscript. Avoid rainbow maps for ordered data unless there is a
documented reason and the map has been evaluated for perceptual artifacts.

Colour is never sufficient. Combine it with marker shape, line style, hatching, direct labels,
or panel separation; audit contrast against the actual background; inspect greyscale without
treating it as a full colour-vision simulation.

## Accessibility

WCAG 2.2 is a web-content standard, not a journal-print specification, but it gives useful
targets for figures delivered on the web:

- SC 1.4.1 (A): colour is not the only visual means.
- SC 1.4.3 (AA): 4.5:1 normal text, 3:1 large text.
- SC 1.4.11 (AA): 3:1 for graphical objects required to understand the content.
- SC 1.1.1 (A): non-text content has a text alternative.
- SC 1.4.5 (AA): use real text rather than text rendered into an image.

For web or interactive figures also provide a concise alt text naming chart type, variables,
main pattern, and important exception; a long description for complex figures; the underlying
data as a table or download; and a static fallback that preserves the message.

Passing a palette audit does not prove WCAG conformance.

## Layout, typography, and annotation

- **Design at final physical size.** A 7 pt label is 7 pt only at the width it will print.
  `figureStyle(..., 'WidthMM', 89)` sets that width before you judge anything.
- One legible font family, restrained size hierarchy. Chinese text needs a CJK font:
  `Microsoft YaHei` (sans) or `SimSun` (serif). Arial and Helvetica have no CJK glyphs.
- Units in every axis and colourbar label. Define abbreviations.
- Panel labels consistent and outside dense data. `(a)`, `(b)` at the top-left of each panel,
  or `tiledlayout` + `title(ax,'(a) ...')` — pick one and keep it.
- `tiledlayout` handles shared colourbars and tight spacing better than repeated `subplot`.
  `sgtitle` is legacy; prefer `title(tlo, '...')`.
- Keep decorative ink subordinate to the data. A light, sparse grid helps value lookup; a
  default-weight grid does not. Removing the grid is not a universal rule.

## Static, vector, raster output

### Vector

PDF/EPS/SVG carry text and line art at any size. In MATLAB:

- `print(fig,'-dpdf','-painters','file.pdf')` honours `PaperSize`/`PaperPosition`, so the page
  is exactly the width you set. This is what `figureExport` uses.
- `exportgraphics(fig,'file.pdf','ContentType','vector')` is convenient but crops to content,
  so the delivered width is smaller than requested. Useful for slides, dangerous for
  submission.
- `-painters` cannot render transparency well. If a figure uses `FaceAlpha`, either drop the
  alpha or accept a rasterized result — and check the PDF afterwards.

### Raster

Required pixel width:

```text
pixels = final width (inches) x target pixels per inch
```

Embedded DPI metadata alone adds no detail. TIFF and PNG are lossless; JPEG is a poor choice
for line art or text. `figureMetadata` reports both the embedded number and the effective DPI
at your target width, because they routinely disagree.

### Transparency

`exportgraphics`/`print` with an alpha channel can reveal an unintended background or change
apparent contrast. Prefer an explicit opaque white background for submission.

## Final scientific review

- [ ] Raw data and native images preserved.
- [ ] Transformations, exclusions, normalization, bins, and seeds recorded.
- [ ] Missing and censored values explicit.
- [ ] Baselines, limits, log scales, and breaks scientifically justified.
- [ ] Uncertainty and sample size defined.
- [ ] Area/volume and colour normalization encode magnitude correctly.
- [ ] Colour is redundant; contrast reviewed.
- [ ] Alt text and underlying data available for web delivery.
- [ ] Physical size, pixel count, fonts, transparency, and format inspected after export.
- [ ] The target journal's current instructions checked for the correct phase.