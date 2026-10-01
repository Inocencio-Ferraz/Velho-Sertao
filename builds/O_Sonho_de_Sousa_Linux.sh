#!/bin/sh
printf '\033c\033]0;%s\a' O Sonho de Sousa
base_path="$(dirname "$(realpath "$0")")"
"$base_path/O_Sonho_de_Sousa_Linux.x86_64" "$@"
