#!/usr/bin/env sh

# https://wiki.archlinux.org/title/Power_management/Wakeup_triggers
printf 'XHC' | sudo tee /proc/acpi/wakeup
