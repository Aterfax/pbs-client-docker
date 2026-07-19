#!/bin/bash

command_exists() { command -v "$1" >/dev/null 2>&1; }

# Verify dependencies
for cmd in git gh; do
    command_exists "$cmd" || { echo "Error: $cmd not found."; exit 1; }
done

# Validate context
ROOT_DIR=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "Not a git repo."; exit 1; }
cd "$ROOT_DIR" || exit

SUBMODULE="proxmox-backup-arm64"
BRANCH="update/$SUBMODULE-$(date +%Y%m%d)"

# Prepare and update
git checkout -b "$BRANCH" || { echo "Branch exists."; exit 1; }
git submodule update --remote "$SUBMODULE" || exit 1

# Commit and push if changes exist
if [ -n "$(git status --porcelain "$SUBMODULE")" ]; then
    git add "$SUBMODULE"
    git commit -m "chore: update $SUBMODULE to latest"
    git push -u origin "$BRANCH"
    
    gh pr create --title "Update $SUBMODULE" --body "Automated update of $SUBMODULE." || echo "PR creation failed."
else
    echo "No updates detected."
fi