# Testing Patterns

**Analysis Date:** 2026-05-26

## Test Framework

**Runner:**
- `bun:test` (Bun's built-in test runner) — used in the single existing test file
- Config: none — no `bunfig.toml`, `jest.config.*`, or `vitest.config.*` in the repo
- Bun lockfile present at `opencode/bun.lock`

**Assertion Library:**
- Built-in `expect` from `bun:test` (Jest-compatible API: `.toBe`, `.toEqual`, `.not.toBe`)

**Run Commands:**
```bash
# No package.json script defined — run directly via Bun:
bun test opencode/skills/codemap/scripts/codemap.test.ts

# Or run the whole skill directory:
cd opencode/skills/codemap/scripts && bun test
```

There is no `make test` target in `nix/Makefile` and no `scripts.test` field in `opencode/package.json` (`{"type":"commonjs"}` only).

## Nix Validation (in lieu of formal tests)

This repo treats `nix build` / `darwin-rebuild` / `nixos-rebuild` as the primary validation step. Test commands per `CLAUDE.md`:

```bash
# Dry-run NixOS host
sudo nixos-rebuild dry-run --flake .#kirby

# Dry-run Darwin host
darwin-rebuild dry-run --flake .#Sterling-MBP

# Lint Nix files (statix)
make lint

# Format check (treefmt / nixfmt)
make format

# Run all pre-commit hooks
pre-commit run --all-files
```

Pre-commit hooks defined in `nix/.pre-commit-config.yaml` act as the closest equivalent to a CI test suite — `nixfmt-tree`, `statix-check`, `trailing-whitespace`, `end-of-file-fixer`, `check-yaml`, `check-json`.

## Test File Organization

**Location:**
- Co-located with implementation in the same directory
- Only one example exists: `opencode/skills/codemap/scripts/codemap.test.ts` next to `codemap.mjs`

**Naming:**
- `<module>.test.ts` — test files use `.test.ts` extension even when testing `.mjs` source

**Structure:**
```
opencode/skills/codemap/scripts/
├── codemap.mjs          # implementation (ESM)
└── codemap.test.ts      # tests (Bun test, dynamic-imports the .mjs)
```

## Test Structure

**Suite Organization** (from `opencode/skills/codemap/scripts/codemap.test.ts`):
```typescript
import { afterEach, describe, expect, mock, test } from 'bun:test';

mock.restore();  // top-level mock reset before dynamic import

const { computeFileHash, computeFolderHash, loadState, PatternMatcher, selectFiles } =
  await import('./codemap.mjs');

describe('PatternMatcher', () => {
  test('matches expected paths', () => {
    const matcher = new PatternMatcher(['node_modules/', 'dist/', '*.log']);
    expect(matcher.matches('node_modules/foo.js')).toBe(true);
    expect(matcher.matches('README.md')).toBe(false);
  });
});
```

**Patterns:**
- One `describe` block per exported symbol or feature area (`PatternMatcher`, `hash helpers`, `selectFiles`, `loadState`)
- Test names are full sentences describing behavior (`'matches expected paths'`, `'computes stable folder hash'`, `'migrates legacy cartography state'`)
- Top-level `mock.restore()` runs before module import to ensure a clean state
- Dynamic `await import('./codemap.mjs')` is used instead of static `import` (because the source is `.mjs` and tested by Bun's TS runner)

**Setup pattern:**
- A module-scoped `tempDirs: string[] = []` array tracks created temp directories
- A `createTempDir()` helper wraps `mkdtempSync(path.join(os.tmpdir(), 'codemap-'))` and pushes onto the array

**Teardown pattern:**
```typescript
afterEach(() => {
  for (const dir of tempDirs.splice(0)) {
    rmSync(dir, { force: true, recursive: true });
  }
});
```
- `afterEach` (not `afterAll`) ensures isolation between tests
- `splice(0)` empties the array atomically while iterating

**Assertion patterns:**
- `expect(value).toBe(literal)` for primitives
- `expect(value).toEqual(object)` for deep equality
- `expect(value).not.toBe(other)` for negation
- Hash determinism asserted by computing twice and checking `toBe`

## Mocking

**Framework:** `mock` import from `bun:test`

**Patterns:**
- `mock.restore()` is called once at the top of the file before dynamic import — a defensive reset rather than active mocking
- No `mock.module()` or `mock.fn()` usage observed
- Real filesystem operations against tempdirs are preferred over mocked `fs`

**What to Mock:**
- Currently nothing — tests exercise real filesystem in isolated tempdirs

**What NOT to Mock:**
- Filesystem APIs — use `mkdtempSync` + cleanup instead
- Hash functions — deterministic by design, asserted directly

## Fixtures and Factories

**Test Data:**
- Inline literals — no shared fixture files
- Example from `opencode/skills/codemap/scripts/codemap.test.ts`:

```typescript
const fileHashes = {
  'src/a.ts': 'hash-a',
  'src/b.ts': 'hash-b',
  'tests/test.ts': 'hash-test',
};
```

- Temp directory creation is the only factory-like pattern:
```typescript
function createTempDir() {
  const dir = mkdtempSync(path.join(os.tmpdir(), 'codemap-'));
  tempDirs.push(dir);
  return dir;
}
```

**Location:**
- No `fixtures/`, `__fixtures__/`, or `testdata/` directories exist
- All test data inlined per-test

## Coverage

**Requirements:** None enforced — no coverage tool configured, no thresholds defined.

**View Coverage:**
```bash
# Bun has built-in coverage:
bun test --coverage opencode/skills/codemap/scripts/codemap.test.ts
```

## Test Types

**Unit Tests:**
- Scope: individual exported functions/classes from `codemap.mjs`
- Approach: pure-function assertions where possible (hash determinism); tempdir-backed integration for IO functions

**Integration Tests:**
- Effectively the same file — `selectFiles` and `loadState` tests touch real filesystem via tempdirs
- No separation between unit and integration test directories

**E2E Tests:**
- Not used

**Nix Build "Tests":**
- `darwin-rebuild dry-run --flake .#Sterling-MBP` validates Darwin host
- `nixos-rebuild dry-run --flake .#kirby` validates NixOS host
- `nix flake check` (not in Makefile) can validate flake outputs
- `nix eval .#nixosConfigurations.kirby.config.system.build.toplevel` per `CLAUDE.md`

**Lua/Neovim:**
- No Plenary/Busted test framework configured
- LazyVim's `lazyvim.plugins.extras.test.core` extra is enabled in `nvim/lazyvim.json` but no project-specific tests live in this repo

**Shell/JS hooks:**
- No test coverage for `opencode/hooks/*.js` scripts
- No tests for sketchybar Lua configuration

## Common Patterns

**Async Testing:**
- All current tests are synchronous
- Test file uses top-level `await import(...)` for dynamic module loading (supported by Bun's ESM-aware runner)

**Error Testing:**
- No `expect().toThrow()` patterns currently present
- Error paths exercised indirectly by feeding empty/missing inputs and asserting safe defaults (e.g., `computeFileHash` returns `''` on read failure in `codemap.mjs`)

**Filesystem Testing:**
- Always allocate a fresh tempdir per test
- Build the directory tree explicitly with `mkdirSync` + `writeFileSync`
- Compute results, then assert on relative paths normalized via `path.relative(root, file).split(path.sep).join('/')` for cross-platform stability

**Cross-platform path normalization:**
```typescript
const selected = selectFiles(root, [...], [...], [], [])
  .map((filePath) => path.relative(root, filePath).split(path.sep).join('/'));
```

## Gaps & Recommendations

- The repo has effectively one test file. New code in `opencode/hooks/`, `opencode/skills/clonedeps/`, and `opencode/skills/simplify/` is untested.
- Nix configurations rely on `darwin-rebuild`/`nixos-rebuild` for validation rather than `nix flake check`. Consider adding `nix flake check` to the Makefile for faster pre-flight validation.
- No CI configuration committed — testing/linting depends on the developer running `pre-commit` locally.
- Neovim plugin specs (`nvim/lua/plugins/*.lua`) and sketchybar Lua (`sketchybar/items/*.lua`) have no automated validation; rely on runtime errors.

---

*Testing analysis: 2026-05-26*
