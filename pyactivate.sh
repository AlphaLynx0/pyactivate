pyactivate() {
    local dir="$PWD"
    local verbosity=0
    local quiet=0
    
    # Parse verbosity flags
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v)
                verbosity=1
                shift
                ;;
            -vv)
                verbosity=2
                shift
                ;;
            -q|--quiet)
                quiet=1
                shift
                ;;
            *)
                cat >&2 << 'EOF'
pyactivate - Activate Python virtual environment from subdirectories

Searches current and parent directories for .venv or venv folders and
activates the first virtual environment found.

USAGE:
    pyactivate [OPTIONS]

OPTIONS:
    -v, --verbose       Show activation message
    -vv                 Show all directories searched
    -q, --quiet         Suppress all output including errors

EXAMPLES:
    pyactivate          # Silent activation
    pyactivate -v       # Show what was activated
    pyactivate -vv      # Show search process
    pyactivate -q       # Completely silent (no errors)
EOF
                return 1
                ;;
        esac
    done
    
    # list of folder names to test
    declare -ar choices=(.venv venv)

    # walk upward until we hit / or find an activate script
    while [[ "$dir" != "/" ]]; do
        if [[ $verbosity -ge 2 && $quiet -eq 0 ]]; then
            printf "Searching in: %s\n" "$dir"
        fi
        
        for name in "${choices[@]}"; do
            if [[ -f "$dir/$name/bin/activate" ]]; then
                # source into current shell and echo activated version
                # shellcheck disable=SC1090
                source "$dir/$name/bin/activate"
                if [[ $verbosity -ge 1 && $quiet -eq 0 ]]; then
                    printf "Activated %s at %s/%s\n" "$(python --version 2>&1)" "$dir" "$name"
                fi
                return 0
            fi
        done
        dir=$(dirname "$dir")
    done

    if [[ $quiet -eq 0 ]]; then
        printf 'Error: No Python venv found in %s or any parent directory\n' "$PWD" >&2
    fi
    return 1
}
