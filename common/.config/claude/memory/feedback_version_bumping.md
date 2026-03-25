---
name: Auto-bump version on commits
description: Bump package version in the same commit when conventional commit type warrants it
type: feedback
---

When committing with conventional-commits, bump the package version in the same commit if the change type warrants it.

**Rules (pre-1.0 semver, i.e. `0.x.y`):**
- `fix:` or `feat:` → bump patch (0.x.Y)
- `feat!:` or `BREAKING CHANGE` → bump minor (0.X.0)
- `chore:`, `docs:`, `ci:`, `refactor:`, `test:`, `style:`, `perf:`, `build:` → no bump

**Rules (post-1.0 semver, i.e. `>=1.0.0`):**
- `fix:` → bump patch (x.y.Z)
- `feat:` → bump minor (x.Y.0)
- `feat!:` or `BREAKING CHANGE` → bump major (X.0.0)
- `chore:`, `docs:`, `ci:`, `refactor:`, `test:`, `style:`, `perf:`, `build:` → no bump

**How to apply:**
1. Before committing, determine the conventional commit type.
2. If it warrants a version bump, find the version file for the project's language and bump it.
3. Include the version file change in the same commit.

**Version file locations by language:**
- Rust: `Cargo.toml` (`version = "x.y.z"`) — also run `cargo check` to update `Cargo.lock` if it exists
- Python: `pyproject.toml` or `setup.cfg` or `__version__` in package `__init__.py`
- JavaScript/TypeScript: `package.json` (`"version": "x.y.z"`)
- Go: version tag only (no file to bump, note in commit message)
- Ruby: `*.gemspec` or `lib/**/version.rb`
- Java/Kotlin: `build.gradle(.kts)` or `pom.xml`
- Elixir: `mix.exs`
- If unsure, search for a version string in common config files.
