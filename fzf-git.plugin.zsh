# Git completions powered by FZF
#
# Based on:
# - https://github.com/junegunn/fzf/wiki/Examples-(completion)
# - https://gist.github.com/junegunn/8b572b8d4b5eddd8b85e5f4d40f17236

_fzf_complete_git() {
    ARGS="$@"
    is_in_git_repo || return

    [[ $ARGS == 'git checkout'* || $ARGS == 'git co'* ]] && \
      fzf_complete_branch "$ARGS"
}

_fzf_complete_g() {
    ARGS="$@"
    is_in_git_repo || return

    [[ $ARGS == 'g checkout'* || $ARGS == 'g co'* ]] && \
      fzf_complete_branch "$ARGS"
}

_fzf_complete_gco() {
    is_in_git_repo || return
    fzf_complete_branch "$@"
}

fzf_complete_branch() {
  git branch -a | \
    grep -vw 'HEAD' | sort | \
    sed 's/^..//' | cut -d' ' -f1 | \
    sed 's|^\(\x1b\[[0-9;]*m\)remotes/\(.*\)|\1\2|' | \
    _fzf_complete "--reverse --multi" "$@"
}

is_in_git_repo() {
  git rev-parse HEAD > /dev/null 2>&1
}

