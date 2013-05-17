set -x fish_color_cwd FFAA00
set -x fish_color_command white
set -x fish_color_match white

set -x fish_color_param white
set -x fish_color_operator white

set -x fish_color_valid_path 'F80 --underline'
set -x fish_color_autosuggestion 830

set -x fish_color_git_prompt 0AF
set -x fish_color_git_branch 05F
set -x fish_color_git_detatched_head F11

set -x fish_color_git_time_since_last_commit_short  green
set -x fish_color_git_time_since_last_commit_medium yellow
set -x fish_color_git_time_since_last_commit_long   red

set -x fish_prompt_git_prompt_unstaged ' ○ '
set -x fish_prompt_git_prompt_staged ' ● '
set -x fish_prompt_git_prompt_clean ' '

# git stuff

function git_current_branch
  set -l ref (git symbolic-ref HEAD | cut -d '/' -f3 ^ /dev/null)
  echo $ref
end

function git_short_sha
  set -l sha (git rev-parse --short HEAD ^ /dev/null)
  echo $sha
end

function git_branch_state
  if [ -n (git_current_branch) ]
    set_color $fish_color_git_branch
    echo (git_current_branch)
  else
    set_color $fish_color_git_detatched_head
    echo (git_short_sha)
  end
end

function git_time_since_last_commit
  set -l last (git log --pretty=format:'%at' -1 ^ /dev/null)
  set -l now (date +%s)

  echo (math $now - $last)
end

function git_prompt_color_for_time_since_last_commit
  if [ (git_time_since_last_commit) -gt 1800 ]
    echo $fish_color_git_time_since_last_commit_long
  else if [ (git_time_since_last_commit) -gt 900 ]
    echo $fish_color_git_time_since_last_commit_medium
  else
    echo $fish_color_git_time_since_last_commit_short
  end
end

function git_prompt_dirty_state
  if [ -z git_short_sha ]
    return
  end

  git diff-index --quiet --cached HEAD ^ /dev/null
  set -l staged $status

  git diff-files --quiet ^ /dev/null
  set -l changed $status

  test -z (git ls-files --exclude-standard --others) ^ /dev/null
  set -l untracked $status

  set_color (git_prompt_color_for_time_since_last_commit)

  if [ $staged = 1 ]
    echo $fish_prompt_git_prompt_staged
  else if [ $untracked = 1 -o $changed = 1 ]
      echo $fish_prompt_git_prompt_unstaged
  else
    echo $fish_prompt_git_prompt_clean
  end
end

function git_prompt_prefix
  set_color $fish_color_git_prompt
  echo 'git('
end

function git_prompt_suffix
  set_color $fish_color_git_prompt
  printf ')'
end

function git_prompt
  if [ -n (git_short_sha) ]
    if [ $argv[1] = 'right' ]
      echo (git_prompt_dirty_state)(git_prompt_prefix)(git_branch_state)(git_prompt_suffix)
    else
      echo (git_prompt_prefix)(git_branch_state)(git_prompt_suffix)(git_prompt_dirty_state)
    end
  end
end

function ssh_prompt
  function ssh_connection
    echo $SSH_CONNECTION
  end

  if [ -n (ssh_connection) ]
    set_color white
    echo '%s@%s ' (whoami) (hostname | cut -d . -f 1)
  else
    echo
  end
end

# Returns the last two path components with ~ as a substitute for $HOME
function cwd
  set_color $fish_color_cwd
  echo $PWD | sed -e "s|^$HOME|~|" | rev | cut -d '/' -f '1 2' | rev
end

function term_width
  set -l width (tput cols)
  echo $width
end

function fish_prompt
  if [ (term_width) -gt 88 ]
    printf '%s%s %s%s' (ssh_prompt) (cwd) (git_prompt 'left')
  else
    printf '%s%s ' (ssh_prompt) (cwd)
  end

  set_color normal
end

function fish_right_prompt
  if [ (term_width) -lt 89 ]
    printf (git_prompt 'right')
  end
end
