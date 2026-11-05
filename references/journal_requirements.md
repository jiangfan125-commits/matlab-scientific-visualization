# Publisher and Journal Figure Snapshots

Reviewed 2026-11-05, carried over from Scientific Agent Skills `scientific-visualization` v1.4
(reviewed 2026-10-01), except the explicitly historical Science snapshot. Requirements are
date-sensitive and depend on journal, article type, figure type, and submission phase. Verify
the live target-journal page before submission. Source IDs resolve in `sources.md`.

The machine-readable subset in `assets/publisher_profiles.json` is for planning and
deterministic screening only. It never claims compliance.

```matlab
P = jsondecode(fileread('.../assets/publisher_profiles.json'));
prof = P.profiles.nature;            % widths_mm, formats, raster_dpi, notes
disp(prof.widths_mm.single)          % 89
```

## Nature (flagship journal)

**Scope:** `Nature` final submission after acceptance in principle, not all Nature Portfolio
journals.

- Standard widths: 89 mm single column, 183 mm double; 120–136 mm for one-and-a-half.
- Full page depth: 247 mm.
- Panels: lowercase bold upright `a`, `b`, `c`, 8 pt.
- Other text: 5–7 pt at final size; Helvetica or Arial preferred.
- Keep text and line art editable; do not outline or rasterize them.
- Preferred line/graph containers include AI, PostScript, vector EPS, and PDF.
- Preferred raster source: layered PSD or TIFF. Final-submission page states 300–600 dpi for
  photographs; minimum 300 dpi at maximum use size.
- The research-figure guide recommends 450 dpi or above for exports because online proofs top
  out at 450 dpi. That is a recommendation layered on the 300 dpi minimum, not a universal rule.
- RGB recommended; final print conversion may use CMYK.
- Extended Data has separate rules: RGB, max 300 ppi, max 10 MB, JPEG preferred.

Do not apply these flagship rules automatically to Nature Communications, Scientific Reports,
npj journals, or Nature Reviews.

## Science (AAAS flagship journal)

**Scope:** historical snapshot accessed 2026-07-23; both pages blocked fresh extraction on
2026-10-01. Numbers below are provisional.

### Initial submission

- One manuscript file with embedded figures is preferred; figures at 300 dpi for review.
- Printed widths usually 5.7 cm (one column), 12.1 cm (two), 18.4 cm (three).
- Vector creation preferred. Sans serif, preferably Helvetica; lettering about 7 pt after
  reduction, never below 5 pt.
- Avoid red/green as the sole identifier; add shape or texture.
- Scales should not extend beyond the plotted data merely as empty range.

### Revised manuscript

- Upload each figure separately. Preferred vector formats: PDF, EPS, AI.
- Raster illustrations and photographs: TIFF. Combinations: PDF or EPS.
- Line art without a vector original: at least 300 dpi at final size.
- Colour and greyscale images: at least 300 dpi at final size.
- Upsampling is not permitted.
- PowerPoint and figures embedded in Word are not accepted at this stage.

Science Advances and other AAAS journals publish separate guides.

## Cell Press

- Initial submission and review accept a wide range of formats, sizes, and resolutions;
  individual 1–2 MB files recommended for reviewers.
- Final production: one file per main figure containing all panels; titles and legends stay in
  the manuscript. Recommended overall maximum 16.5 × 20 cm; max file size 20 MB.
- Two-column widths: 8.5, 11.4, 17.4 cm. Three-column: 5.5, 11.4, 17.4 cm.
- TIFF and PDF preferred. Colour/greyscale at least 300 dpi; black-and-white 500 dpi;
  line art 1000 dpi at final size.
- RGB, Arial, capital panel letters, 6–8 pt text, 0.5–1.5 pt strokes. Embed fonts.
- Do not use red and green together as the only distinction.
- Current policy prohibits generative-AI alteration of research images.

## PLOS research journals

- Formatting requirements are waived until provisional Editorial Accept.
- Final figure format: TIFF or EPS.
- Width 789–2250 px at 300 dpi (6.68–19.05 cm); no wider than 13.2 cm when aligned to a text
  column; max height 2625 px at 300 dpi (22.23 cm).
- Resolution 300–600 dpi at final dimensions; above 600 may trigger resizing, below 300
  degrades output.
- File size limit is 10 MB (the summary table and detail section disagree slightly; use 10 MB).
- Text: Arial, Times, or Symbol, 8–12 pt. RGB 8-bit/channel or greyscale.
- One single-page file per figure; TIFF must have no alpha channel and use LZW.
- Filenames `Fig1.tif`, `Fig2.eps`, and so on.
- Do not increase pixel count and present that as improved resolution.

## Elsevier

Publisher-general instructions; journal-specific Guides for Authors can override them.

- TIFF for halftones/bitmaps, EPS for vector-based images, PDF for vector/text.
- RGB preferred unless the journal says otherwise.
- General widths: 90 mm single, 140 mm one-and-a-half, 190 mm full; 30 mm minimum.
- General raster targets at final size: 300 dpi halftone, 500 dpi combination, 1000 dpi line art.
- Lettering about 7 pt, not smaller than 6 pt for sub/superscripts.

## IEEE journals

- Acceptable vector formats: PS, EPS, PDF.
- Non-vector colour/greyscale: **greater than** 300 dpi. Black-and-white line art: **greater
  than** 600 dpi.
- One-column width 88.9 mm; two-column 182 mm.
- Increasing resolution after creation does not improve quality.

## BMC

- Web widths: 600 px standard, 1200 px high resolution.
- PDF widths: 85 mm half page, 170 mm full page.
- Max figure-plus-legend height 225 mm; approximately 300 dpi at final size.
- Fonts embedded; lines wider than 0.25 pt at final width.
- One composite file per multi-panel figure; max 10 MB.

## ACS Publications

**Scope:** legacy "Preparing Manuscript Graphics", page updated 2006-01-21. Not a current
universal digital-export profile; use the selected journal's Author Guidelines.

- Listed maximum dimensions: 3.25 in single column, 7 in double, 9.5 in length.
- Lettering no smaller than 5 pt after reduction; Helvetica/Arial suggested.
- Lines no thinner than 1 pt on that page.

## Rules that are not universal

Do not present these as cross-publisher laws:

- "JPEG is never accepted." Several publishers accept it for photographs.
- "All line art must be 1000/1200 dpi." Vector output is often preferred, and current Science
  revised guidance says at least 300 dpi when vector is unavailable.
- "All publishers require greyscale compatibility." Accessibility guidance varies; use
  redundant encoding regardless.
- "All figures must be RGB."
- "All figures need error bars or significance stars."
- "A matching DPI/width means compliant."

## Submission-stage workflow

1. Identify the exact journal, article type, figure type, and current stage.
2. Save the live official page URL and access date.
3. Plan the width and format from `assets/publisher_profiles.json`.
4. Export with `figureExport(..., 'WidthMM', w, 'DPI', d)`.
5. Inspect the delivered file with `figureMetadata`.
6. Review fonts, embedded rasters, image integrity, accessibility, caption, and source data by
   eye.
7. Re-check official instructions immediately before upload.