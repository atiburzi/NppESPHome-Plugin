# NppESPHome template coverage

Generated from the official `esphome/esphome.io` `current` branch.

- Source commit: `0525ea5715e7a307775a0feda79c83c288ad0c42`
- Source commit date: `2026-10-08T12:22:49+13:00`
- MDX component pages scanned: **740**
- Configurable/documented pages represented: **732**
- Existing templates preserved: **37** (0 without an online documentation URL)
- New templates generated: **697**
- Final XML templates: **734**
- Duplicate documentation URLs collapsed: **0**
- Validation: **PASS**

## Generation rules

- Existing XML entries retain their YAML content; known citation/encoding artifacts and invalid obsolete syntax are corrected.
- New entries use the first official fenced YAML example from each component/platform page.
- Known indentation errors and prose ellipses in those examples are normalized into valid YAML.
- Generated-entry provenance is stored in `NppESPHome.generated.json` so subsequent runs update without duplication.
- A documentation URL already represented by an existing entry is not generated twice.
- Names are made unique by adding a category or documentation slug only when needed.
- Names are limited to 35 characters and existing concise names are preserved by URL.
- Components are written in case-insensitive ascending alphabetical order.
- URLs listed in `NppESPHome.excluded.txt` remain intentionally excluded.
- Root components use the official main-index category; platform pages use their component domain.

## Regeneration

```powershell
git clone --depth 1 --branch current https://github.com/esphome/esphome.io.git .tmp/esphome.io-current
py -3 Tools/GenerateESPHomeTemplates.py --docs-root .tmp/esphome.io-current/src/content/docs/components --input Templates/NppESPHome.xml --output Templates/NppESPHome.xml --report Templates/NppESPHome.coverage.md --manifest Templates/NppESPHome.generated.json --exclusions Templates/NppESPHome.excluded.txt
```

## Intentionally excluded documentation URLs

- `https://esphome.io/components/esphome/`

## Manual YAML fallbacks

- `sensor/filter/debounce.mdx`
- `sensor/filter/exponential_moving_average.mdx`
- `sensor/filter/multiply.mdx`
- `sensor/filter/throttle_average.mdx`
- `sensor/max44009.mdx`

## Excluded documentation pages

- `camera/index.mdx`
- `index.mdx`
- `one_wire/index.mdx`
- `sensor/xiaomi_hhccjcy01.mdx`
- `sensor/xiaomi_lywsdcgq.mdx`
- `sensor/xiaomi_miscale2.mdx`
- `xxtea.mdx`

## Validation errors

- None.
