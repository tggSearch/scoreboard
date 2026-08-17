#!/usr/bin/env python3
"""Force Runner target signing to match profile for a bundle id."""
import re
import sys
from pathlib import Path

path, profile, bundle_id, team_id = sys.argv[1:5]
text = Path(path).read_text()
prof_lit = profile if re.fullmatch(r"[A-Za-z0-9_.-]+", profile) else f'"{profile}"'


def patch_block(block: str) -> str:
    if f"PRODUCT_BUNDLE_IDENTIFIER = {bundle_id};" not in block:
        return block
    block = re.sub(r"CODE_SIGN_STYLE = Automatic;", "CODE_SIGN_STYLE = Manual;", block)
    if "CODE_SIGN_STYLE =" not in block:
        block = block.replace(
            "buildSettings = {\n",
            "buildSettings = {\n\t\t\t\tCODE_SIGN_STYLE = Manual;\n",
            1,
        )
    if '"CODE_SIGN_IDENTITY[sdk=iphoneos*]"' in block:
        block = re.sub(
            r'"CODE_SIGN_IDENTITY\[sdk=iphoneos\*\]" = "[^"]*";',
            '"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Distribution";',
            block,
        )
    else:
        block = block.replace(
            "CODE_SIGN_STYLE = Manual;\n",
            'CODE_SIGN_STYLE = Manual;\n\t\t\t\t"CODE_SIGN_IDENTITY[sdk=iphoneos*]" = "iPhone Distribution";\n',
            1,
        )
    block = re.sub(r"DEVELOPMENT_TEAM = [^;]+;", f"DEVELOPMENT_TEAM = {team_id};", block)
    if '"DEVELOPMENT_TEAM[sdk=iphoneos*]"' in block:
        block = re.sub(
            r'"DEVELOPMENT_TEAM\[sdk=iphoneos\*\]" = [^;]+;',
            f'"DEVELOPMENT_TEAM[sdk=iphoneos*]" = {team_id};',
            block,
        )
    else:
        block = block.replace(
            f"DEVELOPMENT_TEAM = {team_id};\n",
            f'DEVELOPMENT_TEAM = {team_id};\n\t\t\t\t"DEVELOPMENT_TEAM[sdk=iphoneos*]" = {team_id};\n',
            1,
        )
    if '"PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]"' in block:
        block = re.sub(
            r'"PROVISIONING_PROFILE_SPECIFIER\[sdk=iphoneos\*\]" = [^;]+;',
            f'"PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]" = {prof_lit};',
            block,
        )
    else:
        block = block.replace(
            "CODE_SIGN_STYLE = Manual;\n",
            f'CODE_SIGN_STYLE = Manual;\n\t\t\t\t"PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]" = {prof_lit};\n',
            1,
        )
    if "PROVISIONING_PROFILE_SPECIFIER =" in block:
        block = re.sub(
            r"(?<!\[sdk=iphoneos\*\])PROVISIONING_PROFILE_SPECIFIER = [^;]+;",
            'PROVISIONING_PROFILE_SPECIFIER = "";',
            block,
        )
        # simpler: blank non-sdk line if present
        block = re.sub(
            r"\t\t\t\tPROVISIONING_PROFILE_SPECIFIER = [^;]+;",
            '\t\t\t\tPROVISIONING_PROFILE_SPECIFIER = "";',
            block,
        )
    return block


parts, last, changed = [], 0, 0
for m in re.finditer(r"(\w+ /\* \w+ \*/ = \{.*?name = \w+;\n\t\t\};)", text, re.S):
    block = m.group(1)
    if f"PRODUCT_BUNDLE_IDENTIFIER = {bundle_id};" in block:
        nb = patch_block(block)
        if nb != block:
            changed += 1
        block = nb
    parts.append(text[last : m.start()])
    parts.append(block)
    last = m.end()
parts.append(text[last:])
Path(path).write_text("".join(parts))
print(f"updated-blocks={changed}")
