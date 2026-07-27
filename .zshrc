#execute commands in init
#ncal -3
#jcal -3
# Set up the prompt

autoload -Uz promptinit
promptinit
prompt adam2
setopt histignorealldups sharehistory
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history
# Use modern completion system
autoload -Uz compinit
compinit
# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e
alias getmyip='curl -s icanhazip.com'
alias getmyip2='curl ident.me'
alias _='sudo '
alias njcal='ncal -3;jcal -3;'
alias grep='grep --color '
alias k='sudo kill -9  '
alias kson='buckle &'
alias ksoff='kill -9 $(ps ax | grep buckle | sed -n "1p" | awk "{print \$1}")'
alias p='ping '
alias p1='ping 192.168.1.1 '
alias p8='ping 8.8.8.8 '
alias p61='ping 192.168.1.61 '
#alias bv1='xrandr --output VGA1 --brightness '
alias bd1='xrandr --output DP1 --brightness '
alias bh1='xrandr --output HDMI1 --brightness '
alias bh2='xrandr --output HDMI2 --brightness '
alias t='tail -f /var/log/sms'
alias ls='ls --color=auto'
alias l='ls --color=auto'
alias ll='ls -la --color=auto'
alias -g gp='| grep -i'
alias -s txt=vim
alias -s pdf=evince
alias -s c=vim
alias -s cpp=vim
alias -s h=vim
alias -s php=vim
alias -s py=python
alias -s html=vim
alias -s doc=soffice
alias -s docx=soffice
alias -s xls=soffice
alias -s xlsx=soffice
alias -s jpg=eog
alias -s png=eog
#   screen
####################################################################
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=magenta,fg=white,bold'
HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=red,fg=white,bold'
HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS='i'

history-substring-search-up() {
  _history-substring-search-begin

  _history-substring-search-up-history ||
  _history-substring-search-up-buffer ||
  _history-substring-search-up-search

  _history-substring-search-end
}

history-substring-search-down() {
  _history-substring-search-begin

  _history-substring-search-down-history ||
  _history-substring-search-down-buffer ||
  _history-substring-search-down-search

  _history-substring-search-end
}

zle -N history-substring-search-up
zle -N history-substring-search-down

#-----------------------------------------------------------------------------
# implementation details
#-----------------------------------------------------------------------------

zmodload -F zsh/parameter

#
# We have to "override" some keys and widgets if the
# zsh-syntax-highlighting plugin has not been loaded:
#
# https://github.com/nicoulaj/zsh-syntax-highlighting
#
if [[ $+functions[_zsh_highlight] -eq 0 ]]; then
  #
  # Dummy implementation of _zsh_highlight() that
  # simply removes any existing highlights when the
  # user inserts printable characters into $BUFFER.
  #
  _zsh_highlight() {
    if [[ $KEYS == [[:print:]] ]]; then
      region_highlight=()
    fi
  }

  #--------------8<-------------------8<-------------------8<-----------------
  # Rebind all ZLE widgets to make them invoke _zsh_highlights.
  _zsh_highlight_bind_widgets()
  {
    # Load ZSH module zsh/zleparameter, needed to override user defined widgets.
    zmodload zsh/zleparameter 2>/dev/null || {
      echo 'zsh-syntax-highlighting: failed loading zsh/zleparameter.' >&2
      return 1
    }

    # Override ZLE widgets to make them invoke _zsh_highlight.
    local cur_widget
	#User definned widget: overridde and rebind old one with prefix "orig-".
	#User defined widget: overide and rebind old one with prefix "orig-".
    for cur_widget in ${${(f)"$(builtin zle -la)"}:#(.*|_*|orig-*|run-help|which-command|beep|yank*)}; do
      case $widgets[$cur_widget] in

        # Already rebound event: do nothing.
        user:$cur_widget|user:_zsh_highlight_widget_*);;

        # User defined widget: override and rebind old one with prefix "orig-".
        user:*) eval "zle -N orig-$cur_widget ${widgets[$cur_widget]#*:}; \
                      _zsh_highlight_widget_$cur_widget() { builtin zle orig-$cur_widget -- \"\$@\" && _zsh_highlight }; \
                      zle -N $cur_widget _zsh_highlight_widget_$cur_widget";;

        # Completion widget: override and rebind old one with prefix "orig-".
        completion:*) eval "zle -C orig-$cur_widget ${${widgets[$cur_widget]#*:}/:/ }; \
                            _zsh_highlight_widget_$cur_widget() { builtin zle orig-$cur_widget -- \"\$@\" && _zsh_highlight }; \
                            zle -N $cur_widget _zsh_highlight_widget_$cur_widget";;

        # Builtin widget: override and make it call the builtin ".widget".
        builtin) eval "_zsh_highlight_widget_$cur_widget() { builtin zle .$cur_widget -- \"\$@\" && _zsh_highlight }; \
                       zle -N $cur_widget _zsh_highlight_widget_$cur_widget";;

        # Default: unhandled case.
        *) echo "zsh-syntax-highlighting: unhandled ZLE widget '$cur_widget'" >&2 ;;
      esac
    done
  }
  #-------------->8------------------->8------------------->8-----------------

  _zsh_highlight_bind_widgets
fi

_history-substring-search-begin() {
  setopt localoptions extendedglob

  _history_substring_search_refresh_display=
  _history_substring_search_query_highlight=

  #
  # Continue using the previous $_history_substring_search_result by default,
  # unless the current query was cleared or a new/different query was entered.
  #
  if [[ -z $BUFFER || $BUFFER != $_history_substring_search_result ]]; then
    #
    # For the purpose of highlighting we will also keep
    # a version without doubly-escaped meta characters.
    #
    _history_substring_search_query=$BUFFER

    #
    # $BUFFER contains the text that is in the command-line currently.
    # we put an extra "\\" before meta characters such as "\(" and "\)",
    # so that they become "\\\(" and "\\\)".
    #
    _history_substring_search_query_escaped=${BUFFER//(#m)[\][()|\\*?#<>~^]/\\$MATCH}

    #
    # Find all occurrences of the search query in the history file.
    #
    # (k) returns the "keys" (history index numbers) instead of the values
    # (Oa) reverses the order, because (R) returns results reversed.
    #
    _history_substring_search_matches=(${(kOa)history[(R)(#$HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS)*${_history_substring_search_query_escaped}*]})

    #
    # Define the range of values that $_history_substring_search_match_index
    # can take: [0, $_history_substring_search_matches_count_plus].
    #
    _history_substring_search_matches_count=$#_history_substring_search_matches
    _history_substring_search_matches_count_plus=$(( _history_substring_search_matches_count + 1 ))
    _history_substring_search_matches_count_sans=$(( _history_substring_search_matches_count - 1 ))

    #
    # If $_history_substring_search_match_index is equal to
    # $_history_substring_search_matches_count_plus, this indicates that we
    # are beyond the beginning of $_history_substring_search_matches.
    #
    # If $_history_substring_search_match_index is equal to 0, this indicates
    # that we are beyond the end of $_history_substring_search_matches.
    #
    # If we have initially pressed "up" we have to initialize
    # $_history_substring_search_match_index to
    # $_history_substring_search_matches_count_plus so that it will be
    # decreased to $_history_substring_search_matches_count.
    #
    # If we have initially pressed "down" we have to initialize
    # $_history_substring_search_match_index to
    # $_history_substring_search_matches_count so that it will be increased to
    # $_history_substring_search_matches_count_plus.
    #
    if [[ $WIDGET == history-substring-search-down ]]; then
       _history_substring_search_match_index=$_history_substring_search_matches_count
    else
      _history_substring_search_match_index=$_history_substring_search_matches_count_plus
    fi
  fi
}

_history-substring-search-end() {
  setopt localoptions extendedglob

  _history_substring_search_result=$BUFFER

  # the search was succesful so display the result properly by clearing away
  # existing highlights and moving the cursor to the end of the result buffer
  if [[ $_history_substring_search_refresh_display -eq 1 ]]; then
    region_highlight=()
    CURSOR=${#BUFFER}
  fi

  # highlight command line using zsh-syntax-highlighting
  _zsh_highlight

  # highlight the search query inside the command line
  if [[ -n $_history_substring_search_query_highlight && -n $_history_substring_search_query ]]; then
    #
    # The following expression yields a variable $MBEGIN, which
    # indicates the begin position + 1 of the first occurrence
    # of _history_substring_search_query_escaped in $BUFFER.
    #
    : ${(S)BUFFER##(#m$HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS)($_history_substring_search_query##)}
    local begin=$(( MBEGIN - 1 ))
    local end=$(( begin + $#_history_substring_search_query ))
    region_highlight+=("$begin $end $_history_substring_search_query_highlight")
  fi

  # For debugging purposes:
  # zle -R "mn: "$_history_substring_search_match_index" m#: "${#_history_substring_search_matches}
  # read -k -t 200 && zle -U $REPLY

  # Exit successfully from the history-substring-search-* widgets.
  return 0
}

_history-substring-search-up-buffer() {
  #
  # Check if the UP arrow was pressed to move the cursor within a multi-line
  # buffer. This amounts to three tests:
  #
  # 1. $#buflines -gt 1.
  #
  # 2. $CURSOR -ne $#BUFFER.
  #
  # 3. Check if we are on the first line of the current multi-line buffer.
  #    If so, pressing UP would amount to leaving the multi-line buffer.
  #
  #    We check this by adding an extra "x" to $LBUFFER, which makes
  #    sure that xlbuflines is always equal to the number of lines
  #    until $CURSOR (including the line with the cursor on it).
  #
  local buflines XLBUFFER xlbuflines
  buflines=(${(f)BUFFER})
  XLBUFFER=$LBUFFER"x"
  xlbuflines=(${(f)XLBUFFER})

  if [[ $#buflines -gt 1 && $CURSOR -ne $#BUFFER && $#xlbuflines -ne 1 ]]; then
    zle up-line-or-history
    return 0
  fi

  return 1
}

_history-substring-search-down-buffer() {
  #
  # Check if the DOWN arrow was pressed to move the cursor within a multi-line
  # buffer. This amounts to three tests:
  #
  # 1. $#buflines -gt 1.
  #
  # 2. $CURSOR -ne $#BUFFER.
  #
  # 3. Check if we are on the last line of the current multi-line buffer.
  #    If so, pressing DOWN would amount to leaving the multi-line buffer.
  #
  #    We check this by adding an extra "x" to $RBUFFER, which makes
  #    sure that xrbuflines is always equal to the number of lines
  #    from $CURSOR (including the line with the cursor on it).
  #
  local buflines XRBUFFER xrbuflines
  buflines=(${(f)BUFFER})
  XRBUFFER="x"$RBUFFER
  xrbuflines=(${(f)XRBUFFER})

  if [[ $#buflines -gt 1 && $CURSOR -ne $#BUFFER && $#xrbuflines -ne 1 ]]; then
    zle down-line-or-history
    return 0
  fi

  return 1
}

_history-substring-search-up-history() {
  #
  # Behave like up in ZSH, except clear the $BUFFER
  # when beginning of history is reached like in Fish.
  #
  if [[ -z $_history_substring_search_query ]]; then

    # we have reached the absolute top of history
    if [[ $HISTNO -eq 1 ]]; then
      BUFFER=

    # going up from somewhere below the top of history
    else
      zle up-line-or-history
    fi

    return 0
  fi

  return 1
}

_history-substring-search-down-history() {
  #
  # Behave like down-history in ZSH, except clear the
  # $BUFFER when end of history is reached like in Fish.
  #
  if [[ -z $_history_substring_search_query ]]; then

    # going down from the absolute top of history
    if [[ $HISTNO -eq 1 && -z $BUFFER ]]; then
      BUFFER=${history[1]}
      _history_substring_search_refresh_display=1

    # going down from somewhere above the bottom of history
    else
      zle down-line-or-history
    fi

    return 0
  fi

  return 1
}

_history-substring-search-not-found() {
  #
  # Nothing matched the search query, so put it back into the $BUFFER while
  # highlighting it accordingly so the user can revise it and search again.
  #
  _history_substring_search_old_buffer=$BUFFER
  BUFFER=$_history_substring_search_query
  _history_substring_search_query_highlight=$HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND
}

_history-substring-search-up-search() {
  _history_substring_search_refresh_display=1

  #
  # Highlight matches during history-substring-up-search:
  #
  # The following constants have been initialized in
  # _history-substring-search-up/down-search():
  #
  # $_history_substring_search_matches is the current list of matches
  # $_history_substring_search_matches_count is the current number of matches
  # $_history_substring_search_matches_count_plus is the current number of matches + 1
  # $_history_substring_search_matches_count_sans is the current number of matches - 1
  # $_history_substring_search_match_index is the index of the current match
  #
  # The range of values that $_history_substring_search_match_index can take
  # is: [0, $_history_substring_search_matches_count_plus].  A value of 0
  # indicates that we are beyond the end of
  # $_history_substring_search_matches. A value of
  # $_history_substring_search_matches_count_plus indicates that we are beyond
  # the beginning of $_history_substring_search_matches.
  #
  # In _history-substring-search-up-search() the initial value of
  # $_history_substring_search_match_index is
  # $_history_substring_search_matches_count_plus.  This value is set in
  # _history-substring-search-begin().  _history-substring-search-up-search()
  # will initially decrease it to $_history_substring_search_matches_count.
  #
  if [[ $_history_substring_search_match_index -ge 2 ]]; then
    #
    # Highlight the next match:
    #
    # 1. Decrease the value of $_history_substring_search_match_index.
    #
    # 2. Use $HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND
    #    to highlight the current buffer.
    #
    (( _history_substring_search_match_index-- ))
    BUFFER=$history[$_history_substring_search_matches[$_history_substring_search_match_index]]
    _history_substring_search_query_highlight=$HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND

  elif [[ $_history_substring_search_match_index -eq 1 ]]; then
    #
    # We will move beyond the end of $_history_substring_search_matches:
    #
    # 1. Decrease the value of $_history_substring_search_match_index.
    #
    # 2. Save the current buffer in $_history_substring_search_old_buffer,
    #    so that it can be retrieved by
    #    _history-substring-search-down-search() later.
    #
    # 3. Make $BUFFER equal to $_history_substring_search_query.
    #
    # 4. Use $HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND
    #    to highlight the current buffer.
    #
    (( _history_substring_search_match_index-- ))
    _history-substring-search-not-found

  elif [[ $_history_substring_search_match_index -eq $_history_substring_search_matches_count_plus ]]; then
    #
    # We were beyond the beginning of $_history_substring_search_matches but
    # UP makes us move back to $_history_substring_search_matches:
    #
    # 1. Decrease the value of $_history_substring_search_match_index.
    #
    # 2. Restore $BUFFER from $_history_substring_search_old_buffer.
    #
    # 3. Use $HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND
    #    to highlight the current buffer.
    #
    (( _history_substring_search_match_index-- ))
    BUFFER=$_history_substring_search_old_buffer
    _history_substring_search_query_highlight=$HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND

  else
    #
    # We are at the beginning of history and there are no further matches.
    #
    _history-substring-search-not-found
    return
  fi

  #
  # When HIST_FIND_NO_DUPS is set, meaning that only unique command lines from
  # history should be matched, make sure the new and old results are different.
  # But when HIST_IGNORE_ALL_DUPS is set, ZSH already ensures a unique history.
  #
  if [[ ! -o HIST_IGNORE_ALL_DUPS && -o HIST_FIND_NO_DUPS && $BUFFER == $_history_substring_search_result ]]; then
    #
    # Repeat the current search so that a different (unique) match is found.
    #
    _history-substring-search-up-search
  fi
}

_history-substring-search-down-search() {
  _history_substring_search_refresh_display=1

  #
  # Highlight matches during history-substring-up-search:
  #
  # The following constants have been initialized in
  # _history-substring-search-up/down-search():
  #
  # $_history_substring_search_matches is the current list of matches
  # $_history_substring_search_matches_count is the current number of matches
  # $_history_substring_search_matches_count_plus is the current number of matches + 1
  # $_history_substring_search_matches_count_sans is the current number of matches - 1
  # $_history_substring_search_match_index is the index of the current match
  #
  # The range of values that $_history_substring_search_match_index can take
  # is: [0, $_history_substring_search_matches_count_plus].  A value of 0
  # indicates that we are beyond the end of
  # $_history_substring_search_matches. A value of
  # $_history_substring_search_matches_count_plus indicates that we are beyond
  # the beginning of $_history_substring_search_matches.
  #
  # In _history-substring-search-down-search() the initial value of
  # $_history_substring_search_match_index is
  # $_history_substring_search_matches_count.  This value is set in
  # _history-substring-search-begin().
  # _history-substring-search-down-search() will initially increase it to
  # $_history_substring_search_matches_count_plus.
  #
  if [[ $_history_substring_search_match_index -le $_history_substring_search_matches_count_sans ]]; then
    #
    # Highlight the next match:
    #
    # 1. Increase $_history_substring_search_match_index by 1.
    #
    # 2. Use $HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND
    #    to highlight the current buffer.
    #
    (( _history_substring_search_match_index++ ))
    BUFFER=$history[$_history_substring_search_matches[$_history_substring_search_match_index]]
    _history_substring_search_query_highlight=$HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND

  elif [[ $_history_substring_search_match_index -eq $_history_substring_search_matches_count ]]; then
    #
    # We will move beyond the beginning of $_history_substring_search_matches:
    #
    # 1. Increase $_history_substring_search_match_index by 1.
    #
    # 2. Save the current buffer in $_history_substring_search_old_buffer, so
    #    that it can be retrieved by _history-substring-search-up-search()
    #    later.
    #
    # 3. Make $BUFFER equal to $_history_substring_search_query.
    #
    # 4. Use $HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND
    #    to highlight the current buffer.
    #
    (( _history_substring_search_match_index++ ))
    _history-substring-search-not-found

  elif [[ $_history_substring_search_match_index -eq 0 ]]; then
    #
    # We were beyond the end of $_history_substring_search_matches but DOWN
    # makes us move back to the $_history_substring_search_matches:
    #
    # 1. Increase $_history_substring_search_match_index by 1.
    #
    # 2. Restore $BUFFER from $_history_substring_search_old_buffer.
    #
    # 3. Use $HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND
    #    to highlight the current buffer.
    #
    (( _history_substring_search_match_index++ ))
    BUFFER=$_history_substring_search_old_buffer
    _history_substring_search_query_highlight=$HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND

  else
    #
    # We are at the end of history and there are no further matches.
    #
    _history-substring-search-not-found
    return
  fi

  #
  # When HIST_FIND_NO_DUPS is set, meaning that only unique command lines from
  # history should be matched, make sure the new and old results are different.
  # But when HIST_IGNORE_ALL_DUPS is set, ZSH already ensures a unique history.
  #
  if [[ ! -o HIST_IGNORE_ALL_DUPS && -o HIST_FIND_NO_DUPS && $BUFFER == $_history_substring_search_result ]]; then
    #
    # Repeat the current search so that a different (unique) match is found.
    #
    _history-substring-search-down-search
  fi
}

bindkey "$terminfo[kcuu1]" history-substring-search-up
bindkey "$terminfo[kcud1]" history-substring-search-down

#####################################################################


zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'
: undercover && export PS1='C:${PWD//\//\\}> '
: undercover && new_line_before_prompt=no

# Qwen Code PATH block begin
export PATH='/home/bigant/.local/bin':$PATH
# Qwen Code PATH block end
