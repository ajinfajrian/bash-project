#!/bin/bash

green=`tput setaf 2`
red=`tput setaf 1`
nc=`tput sgr0` #nocolour

if [[ "${UID}" -ne 0 ]]
then
echo "${red}The script is not run as root"
exit 1
fi

COUNT_NR_OPEN=$(echo $(($(getconf _PHYS_PAGES) * $(getconf PAGE_SIZE) / (1024 * 1024) * 100 )))
if [[ $COUNT_NR_OPEN -lt 1048576 ]]; then
    COUNT_NR_OPEN=1048576
fi
sed -i '/fs.nr_open/d' /etc/sysctl.conf
echo "fs.nr_open=$COUNT_NR_OPEN" >> /etc/sysctl.conf
sed -i '/vm.swappiness/d' /etc/sysctl.conf
echo "vm.swappiness=1" >> /etc/sysctl.conf
sysctl -p
echo "${green}Reconfigure fs.nr_open = $COUNT_NR_OPEN Success!${nc}"

COUNT_NR_OPEN_AND_DEVIDE=$(echo $(($COUNT_NR_OPEN / 2)))
ulimit -n $COUNT_NR_OPEN_AND_DEVIDE
ulimit -u 16384
sed -i '/root soft nproc/d' /etc/security/limits.conf
sed -i '/root hard nproc/d' /etc/security/limits.conf
sed -i '/root soft nofile/d' /etc/security/limits.conf
sed -i '/root hard nofile/d' /etc/security/limits.conf
echo "root soft nproc 16384" >> /etc/security/limits.conf
echo "root hard nproc 16384" >> /etc/security/limits.conf
echo "root soft nofile $COUNT_NR_OPEN_AND_DEVIDE" >> /etc/security/limits.conf
echo "root hard nofile $COUNT_NR_OPEN_AND_DEVIDE" >> /etc/security/limits.conf
echo "${green}Reconfigure nofile & nproc = $COUNT_NR_OPEN_AND_DEVIDE Success!${nc}"

os_name=$(cat /etc/os-release | awk -F '=' '/^NAME/{print $2}' | tr -d '"')
if [ "$os_name" == "Ubuntu" ]
then
        echo "${green}===== System is ubuntu =====${nc}"
        os_versionid=$(cat /etc/os-release | awk -F '=' '/^VERSION_ID/{print $2}' | tr -d '"')
        case $os_versionid in
                "14.04" )
                        echo noop > /sys/block/sda/queue/scheduler
                        sed -i 's/elevator=noop//' /etc/default/grub
                        sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& elevator=noop/' /etc/default/grub
                        echo "${green}===== Wait a sec... =====${nc}"
                        update-grub2
                        echo "${green}Configure Ubuntu 14.04 Success${nc}"
                        ;;

                "16.04" )
                        echo noop > /sys/block/sda/queue/scheduler
                        sed -i 's/elevator=noop//' /etc/default/grub
                        sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& elevator=noop/' /etc/default/grub
                        echo "${green}===== Wait a sec... =====${nc}"
                        update-grub2
                        echo "${green}Configure Ubuntu 16.04 Success${nc}"
                        ;;

                "18.04" )
                        echo noop > /sys/block/sda/queue/scheduler
                        sed -i 's/elevator=noop//' /etc/default/grub
                        sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& elevator=noop/' /etc/default/grub
                        echo "${green}===== Wait a sec... =====${nc}"
                        update-grub2
                        echo "${green}Configure Ubuntu 18.04 Success${nc}"
                        ;;
                "20.04" )
                        echo none > /sys/block/sda/queue/scheduler
                        sed -i 's/elevator=none//' /etc/default/grub
                        sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/& elevator=none/' /etc/default/grub
                        echo "${green}===== Wait a sec... =====${nc}"
                        update-grub2
                        echo "${green}Configure Ubuntu 20.04 Success${nc}"
                        ;;
        esac
elif [ "$os_name" == "Red Hat Enterprise Linux" ]
then
        echo "${green}===== System is Redhat =====${nc}"
        os_versionid=$(cat /etc/os-release | awk -F '=' '/^VERSION_ID/{print $2}' | awk -F '.' '{print $1}' | tr -d '"')
        case $os_versionid in
                "8" )
                        echo mq-deadline > /sys/block/sda/queue/scheduler
                        sed -i '/net.netfilter.nf_conntrack_max/d' /etc/sysctl.conf
                        echo "net.netfilter.nf_conntrack_max=524288" >> /etc/sysctl.conf
                        sysctl -p
                        sed -i 's/elevatr=mq-deadline//' /etc/default/grub
                        sed -i 's/GRUB_CMDLINE_LINUX="[^"]*/& elevator=mq-deadline/' /etc/default/grub
                        echo "${green}===== Wait a sec... =====${nc}"
                        grub2-mkconfig -o /boot/grub2/grub.cfg
                        echo "${green}Configure RHEL 8 Success${nc}"
                        ;;

                "7" )
                        echo deadline > /sys/block/sda/queue/scheduler
                        sed -i '/net.netfilter.nf_conntrack_max/d' /etc/sysctl.conf
                        echo "net.netfilter.nf_conntrack_max=524288" >> /etc/sysctl.conf
                        sysctl -p
                        sed -i 's/elevator=deadline//' /etc/default/grub
                        sed -i 's/GRUB_CMDLINE_LINUX="[^"]*/& elevator=deadline/' /etc/default/grub
                        echo "${green}===== Wait a sec... =====${nc}"
                        grub2-mkconfig -o /boot/grub2/grub.cfg
                        echo "${green}Configure RHEL 7 Success${nc}"
                        ;;
        esac
else
        echo "${red}Linux not registered on MOP${nc}"

fi


apps_check=$()
