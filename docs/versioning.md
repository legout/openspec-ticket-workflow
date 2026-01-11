# Versioning and Releases

This document describes the versioning scheme, release process, and how version pinning works in os-tk.

---

## Versioning Scheme

os-tk uses **Semantic Versioning (SemVer)**:

```
MAJOR.MINOR.PATCH
```

| Part | When to bump |
|------|--------------|
| **MAJOR** | Breaking changes (config schema, command behavior, workflow incompatibilities) |
| **MINOR** | New features (new commands, new config options, backward-compatible) |
| **PATCH** | Bug fixes, documentation, minor improvements |

### Version storage

- **`VERSION` file:** Canonical source of truth, contains `0.1.0` (no `v` prefix)
- **Git tags:** Use `v` prefix, e.g., `v0.1.0`
- **GitHub Releases:** Match tags, e.g., `v0.1.0`
- **Embedded versions:** `os-tk` and `install.sh` contain `VERSION="0.1.0"`

---

## Release Process

### Prerequisites

1. Install GitHub CLI: `brew install gh` (or see [cli.github.com](https://cli.github.com))
2. Authenticate: `gh auth login`
3. Ensure you're on `main` with a clean working tree

### Using `release.sh`

The `release.sh` script automates the entire release:

```bash
# Release a specific version
./release.sh 0.2.0

# Or use auto-bump helpers
./release.sh --patch    # 0.1.0 -> 0.1.1
./release.sh --minor    # 0.1.0 -> 0.2.0
./release.sh --major    # 0.1.0 -> 1.0.0

# Preview without making changes
./release.sh --dry-run 0.2.0
```

### What `release.sh` does

1. Updates `VERSION` file
2. Updates embedded `VERSION="..."` in `os-tk` and `install.sh`
3. Updates version references in `README.md` (install URLs)
4. Commits: `chore(release): X.Y.Z`
5. Creates annotated tag: `vX.Y.Z`
6. Pushes to origin (main + tag)
7. Creates GitHub Release with auto-generated notes

### Manual release (without script)

If you prefer manual control:

```bash
# 1. Update versions
echo "0.2.0" > VERSION
# Edit os-tk: VERSION="0.2.0"
# Edit install.sh: VERSION="0.2.0"
# Update README.md install URLs

# 2. Commit
git add VERSION os-tk install.sh README.md
git commit -m "chore(release): 0.2.0"

# 3. Tag
git tag -a v0.2.0 -m "v0.2.0"

# 4. Push
git push origin main
git push origin v0.2.0

# 5. Create release
gh release create v0.2.0 --title "v0.2.0" --generate-notes
```

---

## Version Pinning

### In `.os-tk/config.json`

Projects pin their template version via `templateRef`:

```json
{
  "templateRepo": "legout/openspec-ticket-opencode-starter",
  "templateRef": "v0.1.0"
}
```

| Value | Behavior |
|-------|----------|
| `"v0.1.0"` | Pin to exact version (reproducible) |
| `"v1.2.3"` | Pin to any valid tag |
| `"latest"` | Resolve to newest GitHub Release at sync time |
| `"main"` | Track main branch (not recommended for production) |

### Resolving `"latest"`

When `templateRef` is `"latest"`, `os-tk sync` resolves it at runtime:

1. Fetches `https://github.com/<repo>/releases/latest`
2. Follows redirect to get the actual tag (e.g., `v0.2.0`)
3. Downloads from that tag
4. Prints the resolved version

The config file is **not** updated automatically. To lock to the resolved version, manually edit `templateRef`.

### Install pinning

The install script pins to the tag it was fetched from:

```bash
# Install from v0.1.0 (creates config with templateRef: "v0.1.0")
curl -fsSL .../v0.1.0/install.sh | bash
```

---

## Updating Projects

To update a project to a newer os-tk version:

```bash
# 1. Edit config
# Change templateRef from "v0.1.0" to "v0.2.0" (or "latest")

# 2. Sync
os-tk sync

# 3. Review and commit
git diff
git add .os-tk .opencode AGENTS.md
git commit -m "chore: update os-tk to v0.2.0"
```

---

## Breaking Changes

When releasing a breaking change (MAJOR bump):

1. Document the breaking change clearly in the release notes
2. Provide migration instructions
3. Consider supporting the old behavior behind a flag for one minor release

Examples of breaking changes:
- Renaming config keys
- Changing command behavior
- Removing commands
- Changing file paths (e.g., `.os-tk/config.json` location)

---

## Release Checklist

Before releasing:

- [ ] All tests pass (if applicable)
- [ ] README is up to date
- [ ] Breaking changes are documented
- [ ] You're on `main` with a clean working tree
- [ ] `gh auth status` shows you're authenticated

After releasing:

- [ ] Verify release on GitHub: `gh release view vX.Y.Z --web`
- [ ] Test install from new tag: `curl -fsSL .../vX.Y.Z/install.sh | bash`
- [ ] Announce if appropriate

---

## Changelog

os-tk uses GitHub's auto-generated release notes (`gh release create --generate-notes`).

For best results:
- Use clear PR titles (they become changelog entries)
- Use conventional commit prefixes: `feat:`, `fix:`, `docs:`, `chore:`
- Label PRs if you want category grouping (`feature`, `bug`, `breaking`)

GitHub automatically categorizes based on:
- PR titles
- Labels
- Contributor type (new contributors get highlighted)
