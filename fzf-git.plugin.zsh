# Git completions powered by FZF
#
# Based on:
# - https://github.com/junegunn/fzf/wiki/Examples-(completion)
# - https://gist.github.com/junegunn/8b572b8d4b5eddd8b85e5f4d40f17236

fzf-git::warn() { printf "%b[Warn]%b %s\n" '\e[0;33m' '\e[0m' "$@" >&2; }
fzf-git::info() { printf "%b[Info]%b %s\n" '\e[0;32m' '\e[0m' "$@" >&2; }
fzf-git::inside_work_tree() { git rev-parse --is-inside-work-tree >/dev/null; }

# https://github.com/so-fancy/diff-so-fancy
hash diff-so-fancy &>/dev/null && fzf_git_fancy='|diff-so-fancy'
# https://github.com/wfxr/emoji-cli
hash emojify &>/dev/null && fzf_git_emojify='|emojify'

fzf-git::add() {
  fzf-git::inside_work_tree || { fzf-git::info "Not a git repository"; return 1; }

  opts="
        $FZF_GIT_DEFAULT_OPTS
        $FZF_GIT_PREVIEW_DEFAULT_OPTS
        -0 -m --nth 2..,..
        --preview=\"git diff --color=always -- {-1} $fzf_git_emojify $fzf_git_fancy\"
    "
  files=$(fzf-git::list_unstaged_files | 
    FZF_DEFAULT_OPTS="$opts" fzf | cut -d] -f2 |
    sed 's/.* -> //') # for rename case
  [[ -n "$files" ]] && echo "$files" |xargs -I{} git add {} && git status --short && return
}

fzf-git::checkout_file() {
  fzf-git::inside_work_tree || { fzf-git::info "Not a git repository"; return 1; }

  # If an argument is provided call the command, otherwise call completion
  [[ "$#" -ge 1 ]] && { git checkout "$@"; return "$?"; }
  local cmd files opts
  cmd="git diff --color=always -- {} $fzf_git_emojify $fzf_git_fancy"
  opts="
        $FZF_GIT_DEFAULT_OPTS
        $FZF_GIT_PREVIEW_DEFAULT_OPTS
        -m -0 --preview=\"$cmd\"
    "
  files="$(fzf-git::list_staged_files | FZF_DEFAULT_OPTS="$opts" fzf)"
  [[ -n "$files" ]] && echo "$files" |xargs -I{} git checkout {} && git status --short && return
}

fzf-git::reset() {
  fzf-git::inside_work_tree || { fzf-git::info "Not a git repository"; return 1; }

  [[ "$#" -ge 1 ]] && { git reset HEAD "$@"; return "$?"; }
  local cmd files opts
  cmd="git diff --cached --color=always -- {} $fzf_git_emojify $fzf_git_fancy"
  opts="
        $FZF_GIT_DEFAULT_OPTS
        $FZF_GIT_PREVIEW_DEFAULT_OPTS
        -m -0 --preview=\"$cmd\"
    "
  files="$(fzf-git::list_cached | FZF_DEFAULT_OPTS="$opts" fzf)"
  [[ -n "$files" ]] && echo "$files" |xargs -I{} git reset HEAD {} && git status --short && return
}

fzf-git::checkout_branch() {
  fzf-git::inside_work_tree || { fzf-git::info "Not a git repository"; return 1; }
  [[ "$#" -ge 1 ]] && { git checkout "$@"; return "$?"; }

  local opts="
    $FZF_GIT_DEFAULT_OPTS
    $FZF_GIT_PREVIEW_DEFAULT_OPTS
  "
  branch=$(fzf-git::list_all_branches | \
    FZF_DEFAULT_OPTS="$opts" fzf )
  [[ -n "$branch" ]] && git checkout "$branch"
}


fzf-git::delete_branch() {
  fzf-git::inside_work_tree || { fzf-git::info "Not a git repository"; return 1; }
  [[ "$#" -ge 1 ]] && { git branch -d "$@"; return "$?"; }

  local opts="
    $FZF_GIT_DEFAULT_OPTS
  "
  branch=$(fzf-git::list_local_branches | \
    FZF_DEFAULT_OPTS="$opts" fzf )
  [[ -n "$branch" ]] && git branch -d "$branch"
}


fzf-git::diff() {
  fzf-git::inside_work_tree || { fzf-git::info "Not a git repository"; return 1; }
  local cmd files opts
  cmd="git diff --color=always -- {} $fzf_git_emojify $fzf_git_fancy"
  files="$*"
  [[ $# -eq 0 ]] && files=$(git rev-parse --show-toplevel)

  opts="
        $FZF_GIT_DEFAULT_OPTS
        $FZF_GIT_PREVIEW_DEFAULT_OPTS
        +m -0 --preview=\"$cmd\" --bind=\"enter:execute($cmd |LESS='-R' less)\"
    "
  git ls-files --modified "$files" |
  FZF_DEFAULT_OPTS="$opts" fzf
}

fzf-git::complete_staged_files() {
  fzf-git::inside_work_tree || { fzf-git::info "Not a git repository"; return 1; }

  # TODO: Figure out a way to do preview here as well?
  local opts="$FZF_GIT_DEFAULT_OPTS"

  _fzf_complete "$opts" "$@" < <(fzf-git::list_staged_files)
}

fzf-git::complete_unstaged_files() {
  fzf-git::inside_work_tree || { fzf-git::info "Not a git repository"; return 1; }

  # TODO: Figure out a way to do preview here as well?
  local opts="$FZF_GIT_DEFAULT_OPTS"

  _fzf_complete "$opts" "$@" < <(fzf-git::list_unstaged_files)
}

fzf-git::complete_all_branches() {
  fzf-git::inside_work_tree || { fzf-git::info "Not a git repository"; return 1; }

  local opts="$FZF_GIT_DEFAULT_OPTS"

  _fzf_complete "$opts" "$@" < <(fzf-git::list_all_branches)
}

fzf-git::complete_local_branches() {
  fzf-git::inside_work_tree || { fzf-git::info "Not a git repository"; return 1; }

  local opts="$FZF_GIT_DEFAULT_OPTS"

  _fzf_complete "$opts" "$@" < <(fzf-git::list_local_branches)
}

fzf-git::complete_cached_files() {
  fzf-git::inside_work_tree || { fzf-git::info "Not a git repository"; return 1; }

  local opts="$FZF_GIT_DEFAULT_OPTS"

  _fzf_complete "$opts" "$@" < <(fzf-git::list_cached)
}


fzf-git::list_staged_files() {
  git ls-files --modified "$(git rev-parse --show-toplevel)"
}

fzf-git::list_unstaged_files(){
  local changed unmerged untracked 
  changed=$(git config --get-color color.status.changed red)
  unmerged=$(git config --get-color color.status.unmerged red)
  untracked=$(git config --get-color color.status.untracked red)
  git -c color.status=always status --short | \
    grep -F -e "$changed" -e "$unmerged" -e "$untracked" | \
    awk '{printf "[%10s]  ", $1; $1=""; print $0}' 
}

fzf-git::list_cached(){
  git diff --cached --name-only
}

fzf-git::list_all_branches() {
  git branch -a | \
    grep -vw 'HEAD' | sort | \
    sed 's/^..//' | cut -d' ' -f1 | \
    sed 's|remotes\/.*\/||' | sort | uniq
}

fzf-git::list_local_branches() {
  git branch | \
    grep -vw 'HEAD' | sort | \
    sed 's/^..//' | cut -d' ' -f1 
}

fzf-git::setup_completions() {
  _fzf_complete_ga() { fzf-git::complete_unstaged_files $@ }
  _fzf_complete_gco() { fzf-git::complete_staged_files $@ }
  _fzf_complete_gcof() { fzf-git::complete_staged_files $@ }
  _fzf_complete_gcob() { fzf-git::complete_all_branches $@ }
  _fzf_complete_gbd() { fzf-git::complete_local_branches $@ }
  _fzf_complete_grh() { fzf-git::complete_cached_files $@ }
}

FZF_GIT_DEFAULT_OPTS="
  $FZF_DEFAULT_OPTS
"

FZF_GIT_PREVIEW_DEFAULT_OPTS="
  --bind='alt-k:preview-up,alt-p:preview-up'
  --bind='alt-j:preview-down,alt-n:preview-down'
  --bind='ctrl-r:toggle-all'
  --bind='ctrl-s:toggle-sort'
  --bind='?:toggle-preview'
  --bind='alt-w:toggle-preview-wrap'
  --preview-window='right:60%'
"

alias ga='fzf-git::add'
alias gco='fzf-git::checkout_file'
alias gcof='fzf-git::checkout_file'
alias gcob='fzf-git::checkout_branch'
alias gbd='fzf-git::delete_branch'
alias gd='fzf-git::diff'
alias grh='fzf-git::reset_head'

fzf-git::setup_completions
