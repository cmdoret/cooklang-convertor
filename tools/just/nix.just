set positional-arguments := true
set shell := ["bash", "-cue"]

[private]
default:
    just --list nix

# Enter the Nix development shell `$1` and execute the command `${@:2}`.
[no-cd]
develop *args:
    #!/usr/bin/env bash
    set -eu -o pipefail
    root_dir=$(git rev-parse --show-toplevel) || exit 1
    flake_dir="$root_dir/tools/nix"

    shell="$1"; shift 1;
    nix_args=()
    args=("$@") && [ "${#args[@]}" != 0 ] ||
        args=(env SHELL="$SHELL" "$SHELL")

    nix develop \
        "${nix_args[@]}" \
        --extra-experimental-features flakes \
        --extra-experimental-features nix-command \
        --accept-flake-config \
        "$flake_dir#$shell" \
        --command "${args[@]}"

# Start an Nix interpreter with loaded flake.
[no-cd]
repl:
    #!/usr/bin/env bash
    set -eu -o pipefail

    nix_args=()

    root_dir=$(git rev-parse --show-toplevel) || exit 1
    flake_dir="$root_dir/tools/nix"

    nix repl \
        "${nix_args[@]}" \
        --accept-flake-config \
        "$flake_dir"
