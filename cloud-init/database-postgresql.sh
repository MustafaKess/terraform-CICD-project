#!/bin/bash

# Update system
apt-get update
apt-get upgrade -y

# Install PostgreSQL
apt-get install -y postgresql postgresql-contrib

# Start and enable PostgreSQL
systemctl start postgresql
systemctl enable postgresql

# Configure PostgreSQL
sudo -u postgres psql << EOF
-- Create application database
CREATE DATABASE ${database_name};

-- Create application user
CREATE USER ${database_user} WITH ENCRYPTED PASSWORD '${database_password}';

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE ${database_name} TO ${database_user};

-- Allow connections from local network
ALTER USER ${database_user} CREATEDB;

\q
EOF

# Configure PostgreSQL for network access
pg_version=$(ls /etc/postgresql/)
pg_config_dir="/etc/postgresql/$pg_version/main"

# Update postgresql.conf
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" "$pg_config_dir/postgresql.conf"

# Update pg_hba.conf for network access
cat >> "$pg_config_dir/pg_hba.conf" << EOF

# Allow connections from private networks
host    all             all             10.0.0.0/16            md5
host    all             all             192.168.0.0/16         md5
EOF

# Restart PostgreSQL to apply changes
systemctl restart postgresql

# Install monitoring and admin tools
apt-get install -y htop curl wget postgresql-client

# Create a sample table and data
sudo -u postgres psql -d ${database_name} << EOF
-- Create a sample users table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample data
INSERT INTO users (username, email) VALUES 
('admin', 'admin@terratech.local'),
('testuser', 'test@terratech.local')
ON CONFLICT (username) DO NOTHING;

-- Grant table permissions
GRANT ALL PRIVILEGES ON TABLE users TO ${database_user};
GRANT USAGE, SELECT ON SEQUENCE users_id_seq TO ${database_user};
EOF

# Set up database backup script
cat > /usr/local/bin/backup-db.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="/var/backups/postgresql"
DATE=$(date +%Y%m%d_%H%M%S)
mkdir -p $BACKUP_DIR

# Backup all databases
sudo -u postgres pg_dumpall > "$BACKUP_DIR/all_databases_$DATE.sql"

# Keep only last 7 days of backups
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete

echo "Database backup completed: $DATE"
EOF

chmod +x /usr/local/bin/backup-db.sh

# Add daily backup cron job
cat > /etc/cron.d/postgresql-backup << EOF
# Daily PostgreSQL backup at 2 AM
0 2 * * * root /usr/local/bin/backup-db.sh >> /var/log/postgresql-backup.log 2>&1
EOF

# Set up firewall rules
ufw --force enable
ufw allow ssh
ufw allow from 10.0.0.0/16 to any port 5432

# Create database status check script
cat > /usr/local/bin/db-status.sh << 'EOF'
#!/bin/bash
echo "=== PostgreSQL Status ==="
systemctl status postgresql --no-pager -l

echo -e "\n=== Database Connections ==="
sudo -u postgres psql -c "SELECT datname, usename, client_addr, state FROM pg_stat_activity WHERE state = 'active';"

echo -e "\n=== Database Sizes ==="
sudo -u postgres psql -c "SELECT datname, pg_size_pretty(pg_database_size(datname)) as size FROM pg_database ORDER BY pg_database_size(datname) DESC;"
EOF

chmod +x /usr/local/bin/db-status.sh

echo "PostgreSQL database server setup completed successfully!" > /var/log/cloud-init-postgresql.log
echo "Database: ${database_name}" >> /var/log/cloud-init-postgresql.log
echo "User: ${database_user}" >> /var/log/cloud-init-postgresql.log