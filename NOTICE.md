# Attribution and Provenance

This project is a MATLAB port of an existing skill. Most of the *ideas* below are not mine;
the MATLAB implementation is.

## Upstream work

**Scientific Agent Skills** — `scientific-visualization` skill, version 1.4 (last reviewed
2026-10-01), by **K-Dense Inc.**, released under the MIT License.

- Registry page: https://skills.sh/k-dense-ai/scientific-agent-skills/scientific-visualization
- Repository: https://github.com/k-dense-ai/scientific-agent-skills

Please cite the upstream work if this skill materially contributes to a manuscript, report, or
code release:

> Kassis, T., Agarwal, V., He, Y., Patel, D., & Brueckner, A. M. (2026). *Scientific Agent
> Skills: A Library of Procedural Knowledge for Research Agents.* arXiv:2609.00065.
> https://doi.org/10.48550/arXiv.2609.00065

## What was carried over

| Item | Origin |
|---|---|
| Non-negotiable guardrails | Adapted from the upstream `SKILL.md` |
| Honest-encoding rules (baselines, uncertainty, missing data, area/volume, log axes, binning, normalization, dual axes) | Upstream `references/publication_guidelines.md` |
| Palette semantics and WCAG/CIE L\* reasoning | Upstream `references/color_palettes.md` |
| Okabe-Ito and Paul Tol colour values | Wong, *Nature Methods* 8, 441 (2011); Tol, SRON/EPS/TN/09-002 issue 3.2 (2021) — via upstream |
| Publisher width/format/DPI snapshots | Upstream `references/journal_requirements.md` |
| `assets/publisher_profiles.json` | Copied verbatim from upstream (MIT) |
| Source list | Upstream `references/sources.md` |

## What is new here

| Item | Notes |
|---|---|
| All six `.m` functions | Written for MATLAB; no upstream code exists in MATLAB |
| The four style presets | Values re-derived from upstream `.mplstyle` files, expressed as MATLAB axes properties |
| `figureAudit` contrast and CIE L\* maths | Reimplemented per WCAG 2.2 and CIE definitions; upstream used Python |
| `figureExport` | New. Physical-size control via `PaperSize`/`PaperPosition`, overwrite refusal, JSON manifest |
| `figureMetadata` | New. `imfinfo` for rasters plus a MediaBox parse for PDFs |
| `figureColormap` | New. Eleven-anchor interpolations of the published maps |
| The MATLAB trap table | New, from testing against R2024b |
| The figure-review workflow | New |
| `references/matlab_examples.md` | New; eleven runnable patterns |

## What was not ported

- **Matplotlib-only mechanisms**: `layout="constrained"`, `TwoSlopeNorm`, `cmap.with_extremes`.
  MATLAB has no direct equivalent; the documents say so rather than pretending otherwise.
- **Python ecosystem**: Seaborn, Plotly/Kaleido, Pillow, pypdf, and the `uv` dependency pinning.
- **PDF font-resource inspection**: not possible from MATLAB without external tooling.
- **The upstream CLI scripts**: `export_plan.py`, `figure_export.py`, `image_metadata.py`,
  `palette_audit.py`, `style_presets.py`, `style_preview.py` are replaced by the six `.m`
  functions above, with narrower scope.

## Third-party references

The documents cite W3C WCAG 2.2, ColorBrewer, and the figure guidelines of Nature, Science,
Cell Press, PLOS, Elsevier, IEEE, BMC, and ACS. Those are referenced, not redistributed. See
`references/sources.md` for URLs and access dates.