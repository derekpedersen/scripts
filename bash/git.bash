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
  git pull --ff-only
  git fetch --prune origin

  git branch --merged | grep -v '^\*' | grep -v 'main' | xargs -r -n 1 git branch -d

  git for-each-ref --format='%(refname:short)' refs/heads | while read -r local_branch; do
    if [[ "$local_branch" == "main" || "$local_branch" == "master" ]]; then
      continue
    fi

    if ! git ls-remote --exit-code --heads origin "$local_branch" >/dev/null 2>&1; then
      git branch -D "$local_branch"
    fi
  done

  git branch -r \
    | grep 'origin/' \
    | grep -v 'origin/main' \
    | grep -v 'origin/HEAD' \
    | grep -v 'origin/master' \
    | while read -r ref; do
        branch="${ref#origin/}"
        git push origin --delete "$branch" >/dev/null 2>&1 || true
      done

  git fetch --prune origin
}

# Clean up local branches that have been removed from the remote repository and delete remote branches on origin.
git-clean-removed() {
  git checkout main
  git pull --ff-only
  git fetch --prune origin

  git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -r -n 1 git branch -d

  git for-each-ref --format='%(refname:short)' refs/heads | while read -r local_branch; do
    if [[ "$local_branch" == "main" || "$local_branch" == "master" ]]; then
      continue
    fi

    if ! git ls-remote --exit-code --heads origin "$local_branch" >/dev/null 2>&1; then
      git branch -D "$local_branch"
    fi
  done

  git branch -r \
    | grep 'origin/' \
    | grep -v 'origin/main' \
    | grep -v 'origin/HEAD' \
    | grep -v 'origin/master' \
    | while read -r ref; do
        branch="${ref#origin/}"
        if ! git ls-remote --exit-code --heads origin "$branch" >/dev/null 2>&1; then
          git branch -r -d "$ref" >/dev/null 2>&1 || true
        fi
      done

  git fetch --prune origin
}
