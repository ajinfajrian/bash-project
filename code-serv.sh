o "=== Create & Limiting User Access ==="
sudo echo "%USER  ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoer.d/$USER
sudo useradd code-user -s /bin/bash -d /var/www/ -c "CODE-SERVER"
sudo setfacl -d -m u:code-user:rwx -R /var/www/
sudo setfacl -m u:code-user:--- -R /home/
sudo setfacl -m u:code-user:--- -R /usr/local/bin/
sudo setfacl -m u:code-user:--- -R /usr/local/sbin/
sudo setfacl -m u:code-user:--- /usr/bin/passwd
sudo setfacl -m u:code-user:--- /etc/passwd
sudo setfacl -m u:code-user:--- /etc/passwd-
sudo setfacl -m u:code-user:--- /etc/shadow
sudo setfacl -m u:code-user:--- /etc/shadow-
sudo setfacl -m u:code-user:--- /etc/group
sudo setfacl -m u:code-user:--- /etc/group-
sudo setfacl -m u:code-user:--- /bin/ss
sudo setfacl -m u:code-user:--- /bin/netstat
sudo echo "%code-user ALL=NOPASSWD: /bin/systemctl enable --now code-server@code-user" >> /etc/sudoers.d/code-user
sudo echo "%code-user ALL=NOPASSWD: /bin/systemctl start code-server@code-user" >> /etc/sudoers.d/code-user
sudo echo "%code-user ALL=NOPASSWD: /bin/systemctl restart code-server@code-user" >> /etc/sudoers.d/code-user
sudo usermod 600 /etc/sudoers.d/code-user
sudo su - code-user
curl -fsSL https://code-server.dev/install.sh | sh
sudo systemctl enable --now code-server@code-user
echo "=== Done ... ==="
