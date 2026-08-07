#!/usr/bin/env python3
"""Generate NppESPHome.xml from the official ESPHome component documentation.

The generator preserves existing templates (including local/project templates),
adds one entry for every configurable component/platform documented by ESPHome,
and emits a coverage report alongside the XML file.
"""

from __future__ import annotations

import argparse
import html
import json
import re
import subprocess
import sys
import xml.etree.ElementTree as ET
from collections import Counter
from dataclasses import dataclass
from pathlib import Path

import yaml


CANONICAL_BASE = "https://esphome.io"

MANUAL_YAML = {
    "sensor/max44009.mdx": """# Example configuration entry
sensor:
  - platform: max44009
    name: "MAX44009 Illuminance"
    address: 0x4A
    mode: low_power
    update_interval: 60s""",
    "sensor/filter/debounce.mdx": """# Example sensor filter
filters:
  - debounce: 1s""",
    "sensor/filter/exponential_moving_average.mdx": """# Example sensor filter
filters:
  - exponential_moving_average:
      alpha: 0.1
      send_every: 15
      send_first_at: 1""",
    "sensor/filter/multiply.mdx": """# Example sensor filter
filters:
  - multiply: 2.0""",
    "sensor/filter/throttle_average.mdx": """# Example sensor filter
filters:
  - throttle_average: 60s""",
}

CATEGORY_LABELS = {
    "alarm_control_panel": "Alarm Control Panels",
    "audio_adc": "Audio ADC",
    "audio_dac": "Audio DAC",
    "audio_file": "Audio Files",
    "binary_sensor": "Binary Sensors",
    "button": "Buttons",
    "camera": "Cameras",
    "canbus": "CAN Bus",
    "climate": "Climate",
    "cover": "Covers",
    "datetime": "Date/Time",
    "display": "Displays",
    "display_menu": "Display Menus",
    "event": "Events",
    "fan": "Fans",
    "image": "Images",
    "light": "Lights",
    "lock": "Locks",
    "lvgl": "LVGL",
    "media_player": "Media Players",
    "media_source": "Media Sources",
    "microphone": "Microphones",
    "motion": "Motion",
    "number": "Numbers",
    "one_wire": "1-Wire Bus",
    "ota": "OTA Updates",
    "output": "Outputs",
    "packet_transport": "Packet Transport",
    "select": "Selects",
    "sensor": "Sensors",
    "speaker": "Speakers",
    "switch": "Switches",
    "text": "Text",
    "text_sensor": "Text Sensors",
    "time": "Time",
    "touchscreen": "Touchscreens",
    "update": "Updates",
    "valve": "Valves",
    "water_heater": "Water Heaters",
}

ENCODING_REPLACEMENTS = {
    "â€¦": "…",
    "â€“": "–",
    "â€”": "—",
    "â€˜": "‘",
    "â€™": "’",
    "â€œ": "“",
    "â€": "”",
    "â€‘": "‑",
    "Â°": "°",
    "â„¦": "Ω",
    "Â±": "±",
}


@dataclass
class Template:
    name: str
    category: str
    online_help: str
    description: str
    yaml_text: str
    source: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser()
    parser.add_argument("--docs-root", type=Path, required=True,
                        help="Path to esphome.io/src/content/docs/components")
    parser.add_argument("--input", type=Path, required=True,
                        help="Existing NppESPHome.xml to preserve")
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--report", type=Path, required=True)
    parser.add_argument("--manifest", type=Path,
                        help="Generated-template provenance manifest (defaults beside output)")
    return parser.parse_args()


def fix_encoding(text: str) -> str:
    for broken, fixed in ENCODING_REPLACEMENTS.items():
        text = text.replace(broken, fixed)
    return text


def canonical_url(url: str) -> str:
    url = url.strip().replace("https://www.esphome.io", CANONICAL_BASE)
    url = url.replace("http://esphome.io", CANONICAL_BASE)
    url = re.sub(r"(?i)(https://esphome\.io/components/[^?#]+?)\.html/?$", r"\1/", url)
    aliases = {
        f"{CANONICAL_BASE}/components/rp2040/": f"{CANONICAL_BASE}/components/rp2/",
    }
    url = aliases.get(url, url)
    if url.startswith(f"{CANONICAL_BASE}/components/") and not url.endswith("/"):
        url += "/"
    return url


def clean_existing_yaml(name: str, text: str) -> str:
    text = fix_encoding(text)
    text = re.sub(r"\s*:contentReference\[oaicite:\d+\]\{index=\d+\}", "", text)
    if name == "external_components":
        text = """external_components:
  # Load selected components from ESPHome's development branch.
  - source:
      type: git
      url: https://github.com/esphome/esphome
      ref: dev
    components: [rtttl, dfplayer]

  # Load all components from a local folder.
  - source:
      type: local
      path: my_components"""
    return text.strip("\r\n")


def load_existing(path: Path, generated_urls: set[str]) -> list[Template]:
    root = ET.parse(path).getroot()
    result: list[Template] = []
    for node in root.findall("Component"):
        def value(tag: str) -> str:
            child = node.find(tag)
            return "" if child is None or child.text is None else child.text

        online_help = canonical_url(value("OnlineHelp"))
        if online_help and online_help in generated_urls:
            continue
        category = value("Category").strip()
        if category == "Networking":
            category = "Network"
        result.append(Template(
            name=fix_encoding(value("Name").strip()),
            category=category,
            online_help=online_help,
            description=fix_encoding(value("Description").strip()),
            yaml_text=clean_existing_yaml(value("Name").strip(), value("YAML")),
            source="existing",
        ))
    return result


def doc_relative_path(path: Path, docs_root: Path) -> str:
    return path.relative_to(docs_root).as_posix()


def doc_url(relative: str) -> str:
    rel = relative.removesuffix(".mdx")
    if rel.endswith("/index"):
        rel = rel.removesuffix("/index")
    return f"{CANONICAL_BASE}/components/{rel.strip('/')}/"


def parse_frontmatter(text: str, relative: str) -> dict[str, object]:
    match = re.match(r"\A---\s*\n(.*?)\n---\s*(?:\n|\Z)", text, re.DOTALL)
    if not match:
        raise ValueError(f"Missing frontmatter: {relative}")
    data = yaml.safe_load(match.group(1)) or {}
    if not data.get("title") or not data.get("description"):
        raise ValueError(f"Missing title/description: {relative}")
    return data


def first_yaml_block(text: str) -> str | None:
    match = re.search(r"^```ya?ml\s*\n(.*?)^```\s*$", text,
                      flags=re.MULTILINE | re.DOTALL | re.IGNORECASE)
    return None if not match else match.group(1).strip("\r\n")


def clean_documented_yaml(relative: str, snippet: str) -> str:
    """Fix known presentational indentation issues in official examples."""
    # Documentation sometimes uses a standalone ellipsis as prose. In YAML it
    # is an end-of-document marker, so retain its intent as a comment instead.
    snippet = re.sub(r"^(\s*)\.\.\.\s*$", r"\1# ...", snippet, flags=re.MULTILINE)

    if relative in {"binary_sensor/packet_transport.mdx", "sensor/packet_transport.mdx"}:
        snippet = snippet.replace("\n packet_transport:\n   - platform:",
                                  "\npacket_transport:\n  - platform:")
    elif relative == "canbus/mcp2515.mdx":
        snippet = re.sub(r"^(    - can_id: .+)\n        then:",
                         r"\1\n      then:", snippet, flags=re.MULTILINE)
    elif relative == "i2c_device.mdx":
        snippet = snippet.replace("\n on...:\n then:\n   - lambda:",
                                  "\non_...:\n  then:\n    - lambda:")
        snippet = snippet.replace("\n       id(i2cdev)", "\n        id(i2cdev)")
        snippet = snippet.replace("\n       if (auto", "\n        if (auto")
        snippet = snippet.replace("\n         // TODO", "\n          // TODO")
        snippet = snippet.replace("\n       }", "\n        }")
    elif relative.startswith("packet_transport/"):
        lines = snippet.splitlines()
        in_dht = False
        for index, line in enumerate(lines):
            if line == "  - platform: dht":
                in_dht = True
                continue
            if in_dht and line.startswith("      "):
                lines[index] = line[2:]
        snippet = "\n".join(lines)
    elif relative == "sensor/atm90e26.mdx":
        lines = snippet.splitlines()
        in_sensor = False
        for index, line in enumerate(lines):
            if line == "sensor:":
                in_sensor = True
                continue
            stripped = line.lstrip(" ")
            indent = len(line) - len(stripped)
            if in_sensor and indent >= 4 and not stripped.startswith("#"):
                lines[index] = " " * (indent // 2) + stripped
        snippet = "\n".join(lines)
    elif relative == "switch/modbus_controller.mdx":
        snippet = snippet.replace("switch:\n- platform:", "switch:\n  - platform:")
    return snippet


def index_categories(index_text: str) -> dict[str, str]:
    result: dict[str, str] = {}
    current_h2 = "Miscellaneous Components"
    for line in index_text.splitlines():
        heading = re.match(r"^##\s+(.+?)\s*$", line)
        if heading:
            current_h2 = heading.group(1)
            continue
        item = re.search(r'\[\s*"[^"]+"\s*,\s*"(/components/[^"]+)"', line)
        if item:
            path = item.group(1).rstrip("/") + "/"
            result.setdefault(path, current_h2)
    return result


def category_for(relative: str, url: str, root_categories: dict[str, str]) -> str:
    parts = relative.split("/")
    if len(parts) > 1:
        if len(parts) > 2 and parts[0] == "sensor" and parts[1] == "filter":
            return "Sensor Filters"
        return CATEGORY_LABELS.get(parts[0], parts[0].replace("_", " ").title())
    url_path = url.removeprefix(CANONICAL_BASE)
    return root_categories.get(url_path, "Miscellaneous Components")


def load_documented(docs_root: Path) -> tuple[list[Template], list[str], list[str]]:
    index_path = docs_root / "index.mdx"
    root_categories = index_categories(index_path.read_text(encoding="utf-8"))
    templates: list[Template] = []
    excluded: list[str] = []
    manual: list[str] = []

    for path in sorted(docs_root.rglob("*.mdx")):
        relative = doc_relative_path(path, docs_root)
        if relative == "index.mdx":
            excluded.append(relative)
            continue
        text = path.read_text(encoding="utf-8")
        metadata = parse_frontmatter(text, relative)
        snippet = first_yaml_block(text)
        if snippet is None:
            snippet = MANUAL_YAML.get(relative)
            if snippet is None:
                excluded.append(relative)
                continue
            manual.append(relative)
        url = doc_url(relative)
        snippet = clean_documented_yaml(relative, snippet)
        templates.append(Template(
            name=fix_encoding(str(metadata["title"]).strip()),
            category=category_for(relative, url, root_categories),
            online_help=url,
            description=fix_encoding(str(metadata["description"]).strip()),
            yaml_text=fix_encoding(snippet),
            source=relative,
        ))
    return templates, excluded, manual


def unique_name(candidate: str, category: str, source: str, used: set[str]) -> str:
    if candidate.casefold() not in used:
        used.add(candidate.casefold())
        return candidate
    qualified = f"{candidate} ({category})"
    if qualified.casefold() not in used:
        used.add(qualified.casefold())
        return qualified
    slug = source.removesuffix(".mdx").replace("/index", "").replace("/", "/")
    qualified = f"{candidate} [{slug}]"
    counter = 2
    while qualified.casefold() in used:
        qualified = f"{candidate} [{slug} #{counter}]"
        counter += 1
    used.add(qualified.casefold())
    return qualified


def load_generated_urls(path: Path) -> set[str]:
    if not path.is_file():
        return set()
    data = json.loads(path.read_text(encoding="utf-8"))
    return {canonical_url(str(item["url"])) for item in data.get("generated", [])}


def write_manifest(path: Path, added: list[Template], commit: str, commit_date: str) -> None:
    data = {
        "source_repository": "https://github.com/esphome/esphome.io",
        "source_branch": "current",
        "source_commit": commit,
        "source_commit_date": commit_date,
        "generated": [
            {"name": item.name, "url": item.online_help, "source": item.source}
            for item in added
        ],
    }
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def merge(existing: list[Template], documented: list[Template]) -> tuple[list[Template], list[Template]]:
    result = list(existing)
    added: list[Template] = []
    covered_urls = {item.online_help for item in existing if item.online_help}
    used_names = {item.name.casefold() for item in existing}
    for item in sorted(documented, key=lambda x: (x.category.casefold(), x.name.casefold(), x.source)):
        if item.online_help in covered_urls:
            continue
        item.name = unique_name(item.name, item.category, item.source, used_names)
        result.append(item)
        added.append(item)
        covered_urls.add(item.online_help)
    return result, added


def xml_text(value: str) -> str:
    return html.escape(value, quote=False)


def render_xml(templates: list[Template]) -> str:
    lines = ["<Components>", ""]
    for item in templates:
        if "]]" + ">" in item.yaml_text:
            raise ValueError(f"CDATA terminator in {item.name}")
        normalized_yaml = "\n".join(line.rstrip() for line in item.yaml_text.splitlines())
        lines.extend([
            "<Component>",
            f"  <Name>{xml_text(item.name)}</Name>",
            f"  <Category>{xml_text(item.category)}</Category>",
            f"  <OnlineHelp>{xml_text(item.online_help)}</OnlineHelp>",
            f"  <Description>{xml_text(item.description)}</Description>",
            "  <YAML><![CDATA[",
            normalized_yaml.rstrip(),
            "]]></YAML>",
            "</Component>",
            "",
        ])
    lines.append("</Components>")
    return "\n".join(lines) + "\n"


def git_metadata(docs_root: Path) -> tuple[str, str]:
    repo = docs_root.parents[3]
    try:
        commit = subprocess.check_output(
            ["git", "-C", str(repo), "rev-parse", "HEAD"], text=True
        ).strip()
        commit_date = subprocess.check_output(
            ["git", "-C", str(repo), "log", "-1", "--format=%cI"], text=True
        ).strip()
        return commit, commit_date
    except (OSError, subprocess.CalledProcessError):
        return "unknown", "unknown"


def validate(templates: list[Template], xml_output: str, documented: list[Template]) -> list[str]:
    errors: list[str] = []
    try:
        root = ET.fromstring(xml_output)
    except ET.ParseError as exc:
        errors.append(f"XML parse error: {exc}")
        return errors
    if root.tag != "Components" or len(root.findall("Component")) != len(templates):
        errors.append("XML component count mismatch")
    duplicate_names = [name for name, count in Counter(t.name.casefold() for t in templates).items() if count > 1]
    if duplicate_names:
        errors.append(f"Duplicate names: {', '.join(duplicate_names)}")
    required = ("name", "category", "description", "yaml_text")
    for item in templates:
        for field in required:
            if not getattr(item, field).strip():
                errors.append(f"Empty {field}: {item.name or item.source}")
        if ":contentReference[" in item.yaml_text:
            errors.append(f"Citation artifact: {item.name}")
    class ESPHomeLoader(yaml.SafeLoader):
        pass

    def construct_tag(loader: yaml.SafeLoader, _suffix: str, node: yaml.Node) -> object:
        if isinstance(node, yaml.ScalarNode):
            return loader.construct_scalar(node)
        if isinstance(node, yaml.SequenceNode):
            return loader.construct_sequence(node)
        return loader.construct_mapping(node)

    ESPHomeLoader.add_multi_constructor("!", construct_tag)
    for item in templates:
        try:
            yaml.load(item.yaml_text, Loader=ESPHomeLoader)
        except yaml.YAMLError as exc:
            errors.append(f"YAML parse error in {item.name}: {str(exc).splitlines()[0]}")

    output_urls = {t.online_help for t in templates if t.online_help}
    missing_docs = sorted({t.online_help for t in documented} - output_urls)
    if missing_docs:
        errors.append(f"Uncovered documentation URLs: {len(missing_docs)}")
    return errors


def write_report(path: Path, *, commit: str, commit_date: str,
                 docs_count: int, documented: list[Template], excluded: list[str],
                 manual: list[str], existing: list[Template], added: list[Template],
                 merged: list[Template], errors: list[str]) -> None:
    duplicate_doc_urls = sum(count - 1 for count in Counter(t.online_help for t in documented).values() if count > 1)
    local_count = sum(1 for t in existing if not t.online_help)
    lines = [
        "# NppESPHome template coverage",
        "",
        "Generated from the official `esphome/esphome.io` `current` branch.",
        "",
        f"- Source commit: `{commit}`",
        f"- Source commit date: `{commit_date}`",
        f"- MDX component pages scanned: **{docs_count}**",
        f"- Configurable/documented pages represented: **{len(documented)}**",
        f"- Existing templates preserved: **{len(existing)}** ({local_count} without an online documentation URL)",
        f"- New templates generated: **{len(added)}**",
        f"- Final XML templates: **{len(merged)}**",
        f"- Duplicate documentation URLs collapsed: **{duplicate_doc_urls}**",
        f"- Validation: **{'PASS' if not errors else 'FAIL'}**",
        "",
        "## Generation rules",
        "",
        "- Existing XML entries remain first and retain their YAML content; known citation/encoding artifacts and invalid obsolete syntax are corrected.",
        "- New entries use the first official fenced YAML example from each component/platform page.",
        "- Known indentation errors and prose ellipses in those examples are normalized into valid YAML.",
        "- Generated-entry provenance is stored in `NppESPHome.generated.json` so subsequent runs update without duplication.",
        "- A documentation URL already represented by an existing entry is not generated twice.",
        "- Names are made unique by adding a category or documentation slug only when needed.",
        "- Root components use the official main-index category; platform pages use their component domain.",
        "",
        "## Regeneration",
        "",
        "```powershell",
        "git clone --depth 1 --branch current https://github.com/esphome/esphome.io.git .tmp/esphome.io-current",
        "python Tools/GenerateESPHomeTemplates.py --docs-root .tmp/esphome.io-current/src/content/docs/components --input Templates/NppESPHome.xml --output Templates/NppESPHome.xml --report Templates/NppESPHome.coverage.md --manifest Templates/NppESPHome.generated.json",
        "```",
        "",
        "## Manual YAML fallbacks",
        "",
    ]
    lines.extend(f"- `{item}`" for item in manual)
    lines.extend(["", "## Excluded documentation pages", ""])
    lines.extend(f"- `{item}`" for item in excluded)
    lines.extend(["", "## Validation errors", ""])
    lines.extend(["- None."] if not errors else [f"- {error}" for error in errors])
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    args = parse_args()
    docs_root = args.docs_root.resolve()
    if not (docs_root / "index.mdx").is_file():
        raise SystemExit(f"Invalid ESPHome components documentation root: {docs_root}")

    manifest_path = args.manifest or args.output.with_name("NppESPHome.generated.json")
    generated_urls = load_generated_urls(manifest_path)
    existing = load_existing(args.input, generated_urls)
    documented, excluded, manual = load_documented(docs_root)
    merged, added = merge(existing, documented)
    xml_output = render_xml(merged)
    errors = validate(merged, xml_output, documented)
    commit, commit_date = git_metadata(docs_root)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(xml_output, encoding="utf-8", newline="\n")
    write_manifest(manifest_path, added, commit, commit_date)
    docs_count = len(list(docs_root.rglob("*.mdx")))
    write_report(
        args.report,
        commit=commit,
        commit_date=commit_date,
        docs_count=docs_count,
        documented=documented,
        excluded=excluded,
        manual=manual,
        existing=existing,
        added=added,
        merged=merged,
        errors=errors,
    )

    print(f"Existing: {len(existing)}")
    print(f"Documented/configurable: {len(documented)}")
    print(f"Added: {len(added)}")
    print(f"Final: {len(merged)}")
    print(f"Excluded: {len(excluded)}")
    print(f"Validation: {'PASS' if not errors else 'FAIL'}")
    for error in errors:
        print(f"ERROR: {error}", file=sys.stderr)
    return 0 if not errors else 1


if __name__ == "__main__":
    raise SystemExit(main())
