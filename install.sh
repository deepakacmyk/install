#!/bin/bash
# ==============================================
# 👑 Deepak's 24/7 Command Menu System
# ==============================================

deepak_banner() {
  echo "=============================================="
  echo "🔁 Deepak 24/7 Control Center"
  echo "=============================================="
  echo "1. Start Deepak 24/7 Mode"
  echo "2. Exit Deepak System"
  echo "=============================================="
}

deepak_247() {
  while true; do
    echo "👑 Deepak Deepak Deepak — Running 24/7 💪 ($(date))"
    echo "----------------------------------------------"
    # 👇 Yahan tum apni custom command daal sakte ho:
    # For example:
    # deepak_command_here
    sleep 10
  done
}

while true; do
  clear
  deepak_banner
  read -p "➡️  Choose an option (1 or 2): " choice
  
  case $choice in
    1)
      echo "🚀 Starting Deepak 24/7 Mode..."
      deepak_247
      ;;
    2)
      echo "👋 Deepak System shutting down..."
      exit 0
      ;;
    *)
      echo "❌ Invalid option, please try again Deepak!"
      sleep 2
      ;;
  esac
done
