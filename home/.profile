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

__print_random_pokemon() {
    # https://gitlab.com/phoneybadger/pokemon-colorscripts
    local dir="$HOME/dev/pokemon-colorscripts/colorscripts/small/regular/"
    if [ -d "$dir" ]; then
        export POKEMON="$(find "$dir" -type f -printf "%f\n" | shuf -n 1)"
        command cat "$dir/$POKEMON"
    fi
}

if [ "$TERM_PROGRAM" = "WezTerm" ]; then
    __print_random_pokemon
fi
