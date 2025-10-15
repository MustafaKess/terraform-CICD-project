#!/bin/bash

# Update system
apt-get update
apt-get upgrade -y

# Install Nginx
apt-get install -y nginx

# Enable and start Nginx
systemctl enable nginx
systemctl start nginx

# Create a simple index page
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>TerraTech - Frontend Server</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background-color: #f4f4f4; }
        .container { background-color: white; padding: 30px; border-radius: 10px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        h1 { color: #333; text-align: center; }
        .info { background-color: #e7f3ff; padding: 15px; border-left: 4px solid #2196F3; margin: 20px 0; }
        .status { color: green; font-weight: bold; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 TerraTech Infrastructure</h1>
        <div class="info">
            <h3>Frontend Web Server</h3>
            <p><strong>Server:</strong> $(hostname)</p>
            <p><strong>IP:</strong> $(hostname -I | cut -d' ' -f1)</p>
            <p><strong>Status:</strong> <span class="status">Online ✅</span></p>
            <p><strong>Web Server:</strong> Nginx</p>
            <p><strong>Deployed:</strong> $(date)</p>
        </div>
        <div class="info">
            <h4>Load Balancer Health Check</h4>
            <p>This page serves as a health check endpoint for the load balancer.</p>
            <p>If you can see this page, the server is functioning correctly.</p>
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
    "uptime": "$(uptime -p)"
}
EOF

# Configure Nginx for better load balancer integration
cat > /etc/nginx/sites-available/default << EOF
server {
    listen 80 default_server;
    listen [::]:80 default_server;
    
    server_name _;
    root /var/www/html;
    index index.html index.htm;
    
    # Health check endpoint
    location /health {
        access_log off;
        return 200 '{"status":"healthy","server":"$(hostname)"}';
        add_header Content-Type application/json;
    }
    
    # Main site
    location / {
        try_files \$uri \$uri/ =404;
    }
    
    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
}
EOF

# Test Nginx configuration and restart
nginx -t && systemctl restart nginx

# Install monitoring tools
apt-get install -y htop curl wget

# Create log rotation for application logs
cat > /etc/logrotate.d/webapp << EOF
/var/log/nginx/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 644 www-data www-data
    postrotate
        systemctl reload nginx
    endscript
}
EOF

# Set up firewall rules
ufw --force enable
ufw allow ssh
ufw allow http
ufw allow https

echo "Frontend server setup completed successfully!" > /var/log/cloud-init-frontend.log