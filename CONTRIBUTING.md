# Contributing

Thank you for your interest in contributing! This document outlines the process and standards I follow.

## How to contribute

1. **Fork the repository** and create your branch from `master`.
2. **Make your changes** following the guidelines below.
3. **Test your changes** — See [before submitting](#before-submitting) section below.
4. **Submit a pull request** with a clear description of what changed and why.

## Code standards

### AI agents
Add the [bash skill](https://github.com/petromir/oh-my-ai/tree/master/common/skills/bash) that will ensure high 
standards for bash development are followed.

### Before submitting

```bash
# Check syntax
bash -n android-backup.sh
bash -n export-gdrive.sh

# Run shellcheck (must pass with zero warnings)
shellcheck android-backup.sh export-gdrive.sh

# Run tests
./test-subcommands.sh
```

## Reporting issues

When reporting bugs, please include:

- Your operating system and version
- Bash version (`bash --version`)
- Steps to reproduce the issue
- Expected vs. actual behavior
- Any relevant error messages

## Questions?

Feel free to open an issue for discussion before starting work on a significant change.
