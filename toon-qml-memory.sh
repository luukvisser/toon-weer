#!/bin/bash
# Shows memory usage of all QML apps running on the Toon device.
# Usage: ssh root@<toon-ip> 'bash -s' < toon-qml-memory.sh
#    or: copy to Toon and run directly: ./toon-qml-memory.sh

# Disable colors when not writing to a terminal (e.g. piped/redirected output)
if [ -t 1 ]; then
    BOLD='\033[1m'
    DIM='\033[2m'
    CYAN='\033[0;36m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    RESET='\033[0m'
else
    BOLD='' DIM='' CYAN='' GREEN='' YELLOW='' RESET=''
fi

HR="$(printf '%0.s-' {1..80})"

print_header() {
    echo
    printf "${BOLD}${CYAN}  Toon – QML App Memory Usage${RESET}\n"
    printf "${DIM}  $(date '+%Y-%m-%d %H:%M:%S')${RESET}\n"
    echo "  $HR"
    printf "  ${BOLD}%-8s %-32s %9s %9s %9s${RESET}\n" \
        "PID" "Process" "RSS" "PSS" "VSZ"
    echo "  $HR"
}

# Collect one line per QML process into a temp file so we can sort by PSS.
tmpfile=$(mktemp /tmp/toon-mem-XXXXXX)
trap 'rm -f "$tmpfile"' EXIT

total_rss_kb=0
total_pss_kb=0
count=0

for pid_dir in /proc/[0-9]*/; do
    pid="${pid_dir%/}"
    pid="${pid##*/}"

    maps_file="${pid_dir}maps"
    [ -r "$maps_file" ] || continue

    # Only consider processes that have loaded Qt Quick / QML shared libraries.
    grep -qE "libQt5Quick|libQt5Qml|libqmlscene|/qml/" "$maps_file" 2>/dev/null || continue

    # --- process name ---
    comm=$(cat "${pid_dir}comm" 2>/dev/null | tr -d '\n')
    [ -z "$comm" ] && comm="?"

    # --- RSS and VSZ from /proc/PID/status ---
    status_file="${pid_dir}status"
    vm_rss=$(awk '/^VmRSS:/{print $2; exit}' "$status_file" 2>/dev/null)
    vm_size=$(awk '/^VmSize:/{print $2; exit}' "$status_file" 2>/dev/null)
    vm_rss=${vm_rss:-0}
    vm_size=${vm_size:-0}

    # --- PSS from smaps_rollup (Linux ≥4.14) or fall back to smaps ---
    smaps_rollup="${pid_dir}smaps_rollup"
    smaps="${pid_dir}smaps"
    if [ -r "$smaps_rollup" ]; then
        pss=$(awk '/^Pss:/{print $2; exit}' "$smaps_rollup" 2>/dev/null)
    elif [ -r "$smaps" ]; then
        pss=$(awk '/^Pss:/{s+=$2} END{print s+0}' "$smaps" 2>/dev/null)
    fi
    pss=${pss:-0}

    # Store as "pss_kb pid comm rss_kb vsz_kb" for sort -n
    echo "$pss $pid $comm $vm_rss $vm_size" >> "$tmpfile"

    total_rss_kb=$((total_rss_kb + vm_rss))
    total_pss_kb=$((total_pss_kb + pss))
    count=$((count + 1))
done

print_header

if [ "$count" -eq 0 ]; then
    echo
    printf "  ${YELLOW}No QML processes found.${RESET}\n"
    echo
    exit 0
fi

# Print rows sorted by PSS descending (largest first)
sort -rn "$tmpfile" | while read -r pss pid comm rss vsz; do
    rss_fmt=$(awk "BEGIN{printf \"%.1f MB\", $rss/1024}")
    pss_fmt=$(awk "BEGIN{printf \"%.1f MB\", $pss/1024}")
    vsz_fmt=$(awk "BEGIN{printf \"%.1f MB\", $vsz/1024}")
    printf "  ${GREEN}%-8s${RESET} %-32s %9s %9s %9s\n" \
        "$pid" "$comm" "$rss_fmt" "$pss_fmt" "$vsz_fmt"
done

echo "  $HR"

total_rss_fmt=$(awk "BEGIN{printf \"%.1f MB\", $total_rss_kb/1024}")
total_pss_fmt=$(awk "BEGIN{printf \"%.1f MB\", $total_pss_kb/1024}")
printf "  ${BOLD}%-41s %9s %9s${RESET}\n" \
    "Total  ($count QML process$([ "$count" -ne 1 ] && echo 'es'))" \
    "$total_rss_fmt" "$total_pss_fmt"
echo "  $HR"

echo
printf "  ${DIM}RSS  Resident Set Size   – physical RAM the process is using\n"
printf "  PSS  Proportional Set Size – RSS minus shared pages (most accurate)\n"
printf "  VSZ  Virtual Memory Size   – total virtual address space reserved${RESET}\n"
echo
