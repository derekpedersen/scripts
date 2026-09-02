#!/usr/bin/env bash

# Checkout the main branch and pull latest changes.
git-checkout-main() {
  git checkout main && git pull
}

# Clean up co-pilot workspaces and branches regardless of merge status
git-clean-copilot() {
    git checkout main
    git pull

    # Remove any git worktrees whose paths include copilot/
    git worktree list --porcelain | awk '/^worktree /{path=$2} /^branch /{branch=$2} branch ~ /copilot\//{print path}' | while read -r path; do
        git worktree remove --force "$path"
    done

    # Delete local copilot branches
    git branch | grep -v '^\*' | grep 'copilot/' | xargs -r -n 1 git branch -D

    # Delete remote copilot branches on origin
    git branch -r | grep 'origin/copilot/' | sed 's|origin/||' | xargs -r -n 1 git push origin --delete

    git fetch --prune
}

# Clean up local branches that have been merged into main and delete remote branches on origin.
git-clean-merged() {
  git checkout main
  git pull
  git branch --merged | grep -v '^\*' | grep -v 'main' | xargs -n 1 git branch -d
  git fetch --prune
  git branch -r | grep -v 'origin/main' | grep -v 'origin/HEAD' | grep -v 'origin/master' | xargs -n 1 git push origin --delete
  git fetch --prune
}

# Clean up local branches that have been removed from the remote repository and delete remote branches on origin.
git-clean-removed() {
  git checkout main
  git pull
  git fetch --prune
  git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -n 1 git branch -d
  git fetch --prune
  git branch -r | grep -v 'origin/main' | grep -v 'origin/HEAD' | grep -v 'origin/master' | xargs -n 1 git push origin --delete
  git fetch --prune
}