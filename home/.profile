DOTFILES=$HOME/.dotfiles

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
    if [ -f "$DOTFILES/work/.bashrc" ]; then
        . "$DOTFILES/work/.bashrc"
    fi
fi

if [[ "$TERM_PROGRAM" != "vscode" && "$(command -v lolcat >/dev/null)" ]]; then
    lolcat <<EOF
⠀⠀⠀⠀⢀⣤⢤⡀
⠀⣠⠤⠤⠋⢁⠰⢼⡤⢤⣀
⢾⠁⠀⠀⠀⣵⠋⠳⡜⡆⠀⠉⠓⠲⠤⠤⢤⣀⡀
⠈⠳⣒⢄⣀⠻⢻⣟⣵⢻⡿⣿⣦⣄⠀⠀⠀⠀⠉⠳⣄
⠀⠀⠈⠙⣖⠭⣑⠠⠰⢬⠜⠀⠈⠻⢷⣶⣤⡀⠀⠀⠈⠻⣟⣶⣄
⠀⠀⠀⠀⠘⢦⡀⠉⠀⠀⠈⠁⠀⠀⠀⠈⠙⠻⢷⣆⡀⠀⠈⢯⡟
⠀⠀⠀⠀⠀⠀⢹⣦⣀⠀⠀⠀⠀⠐⢄⠀⠀⠁⠢⡈⠻⣦⢀⡀⢱⣀⣀⡀
⠀⠀⠀⢀⣠⣼⣝⣿⣿⣷⣄⡘⢄⠀⠀⠢⡀⠀⠀⡰⠊⢀⡤⠞⠉⠀⠈⢳
⠸⠿⠟⣛⡿⣿⠾⡿⣟⠿⢿⣻⢳⠃⠀⠀⢸⠀⣸⠁⠀⡌⠀⠀⠀⢀⠄⡞
⠀⠀⠯⠵⠉⠀⣀⠸⡿⢧⢤⣀⠏⠀⠀⠀⡎⠉⢧⠀⠀⠀⠀⢀⡰⠃⡼⠃
⠀⠀⠀⠀⠀⠘⢭⡭⢍⣉⠂⠉⠀⠀⣠⡾⠃⢀⣈⡢⠤⠄⢒⠁⢠⡞⠁
⠀⠀⠀⠀⠀⠀⠯⠬⠐⠒⠒⠒⠒⠒⠋⠀⠀⣹⣶⡿⢛⠔⣁⡴⠋
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⡠⢼⠍⣓⢵⠞⡡⠞⠁
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠓⠚⠉⠀⠈⠉⠁
EOF
fi
