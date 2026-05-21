#!/usr/bin/env python3
"""
Convert svg-to-swiftui Path output into AnimatedFolderIcon command arrays.
Paste one shape to print one array, or paste two shapes to print a normalized
closed/open pair. Two shapes can be separated by a comment such as:
// --- open ---

Usage:
  pbpaste | script/convert_swiftui_path_to_folder_commands.py
  script/convert_swiftui_path_to_folder_commands.py < ConvertedShape.swift
"""

from __future__ import annotations

import re
import subprocess
import sys


POINT = (
    r"CGPoint\(\s*x:\s*"
    r"(?P<x>[+-]?(?:\d+(?:\.\d*)?|\.\d+))\s*\*\s*width\s*,\s*y:\s*"
    r"(?P<y>[+-]?(?:\d+(?:\.\d*)?|\.\d+))\s*\*\s*height\s*\)"
)

MOVE_RE = re.compile(rf"\.move\(to:\s*{POINT}\s*\)")
LINE_RE = re.compile(rf"\.addLine\(to:\s*{POINT}\s*\)")
CURVE_RE = re.compile(
    rf"\.addCurve\(to:\s*{POINT}\s*,\s*"
    rf"control1:\s*{POINT.replace('(?P<x>', '(?P<c1x>').replace('(?P<y>', '(?P<c1y>')}\s*,\s*"
    rf"control2:\s*{POINT.replace('(?P<x>', '(?P<c2x>').replace('(?P<y>', '(?P<c2y>')}\s*\)"
)
LINE_WIDTH_RE = re.compile(r"lineWidth:\s*([+-]?(?:\d+(?:\.\d*)?|\.\d+))\s*\*\s*width")

Command = tuple[str, dict[str, str]]


def main() -> int:
    source = sys.stdin.read()

    if not source.strip():
        source = read_clipboard()

    if not source.strip():
        print("No input. Pipe converted SwiftUI path code into this script.", file=sys.stderr)
        return 1

    parts = split_sources(source)

    if match := LINE_WIDTH_RE.search(source):
        print(f"// lineWidthRatio: {format_number(match.group(1))}")

    if len(parts) == 1:
        commands = parse_commands(parts[0])
        if not commands:
            print("No supported path commands found.", file=sys.stderr)
            return 1

        print_array(commands)
        print_summary(command_kinds(commands))
        return 0

    closed = parse_commands(parts[0])
    open_ = parse_commands(parts[1])

    if not closed or not open_:
        print("Could not parse commands from one or both shapes.", file=sys.stderr)
        return 1

    normalized = normalize_line_curve_mismatches(closed, open_)
    if normalized is None:
        return 1

    closed, open_, notes = normalized
    for note in notes:
        print(note)

    print_property("closedCommands", closed)
    print_property("openCommands", open_)
    print_pair_summary(closed, open_)
    return 0


def parse_commands(source: str) -> list[Command]:
    commands: list[Command] = []

    for raw_line in source.splitlines():
        line = raw_line.strip()

        if match := MOVE_RE.search(line):
            commands.append(("move", {"x": match["x"], "y": match["y"]}))
        elif match := LINE_RE.search(line):
            commands.append(("line", {"x": match["x"], "y": match["y"]}))
        elif match := CURVE_RE.search(line):
            commands.append((
                "curve",
                {
                    "x": match["x"],
                    "y": match["y"],
                    "c1x": match["c1x"],
                    "c1y": match["c1y"],
                    "c2x": match["c2x"],
                    "c2y": match["c2y"],
                },
            ))
        elif ".closeSubpath()" in line:
            commands.append(("close", {}))

    return commands


def split_sources(source: str) -> list[str]:
    marker_split = re.split(r"\n\s*//\s*[-=]{3,}.*\n", source, maxsplit=1)
    if len(marker_split) == 2:
        return marker_split

    path_matches = list(re.finditer(r"\bfunc\s+path\s*\(\s*in\s+rect", source))
    if len(path_matches) >= 2:
        return [source[:path_matches[1].start()], source[path_matches[1].start():]]

    blank_split = re.split(r"\n\s*\n", source, maxsplit=1)
    if len(blank_split) == 2 and parse_commands(blank_split[0]) and parse_commands(blank_split[1]):
        return blank_split

    return [source]


def normalize_line_curve_mismatches(
    closed: list[Command],
    open_: list[Command],
) -> tuple[list[Command], list[Command], list[str]] | None:
    if len(closed) != len(open_):
        print(
            f"Command count mismatch. closed: {len(closed)}, open: {len(open_)}. "
            "Fix the Figma paths so both exports have the same number of commands.",
            file=sys.stderr,
        )
        return None

    normalized_closed: list[Command] = []
    normalized_open: list[Command] = []
    notes: list[str] = []

    for index, (closed_command, open_command) in enumerate(zip(closed, open_)):
        closed_kind = closed_command[0]
        open_kind = open_command[0]

        if closed_kind == open_kind:
            normalized_closed.append(closed_command)
            normalized_open.append(open_command)
            continue

        if closed_kind == "line" and open_kind == "curve":
            normalized_closed.append(line_to_degenerate_curve(previous_command(normalized_closed), closed_command))
            normalized_open.append(open_command)
            notes.append(f"// normalized: promoted closed[{index}] line -> degenerate curve")
            continue

        if closed_kind == "curve" and open_kind == "line":
            normalized_closed.append(closed_command)
            normalized_open.append(line_to_degenerate_curve(previous_command(normalized_open), open_command))
            notes.append(f"// normalized: promoted open[{index}] line -> degenerate curve")
            continue

        print(
            f"Command type mismatch at index {index}: closed is {closed_kind}, open is {open_kind}. "
            "Only line <-> curve mismatches can be normalized automatically.",
            file=sys.stderr,
        )
        return None

    return normalized_closed, normalized_open, notes


def previous_command(commands: list[Command]) -> Command | None:
    return commands[-1] if commands else None


def line_to_degenerate_curve(previous: Command | None, line: Command) -> Command:
    _, line_payload = line
    start = command_destination(previous) if previous is not None else line_payload
    return (
        "curve",
        {
            "x": line_payload["x"],
            "y": line_payload["y"],
            "c1x": start["x"],
            "c1y": start["y"],
            "c2x": line_payload["x"],
            "c2y": line_payload["y"],
        },
    )


def command_destination(command: Command | None) -> dict[str, str]:
    if command is None:
        return {"x": "0", "y": "0"}

    kind, payload = command
    if kind in {"move", "line", "curve"}:
        return {"x": payload["x"], "y": payload["y"]}

    return {"x": "0", "y": "0"}


def print_array(commands: list[Command]) -> None:
    print("[")
    for index, command in enumerate(commands):
        suffix = "," if index < len(commands) - 1 else ""
        print(command_to_swift(command, suffix))
    print("]")


def print_property(name: str, commands: list[Command]) -> None:
    print(f"nonisolated static var {name}: [FolderPathCommand] {{")
    print_array(commands)
    print("}")
    print()


def command_to_swift(command: Command, suffix: str) -> str:
    kind, payload = command

    if kind == "move":
        body = f".move(.init(x: {format_number(payload['x'])}, y: {format_number(payload['y'])}))"
    elif kind == "line":
        body = f".line(.init(x: {format_number(payload['x'])}, y: {format_number(payload['y'])}))"
    elif kind == "curve":
        body = "\n".join([
            ".curve(",
            f"    to: .init(x: {format_number(payload['x'])}, y: {format_number(payload['y'])}),",
            f"    control1: .init(x: {format_number(payload['c1x'])}, y: {format_number(payload['c1y'])}),",
            f"    control2: .init(x: {format_number(payload['c2x'])}, y: {format_number(payload['c2y'])})",
            ")",
        ])
    else:
        body = ".close"

    return indent_command(body, suffix)


def read_clipboard() -> str:
    try:
        return subprocess.check_output(["pbpaste"], text=True)
    except (FileNotFoundError, subprocess.CalledProcessError):
        return ""


def format_number(raw: str) -> str:
    value = float(raw)
    return f"{value:.5f}"


def indent_command(command: str, suffix: str) -> str:
    lines = command.splitlines()
    lines[-1] = f"{lines[-1]}{suffix}"
    return "\n".join(f"    {line}" for line in lines)


def command_kinds(commands: list[Command]) -> list[str]:
    return [kind for kind, _ in commands]


def print_summary(command_kinds: list[str]) -> None:
    signature = ", ".join(command_kinds)
    print()
    print("// Summary")
    print(f"// commandCount: {len(command_kinds)}")
    print(f"// commandSignature: {signature}")
    print("// The other keyframe must have this exact command count and commandSignature.")


def print_pair_summary(closed: list[Command], open_: list[Command]) -> None:
    print("// Summary")
    print(f"// closed commandCount: {len(closed)}")
    print(f"// open commandCount: {len(open_)}")
    print(f"// commandSignature: {', '.join(command_kinds(closed))}")
    print("// These arrays are structurally compatible for morphing.")


if __name__ == "__main__":
    raise SystemExit(main())
