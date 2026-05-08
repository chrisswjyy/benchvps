#!/usr/bin/env bash
BRAND="VPS TESTER BY CHRISS"
VERSION="v2.0"
CREDIT="t.me/chriswijayaa"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

spinner() {
  local pid=$1 msg=$2
  local frames=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')
  local i=0
  while kill -0 "$pid" 2>/dev/null; do
    printf "\r  ${CYAN}${frames[$i]}${NC}  ${WHITE}%s${NC}   " "$msg"
    i=$(( (i+1) % ${#frames[@]} ))
    sleep 0.08
  done
  printf "\r  ${GREEN}✔${NC}  ${WHITE}%s${NC}   \n" "$msg"
}

pbar() {
  local label=$1
  printf "  ${WHITE}%-20s${NC} [" "$label"
  local i=0
  while [ $i -lt 40 ]; do
    printf "${GREEN}█${NC}"
    sleep 0.012
    i=$((i+1))
  done
  printf "] ${GREEN}DONE${NC}\n"
}

tw() {
  local t=$1 c=$2 i=0
  while [ $i -lt ${#t} ]; do
    printf "${c}${t:$i:1}${NC}"
    sleep 0.018
    i=$((i+1))
  done
  echo ""
}

sec() {
  echo ""
  echo -e "  ${CYAN}┌──────────────────────────────────────────────────────┐${NC}"
  echo -e "  ${CYAN}│${NC}  $2  ${BOLD}${WHITE}$1${NC}$(printf '%*s' $((52-${#1}-5)) '')${CYAN}│${NC}"
  echo -e "  ${CYAN}└──────────────────────────────────────────────────────┘${NC}"
}

row() {
  printf "  ${DIM}│${NC}  ${YELLOW}%-20s${NC} ${DIM}:${NC}  ${3:-$WHITE}%s${NC}\n" "$1" "$2"
}

ubar() {
  local used=$1 total=$2 label=$3
  local pct bars i
  pct=$(awk "BEGIN{printf \"%.1f\",$used/$total*100}")
  bars=$(( used * 30 / total ))
  printf "  ${WHITE}%-12s${NC} [" "$label"
  i=0
  while [ $i -lt 30 ]; do
    if [ $i -lt "$bars" ]; then
      if   [ $i -lt 10 ]; then printf "${GREEN}█${NC}"
      elif [ $i -lt 22 ]; then printf "${YELLOW}█${NC}"
      else printf "${RED}█${NC}"; fi
    else printf "${DIM}░${NC}"; fi
    i=$((i+1))
  done
  printf "] ${BOLD}%s%%${NC}\n" "$pct"
}

clear
echo ""
echo -e "  ${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "  ${CYAN}║${NC}  ${MAGENTA}${BOLD}  $BRAND${NC}  ${DIM}$VERSION${NC}$(printf '%*s' 9 '')${CYAN}║${NC}"
echo -e "  ${CYAN}║${NC}  ${DIM}  $CREDIT${NC}$(printf '%*s' 36 '')${CYAN}║${NC}"
echo -e "  ${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
tw "  Nyiapin mesin benchmark, bentar..." "$CYAN"
sleep 0.3
echo ""
echo -e "  ${WHITE}Loading:${NC}"
pbar "Info Sistem"
pbar "RAM"
pbar "Storage"
pbar "CPU"
pbar "GPU"
pbar "Jaringan"
pbar "Keamanan"
echo ""
echo -e "  ${GREEN}✔  Semua siap, mulai scan...${NC}"
sleep 0.5

# ── SYSTEM INFO ──────────────────────────────────────────
sec "INFO SISTEM" "🖥️"
OS=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2)
KERNEL=$(uname -r)
ARCH=$(uname -m)
HOSTN=$(hostname)
UPTIME=$(uptime -p 2>/dev/null || uptime | awk -F'( |,|:)+' '{print $6"h "$7"m"}')
VIRT=$(systemd-detect-virt 2>/dev/null || echo "Unknown")
echo ""
row "OS"             "$OS"     "$WHITE"
row "Kernel"         "$KERNEL" "$WHITE"
row "Architecture"   "$ARCH"   "$CYAN"
row "Hostname"       "$HOSTN"  "$CYAN"
row "Uptime"         "$UPTIME" "$GREEN"
row "Virtualization" "$VIRT"   "$YELLOW"

# ── RAM ──────────────────────────────────────────────────
sec "MEMORI (RAM)" "🧠"
TR=$(free -m | awk '/^Mem:/{print $2}')
UR=$(free -m | awk '/^Mem:/{print $3}')
FR=$(free -m | awk '/^Mem:/{print $4}')
CR=$(free -m | awk '/^Mem:/{print $6}')
ST=$(free -m | awk '/^Swap:/{print $2}')
SU=$(free -m | awk '/^Swap:/{print $3}')
UP=$(awk "BEGIN{printf \"%.1f\",$UR/$TR*100}")
echo ""
row "Total RAM"    "${TR} MB"          "$WHITE"
row "Used RAM"     "${UR} MB (${UP}%)" "$YELLOW"
row "Free RAM"     "${FR} MB"          "$GREEN"
row "Cache/Buffer" "${CR} MB"          "$CYAN"
row "Swap Total"   "${ST} MB"          "$WHITE"
row "Swap Used"    "${SU} MB"          "$YELLOW"
echo ""
ubar "$UR" "$TR" "RAM Usage:"

# ── STORAGE ──────────────────────────────────────────────
sec "STORAGE" "💾"
TD=$(df -h / | awk 'NR==2{print $2}')
UD=$(df -h / | awk 'NR==2{print $3}')
FD=$(df -h / | awk 'NR==2{print $4}')
DP=$(df /    | awk 'NR==2{print $5}' | tr -d '%')
RD=$(lsblk -no pkname "$(df / | awk 'NR==2{print $1}')" 2>/dev/null | head -1)
[ -z "$RD" ] && RD=$(df / | awk 'NR==2{print $1}' | sed 's|/dev/||;s|[0-9p]*$||')
DT="Unknown"; DL="Unknown"
if echo "$RD" | grep -qi nvme; then
  DT="${GREEN}SSD NVMe ⚡${NC}"; DL="SSD NVMe"
elif [ "$(cat /sys/block/${RD}/queue/rotational 2>/dev/null)" = "0" ]; then
  DT="${CYAN}SSD 💨${NC}"; DL="SSD"
elif [ "$(cat /sys/block/${RD}/queue/rotational 2>/dev/null)" = "1" ]; then
  DT="${YELLOW}HDD 🔄${NC}"; DL="HDD"
fi
echo ""
row "Total" "$TD"         "$WHITE"
row "Used"  "$UD (${DP}%)" "$YELLOW"
row "Free"  "$FD"         "$GREEN"
printf "  ${DIM}│${NC}  ${YELLOW}%-20s${NC} ${DIM}:${NC}  ${DT}\n" "Disk Type"
echo ""
ubar "$DP" "100" "Disk Usage:"

# ── CPU ──────────────────────────────────────────────────
sec "CPU BENCHMARK" "⚙️"
CM=$(grep -m1 'model name' /proc/cpuinfo | cut -d: -f2 | xargs)
CC=$(nproc)
CT=$(grep -c processor /proc/cpuinfo)
CF=$(grep -m1 'cpu MHz' /proc/cpuinfo | cut -d: -f2 | xargs | awk '{printf "%.0f MHz",$1}')
CCH=$(grep -m1 'cache size' /proc/cpuinfo | cut -d: -f2 | xargs)
CU=$(top -bn2 | grep "Cpu(s)" | tail -1 | awk '{print $2+$4}')
echo ""
row "Model"          "$CM"       "$WHITE"
row "Cores/Threads"  "$CC / $CT" "$CYAN"
row "Frequency"      "$CF"       "$YELLOW"
row "Cache"          "$CCH"      "$WHITE"
row "Current Usage"  "${CU}%"    "$GREEN"
echo ""
echo -e "  ${WHITE}Lagi ngitung Pi 5000 digit, tunggu...${NC}"
BS=$(date +%s%N)
echo "scale=5000; 4*a(1)" | bc -l > /dev/null 2>&1 &
BPID=$!
spinner "$BPID" "Ngitung Pi, sabar..."
wait "$BPID"
BE=$(date +%s%N)
BM=$(( (BE - BS) / 1000000 ))
row "Pi Benchmark" "${BM} ms" "$GREEN"

# ── GPU ──────────────────────────────────────────────────
sec "GPU" "🎮"
echo ""
if command -v nvidia-smi &>/dev/null; then
  row "GPU Model"    "$(nvidia-smi --query-gpu=name            --format=csv,noheader 2>/dev/null | head -1)" "$GREEN"
  row "VRAM Total"   "$(nvidia-smi --query-gpu=memory.total    --format=csv,noheader 2>/dev/null | head -1)" "$WHITE"
  row "VRAM Used"    "$(nvidia-smi --query-gpu=memory.used     --format=csv,noheader 2>/dev/null | head -1)" "$YELLOW"
  row "GPU Util"     "$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader 2>/dev/null | head -1)" "$CYAN"
  row "Temperature"  "$(nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader 2>/dev/null | head -1)°C" "$YELLOW"
else
  GI=$(lspci 2>/dev/null | grep -i 'vga\|3d\|display' | head -1 | cut -d: -f3 | xargs)
  if [ -n "$GI" ]; then
    row "GPU Detected" "$GI" "$YELLOW"
  else
    row "GPU" "No dedicated GPU / Virtual instance" "$DIM"
  fi
fi

# ── NETWORK ──────────────────────────────────────────────
sec "CEK JARINGAN" "🌐"
echo ""
echo -e "  ${WHITE}Lagi tes kecepatan via Cloudflare...${NC}"
echo ""
DL=$(curl -o /dev/null -s -w "%{speed_download}" --max-time 15 \
     "https://speed.cloudflare.com/__down?bytes=50000000" 2>/dev/null)
DLMBPS=$(echo "$DL" | awk '{printf "%.2f",$1/131072}')
UL=$(curl -s -w "%{speed_upload}" --max-time 15 -X POST \
     -d "$(head -c 3000000 /dev/urandom | base64)" \
     "https://speed.cloudflare.com/__up" 2>/dev/null | tail -1)
ULMBPS=$(echo "$UL" | awk '{printf "%.2f",$1/131072}')
LAT=$(ping -c 4 1.1.1.1 2>/dev/null | tail -1 | awk -F'/' '{printf "%.2f ms",$5}')
LATG=$(ping -c 3 8.8.8.8 2>/dev/null | tail -1 | awk -F'/' '{printf "%.2f ms",$5}')
row "Download"         "${DLMBPS} Mbps" "$GREEN"
row "Upload"           "${ULMBPS} Mbps" "$CYAN"
row "Latency (CF)"     "$LAT"           "$YELLOW"
row "Latency (Google)" "$LATG"          "$YELLOW"
echo ""
DLI=$(echo "$DLMBPS" | cut -d. -f1)
DB2=$(( DLI > 100 ? 30 : DLI * 30 / 100 ))
printf "  ${WHITE}%-12s${NC} [" "Download:"
i=0
while [ $i -lt 30 ]; do
  [ $i -lt "$DB2" ] && printf "${GREEN}█${NC}" || printf "${DIM}░${NC}"
  i=$((i+1))
done
printf "] ${BOLD}%s Mbps${NC}\n" "$DLMBPS"

# ── SECURITY ─────────────────────────────────────────────
sec "KEAMANAN & CEK IP" "🔐"
echo ""
echo -e "  ${WHITE}Ngecek info IP...${NC}"
IPJ=$(curl -s --max-time 8 "https://ipinfo.io/json" 2>/dev/null)
PIP=$(echo "$IPJ" | grep '"ip"'       | cut -d'"' -f4)
CTR=$(echo "$IPJ" | grep '"country"'  | cut -d'"' -f4)
CTY=$(echo "$IPJ" | grep '"city"'     | cut -d'"' -f4)
REG=$(echo "$IPJ" | grep '"region"'   | cut -d'"' -f4)
ORG=$(echo "$IPJ" | grep '"org"'      | cut -d'"' -f4)
TZ=$(echo  "$IPJ" | grep '"timezone"' | cut -d'"' -f4)
echo ""
row "Public IP"     "$PIP"          "$CYAN"
row "Country"       "$CTR"          "$WHITE"
row "Region/City"   "$REG / $CTY"   "$WHITE"
row "Provider/ASN"  "$ORG"          "$YELLOW"
row "Timezone"      "$TZ"           "$WHITE"
echo ""
echo -e "  ${WHITE}Ngecek blacklist (4 database)...${NC}"
BLC=0; BLH=""
REVI=$(echo "$PIP" | awk -F. '{print $4"."$3"."$2"."$1}')
for BL in zen.spamhaus.org bl.spamcop.net dnsbl.sorbs.net b.barracudacentral.org; do
  RES=$(host "${REVI}.${BL}" 2>/dev/null | grep "has address")
  [ -n "$RES" ] && { BLC=$((BLC+1)); BLH="$BLH $BL"; }
done
echo ""
if [ "$BLC" -eq 0 ]; then
  row "Blacklist" "CLEAN - 0 hits dari 4 database" "$GREEN"
  row "Verdict"   "✔  VPS aman, ga ada yang nge-flag" "$GREEN"
else
  row "Blacklist" "KENA $BLC database!" "$RED"
  row "Listed DB" "$BLH"                "$RED"
  row "Verdict"   "⚠  VPS ini bermasalah, hati-hati" "$RED"
fi
if echo "$ORG" | grep -qi "digitalocean\|linode\|vultr\|hetzner\|aws\|gcp\|azure\|ovh\|alibaba"; then
  row "Provider Trust" "✔  Provider gede, terpercaya"       "$GREEN"
elif echo "$ORG" | grep -qi "frantech\|buyvm\|sharktech\|psychz\|leaseweb"; then
  row "Provider Trust" "⚠  Provider abu-abu, waspadai"      "$YELLOW"
else
  row "Provider Trust" "?  Provider ga dikenal, cek manual" "$YELLOW"
fi

# ── SUMMARY ──────────────────────────────────────────────
echo ""
echo ""
echo -e "  ${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "  ${CYAN}║${NC}            ${BOLD}${WHITE}    HASIL BENCHMARK VPS      ${NC}            ${CYAN}║${NC}"
echo -e "  ${CYAN}╠══════════════════════════════════════════════════════════╣${NC}"
printf "  ${CYAN}║${NC}  ${YELLOW}%-20s${NC}  ${WHITE}%-35s${NC}${CYAN}║${NC}\n" "OS"         "$(echo "$OS" | cut -c1-35)"
printf "  ${CYAN}║${NC}  ${YELLOW}%-20s${NC}  ${WHITE}%-35s${NC}${CYAN}║${NC}\n" "CPU"        "$(echo "$CM" | cut -c1-35)"
printf "  ${CYAN}║${NC}  ${YELLOW}%-20s${NC}  ${WHITE}%-35s${NC}${CYAN}║${NC}\n" "RAM"        "${TR} MB | Used: ${UP}%"
printf "  ${CYAN}║${NC}  ${YELLOW}%-20s${NC}  ${WHITE}%-35s${NC}${CYAN}║${NC}\n" "Storage"    "${TD} ${DL} | Used: ${DP}%"
printf "  ${CYAN}║${NC}  ${YELLOW}%-20s${NC}  ${WHITE}%-35s${NC}${CYAN}║${NC}\n" "Download"   "${DLMBPS} Mbps"
printf "  ${CYAN}║${NC}  ${YELLOW}%-20s${NC}  ${WHITE}%-35s${NC}${CYAN}║${NC}\n" "Upload"     "${ULMBPS} Mbps"
printf "  ${CYAN}║${NC}  ${YELLOW}%-20s${NC}  ${WHITE}%-35s${NC}${CYAN}║${NC}\n" "Latency CF" "$LAT"
printf "  ${CYAN}║${NC}  ${YELLOW}%-20s${NC}  ${WHITE}%-35s${NC}${CYAN}║${NC}\n" "IP"         "$PIP ($CTR)"
printf "  ${CYAN}║${NC}  ${YELLOW}%-20s${NC}  ${WHITE}%-35s${NC}${CYAN}║${NC}\n" "CPU Bench"  "${BM} ms (Pi 5k digits)"
if [ "$BLC" -eq 0 ]; then
  printf "  ${CYAN}║${NC}  ${YELLOW}%-20s${NC}  ${GREEN}%-35s${NC}${CYAN}║${NC}\n" "VPS Status" "✔  Aman, ga ada masalah"
else
  printf "  ${CYAN}║${NC}  ${YELLOW}%-20s${NC}  ${RED}%-35s${NC}${CYAN}║${NC}\n" "VPS Status" "⚠  Kena $BLC blacklist, hati-hati"
fi
echo -e "  ${CYAN}╠══════════════════════════════════════════════════════════╣${NC}"
echo -e "  ${CYAN}║${NC}     ${MAGENTA}${BOLD}$BRAND${NC}  ${DIM}$VERSION${NC}  ${CYAN}$CREDIT${NC}   ${CYAN}║${NC}"
echo -e "  ${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "  ${DIM}Script ini milik $CREDIT — dilarang redistribusi tanpa kredit.${NC}"
echo ""
