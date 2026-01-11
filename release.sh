#!/usr/bin/env bash
# release.sh — Bump version, tag, push, and create GitHub Release
#
# Usage:
#   ./release.sh <new-version>       # e.g., ./release.sh 0.2.0
#   ./release.sh --patch             # Bump patch: 0.1.0 -> 0.1.1
#   ./release.sh --minor             # Bump minor: 0.1.0 -> 0.2.0
#   ./release.sh --major             # Bump major: 0.1.0 -> 1.0.0
#   ./release.sh --dry-run <version> # Show what would happen
#
# Requires: git, gh (GitHub CLI, authenticated)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_ROOT"

# =============================================================================
# HELPERS
# =============================================================================
usage() {
  cat << EOF
Usage: ./release.sh <new-version>
       ./release.sh --patch | --minor | --major
       ./release.sh --dry-run <version>

Examples:
  ./release.sh 0.2.0          # Release version 0.2.0
  ./release.sh --patch        # Bump 0.1.0 -> 0.1.1
  ./release.sh --minor        # Bump 0.1.0 -> 0.2.0
  ./release.sh --major        # Bump 0.1.0 -> 1.0.0
  ./release.sh --dry-run 0.2.0  # Preview without making changes

Options:
  --dry-run    Show what would happen without making changes
  --patch      Auto-bump patch version
  --minor      Auto-bump minor version
  --major      Auto-bump major version
  --help       Show this help

EOF
  exit 0
}

require() {
  command -v "$1" >/dev/null 2>&1 || { echo "Error: Missing required command: $1" >&2; exit 1; }
}

get_current_version() {
  if [[ -f VERSION ]]; then
    cat VERSION | tr -d ' \t\r\n'
  else
    echo "0.0.0"
  fi
}

bump_version() {
  local version="$1"
  local part="$2"
  
  local major minor patch
  IFS='.' read -r major minor patch <<< "$version"
  
  case "$part" in
    major)
      echo "$((major + 1)).0.0"
      ;;
    minor)
      echo "${major}.$((minor + 1)).0"
      ;;
    patch)
      echo "${major}.${minor}.$((patch + 1))"
      ;;
    *)
      echo "$version"
      ;;
  esac
}

# =============================================================================
# PARSE ARGUMENTS
# =============================================================================
DRY_RUN=false
NEW_VERSION=""
BUMP_PART=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h)
      usage
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --patch)
      BUMP_PART="patch"
      shift
      ;;
    --minor)
      BUMP_PART="minor"
      shift
      ;;
    --major)
      BUMP_PART="major"
      shift
      ;;
    *)
      if [[ -z "$NEW_VERSION" ]]; then
        NEW_VERSION="$1"
      else
        echo "Error: Unexpected argument: $1" >&2
        exit 1
      fi
      shift
      ;;
  esac
done

# =============================================================================
# DETERMINE VERSION
# =============================================================================
CURRENT_VERSION="$(get_current_version)"

if [[ -n "$BUMP_PART" ]]; then
  NEW_VERSION="$(bump_version "$CURRENT_VERSION" "$BUMP_PART")"
fi

if [[ -z "$NEW_VERSION" ]]; then
  echo "Error: No version specified."
  echo ""
  usage
fi

# Validate version format
if ! [[ "$NEW_VERSION" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Error: Invalid version format: $NEW_VERSION (expected X.Y.Z)" >&2
  exit 1
fi

TAG="v$NEW_VERSION"

# =============================================================================
# PRE-FLIGHT CHECKS
# =============================================================================
require git
require gh
require perl

echo "Release: $CURRENT_VERSION -> $NEW_VERSION (tag: $TAG)"
echo ""

if $DRY_RUN; then
  echo "[DRY-RUN MODE]"
  echo ""
fi

# Check gh auth
if ! gh auth status >/dev/null 2>&1; then
  echo "Error: GitHub CLI not authenticated. Run: gh auth login" >&2
  exit 1
fi

# Check we're in a git repo
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "Error: Not in a git repository" >&2
  exit 1
}

# Check we're on main
BRANCH="$(git branch --show-current)"
if [[ "$BRANCH" != "main" ]]; then
  echo "Error: Not on main branch (currently on: $BRANCH)" >&2
  exit 1
fi

# Check working tree is clean
if [[ -n "$(git status --porcelain)" ]]; then
  echo "Error: Working tree is not clean. Commit or stash changes first." >&2
  git status --short
  exit 1
fi

# Check tag doesn't already exist
if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "Error: Tag already exists: $TAG" >&2
  exit 1
fi

# =============================================================================
# EXECUTE RELEASE
# =============================================================================
echo "Steps:"
echo "  1. Update VERSION file"
echo "  2. Update embedded version in os-tk"
echo "  3. Update embedded version in install.sh"
echo "  4. Update version references in README.md"
echo "  5. Commit changes"
echo "  6. Create tag: $TAG"
echo "  7. Push to origin"
echo "  8. Create GitHub Release with generated notes"
echo ""

if $DRY_RUN; then
  echo "[DRY-RUN] Would update VERSION to: $NEW_VERSION"
  echo "[DRY-RUN] Would update os-tk VERSION=\"$NEW_VERSION\""
  echo "[DRY-RUN] Would update install.sh VERSION=\"$NEW_VERSION\""
  echo "[DRY-RUN] Would update README.md version references"
  echo "[DRY-RUN] Would commit: chore(release): $NEW_VERSION"
  echo "[DRY-RUN] Would tag: $TAG"
  echo "[DRY-RUN] Would push: origin main + $TAG"
  echo "[DRY-RUN] Would run: gh release create $TAG --title \"$TAG\" --generate-notes"
  echo ""
  echo "Done (dry-run, no changes made)."
  exit 0
fi

# Confirm
read -p "Proceed with release $TAG? [y/N] " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 1
fi

echo ""
echo "Releasing $TAG..."

# 1. Update VERSION file
printf "%s\n" "$NEW_VERSION" > VERSION
echo "  [ok] VERSION -> $NEW_VERSION"

# 2. Update embedded VERSION in os-tk
perl -i -pe "s/^VERSION=\"[0-9]+\\.[0-9]+\\.[0-9]+\"/VERSION=\"$NEW_VERSION\"/" os-tk
echo "  [ok] os-tk VERSION -> $NEW_VERSION"

# 3. Update embedded VERSION in install.sh
perl -i -pe "s/^VERSION=\"[0-9]+\\.[0-9]+\\.[0-9]+\"/VERSION=\"$NEW_VERSION\"/" install.sh
echo "  [ok] install.sh VERSION -> $NEW_VERSION"

# 4. Update README.md version references (install URLs)
perl -i -pe "s@/v[0-9]+\\.[0-9]+\\.[0-9]+/@/v$NEW_VERSION/@g" README.md
echo "  [ok] README.md version references -> v$NEW_VERSION"

# Verify replacements
grep -q "^VERSION=\"$NEW_VERSION\"$" os-tk || { echo "Error: Failed to update os-tk" >&2; exit 1; }
grep -q "^VERSION=\"$NEW_VERSION\"$" install.sh || { echo "Error: Failed to update install.sh" >&2; exit 1; }
grep -q "^$NEW_VERSION$" VERSION || { echo "Error: Failed to update VERSION" >&2; exit 1; }

# 5. Commit
git add VERSION os-tk install.sh README.md
git commit -m "chore(release): $NEW_VERSION"
echo "  [ok] Committed: chore(release): $NEW_VERSION"

# 6. Tag
git tag -a "$TAG" -m "$TAG"
echo "  [ok] Tagged: $TAG"

# 7. Push
git push origin main
git push origin "$TAG"
echo "  [ok] Pushed to origin"

# 8. Create GitHub Release
gh release create "$TAG" --title "$TAG" --generate-notes
echo "  [ok] Created GitHub Release: $TAG"

echo ""
echo "Done! Released $TAG"
echo ""
echo "View release: gh release view $TAG --web"
