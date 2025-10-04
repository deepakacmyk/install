#!/bin/bash
# ==============================================
# 👑 Deepak Pterodactyl Installer Menu
# ==============================================

# Check root
if [[ $EUID -ne 0 ]]; then
   echo "⚠️ Please run as root: sudo bash $0"
   exit 1
fi

# Function: Panel install
install_panel() {
    echo "🚀 Installing Pterodactyl Panel..."
    apt update && apt install -y curl wget git unzip nginx php-cli php-mbstring php-bcmath php-curl php-gd php-xml composer mysql-client ufw miniupnpc
    # Create folder
    mkdir -p /var/www/pterodactyl
    cd /var/www/pterodactyl || exit
    # Download panel (latest version)
    curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
    tar -xzf panel.tar.gz --strip-components=1
    composer install --no-dev --optimize-autoloader
    cp .env.example .env
    php artisan key:generate

    # Setup default MySQL database (modify credentials as needed)
    DB_NAME="pterodactyl"
    DB_USER="ptero_user"
    DB_PASS="DeepakP@ss123"
    mysql -e "CREATE DATABASE IF NOT EXISTS $DB_NAME; CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS'; GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost'; FLUSH PRIVILEGES;"

    sed -i "s/DB_DATABASE=.*/DB_DATABASE=$DB_NAME/" .env
    sed -i "s/DB_USERNAME=.*/DB_USERNAME=$DB_USER/" .env
    sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$DB_PASS/" .env

    php artisan migrate --seed

    # Create admin user automatically
    php artisan p:user:make --email="deepak@panel.local" --name="Deepak" --password="DeepakP@ss123" --admin

    # Setup nginx for port 80
    cat >/etc/nginx/sites-available/pterodactyl.conf <<EOF
server {
    listen 80;
    server_name _;

    root /var/www/pterodactyl/public;
    index index.php;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location ~ \.php\$ {
        fastcgi_split_path_info ^(.+\.php)(/.+)\$;
        fastcgi_pass unix:/run/php/php8.3-fpm.sock;
        fastcgi_index index.php;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        fastcgi_param DOCUMENT_ROOT \$realpath_root;
    }

    location ~ /\.ht {
        deny all;
    }
}
EOF
    ln -s /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf
    nginx -t && systemctl restart nginx

    echo "✅ Panel installed on port 80! Admin: deepak@panel.local / DeepakP@ss123"

    # Auto port forwarding (UPnP)
    if command -v upnpc >/dev/null 2>&1; then
        echo "Attempting UPnP port forwarding for port 80..."
        upnpc -e "PteroPanel" -a $(hostname -I | awk '{print $1}') 80 80 TCP || true
    fi
}

# Function: Wings install
install_wings() {
    echo "🚀 Installing Wings..."
    curl -Lo installer.sh https://raw.githubusercontent.com/pterodactyl/wings/master/install.sh
    bash installer.sh
    echo "✅ Wings installed!"
}

# Function: Panel + Wings online
install_panel_wings_online() {
    install_panel
    install_wings
    echo "🌐 Panel + Wings online!"
}

# Function: Uninstall
uninstall_all() {
    echo "⚠️ Uninstalling Panel + Wings..."
    systemctl stop wings || true
    rm -rf /var/www/pterodactyl
    rm -f /etc/nginx/sites-available/pterodactyl.conf
    rm -f /etc/nginx/sites-enabled/pterodactyl.conf
    nginx -s reload || true
    echo "✅ Uninstalled everything!"
}

# Main menu
while true; do
    clear
    echo "=========================================="
    echo "👑 Deepak Pterodactyl Installer Menu"
    echo "=========================================="
    echo "1. Install Panel (port 80, auto-forward, admin)"
    echo "2. Install Wings only"
    echo "3. Install Panel + Wings Online"
    echo "4. Uninstall everything"
    echo "=========================================="
    read -p "Choose an option (1-4): " choice

    case $choice in
        1) install_panel ;;
        2) install_wings ;;
        3) install_panel_wings_online ;;
        4) uninstall_all ;;
        *) echo "❌ Invalid option! Try again." ; sleep 2 ;;
    esac

    read -p "Press Enter to return to menu..."
done
