#!/usr/bin/env bash
info() { printf "%b[INFO]%b %s\n" "$C_BLUE" "$C_RESET" "$*"; }
success() { printf "%b[OK]%b %s\n" "$C_GREEN" "$C_RESET" "$*"; }
warn() { printf "%b[WARN]%b %s\n" "$C_YELLOW" "$C_RESET" "$*"; }
error() { printf "%b[FAIL]%b %s\n" "$C_RED" "$C_RESET" "$*"; }
die() { error "$*"; exit 1; }
section() { printf "\n%b%s%b\n" "$C_BOLD" "$*" "$C_RESET"; }
