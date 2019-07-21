# Git completions powered by FZF
#
# Based on:
# - https://github.com/junegunn/fzf/wiki/Examples-(completion)
# - https://gist.github.com/junegunn/8b572b8d4b5eddd8b85e5f4d40f17236

FZF_GIT_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --reverse --multi"

fzf-git::warn() { printf "%b[Warn]%b %s\n" '\e[0;33m' '\e[0m' "$@" >&2; }
fzf-git::info() { printf "%b[Info]%b %s\n" '\e[0;32m' '\e[0m' "$@" >&2; }
fzf-git::inside_work_tree() { git rev-parse --is-inside-work-tree >/dev/null; }

# https://github.com/so-fancy/diff-so-fancy
hash diff-so-fancy &>/dev/null && fzf_git_fancy='|diff-so-fancy'
# https://github.com/wfxr/emoji-cli
hash emojify &>/dev/null && fzf_git_emojify='|emojify'

# Takes a command to execute and a completion
# 
# If the whole thing was called with additional arguments, just call the original
# cmd. Otherwise invoke the passed completion to get the argument.
fzf-git::cmd_proxy() {
  fzf-git::inside_work_tree || { fzf-git::info "Not a git repository"; return 1; }
  

  local cmd=$1
  shift
  # If an argument is provided call the command, otherwise call completion
  [[ "$#" -ge 1 ]] && { eval $cmd "$@"; return "$?"; }

  local opts="$FZF_GIT_DEFAULT_OPTS"
  branch=$(fzf-git::list_branches | \
    FZF_DEFAULT_OPTS="$opts" fzf )
  [[ -n "$branch" ]] && eval $cmd "$branch"
}

fzf-git::complete_branch() {
  fzf-git::inside_work_tree || { fzf-git::info "Not a git repository"; return 1; }

  local opts="$FZF_GIT_DEFAULT_OPTS"

  _fzf_complete "$opts" "$@" < <(fzf-git::list_branches)
}

fzf-git::list_branches() {
  git branch -a | \
    grep -vw 'HEAD' | sort | \
    sed 's/^..//' | cut -d' ' -f1 | \
    sed 's|remotes\/.*\/||' | uniq | sort
}

fzf-git::setup_completions() {
  for cmd in ${FZF_GIT_BRANCH_COMPLETIONS[@]}; do
    eval "_fzf_complete_$cmd() { fzf-git::complete_branch \$@ }"
  done
}

alias gcb='fzf-git::cmd_proxy "git checkout"'
alias gcob='fzf-git::cmd_proxy "git checkout"'
alias gbd='fzf-git::cmd_proxy "git branch -d"'

FZF_GIT_BRANCH_COMPLETIONS=(gcb gbd)

fzf-git::setup_completions
