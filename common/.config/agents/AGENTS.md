# Global agent instructions

## Commits

Keep commits atomic: commit only the files you touched and list each path
explicitly.

For tracked files, run:

```sh
git commit -m "<scoped message>" -- path/to/file1 path/to/file2
```

For brand-new files, run:

```sh
git restore --staged :/ && git add "path/to/file1" "path/to/file2" && git commit -m "<scoped message>" -- path/to/file1 path/to/file2
```
