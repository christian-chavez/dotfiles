#
# ~/.bashrc
#

source ~/.profile
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
function gitcommit () { 
    git add -A && git commit -m "$@" 
}

# alias dotup='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
# Dotfiles repo helper (bare repo)
dotup() {
  /usr/bin/git --git-dir="$HOME/.dotfiles/" --work-tree="$HOME" "$@"
}

dotupcommit() {
  dotup add -u && dotup commit -m "$*"
}

alias gits="git status"

# 2024-02-17 Sat 10:05:55 ~/.profile didnt work
export PATH="/usr/local/texlive/2023/bin/x86_64-linux:$PATH"

# 2024-02-25 Sun 20:22:49
export EDITOR=nvim
export VISUAL=nvim


# Eternal bash history.
# ---------------------
# Undocumented feature which sets the size to "unlimited".
# http://stackoverflow.com/questions/9457233/unlimited-bash-history
export HISTFILESIZE=
export HISTSIZE=
export HISTTIMEFORMAT="[%F %T] "
# Change the file location because certain bash sessions truncate .bash_history file upon close.
# http://superuser.com/questions/575479/bash-history-truncated-to-500-lines-on-each-login
export HISTFILE=~/.bash_eternal_history
# Force prompt to write history after every command.
# http://superuser.com/questions/20900/bash-history-loss
PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

alias unbl='sudo rfkill unblock bluetooth'
alias blbl='sudo rfkill block bluetooth'

function fr () { 
	echo "$@" >> /home/christian/Documents/obsidian-vaults/Test/Zettelkasten/notes/francais.md
}

alias cor='bspc node -v 500 500'
eval "$(starship init bash)"
# export WINEPREFIX="/home/christian/.wine"

# for open with sumatrapdf
# alias sumatra='env WINEPREFIX="/home/christian/.wine" wine "C:\\Program Files\\SumatraPDF\\SumatraPDF.exe"'
alias sumatra='env WINEPREFIX="/home/christian/wine-32" wine "C:\\Program Files\\SumatraPDF\\SumatraPDF.exe"'
# export WINEPREFIX=~/wine-32
# export WINEARCH=win32

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# 2025-09-08 zathura recent list of pdfs with rofi integration
export PATH="$HOME/Documents/scripts:$PATH"


# 2025-09-26 Autopairs para Bash
source ~/.bash-autopairs/autopairs.sh

# 2026-01-02
alias rm='safe-rm'

# 2026-03-14
# function to download from youtube
ytdl() {
    yt-dlp -f "bestvideo[height<=1080][vcodec^=av01]+bestaudio/bestvideo[height<=1080][vcodec^=vp9]+bestaudio/bestvideo[height<=1080]+bestaudio/best" \
           --merge-output-format mp4 \
           -N 4 \
           "$1"
}

#2026-03-16

zks() {
    local vault="/home/christian/Documents/obsidian-vaults/Test/Zettelkasten"
    
    local result=$(
        cd "$vault" || return
        
        (
            # 1. Inject filenames (Strictly .md, sorted by newest first)
            rg --files --glob "*.md" --sortr modified | awk -F/ '{print $0":1:\033[36m[FILE]\033[0m " $NF}'
            
            # 2. Add contents (Strictly .md, sorted by newest first)
            rg --glob "*.md" --sortr modified --line-number --no-heading --color=always ""
        ) | fzf --ansi \
            --delimiter : \
            --nth 3.. \
            --no-sort \
            --preview "bat --color=always --style=numbers --highlight-line {2} {1} 2>/dev/null || cat {1}" \
            --preview-window "right:60%:+{2}-/3"
    )
    
    if [ -n "$result" ]; then
        local file=$(echo "$result" | cut -d: -f1)
        local line=$(echo "$result" | cut -d: -f2)
        
        nvim "+$line" "$vault/$file"
    fi
}
