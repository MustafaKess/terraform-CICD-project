#!/bin/bash

# Update system
apt-get update
apt-get upgrade -y

# Install MySQL Server
export DEBIAN_FRONTEND=noninteractive
apt-get install -y mysql-server

# Start and enable MySQL
systemctl start mysql
systemctl enable mysql

# Secure MySQL installation and configure
mysql << EOF
-- Set root password and secure installation
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${database_password}';

-- Remove anonymous users
DELETE FROM mysql.user WHERE User='';

-- Remove test database
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Create application database
CREATE DATABASE IF NOT EXISTS ${database_name};

-- Create application user
CREATE USER IF NOT EXISTS '${database_user}'@'%' IDENTIFIED BY '${database_password}';
CREATE USER IF NOT EXISTS '${database_user}'@'localhost' IDENTIFIED BY '${database_password}';

-- Grant privileges
GRANT ALL PRIVILEGES ON ${database_name}.* TO '${database_user}'@'%';
GRANT ALL PRIVILEGES ON ${database_name}.* TO '${database_user}'@'localhost';

-- Reload privileges
FLUSH PRIVILEGES;
EOF

# Configure MySQL for network access
cat > /etc/mysql/mysql.conf.d/terratech.cnf << EOF
[mysqld]
# Network configuration
bind-address = 0.0.0.0
mysqlx-bind-address = 0.0.0.0

# Security settings
local-infile = 0
skip-show-database

# Performance settings
innodb_buffer_pool_size = 256M
max_connections = 100

# Logging
log-error = /var/log/mysql/error.log
slow-query-log = 1
slow-query-log-file = /var/log/mysql/slow-query.log
long_query_time = 2
EOF

# Restart MySQL to apply changes
systemctl restart mysql

# Install monitoring and admin tools
apt-get install -y htop curl wget mysql-client

# Create sample database structure
mysql -u${database_user} -p${database_password} ${database_name} << EOF
-- Create a sample users table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT IGNORE INTO users (username, email) VALUES 
('admin', 'admin@terratech.local'),
('testuser', 'test@terratech.local');
EOF

# Set up database backup script
cat > /usr/local/bin/backup-mysql.sh << EOF
#!/bin/bash
BACKUP_DIR="/var/backups/mysql"
DATE=\$(date +%Y%m%d_%H%M%S)
mkdir -p \$BACKUP_DIR

# Backup specific database
mysqldump -u${database_user} -p${database_password} ${database_name} > "\$BACKUP_DIR/${database_name}_\$DATE.sql"

# Backup all databases (root access)
mysqldump -uroot -p${database_password} --all-databases > "\$BACKUP_DIR/all_databases_\$DATE.sql"

# Keep only last 7 days of backups
find \$BACKUP_DIR -name "*.sql" -mtime +7 -delete

echo "MySQL backup completed: \$DATE"
EOF

chmod +x /usr/local/bin/backup-mysql.sh

# Add daily backup cron job
cat > /etc/cron.d/mysql-backup << EOF
# Daily MySQL backup at 2 AM
0 2 * * * root /usr/local/bin/backup-mysql.sh >> /var/log/mysql-backup.log 2>&1
EOF

# Set up firewall rules
ufw --force enable
ufw allow ssh
ufw allow from 10.0.0.0/16 to any port 3306

# Create database status check script
cat > /usr/local/bin/mysql-status.sh << 'EOF'
#!/bin/bash
echo "=== MySQL Status ==="
systemctl status mysql --no-pager -l

echo -e "\n=== Database Connections ==="
mysql -uroot -p${database_password} -e "SHOW PROCESSLIST;"

echo -e "\n=== Database Sizes ==="
mysql -uroot -p${database_password} -e "SELECT table_schema AS 'Database', ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS 'Size (MB)' FROM information_schema.tables GROUP BY table_schema;"
EOF

chmod +x /usr/local/bin/mysql-status.sh

echo "MySQL database server setup completed successfully!" > /var/log/cloud-init-mysql.log
echo "Database: ${database_name}" >> /var/log/cloud-init-mysql.log
echo "User: ${database_user}" >> /var/log/cloud-init-mysql.log