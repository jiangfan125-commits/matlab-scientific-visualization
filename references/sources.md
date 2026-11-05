# Sources and Version Snapshot

Reviewed 2026-11-05. Palette values, publisher snapshots, and accessibility targets are carried
over from Scientific Agent Skills `scientific-visualization` v1.4 (reviewed 2026-10-01), whose
own sources are listed below. The MATLAB implementation was tested against the local MATLAB
release rather than a pinned package.

## What was actually tested here

- `figurePalette`, `figureAudit`, `figureStyle`, `figureExport`, `figureMetadata`,
  `figureColormap` were run on a local MATLAB install with synthetic data.
- Verified: palette lookup and error handling; WCAG contrast and CIE L\* output; style
  application to 2-D and 3-D axes; PDF page width (parsed from the MediaBox) and PNG pixel
  count at a stated DPI; overwrite refusal; Chinese-label export.
- Not verified: colour-vision simulation, CMYK conversion, ICC profiles, journal preflight,
  PDF page boxes stored in compressed object streams, and behaviour on MATLAB releases older
  than the one tested.

A passing check means the file has the requested dimensions. It does not mean the science is
right or the journal will accept it.

## MATLAB documentation

- **[MATHWORKS-EXPORTGRAPHICS]** [`exportgraphics`](https://www.mathworks.com/help/matlab/ref/exportgraphics.html)
  — content type, resolution, background colour, padding behaviour.
- **[MATHWORKS-PRINT]** [`print`](https://www.mathworks.com/help/matlab/ref/print.html) —
  driver list, `-r` resolution, renderer selection, `PaperPosition` interaction.
- **[MATHWORKS-PAPERPOS]** [Figure printing and paper properties](https://www.mathworks.com/help/matlab/printing-and-exporting.html)
  — `PaperSize`, `PaperPosition`, `PaperPositionMode`.
- **[MATHWORKS-TILEDLAYOUT]** [`tiledlayout`](https://www.mathworks.com/help/matlab/ref/tiledlayout.html)
  — shared labels and colourbars, spacing, panel management.
- **[MATHWORKS-COLORORDER]** [`ColorOrder`](https://www.mathworks.com/help/matlab/ref/matlab.graphics.axis.axes-properties.html)
  — cycling order and `ColorOrderIndex`.
- **[MATHWORKS-COLORMAP]** [Colormaps](https://www.mathworks.com/help/matlab/colormaps.html)
  — `parula`, `turbo`, and perceptual considerations.
- **[MATHWORKS-IMFINFO]** [`imfinfo`](https://www.mathworks.com/help/matlab/ref/imfinfo.html)
  — width, height, resolution, resolution unit, colour type, compression.

## Accessibility and colour

- **[WCAG22]** [Web Content Accessibility Guidelines (WCAG) 2.2](https://www.w3.org/TR/WCAG22/)
  — W3C Recommendation; normative SC 1.1.1, 1.4.1, 1.4.3, 1.4.5, 1.4.11.
- **[WCAG-NONTEXT]** [Understanding SC 1.4.11: Non-text Contrast](https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html)
  — informative chart and graph examples; not itself normative.
- **[WCAG-COLOR]** [Understanding SC 1.4.1: Use of Color](https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html)
  — informative guidance on non-colour cues.
- **[COLORBREWER]** [ColorBrewer 2.0](https://colorbrewer2.org/) — scheme type, class count,
  colourblind/print/photocopy filters.
- **[TOL-HOME]** [Paul Tol's Notes](https://sronpersonalpages.nl/~pault/) — canonical site.
- **[TOL]** [Paul Tol, "Colour Schemes"](https://sronpersonalpages.nl/~pault/data/colourschemes.pdf)
  — SRON/EPS/TN/09-002, issue 3.2, 2021-08-18; exact sRGB values, intended uses,
  colour-vision checks, greyscale analysis.
- **[WONG]** [Bang Wong, "Color blindness"](https://www.nature.com/articles/nmeth.1618) —
  *Nature Methods* 8, 441 (2011); source of the eight-colour palette.

## Publishers and journals

Most publisher content was verified 2026-10-01 by the upstream skill. Nature final submission
and Cell Press needed fresh extraction; Science initial/revised pages were blocked and their
2026-07-23 values are historical; ACS is a legacy page updated 2006-01-21. Dates label access,
not publication.

- **[NATURE-FINAL]** [`Nature` final submission](https://www.nature.com/nature/for-authors/final-submission)
- **[NATURE-FIG]** [`Nature` research figure specifications](https://research-figure-guide.nature.com/figures/preparing-figures-our-specifications)
- **[SCIENCE-INITIAL]** [`Science` initial manuscript instructions](https://www.science.org/content/page/instructions-preparing-initial-manuscript)
- **[SCIENCE-REVISED]** [`Science` revised manuscript instructions](https://www.science.org/content/page/instructions-preparing-revised-manuscript)
- **[CELL-FIG]** [Cell Press figure guidelines](https://www.cell.com/information-for-authors/figure-guidelines)
- **[PLOS-FIG]** [PLOS Computational Biology figures](https://journals.plos.org/ploscompbiol/s/figures)
- **[ELSEVIER-FORMAT]** [Elsevier artwork formats](https://www.elsevier.com/about/policies-and-standards/author/artwork-and-media-instructions/artwork-formats-checklist)
- **[ELSEVIER-SIZE]** [Elsevier artwork sizing](https://www.elsevier.com/about/policies-and-standards/author/artwork-and-media-instructions/artwork-sizing)
- **[IEEE-SIZE]** [IEEE Resolution and Size](https://journals.ieeeauthorcenter.ieee.org/create-your-ieee-journal-article/create-graphics-for-your-article/resolution-and-size/)
- **[BMC-BIOINFO]** [BMC Bioinformatics submission guidelines](https://link.springer.com/journal/12859/submission-guidelines)
- **[ACS-GRAPHICS]** [ACS Preparing Manuscript Graphics](https://pubsapp.acs.org/paragonplus/submission/general/graphics_prep.html)
  — legacy, updated 2006-01-21; target-journal rules govern.

## Rules that are not universal

- "JPEG is never accepted." Several publishers accept it for photographs.
- "All line art must be 1000 dpi." Vector output is usually preferred.
- "All figures must be RGB." RGB is often preferred; rules differ.
- "A matching DPI and width means compliant." Metadata is one part of review.