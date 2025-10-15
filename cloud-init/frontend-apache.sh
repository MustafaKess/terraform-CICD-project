#!/bin/bash

# Update system
apt-get update
apt-get upgrade -y

# Install Apache2
apt-get install -y apache2

# Enable and start Apache
systemctl enable apache2
systemctl start apache2

# Create a simple index page
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>TerraTech - Frontend Server (Apache)</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f8f9fa; }
        .container { background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        h1 { color: #dc3545; text-align: center; }
        .info { background-color: #fff3cd; padding: 15px; border-left: 4px solid #ffc107; margin: 20px 0; }
        .status { color: green; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🌐 TerraTech Infrastructure</h1>
        <div class="info">
            <h3>Frontend Web Server (Apache)</h3>
            <p><strong>Server:</strong> $(hostname)</p>
            <p><strong>IP:</strong> $(hostname -I | cut -d' ' -f1)</p>
            <p><strong>Status:</strong> <span class="status">Online ✅</span></p>
            <p><strong>Web Server:</strong> Apache HTTP Server</p>
            <p><strong>Deployed:</strong> $(date)</p>
        </div>
        <div class="info">
            <h4>Load Balancer Health Check</h4>
            <p>This page serves as a health check endpoint for the load balancer.</p>
            <p>Apache server is ready to handle requests.</p>
        </div>
    </div>
</body>
</html>
EOF

# Create health check endpoint
mkdir -p /var/www/html/health
cat > /var/www/html/health/index.html << EOF
{
    "status": "healthy",
    "server": "$(hostname)",
    "timestamp": "$(date -Iseconds)",
    "webserver": "Apache",
    "uptime": "$(uptime -p)"
}
EOF

# Enable Apache modules
a2enmod rewrite
a2enmod headers

# Configure Apache virtual host
cat > /etc/apache2/sites-available/000-default.conf << EOF
<VirtualHost *:80>
    ServerAdmin admin@terratech.local
    DocumentRoot /var/www/html
    
    # Security headers
    Header always set X-Frame-Options DENY
    Header always set X-Content-Type-Options nosniff
    Header always set X-XSS-Protection "1; mode=block"
    
    # Health check endpoint
    Alias /health /var/www/html/health
    <Location /health>
        SetHandler none
    </Location>
    
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
    
    <Directory /var/www/html>
        Options -Indexes +FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

# Test Apache configuration and restart
apache2ctl configtest && systemctl restart apache2

# Install monitoring tools
apt-get install -y htop curl wget

# Set up firewall rules
ufw --force enable
ufw allow ssh
ufw allow http
ufw allow https

echo "Frontend Apache server setup completed successfully!" > /var/log/cloud-init-frontend-apache.log