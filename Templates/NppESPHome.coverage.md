# NppESPHome template coverage

Generated from the official `esphome/esphome.io` `current` branch.

- Source commit: `7c494bb0d85d51bb946415cdd7e46a7cd345a9ef`
- Source commit date: `2026-08-06T08:08:57+12:00`
- MDX component pages scanned: **719**
- Configurable/documented pages represented: **712**
- Existing templates preserved: **41** (3 without an online documentation URL)
- New templates generated: **676**
- Final XML templates: **717**
- Duplicate documentation URLs collapsed: **0**
- Validation: **PASS**

## Generation rules

- Existing XML entries remain first and retain their YAML content; known citation/encoding artifacts and invalid obsolete syntax are corrected.
- New entries use the first official fenced YAML example from each component/platform page.
- Known indentation errors and prose ellipses in those examples are normalized into valid YAML.
- Generated-entry provenance is stored in `NppESPHome.generated.json` so subsequent runs update without duplication.
- A documentation URL already represented by an existing entry is not generated twice.
- Names are made unique by adding a category or documentation slug only when needed.
- Root components use the official main-index category; platform pages use their component domain.

## Regeneration

```powershell
git clone --depth 1 --branch current https://github.com/esphome/esphome.io.git .tmp/esphome.io-current
python Tools/GenerateESPHomeTemplates.py --docs-root .tmp/esphome.io-current/src/content/docs/components --input Templates/NppESPHome.xml --output Templates/NppESPHome.xml --report Templates/NppESPHome.coverage.md --manifest Templates/NppESPHome.generated.json
```

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
