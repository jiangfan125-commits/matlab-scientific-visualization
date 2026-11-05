---
name: matlab-scientific-visualization
description: Creates, restyles, and audits truthful, publication-ready scientific figures in MATLAB. Use it whenever a task involves MATLAB plotting - drawing, re-plotting, beautifying, or reviewing figures for a paper, thesis, lab report, or poster (MATLAB 画图/绘图/出图/配图/美化/论文插图). Trigger it even when the user only says a figure "looks bad", asks why a subplot has too much whitespace, or asks to convert MATLAB figures for journal submission; do not wait for the word "aesthetics". Also use it for colour-palette selection, multi-panel layouts, 3-D orbit/surface views, vector-versus-raster export decisions, and checking an exported PNG/PDF against a target width and DPI.
license: MIT
compatibility: MATLAB R2020a or newer (exportgraphics, tiledlayout). figureExport falls back to print() for vector output and works on older releases. No toolboxes required. Chinese text export needs Microsoft YaHei or SimSun installed.
metadata:
  version: "1.0"
  last-reviewed: "2026-11-05"
  skill-author: derived from K-Dense scientific-visualization 1.4
---

# MATLAB Scientific Visualization

Build figures that preserve scientific meaning before optimizing appearance. Separate
universal principles from dated publisher rules, keep the evidence chain intact, use colour
redundantly, and inspect the delivered file instead of trusting the defaults.

MATLAB's defaults are tuned for interactive exploration, not for print: a heavy grid, a
seven-colour cycle that was never tested for colour-vision deficiency, legends drawn inside
the data, and `print -dpng -r200` output that nobody measures. Every rule below exists
because one of those defaults is wrong for a paper.

## Non-negotiable guardrails

- Never alter, hide, invent, or selectively enhance data to improve a figure.
- Preserve raw tables, native images, exclusions, missing-value codes, analysis code,
  normalization, binning, and random seeds. Keep the `.m` that produced a figure next to it.
- Do not infer journal requirements. Identify the exact journal, article type, figure type,
  and submission phase, then check the journal's live instructions.
- Do not claim that a palette, DPI value, format, or automated report makes a figure
  accessible or journal-compliant.
- Do not silently connect missing observations, suppress inconvenient points, upsample images
  as if detail increased, or tune axes to exaggerate a conclusion.
- Keep interactive and static outputs as distinct deliverables. A zoomed `.fig` is not a
  substitute for a labelled static figure.

Read `references/publication_guidelines.md` for deceptive encodings and integrity checks.
Read `references/journal_requirements.md` only after the target and phase are known.

## Workflow

### 1. Define the evidence and the destination

Record before writing plotting code:

- medium: manuscript, thesis, lab report (Word/LaTeX), slide, poster;
- exact target and intended final width in millimetres;
- variable semantics, units, sample/replicate structure, missing or censored values;
- the estimator and what the uncertainty bar actually means;
- transformations: filtering, averaging, normalization, smoothing, binning;
- the `.mat`/`.csv` the figure came from.

If the destination is unknown, produce a provisional figure at a general width (85–90 mm
single column, 180 mm full page, 140 mm slide) and label publisher choices as unverified.

### 2. Choose an honest encoding

- **Bars and filled areas** encode length from a baseline: normally include zero.
- **Points and lines** encode position: non-zero limits are legitimate, but show context.
- **Uncertainty:** name it (SD, SE, 95% CI, percentile); state `n` and the unit of replication.
- **Raw observations:** plot them when feasible; do not let jitter blur the category.
- **Missing data:** distinguish missing from zero. Leave a gap (`NaN`) rather than letting
  `plot` bridge it — MATLAB draws straight through `NaN` only if you pass gaps explicitly.
- **Area/volume:** scale area, not radius. Avoid decorative 3-D for flat comparisons.
- **Log axes:** label the base and state the policy for zero and negative values.
- **Normalization:** state the reference and keep limits identical across compared panels.
- **Dual axes:** prefer aligned panels. Dual `yyaxis` lets each range be tuned independently,
  which can manufacture an apparent correlation.
- **Images:** preserve originals, disclose whole-image adjustments, show scale bars.

### 3. Design accessibility in, not after

- Use colour **plus** marker, line style, hatching, or a direct label. Okabe-Ito is designed
  for separability, but colour alone still fails a greyscale photocopy.
- Match the palette to data semantics: qualitative for categories, sequential for magnitude,
  diverging only around a meaningful centre, cyclic for phase.
- Audit contrast against the actual background with `figureAudit` before you believe anything.
- Keep legends ordered like the data, or label series directly and drop the legend.
- WCAG 2.2 targets apply to web delivery: 4.5:1 normal text, 3:1 large text, 3:1 for graphical
  objects required for understanding. They are guidance for print, not a print standard.

See `references/color_palettes.md`.

### 4. Implement with the bundled toolbox

Put `scripts/` on the path once per session:

```matlab
home = getenv('USERPROFILE');
if isempty(home), home = getenv('HOME'); end
addpath(fullfile(home, '.claude', 'skills', 'matlab-scientific-visualization', 'scripts'))
```

Then the whole style is four calls:

```matlab
C = figurePalette('okabe_ito_on_white', 3);   % 3 series, all ≥3:1 on white
f = figure('Color','w','Visible','off');
ax = axes(f); hold(ax,'on')
plot(ax, t, y1, '-',  'Color',C(1,:), 'LineWidth',1.5, 'DisplayName','Observed')
plot(ax, t, y2, '--', 'Color',C(2,:), 'LineWidth',1.5, 'DisplayName','Model')
plot(ax, t, y3, '-.', 'Color',C(3,:), 'LineWidth',1.5, 'DisplayName','Residual')
hold(ax,'off')
xlabel(ax,'Time (s)'); ylabel(ax,'Response (unit)')
legend(ax,'Location','northeastoutside')

figureStyle('publication', ax, 'WidthMM', 89, 'HeightMM', 60, 'Grid','on');
figureExport(f, 'outputs/fig1', 'Formats', {'pdf','png'}, 'WidthMM', 89, 'DPI', 300, ...
    'Provenance', struct('raw_data','data/obs.csv', ...
                         'uncertainty','SD, n = 6 independent runs'));
```

`figurePalette` | palettes in `[0 1]` RGB, with a note on what each is for
`figureStyle` | presets `default`, `publication`, `nature`, `presentation`
`figureExport` | vector + raster at a stated physical width, with a manifest
`figureAudit` | WCAG contrast and greyscale-separation screen for a colour set
`figureMetadata` | reads back the delivered file and checks size and effective DPI
`figureColormap` | `viridis`, `cividis`, `plasma`, `magma` as anchor-interpolated maps

Why the function instead of copy-pasted `set(gca, ...)` lines: the same eight properties get
repeated in every plotting script and drift apart. One call keeps them identical and makes a
later change a one-line edit.

For Chinese text in vector output, pass `'FontName','Microsoft YaHei'`. Arial and Helvetica
have no CJK glyphs; MATLAB substitutes a fallback font, and the PDF can differ from what you
saw on screen.

### 5. Export explicitly and record provenance

`figureExport` refuses to overwrite an existing file. That is deliberate: a silently replaced
figure breaks the link between a manuscript and the data version behind it. Pass
`'Overwrite', true` when replacement is what you mean.

Vector output goes through `print` with `PaperSize`/`PaperPosition` set, so the PDF page really
is the requested width. Raster output uses `print -r<dpi>`, giving
`pixels = width_mm / 25.4 × dpi` exactly. `exportgraphics` is used only for SVG, because it
crops to content and silently shrinks the delivered physical width.

Every exported file is then read back by `figureMetadata`. Treat its warnings as findings.

Use an opaque white background unless the destination requires transparency; blending against
an unknown background changes apparent contrast.

### 6. Inspect, compare, review

1. `figureMetadata(file, 'TargetWidthMM', w, 'MinDPI', d)`.
2. `figureAudit(C)` on the colours actually used.
3. Open the file at final printed size; check legend overlap, clipping, and dash visibility.
4. Check fonts, embedded rasters, scale bars, caption, and source data by eye.
5. Re-check the target journal's live page immediately before upload.

## Reviewing a figure that already exists

When asked why a figure "looks bad", read the code and the exported image together, then
report findings in this order — most figures fail on layout first and colour second:

1. **Clipping and truncation.** Is data cut by axis limits? Does a curve stop at the box edge?
   `axis equal` on a `subplot` is the usual culprit: the data aspect forces the axes box far
   from the panel shape, leaving most of the panel empty.
2. **Legend.** `'best'` frequently lands on the data. `northeastoutside` avoids the data but
   steals width; if the legend has more than four entries, consider direct labels.
3. **Whitespace budget.** If more than about a third of a panel is empty, the panel is not
   doing work — reframe, change the view, or merge panels.
4. **Colour.** Default cycle? Pure `'r'`, `'b'`, `'y'`? Yellow on white is invisible.
5. **Contrast of decoration.** Default grid and box compete with the data.
6. **Typography.** Unit present? Minus sign a hyphen? Font size legible at final width?
7. **Export.** Raster only, unmeasured, no vector copy, oversize file.

Report each as a concrete change (`ax.XLim`, `legend('Location','eastoutside')`,
`figureStyle(...)`), not as a taste judgement.

## MATLAB-specific traps

| Symptom | Cause | Fix |
|---|---|---|
| Subplot mostly empty, data a thin band | `axis equal` inside a small panel | Set the view first, then `daspect`; do not combine `axis equal` with a small 3-D panel |
| Curve stops dead at the box edge | Limits set tighter than the data | Check `XLim/YLim/ZLim` against `min/max` of the plotted arrays |
| Yellow/cyan dots vanish on white | Light colour with no outline | Use `okabe_ito_on_white`, add `MarkerEdgeColor` |
| Legend sits on the data | `'Location','best'` chooses inside the axes | `'eastoutside'`, or direct text labels |
| `ColorOrder` change does nothing | It only affects lines drawn *after* it is set | Set it before plotting, or restyle existing children in a loop |
| Grid overwhelms the lines | Default grid colour and alpha | `ax.GridAlpha = 0.2; ax.GridColor = [0.85 0.85 0.85]` |
| Figure looks right on screen, wrong in PDF | Font substitution, or `exportgraphics` cropping | Pass the CJK font explicitly; use `print` with `PaperPosition` |
| 3-D view has no back planes | `Box = 'off'` from a print preset | `figureStyle(..., 'Box','on')` for 3-D |
| `hold on` then colours repeat oddly | `ColorOrderIndex` carried over from earlier lines | `ax.ColorOrderIndex = 1` after `cla`/`hold on` |
| Dashed line disappears at small size | Dash pattern too fine at 0.5 pt | Raise `LineWidth` or use a marker instead |
| `.fig` reopened and looks different | Style applied to `gca` only, not all axes | Apply `figureStyle` to `findall(f,'Type','axes')` |

## Final review checklist

- [ ] Raw data and the `.m` that produced the figure are preserved.
- [ ] Missing values, exclusions, bins, normalization, and uncertainty are explicit.
- [ ] Baselines, limits, and area/volume encodings are honest.
- [ ] Colour is redundant and the rendered contrast was audited.
- [ ] Physical width, pixel count, effective DPI, format, and background were measured.
- [ ] A vector copy exists alongside any raster used for a slide.
- [ ] Publisher rules were verified for the exact journal and phase.
- [ ] No automated report is presented as a compliance certification.

## References

- `references/publication_guidelines.md` — integrity, deceptive encodings, accessibility.
- `references/color_palettes.md` — palette semantics, exact values, WCAG contrast.
- `references/journal_requirements.md` — phase-specific publisher snapshots.
- `references/matlab_examples.md` — runnable MATLAB patterns for common figure types.
- `references/sources.md` — official URLs, dates, versions.
- `assets/publisher_profiles.json` — dated machine-readable width/format/DPI snapshots.

## Attribution

Derived from K-Dense "Scientific Agent Skills" `scientific-visualization` v1.4 (MIT), ported
to MATLAB. Principles and palette values follow that skill and its sources; the MATLAB
implementation, the trap table, and the review workflow are new.

> Kassis, T., Agarwal, V., He, Y., Patel, D., & Brueckner, A. M. (2026). Scientific Agent
> Skills: A Library of Procedural Knowledge for Research Agents. arXiv:2609.00065.
> https://doi.org/10.48550/arXiv.2609.00065