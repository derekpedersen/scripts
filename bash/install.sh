#!/usr/bin/env bash
set -euo pipefail

bootstrap_from_github() {
  if ! command -v curl >/dev/null 2>&1; then
    echo "curl is required to bootstrap bash helper files from GitHub."
    return 1
  fi

  local repo="${SCRIPTS_REPO:-derekpedersen/scripts}"
  local ref="${SCRIPTS_REF:-main}"
  local tmpdir
  local archive
  local extracted_dir
  local rc

  tmpdir="$(mktemp -d)"
  archive="$tmpdir/scripts.tar.gz"

  echo "Bootstrapping bash helper installer from github.com/$repo ($ref)..."
  curl -fsSL "https://codeload.github.com/$repo/tar.gz/refs/heads/$ref" -o "$archive"
  tar -xzf "$archive" -C "$tmpdir"

  extracted_dir="$(find "$tmpdir" -mindepth 1 -maxdepth 1 -type d | head -n 1)"
  if [[ -z "$extracted_dir" || ! -f "$extracted_dir/bash/install.sh" ]]; then
    echo "Bootstrap failed: could not find bash/install.sh in downloaded archive."
    rm -rf "$tmpdir"
    return 1
  fi

  SCRIPTS_BOOTSTRAPPED=1 SCRIPTS_REF="$ref" SCRIPTS_REPO="$repo" bash "$extracted_dir/bash/install.sh" "$@"
  rc=$?
  rm -rf "$tmpdir"
  return $rc
}

# BASH_SOURCE is unset when piped via curl; fall back to cwd so bootstrap runs
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-}")" && pwd)"
SHELL_NAME="${SHELL:-}"
MARKER_BEGIN="# >>> scripts/bash helpers >>>"
MARKER_END="# <<< scripts/bash helpers <<<"
LEGACY_LINE="# Added by scripts/bash/install.sh"

if ! compgen -G "$SCRIPT_DIR/*.bash" >/dev/null 2>&1; then
  if [[ "${SCRIPTS_BOOTSTRAPPED:-0}" == "1" ]]; then
    echo "No helper files found in $SCRIPT_DIR and bootstrap already ran."
    exit 1
  fi

  bootstrap_from_github "$@"
  exit $?
fi

if [[ "$SHELL_NAME" == *"zsh"* ]]; then
  PROFILE_FILE="$HOME/.zshrc"
elif [[ "$SHELL_NAME" == *"bash"* ]]; then
  PROFILE_FILE="$HOME/.bashrc"
else
  PROFILE_FILE="$HOME/.profile"
fi

if [[ ! -f "$PROFILE_FILE" ]]; then
  touch "$PROFILE_FILE"
fi

helper_files=()
while IFS= read -r file; do
  helper_files+=("$(basename "$file")")
done < <(find "$SCRIPT_DIR" -maxdepth 1 -type f -name '*.bash' ! -name 'install.sh' | sort)

if ((${#helper_files[@]} == 0)); then
  echo "No helper files found in $SCRIPT_DIR"
  exit 0
fi

read_existing_selection() {
  local file="$1"
  local selection=""

  if [[ ! -f "$file" ]]; then
    echo ""
    return
  fi

  awk -v start="$MARKER_BEGIN" -v end="$MARKER_END" '
    $0 == start { inblock = 1; next }
    inblock && $0 ~ /^# selected:/ { print substr($0, 11); exit }
    $0 == end { exit }
  ' "$file" 2>/dev/null | tr -d '\r'
}

remove_profile_block() {
  local file="$1"
  local start_marker="$2"
  local end_marker="$3"

  if [[ ! -f "$file" ]]; then
    return
  fi

  awk -v start="$start_marker" -v end="$end_marker" '
    $0 == start { skip = 1; next }
    $0 == end { skip = 0; next }
    !skip { print }
  ' "$file" > "$file.tmp"
  mv "$file.tmp" "$file"
}

remove_legacy_profile_block() {
  local file="$1"
  local legacy="$LEGACY_LINE"

  if [[ ! -f "$file" ]]; then
    return
  fi

  awk -v legacy="$legacy" '
    $0 == legacy { skip = 1; next }
    skip && $0 ~ /^for file in / { next }
    skip && $0 ~ /^  \[ -f / { next }
    skip && $0 ~ /^\[ -f / { next }
    skip && $0 ~ /^done$/ { skip = 0; next }
    skip && $0 ~ /^$/ { next }
    !skip { print }
  ' "$file" > "$file.tmp"
  mv "$file.tmp" "$file"
}

remove_profile_block "$PROFILE_FILE" "$MARKER_BEGIN" "$MARKER_END"
remove_legacy_profile_block "$PROFILE_FILE"

selected_files=()
existing_selection="$(read_existing_selection "$PROFILE_FILE")"
if [[ -n "$existing_selection" ]]; then
  for file in $existing_selection; do
    selected_files+=("$file")
  done
fi

if [[ -t 0 ]]; then
  available_missing=()
  for file in "${helper_files[@]}"; do
    already_selected=0
    for selected in "${selected_files[@]}"; do
      if [[ "$selected" == "$file" ]]; then
        already_selected=1
        break
      fi
    done
    if (( already_selected == 0 )); then
      available_missing+=("$file")
    fi
  done

  if (( ${#available_missing[@]} > 0 )); then
    echo "New helper files available:"
    for i in "${!helper_files[@]}"; do
      printf '  %2d) %s\n' "$((i + 1))" "${helper_files[$i]}"
    done
    printf 'Select the files to enable (blank = all, or enter a comma-separated list like 1,3): '
    read -r response

    if [[ -n "$response" ]]; then
      selected_files=()
      IFS=',' read -ra picks <<< "$response"
      for pick in "${picks[@]}"; do
        pick="${pick//[[:space:]]/}"
        if [[ "$pick" =~ ^[0-9]+$ ]] && (( pick >= 1 && pick <= ${#helper_files[@]} )); then
          selected_files+=("${helper_files[$((pick - 1))]}")
        fi
      done

      if ((${#selected_files[@]} == 0)); then
        selected_files=("${helper_files[@]}")
      fi
    else
      selected_files=("${helper_files[@]}")
    fi
  elif ((${#selected_files[@]} == 0)); then
    selected_files=("${helper_files[@]}")
  fi
else
  if ((${#selected_files[@]} == 0)); then
    selected_files=("${helper_files[@]}")
  fi
fi

if [[ "$(uname -s)" == "Darwin" ]] && [[ "$SHELL_NAME" == *"bash"* ]]; then
  BASH_PROFILE="$HOME/.bash_profile"
  if [[ ! -f "$BASH_PROFILE" ]]; then
    touch "$BASH_PROFILE"
  fi

  if ! grep -Fq "~/.bashrc" "$BASH_PROFILE" && ! grep -Fq ". ~/.bashrc" "$BASH_PROFILE" && ! grep -Fq "source ~/.bashrc" "$BASH_PROFILE"; then
    printf '\nif [ -f ~/.bashrc ]; then\n  . ~/.bashrc\nfi\n' >> "$BASH_PROFILE"
  fi
fi

selected_list="${selected_files[*]}"
SOURCE_BLOCK=$(cat <<EOF

$MARKER_BEGIN
# selected: $selected_list
for file in "$SCRIPT_DIR"/*.bash; do
  name="\$(basename "\$file")"
  for selected in $selected_list; do
    if [[ "\$name" == "\$selected" ]]; then
      source "\$file"
      break
    fi
  done
done
$MARKER_END
EOF
)

printf '%s\n' "$SOURCE_BLOCK" >> "$PROFILE_FILE"

echo "Added Bash helper sources to $PROFILE_FILE"
if ((${#selected_files[@]} > 0)); then
  printf 'Enabled: %s\n' "${selected_files[*]}"
fi

echo
printf 'Reload your shell with:\n  source "%s"\n' "$PROFILE_FILE"
if [[ "$(uname -s)" == "Darwin" ]] && [[ "$SHELL_NAME" == *"bash"* ]]; then
  printf 'If your terminal uses bash login shells, also reload ~/.bash_profile or open a new terminal.\n'
fi
printf 'Or open a new terminal session to use the helpers.\n'
