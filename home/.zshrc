# Set up the prompt

autoload -Uz promptinit
promptinit

setopt histignorealldups sharehistory chasedots autopushd

# Define a default dotfiles info in case the below files aren't available.
function _dotfiles_scm_info {}

[[ -f /usr/facebook/ops/rc/master.zshrc ]] && source /usr/facebook/ops/rc/master.zshrc
[[ -f /usr/share/scm/scm-prompt.sh ]] && source /usr/share/scm/scm-prompt.sh
[[ -f /opt/facebook/hg/share/scm-prompt.sh ]] && source /opt/facebook/hg/share/scm-prompt.sh

setopt PROMPT_SUBST
export PS1='%K{${bg_color:-$color_xanadu}}%n@%2m%k %B%F{magenta}%(4~|...|)%3~ %f%b{%F{yellow}%T%f} [%F{yellow}%?%f]
%F{green}$(_dotfiles_scm_info)%F{white}%# %b%f%k'
# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 100000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history

# Make M-f and M-b better
export WORDCHARS='_'

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
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

alias m=mosh --ssh="ssh -a"


function precmd() {
	print -Pn "\033]0;%~\007"
}

function preexec() {
	print -Pn "\e]0;$1\a"
}

export EDITOR=vim

# Initialize pyenv and rbenv if available
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
(( $+commands[pyenv] )) && eval "$(pyenv init -)"
(( $+commands[rbenv] )) && eval "$(rbenv init -)"

function _sourcebk() {
	# grab the backup version of the script from within the dotfiles directory
	local zshrc_loc="$(readlink ~/.zshrc)"
	local bk="$HOME/${zshrc_loc:h:h}/bk/$2"
	if [[ -f "$1" ]]; then
		source "$1"
	elif [[ -f "$bk" ]]; then
		source "$bk"
	fi
}

_sourcebk /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
_sourcebk /usr/local/share/zsh-history-substring-search/zsh-history-substring-search.zsh zsh-history-substring-search.zsh

# history up and down
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

export PATH=$HOME/.cargo/bin:$HOME/.cabal/bin:$HOME/go/bin:$HOME/bin:$HOME/.local/bin:$HOME/homebrew/bin:/home/linuxbrew/.linuxbrew/bin:$PATH
[ -f ~/.homesick/repos/homeshick/homeshick.sh ] && source ~/.homesick/repos/homeshick/homeshick.sh

# Cargo aliases
alias ccc='cargo check --all-targets'

# Enable direnv if available
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"

# Some colors to use
local color_xanadu="#7D938A"
local color_english_red="#AF3E4D"
local color_vine_green="#34B233"

# TODO: test this out
#fpath=(/opt/cargo/zsh-completions $fpath)

# Nix has highest priority
export PATH="$HOME/.nix-profile/bin:$PATH"

if [[ -e /run/current-system/sw/share/nix-direnv/direnvrc ]]; then
    source /run/current-system/sw/share/nix-direnv/direnvrc
elif [[ -e $HOME/.nix-profile/share/nix-direnv/direnvrc ]]; then
    source $HOME/.nix-profile/share/nix-direnv/direnvrc
fi
. "/opt/cargo/env"

# local overrides (MUST BE AT THE END)
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
