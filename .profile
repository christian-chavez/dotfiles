export PATH="/usr/local/texlive/2023/bin/x86_64-linux:$PATH"
export RANGER_LOAD_DEFAULT_RC=false
export RANGER_DEVICONS_SEPARATOR="  "
# export WINEPREFIX="$HOME/.wine"
#alias sumatra='env WINEPREFIX="/home/christian/.wine" wine "C:\\Program Files\\SumatraPDF\\SumatraPDF.exe"'
alias blank='xset s on -dpms'
alias noblank='xset s off -dpms'
alias bsprc='nvim ~/.config/bspwm/bspwmrc'
alias cl='calc'
alias sxhrc='nvim ~/.config/sxhkd/sxhkdrc'
alias lf='.lf-gadgets/lf-ueberzug/lf-ueberzug ~'
alias camera='mpv av://v4l2:/dev/video0 --profile=low-latency --untimed --no-correct-pts > /dev/null 2>&1 &'
export GEM_HOME="$HOME/.local/share/gem/ruby/3.3.0"
export PATH="$GEM_HOME/bin:$PATH"
# 2025-09-08 zathura recent list of pdfs with rofi integration
export PATH="$HOME/Documents/scripts:$PATH"
alias morning="mpv --loop-playlist=no --loop-file=no --start=0 --no-resume-playback /home/christian/Videos/morning-exercise.mp4"
alias meditacion="mpv --no-video --loop-playlist=no --loop-file=no --start=0 --no-resume-playback /home/christian/Videos/meditacion-mañana.mp4"
alias mwander="/home/christian/Documents/scripts/wander.sh"
alias qsc="Documents/scripts/quick-capture.sh"
alias zim='/home/christian/Documents/scripts/zettelkasten-vim.sh'
alias xp="xclip -selection c"
