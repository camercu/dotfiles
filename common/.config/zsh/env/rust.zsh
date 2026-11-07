#!/usr/bin/env zsh

# RUSTUP_HOME, CARGO_HOME: rust.sh. rustup and its cargo/rustc proxies come
# from nix; this adds the tools `cargo install` puts in CARGO_HOME.
export PATH="${PATH}:${CARGO_HOME}/bin"
