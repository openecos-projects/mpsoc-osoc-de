#!/usr/bin/env python3
"""Generate a build-only SoC top with sequential user core substitutions."""

from __future__ import annotations

import argparse
import re
import shlex
from pathlib import Path

CORE_COUNT = 32
INSTANCE_RE = re.compile(r"(?m)^(\s*)NPC(\s+core(\d+)\s*\()")


def safe_path(root: Path, value: str, context: str) -> Path:
    path = Path(value)
    if path.is_absolute() or ".." in path.parts:
        raise ValueError(f"{context}: path must stay below the project root: {value}")
    candidate = (root / path).resolve()
    try:
        candidate.relative_to(root.resolve())
    except ValueError as exc:
        raise ValueError(f"{context}: path escapes project root: {value}") from exc
    return candidate


def parse_manifest(root: Path, manifest: Path) -> dict[int, tuple[str, Path]]:
    result: dict[int, tuple[str, Path]] = {}
    for lineno, line in enumerate(manifest.read_text(encoding="utf-8").splitlines(), 1):
        stripped = line.split("#", 1)[0].strip()
        if not stripped:
            continue
        fields = shlex.split(stripped)
        if len(fields) != 3:
            raise ValueError(f"{manifest}:{lineno}: expected '<slot> <module> <source>'")
        try:
            slot = int(fields[0], 10)
        except ValueError as exc:
            raise ValueError(f"{manifest}:{lineno}: slot must be an integer") from exc
        if not 0 <= slot < CORE_COUNT:
            raise ValueError(f"{manifest}:{lineno}: slot must be in [0, {CORE_COUNT - 1}]")
        module = fields[1]
        if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_$]*", module) or module == "NPC":
            raise ValueError(f"{manifest}:{lineno}: invalid or reserved module name: {module}")
        if slot in result:
            raise ValueError(f"{manifest}:{lineno}: duplicate slot {slot}")
        source = safe_path(root / "user-cores", fields[2], f"{manifest}:{lineno}")
        if not source.is_file():
            raise ValueError(f"{manifest}:{lineno}: source does not exist: {fields[2]}")
        result[slot] = (module, source)
    expected = list(range(len(result)))
    actual = sorted(result)
    if actual != expected:
        raise ValueError(f"core slots must be consecutive from 0; got {actual}")
    return result


def assemble(root: Path, manifest: Path, output_top: Path, output_list: Path) -> None:
    slots = parse_manifest(root, manifest)
    source_top = root / "rtl" / "soc" / "asicTopYSYXstageDE.v"
    text = source_top.read_text(encoding="utf-8")
    seen: set[int] = set()

    def replace(match: re.Match[str]) -> str:
        slot = int(match.group(3))
        seen.add(slot)
        module = slots.get(slot, ("NPC", Path()))[0]
        return f"{match.group(1)}{module}{match.group(2)}"

    patched = INSTANCE_RE.sub(replace, text)
    if seen != set(range(CORE_COUNT)):
        raise ValueError(f"expected {CORE_COUNT} NPC instances, found slots {sorted(seen)}")
    output_top.parent.mkdir(parents=True, exist_ok=True)
    output_top.write_text(patched, encoding="utf-8")

    filelist = []
    for line in (root / "rtl" / "filelist.f").read_text(encoding="utf-8").splitlines():
        item = line.strip()
        if not item or item.startswith("#"):
            continue
        if item in {"soc/asicTopYSYXstageDE.v", "perip/spi/rtl/spi_top_apb.v"}:
            continue
        filelist.append(str((root / "rtl" / item).resolve()))
    filelist.extend(str(source.resolve()) for _, source in slots.values())
    output_list.write_text("\n".join(filelist) + "\n", encoding="utf-8")
    print(f"assembled {len(slots)} user core(s)")
    print(output_top)
    print(output_list)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, required=True)
    parser.add_argument("--manifest", type=Path, required=True)
    parser.add_argument("--cpu-id", type=int)
    parser.add_argument("--check-only", action="store_true")
    args = parser.parse_args()
    root = args.root.resolve()
    manifest = args.manifest.resolve()
    try:
        slots = parse_manifest(root, manifest)
        if args.cpu_id is not None and slots and args.cpu_id >= len(slots):
            raise ValueError(
                f"CPU_ID {args.cpu_id} has no user core; registered slots are 0..{len(slots) - 1}"
            )
        if args.check_only:
            print(f"validated {len(slots)} user core(s)")
        else:
            assemble(
                root,
                manifest,
                root / "build" / "generated" / "asicTopYSYXstageDE_user.v",
                root / "build" / "generated" / "user-filelist.f",
            )
    except (OSError, ValueError) as exc:
        parser.error(str(exc))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
