# execute commands in init
# ncal -3
# jcal -3

# Set up the prompt
autoload -Uz promptinit
promptinit
prompt adam2

# ---------------------------------------------------------
# Git Integration - Custom Function (Fast & Reliable)
# ---------------------------------------------------------

_git_prompt_info() {
  local branch git_status staged unstaged untracked output
  
  # دریافت نام شاخه (اگر در repo نباشیم، تابع خروجی ندارد)
  branch=$(git symbolic-ref --short HEAD 2>/dev/null) || return
  
  # دریافت وضعیت کامل فایل‌ها
  git_status=$(git status --porcelain 2>/dev/null)
  
  if [[ -n "$git_status" ]]; then
    # بررسی فایل‌های staged (ستون اول: M, A, D, R, C)
    if echo "$git_status" | grep -qE '^[MADRC]'; then
      staged="%F{yellow}[staged]✚%f"
    fi
    
    # بررسی فایل‌های unstaged (ستون دوم: M, D)
    if echo "$git_status" | grep -qE '^.[MD]'; then
      unstaged="%F{red}[unstaged]%f"
    fi
    
    # بررسی فایل‌های untracked (ستون اول: ??)
    if echo "$git_status" | grep -qE '^\?\?'; then
      untracked="%F{blue}[untracked]%f"
    fi
  fi
  
  # ساخت خروجی نهایی
  output=" %F{green} ${branch}"
  [[ -n "$staged" ]] && output+="$staged"
  [[ -n "$unstaged" ]] && output+="$unstaged"
  [[ -n "$untracked" ]] && output+="$untracked"
  output+="%f"
  
  echo "$output"
}

# تابع به‌روزرسانی پرامپت
_update_git_prompt() {
  local git_info=$(_git_prompt_info)
  if [[ -n "$git_info" ]]; then
    RPROMPT="$git_info"
  else
    RPROMPT=""
  fi
}

# اضافه کردن تابع به چرخه precmd
precmd_functions+=(_update_git_prompt)
# ---------------------------------------------------------

setopt histignorealldups sharehistory
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Aliases
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
# alias bv1='xrandr --output VGA1 --brightness '
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

if [[ $+functions[_zsh_highlight] -eq 0 ]]; then
  _zsh_highlight() {
    if [[ $KEYS == [[:print:]] ]]; then
      region_highlight=()
    fi
  }

  _zsh_highlight_bind_widgets()
  {
    zmodload zsh/zleparameter 2>/dev/null || {
      echo 'zsh-syntax-highlighting: failed loading zsh/zleparameter.' >&2
      return 1
    }

    local cur_widget
    for cur_widget in ${${(f)"$(builtin zle -la)"}:#(.*|_*|orig-*|run-help|which-command|beep|yank*)}; do
      case $widgets[$cur_widget] in
        user:$cur_widget|user:_zsh_highlight_widget_*);;
        user:*) eval "zle -N orig-$cur_widget ${widgets[$cur_widget]#*:}; \
                      _zsh_highlight_widget_$cur_widget() { builtin zle orig-$cur_widget -- \"\$@\" && _zsh_highlight }; \
                      zle -N $cur_widget _zsh_highlight_widget_$cur_widget";;
        completion:*) eval "zle -C orig-$cur_widget ${${widgets[$cur_widget]#*:}/:/ }; \
                            _zsh_highlight_widget_$cur_widget() { builtin zle orig-$cur_widget -- \"\$@\" && _zsh_highlight }; \
                            zle -N $cur_widget _zsh_highlight_widget_$cur_widget";;
        builtin) eval "_zsh_highlight_widget_$cur_widget() { builtin zle .$cur_widget -- \"\$@\" && _zsh_highlight }; \
                       zle -N $cur_widget _zsh_highlight_widget_$cur_widget";;
        *) echo "zsh-syntax-highlighting: unhandled ZLE widget '$cur_widget'" >&2 ;;
      esac
    done
  }

  _zsh_highlight_bind_widgets
fi

_history-substring-search-begin() {
  setopt localoptions extendedglob

  _history_substring_search_refresh_display=
  _history_substring_search_query_highlight=

  if [[ -z $BUFFER || $BUFFER != $_history_substring_search_result ]]; then
    _history_substring_search_query=$BUFFER
    _history_substring_search_query_escaped=${BUFFER//(#m)[\][()|\\*?#<>~^]/\\$MATCH}
    _history_substring_search_matches=(${(kOa)history[(R)(#$HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS)*${_history_substring_search_query_escaped}*]})

    _history_substring_search_matches_count=$#_history_substring_search_matches
    _history_substring_search_matches_count_plus=$(( _history_substring_search_matches_count + 1 ))
    _history_substring_search_matches_count_sans=$(( _history_substring_search_matches_count - 1 ))

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

  if [[ $_history_substring_search_refresh_display -eq 1 ]]; then
    region_highlight=()
    CURSOR=${#BUFFER}
  fi

  _zsh_highlight

  if [[ -n $_history_substring_search_query_highlight && -n $_history_substring_search_query ]]; then
    : ${(S)BUFFER##(#m$HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS)($_history_substring_search_query##)}
    local begin=$(( MBEGIN - 1 ))
    local end=$(( begin + $#_history_substring_search_query ))
    region_highlight+=("$begin $end $_history_substring_search_query_highlight")
  fi

  return 0
}

_history-substring-search-up-buffer() {
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
  if [[ -z $_history_substring_search_query ]]; then
    if [[ $HISTNO -eq 1 ]]; then
      BUFFER=
    else
      zle up-line-or-history
    fi
    return 0
  fi
  return 1
}

_history-substring-search-down-history() {
  if [[ -z $_history_substring_search_query ]]; then
    if [[ $HISTNO -eq 1 && -z $BUFFER ]]; then
      BUFFER=${history[1]}
      _history_substring_search_refresh_display=1
    else
      zle down-line-or-history
    fi
    return 0
  fi
  return 1
}

_history-substring-search-not-found() {
  _history_substring_search_old_buffer=$BUFFER
  BUFFER=$_history_substring_search_query
  _history_substring_search_query_highlight=$HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND
}

_history-substring-search-up-search() {
  _history_substring_search_refresh_display=1

  if [[ $_history_substring_search_match_index -ge 2 ]]; then
    (( _history_substring_search_match_index-- ))
    BUFFER=$history[$_history_substring_search_matches[$_history_substring_search_match_index]]
    _history_substring_search_query_highlight=$HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND
  elif [[ $_history_substring_search_match_index -eq 1 ]]; then
    (( _history_substring_search_match_index-- ))
    _history-substring-search-not-found
  elif [[ $_history_substring_search_match_index -eq $_history_substring_search_matches_count_plus ]]; then
    (( _history_substring_search_match_index-- ))
    BUFFER=$_history_substring_search_old_buffer
    _history_substring_search_query_highlight=$HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND
  else
    _history-substring-search-not-found
    return
  fi

  if [[ ! -o HIST_IGNORE_ALL_DUPS && -o HIST_FIND_NO_DUPS && $BUFFER == $_history_substring_search_result ]]; then
    _history-substring-search-up-search
  fi
}

_history-substring-search-down-search() {
  _history_substring_search_refresh_display=1

  if [[ $_history_substring_search_match_index -le $_history_substring_search_matches_count_sans ]]; then
    (( _history_substring_search_match_index++ ))
    BUFFER=$history[$_history_substring_search_matches[$_history_substring_search_match_index]]
    _history_substring_search_query_highlight=$HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND
  elif [[ $_history_substring_search_match_index -eq $_history_substring_search_matches_count ]]; then
    (( _history_substring_search_match_index++ ))
    _history-substring-search-not-found
  elif [[ $_history_substring_search_match_index -eq 0 ]]; then
    (( _history_substring_search_match_index++ ))
    BUFFER=$_history_substring_search_old_buffer
    _history_substring_search_query_highlight=$HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND
  else
    _history-substring-search-not-found
    return
  fi

  if [[ ! -o HIST_IGNORE_ALL_DUPS && -o HIST_FIND_NO_DUPS && $BUFFER == $_history_substring_search_result ]]; then
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
export PATH='/home/sassiz/.local/bin':$PATH
# Qwen Code PATH block end
