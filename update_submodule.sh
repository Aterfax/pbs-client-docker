#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Function to check if a command exists
command_exists() { 
    command -v "$1" >/dev/null 2>&1
}

# Verify dependencies
for cmd in git gh; do
    if ! command_exists "$cmd"; then
        echo "Error: $cmd not found."
        exit 1
    fi
done

# Validate context
ROOT_DIR=$(git rev-parse --show-toplevel 2>/dev/null) || { 
    echo "Not a git repo."
    exit 1
}
cd "$ROOT_DIR" || exit

SUBMODULE="proxmox-backup-arm64"
BRANCH="update/$SUBMODULE-$(date +%Y%m%d)"

# Prepare and update
git checkout -b "$BRANCH" || { 
    echo "Branch exists. Skipping."
    exit 0
}

git submodule update --remote "$SUBMODULE" || exit 1

# Commit and push if changes exist
if [ -n "$(git status --porcelain "$SUBMODULE")" ]; then
    git add "$SUBMODULE"
    git commit -m "chore: update $SUBMODULE to latest"
    
    # Configure git user for GitHub Actions
    git config --global user.name "github-actions[bot]"
    git config --global user.email "github-actions[bot]@users.noreply.github.com"
    
    git push -u origin "$BRANCH"
    
    # Create PR using GitHub CLI
    gh pr create --title "Update $SUBMODULE" --body "Automated update of $SUBMODULE." || echo "PR creation failed."
else
    echo "No updates required."
fi