#!/usr/bin/env python3
"""Regenerate the constant block in Lib/Npp.Scintilla.Api.pas.

The input is the official Scintilla include/Scintilla.iface file. The script
deliberately updates only the marked generated block, leaving Delphi ABI record
declarations under manual review.
"""

from __future__ import annotations

import argparse
import hashlib
import re
import sys
from collections import OrderedDict
from pathlib import Path


VALUE_RE = re.compile(r"^(?:val|lex)\s+([A-Za-z0-9_]+)\s*=\s*([^\s#]+)")
FEATURE_RE = re.compile(
    r"^(fun|get|set|evt)\s+\S+\s+([A-Za-z0-9_]+)\s*=\s*([^\s(]+)"
)
BLOCK_RE = re.compile(
    r"(?ms)^\s*//\+\+Const -- start of section automatically generated"
    r" from Scintilla\.iface\r?\n.*?^\s*//--Const\s*$"
)


def pascal_value(value: str) -> str:
    return re.sub(r"\b0x([0-9A-Fa-f]+)\b", r"$\1", value)


def read_constants(iface: Path) -> OrderedDict[str, str]:
    constants: OrderedDict[str, str] = OrderedDict()
    for line_number, raw_line in enumerate(
        iface.read_text(encoding="utf-8").splitlines(), start=1
    ):
        line = raw_line.strip()
        match = VALUE_RE.match(line)
        if match:
            name, value = match.groups()
        else:
            match = FEATURE_RE.match(line)
            if not match:
                continue
            kind, feature_name, value = match.groups()
            prefix = "SCN_" if kind == "evt" else "SCI_"
            name = prefix + feature_name.upper()
        value = pascal_value(value)
        previous = constants.get(name)
        if previous is not None and previous != value:
            raise ValueError(
                f"{iface}:{line_number}: conflicting values for {name}: "
                f"{previous} and {value}"
            )
        constants[name] = value
    if not constants:
        raise ValueError(f"No constants found in {iface}")
    return constants


def render_block(
    constants: OrderedDict[str, str], iface: Path, version: str
) -> str:
    digest = hashlib.sha256(iface.read_bytes()).hexdigest()
    lines = [
        "  //++Const -- start of section automatically generated from Scintilla.iface",
        "  // Generator: Tools/GenerateScintillaApi.py",
        f"  // Upstream version: {version or 'unspecified'}",
        f"  // Scintilla.iface SHA-256: {digest}",
    ]
    width = max(len(name) for name in constants) + 2
    for name, value in constants.items():
        lines.append(f"  {name:<{width}}= {value};")
    lines.append("  //--Const")
    return "\n".join(lines)


def main() -> int:
    repo_root = Path(__file__).resolve().parents[1]
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--iface", required=True, type=Path,
        help="path to the official Scintilla include/Scintilla.iface",
    )
    parser.add_argument(
        "--unit", type=Path,
        default=repo_root / "Lib" / "Npp.Scintilla.Api.pas",
    )
    parser.add_argument(
        "--version", default="",
        help="upstream Scintilla tag/version recorded in the generated block",
    )
    parser.add_argument(
        "--check", action="store_true",
        help="exit non-zero instead of writing when regeneration is needed",
    )
    args = parser.parse_args()

    iface = args.iface.resolve()
    unit = args.unit.resolve()
    constants = read_constants(iface)
    generated = render_block(constants, iface, args.version)
    source = unit.read_text(encoding="utf-8")
    if not BLOCK_RE.search(source):
        raise ValueError(f"Generated constant markers were not found in {unit}")
    updated = BLOCK_RE.sub(generated, source, count=1)
    if updated == source:
        print(f"{unit} is up to date")
        return 0
    if args.check:
        print(f"{unit} must be regenerated", file=sys.stderr)
        return 1
    unit.write_text(updated, encoding="utf-8", newline="\n")
    print(
        f"Updated {unit} with {len(constants)} constants from {iface} "
        f"(SHA-256 {hashlib.sha256(iface.read_bytes()).hexdigest()})"
    )
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError) as exc:
        print(exc, file=sys.stderr)
        raise SystemExit(2)
