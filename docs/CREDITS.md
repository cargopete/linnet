# Credits & third-party assets

Linnet bundles a small number of third-party assets, all offline (no CDN, in
keeping with the no-network privacy promise) and under permissive licences.

## OpenMoji — size-comparison illustrations

The colourful "as big as…" illustrations in the pregnancy week-by-week journey
(`assets/sizes/*.png`) are from **OpenMoji**, the open-source emoji project.

- Source: https://openmoji.org
- Licence: **Creative Commons Attribution-ShareAlike 4.0 International
  (CC BY-SA 4.0)** — https://creativecommons.org/licenses/by-sa/4.0/
- The files are the unmodified 618×618 colour PNGs, named by their Unicode
  codepoint (e.g. `1F34C.png` is a banana).

All other imagery in the app (e.g. the week-by-week fetal silhouette) is drawn
in code and is original to Linnet.

## WHO Child Growth Standards — baby growth percentiles

The baby growth charts plot weight and height against the **WHO Child Growth
Standards** (weight-for-age and length/height-for-age), computed on-device from
the published LMS parameters.

- Source: World Health Organization — https://www.who.int/tools/child-growth-standards
- The LMS tables (boys & girls, 0–60 months) are bundled in
  `lib/src/features/growth/domain/who_growth_data.dart`, generated from the WHO
  data as redistributed by the open-source nutriverse/zscorer dataset.
- WHO growth-standard data is freely available for use. These charts are a
  health reference, not a medical assessment.

## Plus Jakarta Sans — typeface

- Source: https://github.com/tokotype/PlusJakartaSans
- Licence: **SIL Open Font License 1.1 (OFL)**
- Bundled as `assets/fonts/PlusJakartaSans.ttf` rather than fetched from a font
  CDN, so the app makes no network requests for fonts.
