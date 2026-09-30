#!/usr/bin/env nix-shell
#!nix-shell -i python3 -p "python3.withPackages(p: [p.pyyaml])"
"""
Validate skill directories: frontmatter, trigger-only description, Overview.

Usage: validate_skill.py <skill_dir>...
       validate_skill.py --repo   (every SKILL.md git tracks under cwd;
                                  claude.ai-synced skills excluded)

Exit 0 = all valid, 10 = some skill invalid. Any other code = the validator
itself failed (nix, python, usage), so callers can tell a verdict from a crash.
"""

import subprocess
import sys
import os
import re
import yaml
from pathlib import Path

# Bodies this short are grasped by reading them; an Overview would only restate them.
OVERVIEW_EXEMPT_LINES = 25

TRIGGER_CUE = re.compile(
    r"use\s+(this\s+skill\s+)?when|triggers?\s+(on|when|:)|when\s+the\s+user|when\s+user|must\s+be\s+used",
    re.IGNORECASE,
)


def validate_skill(skill_path):
    """Basic validation of a skill"""
    skill_path = Path(skill_path)

    # Check SKILL.md exists
    skill_md = skill_path / 'SKILL.md'
    if not skill_md.exists():
        return False, "SKILL.md not found"

    # Read and validate frontmatter
    try:
        content = skill_md.read_text(encoding='utf-8')
    except UnicodeDecodeError as e:
        return False, f"SKILL.md is not UTF-8: {e}"
    if not content.startswith('---'):
        return False, "No YAML frontmatter found"

    # Extract frontmatter
    match = re.match(r'^---\n(.*?)\n---', content, re.DOTALL)
    if not match:
        return False, "Invalid frontmatter format"

    frontmatter_text = match.group(1)

    # Parse YAML frontmatter
    try:
        frontmatter = yaml.safe_load(frontmatter_text)
        if not isinstance(frontmatter, dict):
            return False, "Frontmatter must be a YAML dictionary"
    except yaml.YAMLError as e:
        return False, f"Invalid YAML in frontmatter: {e}"

    # Define allowed properties
    # Agent Skills spec keys plus Claude Code's (https://code.claude.com/docs/en/skills).
    ALLOWED_PROPERTIES = {'name', 'description', 'license', 'allowed-tools', 'metadata', 'compatibility',
                          'argument-hint', 'disable-model-invocation', 'user-invocable', 'context', 'agent', 'model',
                          'when_to_use', 'arguments', 'disallowed-tools', 'effort', 'background', 'hooks',
                          'paths', 'shell'}

    # Check for unexpected properties (excluding nested keys under metadata)
    unexpected_keys = set(frontmatter.keys()) - ALLOWED_PROPERTIES
    if unexpected_keys:
        return False, (
            f"Unexpected key(s) in SKILL.md frontmatter: {', '.join(sorted(map(str, unexpected_keys)))}. "
            f"Allowed properties are: {', '.join(sorted(ALLOWED_PROPERTIES))}"
        )

    # Check required fields
    if 'name' not in frontmatter:
        return False, "Missing 'name' in frontmatter"
    if 'description' not in frontmatter:
        return False, "Missing 'description' in frontmatter"

    # Extract name for validation
    name = frontmatter.get('name', '')
    if not isinstance(name, str):
        return False, f"Name must be a string, got {type(name).__name__}"
    name = name.strip()
    if not name:
        return False, "'name' is empty"
    # Check naming convention (kebab-case: lowercase with hyphens)
    if not re.match(r'^[a-z0-9-]+$', name):
        return False, f"Name '{name}' should be kebab-case (lowercase letters, digits, and hyphens only)"
    if name.startswith('-') or name.endswith('-') or '--' in name:
        return False, f"Name '{name}' cannot start/end with hyphen or contain consecutive hyphens"
    # Check name length (max 64 characters per spec)
    if len(name) > 64:
        return False, f"Name is too long ({len(name)} characters). Maximum is 64 characters."
    # Harness lists the skill by directory, other skills call it by name;
    # a mismatch leaves one of the two pointing at nothing.
    if name != skill_path.resolve().name:
        return False, f"Name '{name}' differs from directory '{skill_path.resolve().name}'"

    # Extract and validate description
    description = frontmatter.get('description', '')
    if not isinstance(description, str):
        return False, f"Description must be a string, got {type(description).__name__}"
    description = description.strip()
    if not description:
        return False, "'description' is empty. It must say WHEN to invoke the skill."
    # Check for angle brackets
    if '<' in description or '>' in description:
        return False, "Description cannot contain angle brackets (< or >)"
    # Check description length (max 1024 characters per spec)
    if len(description) > 1024:
        return False, f"Description is too long ({len(description)} characters). Maximum is 1024 characters."

    # Description carries trigger cues only; it must actually contain one.
    # User-invoked skills are exempt: their description is written for the
    # human browsing slash commands, not for the model's trigger match.
    user_invoked = frontmatter.get('disable-model-invocation') is True
    if not user_invoked and not TRIGGER_CUE.search(description):
        return False, (
            "Description has no trigger cue. It must say WHEN to invoke the skill "
            "(\"Use when ...\", \"Triggers on ...\", \"when the user ...\"), not what the "
            "skill does - that belongs in the body's '## Overview' section."
        )

    # Validate compatibility field if present (optional)
    compatibility = frontmatter.get('compatibility', '')
    if compatibility:
        if not isinstance(compatibility, str):
            return False, f"Compatibility must be a string, got {type(compatibility).__name__}"
        if len(compatibility) > 500:
            return False, f"Compatibility is too long ({len(compatibility)} characters). Maximum is 500 characters."

    # Body checks come last: short bodies return valid early, so a check placed
    # after them would never run for small skills.
    # Body must open with an Overview section - `description` carries no "what",
    # so the body is the only place a reader learns the skill's job. Bodies at or
    # under OVERVIEW_EXEMPT_LINES are read whole in one glance, and an Overview
    # there is a summary as long as the thing it summarises.
    body = content[match.end():]
    headings = re.findall(r'^(#{1,6})\s+(.*)$', body, re.MULTILINE)
    first_section = next((text.strip() for level, text in headings if len(level) >= 2), None)
    body_lines = len(body.strip().splitlines())
    if first_section is None:
        if body_lines > OVERVIEW_EXEMPT_LINES:
            return False, (
                f"Body is {body_lines} lines and has no '## Overview' section. Bodies over "
                f"{OVERVIEW_EXEMPT_LINES} lines must open with one."
            )
        return True, "Skill is valid!"
    if first_section.lower() != 'overview':
        if body_lines <= OVERVIEW_EXEMPT_LINES:
            return True, "Skill is valid!"
        return False, f"Body's first section is '{first_section}'; it must be '## Overview'."
    overview_body = re.split(r'^#{1,6}\s', body.split(first_section, 1)[1], maxsplit=1, flags=re.MULTILINE)[0]
    if not overview_body.strip():
        return False, "'## Overview' section is empty. It must say what the skill does."

    return True, "Skill is valid!"

INVALID = 10


def repo_skill_dirs():
    """Dirs of every SKILL.md git tracks under cwd, synced (third-party) ones excluded."""
    paths = subprocess.run(['git', 'ls-files', '-z', '*SKILL.md'],
                           check=True, capture_output=True, text=True).stdout.split('\0')
    return sorted(os.path.dirname(p) or '.' for p in paths
                  if p and '/skills/synced/' not in f'/{p}')


if __name__ == "__main__":
    args = repo_skill_dirs() if sys.argv[1:] == ['--repo'] else sys.argv[1:]
    if not args:
        print("Usage: validate_skill.py <skill_directory>... | --repo")
        sys.exit(1)

    failed = False
    for arg in args:
        valid, message = validate_skill(arg)
        print(f"{arg}: {message}")
        failed |= not valid
    sys.exit(INVALID if failed else 0)
