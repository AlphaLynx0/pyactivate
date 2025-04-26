pyactivate() {
    local dir="$PWD"
    # list of folder names to test
    declare -ar choices=(.venv venv)

    # walk upward until we hit / or find an activate script
    while [[ "$dir" != "/" ]]; do
        for name in "${choices[@]}"; do
            if [[ -f "$dir/$name/bin/activate" ]]; then
                # source into current shell and echo activated version
                # shellcheck disable=SC1090
                source "$dir/$name/bin/activate"
                printf "Activated %s at %s/%s\n" "$(python --version 2>&1)" "$dir" "$name"
                return 0
            fi
        done
        dir=$(dirname "$dir")
    done

    printf 'Error: No Python venv found in %s or any parent directory\n' "$PWD" >&2
    return 1
}
