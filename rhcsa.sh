#!/bin/bash

echo ""
echo "===== Task 01 - Manage Local User and Group ====="
echo ""
sudo useradd -G admin harry
sudo useradd -G admin natasha
sudo useradd -s /sbin/nologin tom
echo ""
echo "===== End Task 01 ====="


echo ""
echo "===== Task 02 - Tune system performance ====="
echo ""
sudo tuned-adm profile virtual-guest
echo ""
echo "===== End Task 02 ====="


echo ""
echo "===== Task 03 - Enabling Yum Software Repositories ====="
echo ""
sudo yum-config-manager --add-repo http://content.example.com/rhel8.0/x86_64/dvd/BaseOS
sudo yum-config-manager --add-repo http://content.example.com/rhel8.0/x86_64/dvd/AppStream
echo ""
echo "===== End Task 03 ====="


echo ""
echo "===== Task 04 - NFS Autofs ====="
echo ""
ssh serverb 'sudo mkdir -p /shares'
sudo mkdir -p /mnt/shares
cat <<EOF | sudo tee -a /etc/fstab
serverb:/shares     /mnt/shares         nfs     defaults        0 0
EOF
sudo mount serverb:/shares /mnt/shares
echo ""
echo "===== End Task 04 ====="


echo ""
echo "===== Task 05 - Managing Basic Storage ====="
echo ""
sudo parted -s /dev/vdb mklabel gpt
sudo parted -s /dev/vdb mkpart primary 2048s  201MB
sudo mkfs.xfs -f /dev/vdb1
sudo mkdir -p /mnt/data
sudo mount /dev/vdb1 /mnt/data
cat <<EOF | sudo tee -a /etc/fstab
/dev/vdb1       /mnt/data       xfs     defaults        0 0
EOF
sudo parted -s /dev/vdb print
echo ""
echo "===== End Task 05 ====="


echo ""
echo "===== Task 06 - Managing Extend Basic Storage ====="
echo ""
sudo parted -s /dev/vdb mkpart primary 201MB 701MB
sudo mkswap /dev/vdb2
sudo swapon /dev/vdb2
cat <<EOF | sudo tee -a /etc/fstab
/dev/vdb2       none    swap    sw      0 0
EOF
sudo swapon --show
echo ""
echo "===== End Task 06 ====="


echo ""
echo "===== Task 07 - Implementing Advanced Storage Feature ====="
echo ""
sudo parted -s /dev/vdc mklabel gpt
sudo parted -s /dev/vdc mkpart primary 2048s  1001MB
sudo mkfs.xfs -f /dev/vdc1
sudo parted -s /dev/vdc mkpart primary 1001MB  2002MB
sudo mkfs.xfs -f /dev/vdc2
sudo pvcreate /dev/vdc1 
sudo pvcreate /dev/vdc2
sudo vgcreate vg0 /dev/vdc1 /dev/vdc2
sudo lvcreate -n lv0 -L 500MB vg0
sudo mkfs.xfs -f /dev/mapper/vg0-lv0
sudo mkdir -p /mnt/data-lvm
sudo mount /dev/mapper/vg0-lv0 /mnt/data-lvm/
cat <<EOF | sudo tee -a /etc/fstab
/dev/mapper/vg0-lv0     /mnt/data-lvm/      xfs     defaults    0 0
EOF
echo ""
echo "===== End Task 07 ====="


echo ""
echo "===== Task 08 - Implementing Advanced Storage Feature ====="
echo ""
sudo lvextend -L +200M -r /dev/vg0/lv0
sudo lvs
echo ""
echo "===== End Task 08 ====="


echo ""
echo "===== Task 09 - Implementing Advanced Storage Feature ====="
echo ""
sudo stratis pool create str0 /dev/vdd
sudo stratis fs create str0 str0fs0
sudo mkdir -p /mnt/stratis/
sudo mount /stratis/str0/str0fs0 /mnt/stratis/
sudo stratis fs snapshot str0 str0fs0 str0fs0-snap
sudo mkdir -p /mnt/stratis-snap/
sudo mount /stratis/str0/str0fs0-snap /mnt/stratis-snap/
echo ""
echo "===== End Task 09 ====="


echo ""
echo "===== Task 11 - Implementing Advanced Storage Feature ====="
echo ""

echo ""
echo "===== End Task 11 ====="


echo ""
echo "===== Task 12 - Scheduling Job ====="
echo ""
sudo crontab -u natasha -l | { cat; echo "*/2 * * * * echo 'hello' >> /home/natasha/file_cron"; } | sudo crontab -u natasha -
echo ""
echo "===== End Task 12 ====="


echo ""
echo "===== Task 13 - SELinux ====="
echo ""
sudo chcon -R -t httpd_sys_content_t /var/www/html/index.html
echo ""
echo "===== End Task 13 ====="


echo ""
echo "===== Task 14 - SELinux ====="
echo ""
sudo chmod 711 /home/student
sudo chmod 755 -R /home/student/public_html/
sudo sed -i 's/UserDir disabled/#UserDir disabled/g' /etc/httpd/conf.d/userdir.conf
sudo sed -i 's/#UserDir public_html/UserDir public_html/g' /etc/httpd/conf.d/userdir.conf
sudo systemctl restart httpd.service
sudo chcon -R -t httpd_sys_content_t /home/student/public_html/index.html
echo ""
echo "===== End Task 14 ====="


echo ""
echo "===== Task 15 - ACL ====="
echo ""
sudo cp /etc/fstab /var/tmp
sudo chown root:admin /var/tmp/fstab
sudo setfacl -m u:natasha:rwx /var/tmp/fstab
sudo setfacl -m u:harry:--- /var/tmp/fstab
echo ""
echo "===== End Task 15 ====="


echo ""
echo "===== Task 16 - ACL ====="
echo ""
sudo setfacl -m g:contractors:rwx /home/contractors/filecon
sudo setfacl -m u:contractor2:r-- /home/contractors/filecon
echo ""
echo "===== End Task 16 ====="


echo ""
echo "===== Task 17 - Network Security ====="
echo ""
cat <<EOF | tee ~/httpd.sh
sudo firewall-cmd --add-port=80/tcp --zone=public --permanent
sudo firewall-cmd --add-port=8182/tcp --zone=public --permanent
sudo firewall-cmd --reload
sudo sed -i 's/Listen 80/Listen 8182/g' /etc/httpd/conf/httpd.conf
sudo semanage port -a -t http_port_t -p tcp 8182
sudo systemctl restart httpd
EOF
scp ~/httpd.sh serverb:~/
ssh serverb 'bash ~/httpd.sh'
echo ""
echo "===== End Task 17 ====="


echo ""
echo "===== Task 18 - Link ====="
echo ""
sudo ln /home/student/fileA /home/student/fileA-hard-link.txt
sudo ln -sv /home/student/fileB /home/student/fileB-soft-link.txt
echo ""
echo "===== End Task 18 ====="


echo ""
echo "===== Task 19 - Running Containers ====="
echo ""
ssh serverb 'echo -e "podsvc_pass\npodsvc_pass" | sudo passwd podsvc'
echo <<EOF | tee ~/container.sh
sudo firewall-cmd --add-port=8888/tcp --permanent
sudo firewall-cmd --reload
sudo semanage port -a -t http_port_t -p tcp 8888
sudo mkdir -p /home/podsvc/srv/web
sudo chown -R podsvc:podsvc /home/podsvc/srv/web
sudo semanage fcontext -a -t container_file_t '/home/podsvc/srv(/.*)?'
sudo chcon -t httpd_sys_script_exec_t /home/podsvc/srv/web/index.html
sudo sed -i "/\[registries\.insecure\]/,/^$/s/registries = \[''\]/registries = \['registry.lab.example.com'\]/" /etc/containers/registries.conf
su - podsvc <<END_OF_COMMANDS
podman login registry.lab.example.com -u admin -p redhat321
podman pull registry.lab.example.com/rhel8/httpd-24:1-105
echo "Hello World" > /home/podsvc/srv/web/index.html
podman run -d --name web -p 8888:8080 -v /home/podsvc/srv/web:/var/www/html registry.lab.example.com/rhel8/httpd-24:1-105
END_OF_COMMANDS
curl -o /dev/null -s -w '%{http_code}\n' http://localhost:8888 -v
mkdir -p ~/.config/systemd/user
podman generate systemd --name web  > ~/.config/systemd/user/container-web.service
systemctl --user daemon-reload # not work, you have to ssh manual to specific user instead of switch user
systemctl --user start container-web.service
EOF
scp ~/container.sh serverb:~/
ssh serverb 'bash ~/container.sh'
echo ""
echo "===== End Task 19 ====="


echo ""
echo "===== Task 10 - Implementing Advanced Storage Feature ====="
echo ""
sudo cat <<EOF | tee ~/vdo.sh
sudo vdo create --name vdo1 --device /dev/vdb --vdoLogicalSize 50G
sudo mkfs.xfs /dev/mapper/vdo1
sudo mkdir -p /mnt/vdo1
sudo mount /dev/mapper/vdo1 /mnt/vdo1/
EOF
scp ~/vdo.sh serverb:~/
ssh serberb 'bash ~/vdo.sh'
echo ""
echo "===== End Task 10 ====="

: '
sudo parted -s /dev/vdb print // for print out partition
sudo parted -s /dev/vdb rm 1 // for deleting partition by id number
sudo swapon --show // for print active on swap partition
sudo pvs // for print persistent volume list
sudo vgs // for print volume group list
sudo lvs // for print logical volume list
sudo stratis pool list // for print stratis pool list
sudo stratis fs list // for print stratis filesystem list
'
