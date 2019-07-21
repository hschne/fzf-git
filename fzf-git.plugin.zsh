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

fzf-git::checkout_file() {
  fzf-git::inside_work_tree || { fzf-git::info "Not a git repository"; return 1; }

  # If an argument is provided call the command, otherwise call completion
  [[ "$#" -ge 1 ]] && { eval $cmd "$@"; return "$?"; }
  local cmd files opts
  cmd="git diff --color=always -- {} $fzf_git_emojify $fzf_git_fancy"
  opts="
        $FZF_GIT_DEFAULT_OPTS
        -m -0 --preview=\"$cmd\"
    "
  files="$(fzf-git::list_staged | FZF_DEFAULT_OPTS="$opts" fzf)"
  [[ -n "$files" ]] && echo "$files" |xargs -I{} git checkout {} && git status --short && return
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

fzf-git::complete_staged_files() {
  fzf-git::inside_work_tree || { fzf-git::info "Not a git repository"; return 1; }

  # TODO: Figure out a way to do preview here as well?
  local opts="$FZF_GIT_DEFAULT_OPTS"

  _fzf_complete "$opts" "$@" < <(fzf-git::list_staged_files)
}


# Takes a command to execute and a completion
# 
# If the whole thing was called with additional arguments, just call the original
# cmd. Otherwise invoke the passed completion to get the argument.
fzf-git::cmd_proxy() {
  fzf-git::inside_work_tree || { fzf-git::info "Not a git repository"; return 1; }

  local cmd=$1
  local completion=$2
  shift 2
  # If an argument is provided call the command, otherwise call completion
  [[ "$#" -ge 1 ]] && { eval $cmd "$@"; return "$?"; }

  local opts="$FZF_GIT_DEFAULT_OPTS"
  branch=$(fzf-git::list_$completion | \
    FZF_DEFAULT_OPTS="$opts" fzf )
  [[ -n "$branch" ]] && eval $cmd "$branch"
}


fzf-git::list_all_branches() {
  git branch -a | \
    grep -vw 'HEAD' | sort | \
    sed 's/^..//' | cut -d' ' -f1 | \
    sed 's|remotes\/.*\/||' | uniq | sort
}

fzf-git::list_local_branches() {
  git branch | \
    grep -vw 'HEAD' | sort | \
    sed 's/^..//' | cut -d' ' -f1 
}

fzf-git::list_staged_files() {
  git ls-files --modified "$(git rev-parse --show-toplevel)"
}

fzf-git::setup_completions() {
  eval "_fzf_complete_gco() { fzf-git::complete_staged_files \$@ }"
  eval "_fzf_complete_gcof() { fzf-git::complete_staged_files \$@ }"
  eval "_fzf_complete_gcob() { fzf-git::complete_all_branches \$@ }"
  eval "_fzf_complete_gbd() { fzf-git::complete_local_branches \$@ }"
  # for cmd in ${FZF_GIT_BRANCH_COMPLETIONS[@]}; do
  #   eval "_fzf_complete_$cmd() { fzf-git::complete_branch \$@ }"
  # done
}


alias gco='fzf-git::checkout_file'
alias gcof='fzf-git::checkout_file'
alias gcob='fzf-git::cmd_proxy "git checkout" all_branches'
alias gbd='fzf-git::cmd_proxy "git branch -d" local_branches'

fzf-git::setup_completions
