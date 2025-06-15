#!/data/data/com.termux/files/usr/bin/bash

# Update and install required packages
pkg update -y && pkg upgrade -y
pkg install tur-repo -y
pkg install tor privoxy netcat-openbsd curl -y

# Clean old config
pkill tor
pkill privoxy
rm -rf ~/.tor_multi ~/.privoxy
mkdir -p ~/.tor_multi ~/.privoxy

# Define ports
PORTS=(9050 9060 9070 9080 9090)
CONTROL_PORTS=(9051 9061 9071 9081 9091)

# Start Tor instances
for i in {0..4}; do
  TOR_DIR="$HOME/.tor_multi/tor$i"
  mkdir -p "$TOR_DIR"
  cat <<EOF > "$TOR_DIR/torrc"
SocksPort ${PORTS[$i]}
ControlPort ${CONTROL_PORTS[$i]}
DataDirectory $TOR_DIR
CookieAuthentication 0
EOF

  tor -f "$TOR_DIR/torrc" > /dev/null 2>&1 &
  sleep 2
done

# Setup Privoxy
cat <<EOF > "$HOME/.privoxy/config"
listen-address 127.0.0.1:8118
EOF

for port in "${PORTS[@]}"; do
  echo "forward-socks5 / 127.0.0.1:$port ." >> "$HOME/.privoxy/config"
done

privoxy "$HOME/.privoxy/config" > /dev/null 2>&1 &

# Ask for rotation time
echo -ne "\e[1;36mEnter IP rotation interval (in seconds, min 5s): \e[0m"
read -r ROTATION_TIME

if [[ ! "$ROTATION_TIME" =~ ^[0-9]+$ ]] || [[ "$ROTATION_TIME" -lt 5 ]]; then
  echo -e "\e[1;31mInvalid input! Using default 10 seconds.\e[0m"
  ROTATION_TIME=10
fi

# Start rotation loop
while true; do
  for ctrl_port in "${CONTROL_PORTS[@]}"; do
    echo -e "AUTHENTICATE \"\"\r\nSIGNAL NEWNYM\r\nQUIT" | nc 127.0.0.1 $ctrl_port > /dev/null 2>&1
  done

  NEW_IP=$(curl --proxy http://127.0.0.1:8118 -s https://api64.ipify.org)
  echo -e "\e[1;32m✅ New IP: $NEW_IP\e[0m"
  echo -e "\e[1;34m[Proxy]: 127.0.0.1:8118\e[0m"
  sleep "$ROTATION_TIME"
done#!/data/data/com.termux/files/usr/bin/bash

# Update and install required packages
pkg update -y && pkg upgrade -y
pkg install tur-repo -y
pkg install tor privoxy netcat-openbsd curl -y

# Clean old config
pkill tor
pkill privoxy
rm -rf ~/.tor_multi ~/.privoxy
mkdir -p ~/.tor_multi ~/.privoxy

# Define ports
PORTS=(9050 9060 9070 9080 9090)
CONTROL_PORTS=(9051 9061 9071 9081 9091)

# Start Tor instances
for i in {0..4}; do
  TOR_DIR="$HOME/.tor_multi/tor$i"
  mkdir -p "$TOR_DIR"
  cat <<EOF > "$TOR_DIR/torrc"
SocksPort ${PORTS[$i]}
ControlPort ${CONTROL_PORTS[$i]}
DataDirectory $TOR_DIR
CookieAuthentication 0
EOF

  tor -f "$TOR_DIR/torrc" > /dev/null 2>&1 &
  sleep 2
done

# Setup Privoxy
cat <<EOF > "$HOME/.privoxy/config"
listen-address 127.0.0.1:8118
EOF

for port in "${PORTS[@]}"; do
  echo "forward-socks5 / 127.0.0.1:$port ." >> "$HOME/.privoxy/config"
done

privoxy "$HOME/.privoxy/config" > /dev/null 2>&1 &

# Ask for rotation time
echo -ne "\e[1;36mEnter IP rotation interval (in seconds, min 5s): \e[0m"
read -r ROTATION_TIME

if [[ ! "$ROTATION_TIME" =~ ^[0-9]+$ ]] || [[ "$ROTATION_TIME" -lt 5 ]]; then
  echo -e "\e[1;31mInvalid input! Using default 10 seconds.\e[0m"
  ROTATION_TIME=10
fi

# Start rotation loop
while true; do
  for ctrl_port in "${CONTROL_PORTS[@]}"; do
    echo -e "AUTHENTICATE \"\"\r\nSIGNAL NEWNYM\r\nQUIT" | nc 127.0.0.1 $ctrl_port > /dev/null 2>&1
  done

  NEW_IP=$(curl --proxy http://127.0.0.1:8118 -s https://api64.ipify.org)
  echo -e "\e[1;32m✅ New IP: $NEW_IP\e[0m"
  echo -e "\e[1;34m[Proxy]: 127.0.0.1:8118\e[0m"
  sleep "$ROTATION_TIME"
done