# Global agent instructions

## Rust libraries

When editing Rust libraries, ensure the public API follows the Rust API
guidelines checklist:
https://rust-lang.github.io/api-guidelines/checklist.html

## Git

Keep commits atomic: commit only the files you touched and list each path explicitly. For tracked files run `git commit -m "<scoped message>" -- path/to/file1 path/to/file2`. For brand-new files, use the one-liner `git restore --staged :/ && git add "path/to/file1" "path/to/file2" && git commit -m "<scoped message>" -- path/to/file1 path/to/file2`
