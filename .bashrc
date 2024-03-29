#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# Added by Christian
alias vim='nvim'

function note {
    echo "" >> /home/chris/Documents/obsidian-vaults/Christian/thoughts.md
    echo "$(date "+%Y-%m-%d %a %H:%M:%S")" >> /home/chris/Documents/obsidian-vaults/Christian/thoughts.md
    echo "$@" >> /home/chris/Documents/obsidian-vaults/Christian/thoughts.md
}
function rnote {
    echo "" >> /home/chris/Documents/obsidian-vaults/Christian/Research.md
    echo "$(date "+%Y-%m-%d %a %H:%M:%S")" >> /home/chris/Documents/obsidian-vaults/Christian/Research.md
    echo "$@" >> /home/chris/Documents/obsidian-vaults/Christian/Research.md
}

# 2024-01-27 Sat 23:01:40, for commits with git
function git-commit () { 
    git add -A && git commit -m "$@" 
}

alias dotup='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# 2024-02-17 Sat 10:05:55 ~/.profile didnt work
export PATH="/usr/local/texlive/2023/bin/x86_64-linux:$PATH"

# 2024-02-25 Sun 20:22:49
export EDITOR=nvim
export VISUAL=nvim