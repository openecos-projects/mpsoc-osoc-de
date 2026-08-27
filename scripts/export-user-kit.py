#!/usr/bin/env python3
"""Export the small public mpsoc-osoc user kit without build artifacts."""

from __future__ import annotations

import argparse
import json
import shutil
from pathlib import Path


def is_excluded(root: Path, source: Path, excludes: list[Path]) -> bool:
    relative = source.relative_to(root)
    return any(relative == item or item in relative.parents for item in excludes)


def copy_checked(
    root: Path,
    output: Path,
    name: str,
    excludes: list[Path],
    destination: str | None = None,
) -> None:
    source = (root / name).resolve()
    try:
        source.relative_to(root.resolve())
    except ValueError as exc:
        raise ValueError(f"path escapes root: {name}") from exc
    if not source.exists():
        raise FileNotFoundError(name)
    if is_excluded(root.resolve(), source, excludes):
        return
    target_name = destination or name
    target = (output / target_name).resolve()
    try:
        target.relative_to(output.resolve())
    except ValueError as exc:
        raise ValueError(f"destination escapes output: {target_name}") from exc
    target.parent.mkdir(parents=True, exist_ok=True)
    if source.is_dir():
        def ignore(directory: str, names: list[str]) -> set[str]:
            directory_path = Path(directory).resolve()
            ignored = set(shutil.ignore_patterns("build", "__pycache__", "*.pyc")(directory, names))
            ignored.update(
                name
                for name in names
                if is_excluded(root.resolve(), directory_path / name, excludes)
            )
            return ignored

        shutil.copytree(source, target, dirs_exist_ok=True, ignore=ignore)
    else:
        shutil.copy2(source, target)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    root = args.root.resolve()
    manifest = json.loads((root / "dev" / "user-kit.json").read_text(encoding="utf-8"))
    excludes = []
    for item in manifest.get("exclude", []):
        exclude_path = (root / item).resolve()
        try:
            exclude_path.relative_to(root)
        except ValueError as exc:
            parser.error(f"exclude path escapes root: {item}")
        excludes.append(exclude_path.relative_to(root))
    output = args.output.resolve()
    build_root = (root / "build").resolve()
    if output == build_root or build_root not in output.parents:
        parser.error("output must be below build/")
    shutil.rmtree(output, ignore_errors=True)
    output.mkdir(parents=True)
    try:
        for name in manifest["files"]:
            copy_checked(root, output, name, excludes)
        for name in manifest["trees"]:
            copy_checked(root, output, name, excludes)
        for override in manifest.get("overrides", []):
            copy_checked(
                root,
                output,
                override["source"],
                excludes,
                override["destination"],
            )
    except (KeyError, FileNotFoundError, ValueError, OSError) as exc:
        parser.error(str(exc))
    print(f"exported user kit to {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
