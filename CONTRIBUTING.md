# Contributing

## Dev quickstart

scripts/install.sh --yes
make fmt lint test

## Style & lint

- Bash, formatted with `shfmt -i 2 -ci -sr`.
- `shellcheck` must pass (see `.shellcheckrc`).
- Prefer `set -Eeuo pipefail`, defensive quoting, and small helpers over subshell side effects.

## Tests

- Use **Bats** (`bats-core`) under `tests/`.
- All tests run in temp dirs and must not hit the network.
- For commands that normally use `gh`, tests use a `$PATH` stub and `GAM_SKIP_PUSH=1`.

## Local CI

make lint test

## Conventional commits

Use types like `feat:`, `fix:`, `docs:`, `test:`, `ci:`, `chore:`, `style:` with clear scope.

