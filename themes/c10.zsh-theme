# By Alex Ciobica - <alex.ciobica@gmail.com>
# Based on Steve Losh's prompt http://stevelosh.com/blog/2010/02/my-extravagant-zsh-prompt/
# Help from Mark Nichols http://zanshin.net/2012/03/09/wordy-nerdy-zsh-prompt/

function prompt_char {
	local CHAR_COL="%{$fg[cyan]%}"
	local CHAR_END="%{$reset_color%}"
    git branch >/dev/null 2>/dev/null && echo "$CHAR_COL±$CHAR_END " && return
    hg root >/dev/null 2>/dev/null && echo "$CHAR_COL☿$CHAR_END " && return
	svn info >/dev/null 2>/dev/null && echo "$CHAR_COL⑆$CHAR_END" && return
    echo "$CHAR_COL○$CHAR_END"
}

function hg_prompt_info {
    hg prompt --angle-brackets prompt --angle-brackets "\
< on %{$fg[magenta]%}<branch>%{$reset_color%}>\
<@%{$fg[yellow]%}<tags|%{$reset_color%}, %{$fg[yellow]%}>%{$reset_color%}>\
%{$fg[green]%}<status|modified|unknown><update>%{$reset_color%}<
patches: <patches|join( → )|pre_applied(%{$fg[yellow]%})|post_applied(%{$reset_color%})|pre_unapplied(%{$fg_bold[black]%})|post_unapplied(%{$reset_color%})>>" 2>/dev/null
}

function svn_prompt_info {
    # Set up defaults
    local svn_branch=""
    local svn_repository=""
    local svn_version=""
    local svn_change=""

    # only if we are in a directory that contains a .svn entry
    if [ -d ".svn" ]; then
        # query svn info and parse the results
        svn_branch=`svn info | grep '^URL:' | egrep -o '((tags|branches)/[^/]+|trunk).*' | sed -E -e 's/^(branches|tags)\///g'`
        svn_repository=`svn info | grep '^Repository Root:' | egrep -o '(http|https|file|svn|svn+ssh)/[^/]+' | egrep -o '[^/]+$'`
        svn_version=`svnversion -n`

        # this is the slowest test of the bunch
        change_count=`svn status | grep "?\|\!\|M\|A" | wc -l`
        if [ "$change_count" != "       0" ]; then
            svn_change=" [dirty]"
        else
            svn_change=""
        fi

        # show the results
        echo "%{$fg[blue]%}$svn_repository/$svn_branch @ $svn_version%{$reset_color%}%{$fg[yellow]%}$svn_change%{$reset_color%}"
    fi
}


function box_name {
    [ -f ~/.box-name ] && cat ~/.box-name || hostname -s
}

function rvm_prompt_info {
  # ruby_version=$(~/.rvm/bin/rvm-prompt)
  if [ -f ~/.rvm/bin/rvm-prompt ]; then
      ruby_version=$(~/.rvm/bin/rvm-prompt v g)
      if [ -n "$ruby_version" ]; then
        echo "%{$fg[yellow]%}|$ruby_version|"
      fi
  fi
}

function user_host {
	echo %{$fg[magenta]%}%n%{$reset_color%}@%{$fg[yellow]%}$(box_name)%{$reset_color%}
}

function virtualenv_info {
    [ $VIRTUAL_ENV ] && echo ' ('`basename $VIRTUAL_ENV`')'
}

PROMPT='
$(rvm_prompt_info)$(virtualenv_info) $(user_host) in %{$fg_bold[green]%}${PWD/#$HOME/~}$(svn_prompt_info)%{$reset_color%}
%(?,,%{${fg_bold[white]}%}[%?]%{$reset_color%} )$(prompt_char)$(git_prompt_info) → %{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}|"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg[green]%}|"
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}✗"
ZSH_THEME_GIT_PROMPT_UNTRACKED=" %{$fg_bold[green]%}?"
ZSH_THEME_GIT_PROMPT_CLEAN=" %{$fg_bold[green]%}✓"

# local return_status="%{$fg[red]%}%(?..✘)%{$reset_color%}"
# RPROMPT='${return_status}%{$reset_color%}'
