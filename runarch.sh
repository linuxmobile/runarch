#!/bin/bash

# fork archfi
# author: MatMoul
#         https://github.com/MatMoul
# --------------------------------
# Arch Linux installer (runarch)
# linuxmobile | This is a test
#         https://github.com/linuxmobile
#         https://github.com/linuxmobile


apptitle="Arch Linux installer (runarch) (GPLv3)"
baseurl=https://raw.githubusercontent.com/linuxmobile/runarch/master
skipfont="0"


# --------------------------------------------------------
mainmenu(){
  if [ "${1}" = "" ]; then
    nextitem="."
  else
    nextitem=${1}
  fi
  options=()
  options+=("${txtlanguage}" "Language")
  options+=("${txtsetkeymap}" "(loadkeys ...)")
  options+=("${txteditor}" "(${txtoptional})")
  options+=("${txtdiskpartmenu}" "")
  options+=("${txtselectpartsmenu}" "")
  options+=("" "")
  options+=("${txtreboot}" "")
  sel=$(whiptail --backtitle "${apptitle}" --title "${txtmainmenu}" --menu "" --cancel-button "${txtexit}" --default-item "${nextitem}" 0 0 0 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  if [ "$?" = "0" ]; then
    case ${sel} in
      "${txtlanguage}")
        chooselanguage
        nextitem="${txtsetkeymap}"
      ;;
      "${txtsetkeymap}")
        setkeymap
        nextitem="${txtdiskpartmenu}"
      ;;
      "${txteditor}")
        chooseeditor
        nextitem="${txtdiskpartmenu}"
      ;;
      "${txtdiskpartmenu}")
        diskpartmenu
        nextitem="${txtselectpartsmenu}"
      ;;
      "${txtselectpartsmenu}")
        selectparts
        nextitem="${txtreboot}"
      ;;
      "${txthelp}")
        help
        nextitem="${txtreboot}"
      ;;
      "${txtchangelog}")
        showchangelog
        nextitem="${txtreboot}"
      ;;
      "${txtreboot}")
        rebootpc
        nextitem="${txtreboot}"
      ;;
    esac
    mainmenu "${nextitem}"
  else
    clear
  fi
}

chooselanguage(){
  options=()
  options+=("English" "(By Anon)")
  options+=("Spanish" "(By Anon)")
  sel=$(whiptail --backtitle "${apptitle}" --title "${txtlanguage}" --menu "" 0 0 0 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  if [ "$?" = "0" ]; then
    clear
    if [ "${sel}" = "English" ]; then
      loadstrings
    else
      eval $(curl -L ${baseurl}/lang/${sel} | sed '/^#/ d')
    fi
    if [ "${skipfont}" = "0" ]; then
      eval $(setfont ${font})
    fi
    font=
    if [ "$(cat /etc/locale.gen | grep ""#${locale}"")" != "" ]; then
      sed -i "/${locale}/s/^#//g" /etc/locale.gen
      locale-gen
    fi
    export LANG=${locale}
  fi
}

setkeymap(){
  items=$(find /usr/share/kbd/keymaps/ -type f -printf "%f\n" | sort -V)
  options=()
  for item in ${items}; do
    options+=("${item%%.*}" "")
  done
  keymap=$(whiptail --backtitle "${apptitle}" --title "${txtsetkeymap}" --menu "" 0 0 0 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  if [ "$?" = "0" ]; then
    clear
    echo "loadkeys ${keymap}"
    loadkeys ${keymap}
    pressanykey
  fi
}

chooseeditor(){
  options=()
  options+=("nano" "")
  options+=("vim" "")
  options+=("vi" "")
  options+=("edit" "")
  sel=$(whiptail --backtitle "${apptitle}" --title "${txteditor}" --menu "" 0 0 0 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  if [ "$?" = "0" ]; then
    clear
    echo "export EDITOR=${sel}"
    export EDITOR=${sel}
    EDITOR=${sel}
    pressanykey
  fi
}

rebootpc(){
  if (whiptail --backtitle "${apptitle}" --title "${txtreboot}" --yesno "${txtreboot} ?" --defaultno 0 0) then
    clear
    reboot
  fi
}
# --------------------------------------------------------



# --------------------------------------------------------
selectdisk(){
    items=$(lsblk -d -p -n -l -o NAME,SIZE -e 7,11)
    options=()
    IFS_ORIG=$IFS
    IFS=$'\n'
    for item in ${items}
    do
        options+=("${item}" "")
    done
    IFS=$IFS_ORIG
    result=$(whiptail --backtitle "${APPTITLE}" --title "${1}" --menu "" 0 0 0 "${options[@]}" 3>&1 1>&2 2>&3)
    if [ "$?" != "0" ]
    then
        return 1
    fi
    echo ${result%%\ *}
    return 0
}

diskpartmenu(){
  if [ "${1}" = "" ]; then
    nextitem="."
  else
    nextitem=${1}
  fi
  options=()
  if [ "${eficomputer}" == "0" ]; then
    options+=("${txtautoparts} (gpt)" "")
    options+=("${txtautoparts} (dos)" "")
  else
    options+=("${txtautoparts} (gpt,efi)" "")
    options+=("${txtautoparts} (gpt)" "")
    options+=("${txtautoparts} (dos)" "")
    options+=("${txtautoparts} (gpt,efi,noswap)" "")
  fi
  options+=("${txteditparts} (cfdisk)" "")
  options+=("${txteditparts} (cgdisk)" "")
  sel=$(whiptail --backtitle "${apptitle}" --title "${txtdiskpartmenu}" --menu "" --cancel-button "${txtback}" --default-item "${nextitem}" 0 0 0 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  if [ "$?" = "0" ]; then
    case ${sel} in
      "${txtautoparts} (dos)")
        diskpartautodos
        nextitem="${txtautoparts} (dos)"
      ;;
      "${txtautoparts} (gpt)")
        diskpartautogpt
        nextitem="${txtautoparts} (gpt)"
      ;;
      "${txtautoparts} (gpt,efi)")
        diskpartautoefi
        nextitem="${txtautoparts} (gpt,efi)"
      ;;
      "${txtautoparts} (gpt,efi,noswap)")
        diskpartautoefiusb
        nextitem="${txtautoparts} (gpt,efi,noswap)"
      ;;
      "${txteditparts} (cfdisk)")
        diskpartcfdisk
        nextitem="${txteditparts} (cfdisk)"
      ;;
      "${txteditparts} (cgdisk)")
        diskpartcgdisk
        nextitem="${txteditparts} (cgdisk)"
      ;;
    esac
    diskpartmenu "${nextitem}"
  fi
}


diskpartautodos(){
    device=$(selectdisk "${txtautoparts} (dos)")
  if [ "$?" = "0" ]; then
    if (whiptail --backtitle "${apptitle}" --title "${txtautoparts} (dos)" --yesno "${txtautopartsconfirm//%1/${device}}" --defaultno 0 0) then
      clear
      echo "${txtautopartclear}"
      parted ${device} mklabel msdos
      sleep 1
      echo "${txtautopartcreate//%1/boot}"
      echo -e "n\np\n\n\n+512M\na\nw" | fdisk ${device}
      sleep 1
      echo "${txtautopartcreate//%1/swap}"
      swapsize=$(cat /proc/meminfo | grep MemTotal | awk '{ print $2 }')
      swapsize=$((${swapsize}/1000))"M"
      echo -e "n\np\n\n\n+${swapsize}\nt\n\n82\nw" | fdisk ${device}
      sleep 1
      echo "${txtautopartcreate//%1/root}"
      echo -e "n\np\n\n\n\nw" | fdisk ${device}
      sleep 1
      echo ""
      pressanykey
      if [ "${device::8}" == "/dev/nvm" ]; then
        bootdev=${device}"p1"
        swapdev=${device}"p2"
        rootdev=${device}"p3"
      else
        bootdev=${device}"1"
        swapdev=${device}"2"
        rootdev=${device}"3"
      fi
      efimode="0"
    fi
  fi
}

diskpartautogpt(){
    device=$(selectdisk "${txtautoparts} (gpt)")
  if [ "$?" = "0" ]; then
    if (whiptail --backtitle "${apptitle}" --title "${txtautoparts} (gpt)" --yesno "${txtautopartsconfirm//%1/${device}}" --defaultno 0 0) then
      clear
      echo "${txtautopartclear}"
      parted ${device} mklabel gpt
      echo "${txtautopartcreate//%1/BIOS boot}"
      sgdisk ${device} -n=1:0:+31M -t=1:ef02
      echo "${txtautopartcreate//%1/boot}"
      sgdisk ${device} -n=2:0:+512M
      echo "${txtautopartcreate//%1/swap}"
      swapsize=$(cat /proc/meminfo | grep MemTotal | awk '{ print $2 }')
      swapsize=$((${swapsize}/1000))"M"
      sgdisk ${device} -n=3:0:+${swapsize} -t=3:8200
      echo "${txtautopartcreate//%1/root}"
      sgdisk ${device} -n=4:0:0
      echo ""
      pressanykey
      if [ "${device::8}" == "/dev/nvm" ]; then
        bootdev=${device}"p2"
        swapdev=${device}"p3"
        rootdev=${device}"p4"
      else
        bootdev=${device}"2"
        swapdev=${device}"3"
        rootdev=${device}"4"
      fi
      efimode="0"
    fi
  fi
}

diskpartautoefi(){
    device=$(selectdisk "${txtautoparts} (gpt,efi)")
  if [ "$?" = "0" ]; then
    if (whiptail --backtitle "${apptitle}" --title "${txtautoparts} (gpt,efi)" --yesno "${txtautopartsconfirm//%1/${device}}" --defaultno 0 0) then
      clear
      echo "${txtautopartclear}"
      parted ${device} mklabel gpt
      echo "${txtautopartcreate//%1/EFI boot}"
      sgdisk ${device} -n=1:0:+1024M -t=1:ef00
      echo "${txtautopartcreate//%1/swap}"
      swapsize=$(cat /proc/meminfo | grep MemTotal | awk '{ print $2 }')
      swapsize=$((${swapsize}/1000))"M"
      sgdisk ${device} -n=3:0:+${swapsize} -t=3:8200
      echo "${txtautopartcreate//%1/root}"
      sgdisk ${device} -n=4:0:0
      echo ""
      pressanykey
      if [ "${device::8}" == "/dev/nvm" ]; then
        bootdev=${device}"p1"
        swapdev=${device}"p3"
        rootdev=${device}"p4"
      else
        bootdev=${device}"1"
        swapdev=${device}"3"
        rootdev=${device}"4"
      fi
      efimode="1"
    fi
  fi
}

diskpartautoefiusb(){
    device=$(selectdisk "${txtautoparts} (gpt,efi)")
  if [ "$?" = "0" ]; then
    if (whiptail --backtitle "${apptitle}" --title "${txtautoparts} (gpt,efi)" --yesno "${txtautopartsconfirm//%1/${device}}" --defaultno 0 0) then
      clear
      echo "${txtautopartclear}"
      parted ${device} mklabel gpt
      echo "${txtautopartcreate//%1/EFI boot}"
      sgdisk ${device} -n=1:0:+1024M -t=1:ef00
      echo "${txtautopartcreate//%1/root}"
      sgdisk ${device} -n=4:0:0
      echo "${txthybridpartcreate}"
      echo -e "r\nh\n3\nN\n\nY\nN\nw\nY\n" | gdisk ${device}
      echo ""
      pressanykey
      if [ "${device::8}" == "/dev/nvm" ]; then
        bootdev=${device}"p1"
        swapdev=
        rootdev=${device}"p4"
      else
        bootdev=${device}"1"
        swapdev=
        rootdev=${device}"4"
      fi
      efimode="2"
    fi
  fi
}

diskpartcfdisk(){
    device=$( selectdisk "${txteditparts} (cfdisk)" )
  if [ "$?" = "0" ]; then
    clear
    cfdisk ${device}
  fi
}

diskpartcgdisk(){
    device=$( selectdisk "${txteditparts} (cgdisk)" )
  if [ "$?" = "0" ]; then
    clear
    cgdisk ${device}
  fi
}
# --------------------------------------------------------



# --------------------------------------------------------
selectparts(){
  items=$(lsblk -p -n -l -o NAME -e 7,11)
  options=()
  for item in ${items}; do
    options+=("${item}" "")
  done

  bootdev=$(whiptail --backtitle "${apptitle}" --title "${txtselectpartsmenu}" --menu "${txtselectdevice//%1/boot}" --default-item "${bootdev}" 0 0 0 \
    "none" "-" \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    return 1
  else
    if [ "${bootdev}" = "none" ]; then
      bootdev=
    fi
  fi

  swapdev=$(whiptail --backtitle "${apptitle}" --title "${txtselectpartsmenu}" --menu "${txtselectdevice//%1/swap}" --default-item "${swapdev}" 0 0 0 \
    "none" "-" \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    return 1
  else
    if [ "${swapdev}" = "none" ]; then
      swapdev=
    fi
  fi

  rootdev=$(whiptail --backtitle "${apptitle}" --title "${txtselectpartsmenu}" --menu "${txtselectdevice//%1/root}" --default-item "${rootdev}" 0 0 0 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    return 1
  fi
  realrootdev=${rootdev}

  homedev=$(whiptail --backtitle "${apptitle}" --title "${txtselectpartsmenu}" --menu "${txtselectdevice//%1/home}" 0 0 0 \
    "none" "-" \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    return 1
  else
    if [ "${homedev}" = "none" ]; then
      homedev=
    fi
  fi

  msg="${txtselecteddevices}\n\n"
  msg=${msg}"boot : "${bootdev}"\n"
  msg=${msg}"swap : "${swapdev}"\n"
  msg=${msg}"root : "${rootdev}"\n"
  msg=${msg}"home : "${homedev}"\n\n"
  if (whiptail --backtitle "${apptitle}" --title "${txtselectpartsmenu}" --yesno "${msg}" 0 0) then
    isnvme=0
    if [ "${bootdev::8}" == "/dev/nvm" ]; then
      isnvme=1
    fi
    if [ "${rootdev::8}" == "/dev/nvm" ]; then
      isnvme=1
    fi
    mountmenu
  fi
}
# --------------------------------------------------------



# --------------------------------------------------------
mountmenu(){
  if [ "${1}" = "" ]; then
    nextitem="."
  else
    nextitem=${1}
  fi
  options=()
  options+=("${txtformatdevices}" "")
  options+=("${txtmount}" "${txtmountdesc}")
  sel=$(whiptail --backtitle "${apptitle}" --title "${txtformatmountmenu}" --menu "" --cancel-button "${txtback}" --default-item "${nextitem}" 0 0 0 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  if [ "$?" = "0" ]; then
    case ${sel} in
      "${txtformatdevices}")
        formatdevices
        nextitem="${txtmount}"
      ;;
      "${txtmount}")
        mountparts
        nextitem="${txtmount}"
      ;;
    esac
    mountmenu "${nextitem}"
  fi
}


formatdevices(){
  if (whiptail --backtitle "${apptitle}" --title "${txtformatdevices}" --yesno "${txtformatdeviceconfirm}" --defaultno 0 0) then
    if [ ! "${bootdev}" = "" ]; then
      formatbootdevice boot ${bootdev}
    fi
    if [ ! "${swapdev}" = "" ]; then
      formatswapdevice swap ${swapdev}
    fi
    formatdevice root ${rootdev}
    if [ ! "${homedev}" = "" ]; then
      formatdevice home ${homedev}
    fi
  fi
}
formatbootdevice(){
  options=()
  if [ "${efimode}" == "1" ]||[ "${efimode}" = "2" ]; then
    options+=("fat32" "(EFI)")
  fi
  options+=("ext2" "")
  options+=("ext3" "")
  options+=("ext4" "")
  if [ ! "${efimode}" = "1" ]&&[ ! "${efimode}" = "2" ]; then
    options+=("fat32" "(EFI)")
  fi
  sel=$(whiptail --backtitle "${apptitle}" --title "${txtformatdevice}" --menu "${txtselectpartformat//%1/${1} (${2})}" 0 0 0 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    return 1
  fi
  clear
  echo "${txtformatingpart//%1/${2}} ${sel}"
  echo "----------------------------------------------"
  case ${sel} in
    ext2)
      echo "mkfs.ext2 ${2}"
      mkfs.ext2 ${2}
    ;;
    ext3)
      echo "mkfs.ext3 ${2}"
      mkfs.ext3 ${2}
    ;;
    ext4)
      echo "mkfs.ext4 ${2}"
      mkfs.ext4 ${2}
    ;;
    fat32)
      echo "mkfs.fat ${2}"
      mkfs.fat ${2}
    ;;
  esac
  echo ""
  pressanykey
}
formatswapdevice(){
  options=()
  options+=("swap" "")
  sel=$(whiptail --backtitle "${apptitle}" --title "${txtformatdevice}" --menu "${txtselectpartformat//%1/${1} (${2})}" 0 0 0 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    return 1
  fi
  clear
  echo "${txtformatingpart//%1/${swapdev}} swap"
  echo "----------------------------------------------------"
  case ${sel} in
    swap)
      echo "mkswap ${swapdev}"
      mkswap ${swapdev}
      echo ""
      pressanykey
    ;;
  esac
  clear
}
formatdevice(){
  options=()
  options+=("btrfs" "")
  options+=("reiserfs" "")
  options+=("ext4" "")
  options+=("ext3" "")
  options+=("ext2" "")
  options+=("xfs" "")
  options+=("f2fs" "")
  options+=("jfs" "")
  if [ ! "${3}" = "noluks" ]; then
    options+=("luks" "encrypted")
  fi
  sel=$(whiptail --backtitle "${apptitle}" --title "${txtformatdevice}" --menu "${txtselectpartformat//%1/${1} (${2})}" 0 0 0 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    return 1
  fi
  clear
  echo "${txtformatingpart//%1/${2}} ${sel}"
  echo "----------------------------------------------"
  case ${sel} in
    btrfs)
      echo "mkfs.btrfs -f ${2}"
      mkfs.btrfs -f ${2}
      if [ "${1}" = "root" ]; then
        echo "mount ${2} /mnt"
        echo "btrfs subvolume create /mnt/root"
        echo "btrfs subvolume set-default /mnt/root"
        echo "umount /mnt"
        mount ${2} /mnt
        btrfs subvolume create /mnt/root
        btrfs subvolume set-default /mnt/root
        umount /mnt
      fi
    ;;
    reiserfs)
      echo "mkfs.reiserfs -f ${2}"
      mkfs.reiserfs -f ${2}
    ;;
    ext4)
      echo "mkfs.ext4 ${2}"
      mkfs.ext4 ${2}
    ;;
    ext3)
      echo "mkfs.ext3 ${2}"
      mkfs.ext3 ${2}
    ;;
    ext2)
      echo "mkfs.ext2 ${2}"
      mkfs.ext2 ${2}
    ;;
    xfs)
      echo "mkfs.xfs -f ${2}"
      mkfs.xfs -f ${2}
    ;;
    f2fs)
      echo "mkfs.f2fs $2"
      mkfs.f2fs $2
    ;;
    jfs)
      echo "mkfs.xfs -f ${2}"
      mkfs.jfs -f ${2}
    ;;
    luks)
      echo "${txtcreateluksdevice}"
      echo "cryptsetup luksFormat ${2}"
      cryptsetup luksFormat ${2}
      if [ ! "$?" = "0" ]; then
        pressanykey
        return 1
      fi
      pressanykey
      echo ""
      echo "${txtopenluksdevice}"
      echo "cryptsetup luksOpen ${2} ${1}"
      cryptsetup luksOpen ${2} ${1}
      if [ ! "$?" = "0" ]; then
        pressanykey
        return 1
      fi
      pressanykey
      options=()
      options+=("normal" "")
      options+=("fast" "")
      sel=$(whiptail --backtitle "${apptitle}" --title "${txtformatdevice}" --menu "Wipe device ?" --cancel-button="${txtignore}" 0 0 0 \
        "${options[@]}" \
        3>&1 1>&2 2>&3)
      if [ "$?" = "0" ]; then
        case ${sel} in
          normal)
            echo "dd if=/dev/zero of=/dev/mapper/${1}"
            dd if=/dev/zero of=/dev/mapper/${1} & PID=$! &>/dev/null
          ;;
          fast)
            echo "dd if=/dev/zero of=/dev/mapper/${1} bs=60M"
            dd if=/dev/zero of=/dev/mapper/${1} bs=60M & PID=$! &>/dev/null
          ;;
        esac
        clear
        sleep 1
        while kill -USR1 ${PID} &>/dev/null
        do
          sleep 1
        done
      fi
      echo ""
      pressanykey
      formatdevice ${1} /dev/mapper/${1} noluks
      if [ "${1}" = "root" ]; then
        realrootdev=${rootdev}
        rootdev=/dev/mapper/${1}
        luksroot=1
        luksrootuuid=$(cryptsetup luksUUID ${2})
      else
        case ${1} in
          home) homedev=/dev/mapper/${1} ;;
        esac
        luksdrive=1
        crypttab="\n${1}    UUID=$(cryptsetup luksUUID ${2})    none"
      fi
      echo ""
      echo "${txtluksdevicecreated}"
    ;;
  esac
  echo ""
  pressanykey
}

mountparts(){
  clear
  echo "mount ${rootdev} /mnt"
  mount ${rootdev} /mnt
  echo "mkdir /mnt/{boot,home}"
  mkdir /mnt/{boot,home} 2>/dev/null
  if [ ! "${bootdev}" = "" ]; then
    echo "mount ${bootdev} /mnt/boot"
    mount ${bootdev} /mnt/boot
  fi
  if [ ! "${swapdev}" = "" ]; then
    echo "swapon ${swapdev}"
    swapon ${swapdev}
  fi
  if [ ! "${homedev}" = "" ]; then
    echo "mount ${homedev} /mnt/home"
    mount ${homedev} /mnt/home
  fi
  pressanykey
  installmenu
}
# --------------------------------------------------------



# --------------------------------------------------------
installmenu(){
  if [ "${1}" = "" ]; then
    nextitem="${txtinstallarchlinux}"
  else
    nextitem=${1}
  fi
  options=()
  options+=("${txteditmirrorlist}" "(${txtoptional})")
  options+=("${txtinstallarchlinux}" "pacstrap base kernel")
  options+=("${txtinstallfirmware}" "(${txtoptional}) pacstrap linux-firmware")
  options+=("${txtconfigarchlinux}" "")
  sel=$(whiptail --backtitle "${apptitle}" --title "${txtinstallmenu}" --menu "" --cancel-button "${txtunmount}" --default-item "${nextitem}" 0 0 0 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  if [ "$?" = "0" ]; then
    case ${sel} in
      "${txteditmirrorlist}")
        ${EDITOR} /etc/pacman.d/mirrorlist
        nextitem="${txtinstallarchlinux}"
      ;;
      "${txtinstallarchlinux}")
        if(installbase) then
          nextitem="${txtinstallfirmware}"
        fi
      ;;
      "${txtinstallfirmware}")
        installfirmware
        nextitem="${txtconfigarchlinux}"
      ;;
      "${txtconfigarchlinux}")
        archmenu
        nextitem="${txtconfigarchlinux}"
      ;;
    esac
    installmenu "${nextitem}"
  else
    unmountdevices
  fi
}

installbase(){
  clear
  echo "pacstrap /mnt base"
  #pacman-key --init
  #pacman-key --populate archlinux
  #pacman-key --refresh-keys
  pacstrap /mnt base base-devel linux linux-headers nano netctl dhcpcd which inetutils wpa_supplicant dialog btrfs-progs dosfstools efitools git wget curl zsh
  pressanykey
}

installfirmware(){
  clear
  echo "pacstrap /mnt linux-firmware"
  pacstrap /mnt linux-firmware
  pressanykey
}

unmountdevices(){
  clear
  echo "umount -R /mnt"
  umount -R /mnt
  if [ ! "${swapdev}" = "" ]; then
    echo "swapoff ${swapdev}"
    swapoff ${swapdev}
  fi
  pressanykey
}
# --------------------------------------------------------



# --------------------------------------------------------
archmenu(){
  if [ "${1}" = "" ]; then
    nextitem="."
  else
    nextitem=${1}
  fi
  options=()
  options+=("${txtsethostname}" "/etc/hostname")
  options+=("${txtsetkeymap}" "/etc/vconsole.conf")
  options+=("${txtsetfont}" "/etc/vconsole.conf (${txtoptional})")
  options+=("${txtsetlocale}" "/etc/locale.conf, /etc/locale.gen")
  options+=("${txtsettime}" "/etc/localtime")
  options+=("${txtsetrootpassword}" "")
  options+=("${txtgenerate//%1/fstab}" "")
  if [ "${luksdrive}" = "1" ]; then
    options+=("${txtgenerate//%1/crypttab}" "")
  fi
  if [ "${luksroot}" = "1" ]; then
    options+=("${txtgenerate//%1/mkinitcpio.conf-luks}" "(encrypt hooks)")
  fi
  if [ "${isnvme}" = "1" ]; then
    options+=("${txtgenerate//%1/mkinitcpio.conf-nvme}" "(nvme module)")
  fi
  options+=("${txtedit//%1/fstab}" "(${txtoptional})")
  options+=("${txtedit//%1/crypttab}" "(${txtoptional})")
  options+=("${txtedit//%1/mkinitcpio.conf}" "(${txtoptional})")
  options+=("${txtedit//%1/mirrorlist}" "(${txtoptional})")
  options+=("${txtbootloader}" "")
  options+=("${txtenable//%1/dhcpcd}" "systemctl enable dhcpcd")
  sel=$(whiptail --backtitle "${apptitle}" --title "${txtarchinstallmenu}" --menu "" --cancel-button "${txtback}" --default-item "${nextitem}" 0 0 0 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  if [ "$?" = "0" ]; then
    case ${sel} in
      "${txtsethostname}")
        archsethostname
        nextitem="${txtsetkeymap}"
      ;;
      "${txtsetkeymap}")
        archsetkeymap
        nextitem="${txtsetlocale}"
      ;;
      "${txtsetfont}")
        archsetfont
        nextitem="${txtsetlocale}"
      ;;
      "${txtsetlocale}")
        archsetlocale
        nextitem="${txtsettime}"
      ;;
      "${txtsettime}")
        archsettime
        nextitem="${txtsetrootpassword}"
      ;;
      "${txtsetrootpassword}")
        archsetrootpassword
        nextitem="${txtgenerate//%1/fstab}"
      ;;
      "${txtgenerate//%1/fstab}")
        archgenfstabmenu
        if [ "${luksdrive}" = "1" ]; then
          nextitem="${txtgenerate//%1/crypttab}"
        else
          if [ "${luksroot}" = "1" ]; then
            nextitem="${txtgenerate//%1/mkinitcpio.conf-luks}"
          else
            if [ "${isnvme}" = "1" ]; then
              nextitem="${txtgenerate//%1/mkinitcpio.conf-nvme}"
            else
              nextitem="${txtbootloader}"
            fi
          fi
        fi
      ;;
      "${txtgenerate//%1/crypttab}")
        archgencrypttab
        if [ "${luksroot}" = "1" ]; then
          nextitem="${txtgenerate//%1/mkinitcpio.conf-luks}"
        else
          if [ "${isnvme}" = "1" ]; then
            nextitem="${txtgenerate//%1/mkinitcpio.conf-nvme}"
          else
            nextitem="${txtbootloader}"
          fi
        fi
      ;;
      "${txtgenerate//%1/mkinitcpio.conf-luks}")
        archgenmkinitcpioluks
        if [ "${isnvme}" = "1" ]; then
          nextitem="${txtgenerate//%1/mkinitcpio.conf-nvme}"
        else
          nextitem="${txtbootloader}"
        fi
      ;;
      "${txtgenerate//%1/mkinitcpio.conf-nvme}")
        archgenmkinitcpionvme
        nextitem="${txtbootloader}"
      ;;
      "${txtedit//%1/fstab}")
        ${EDITOR} /mnt/etc/fstab
        nextitem="${txtedit//%1/fstab}"
      ;;
      "${txtedit//%1/crypttab}")
        ${EDITOR} /mnt/etc/crypttab
        nextitem="${txtedit//%1/crypttab}"
      ;;
      "${txtedit//%1/mkinitcpio.conf}")
        archeditmkinitcpio
        nextitem="${txtedit//%1/mkinitcpio.conf}"
      ;;
      "${txtedit//%1/mirrorlist}")
        ${EDITOR} /mnt/etc/pacman.d/mirrorlist
        nextitem="${txtedit//%1/mirrorlist}"
      ;;
      "${txtbootloader}")
        archbootloadermenu
        nextitem="${txtenable//%1/dhcpcd}"
      ;;
      "${txtenable//%1/dhcpcd}")
        archenabledhcpcd
        nextitem="dhcpcd"
      ;;
    esac
    archmenu "${nextitem}"
  fi
}

archchroot(){
  echo "arch-chroot /mnt /root"
  cp ${0} /mnt/root
  chmod 755 /mnt/root/$(basename "${0}")
  arch-chroot /mnt /root/$(basename "${0}") --chroot ${1} ${2}
  rm /mnt/root/$(basename "${0}")
  echo "exit"
}


archsethostname(){
  hostname=$(whiptail --backtitle "${apptitle}" --title "${txtsethostname}" --inputbox "" 0 0 "arsh" 3>&1 1>&2 2>&3)
  if [ "$?" = "0" ]; then
    clear
    echo "echo \"${hostname}\" > /mnt/etc/hostname"
    echo "${hostname}" > /mnt/etc/hostname
    pressanykey
  fi
}

archsetkeymap(){
  items=$(find /usr/share/kbd/keymaps/ -type f -printf "%f\n" | sort -V)
  options=()
  defsel=""
  for item in ${items}; do
    if [ "${item%%.*}" == "${keymap}" ]; then
      defsel="${item%%.*}"
    fi
    options+=("${item%%.*}" "")
  done
  keymap=$(whiptail --backtitle "${apptitle}" --title "${txtsetkeymap}" --menu "" --default-item "${defsel}" 0 0 0 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  if [ "$?" = "0" ]; then
    clear
    echo "echo \"KEYMAP=${keymap}\" > /mnt/etc/vconsole.conf"
    echo "KEYMAP=${keymap}" > /mnt/etc/vconsole.conf
    pressanykey
  fi
}

archsetfont(){
  items=$(find /usr/share/kbd/consolefonts/*.psfu.gz -printf "%f\n")

  options=()
  for item in ${items}; do
    options+=("${item%%.*}" "")
  done
  vcfont=$(whiptail --backtitle "${apptitle}" --title "${txtsetfont} (${txtoptional})" --menu "" 0 0 0 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  if [ "$?" = "0" ]; then
    clear
    echo "echo \"FONT=${vcfont}\" >> /mnt/etc/vconsole.conf"
    echo "FONT=${vcfont}" >> /mnt/etc/vconsole.conf
    pressanykey
  fi
}

archsetlocale(){
  items=$(ls /usr/share/i18n/locales)
  options=()
  defsel=""
  for item in ${items}; do
    if [ "${defsel}" == "" ]&&[ "${keymap::2}" == "${item::2}" ]; then
      defsel="${item}"
    fi
    options+=("${item}" "")
  done
  locale=$(whiptail --backtitle "${apptitle}" --title "${txtsetlocale}" --menu "" --default-item "${defsel}" 0 0 0 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  if [ "$?" = "0" ]; then
    clear
    echo "echo \"LANG=${locale}.UTF-8\" > /mnt/etc/locale.conf"
    echo "LANG=${locale}.UTF-8" > /mnt/etc/locale.conf
    echo "echo \"LC_COLLATE=C\" >> /mnt/etc/locale.conf"
    echo "LC_COLLATE=C" >> /mnt/etc/locale.conf
    echo "sed -i '/"${locale}".UTF-8/s/^#//g' /mnt/etc/locale.gen"
    sed -i '/'${locale}'.UTF-8/s/^#//g' /mnt/etc/locale.gen
    archchroot setlocale
    pressanykey
  fi
}
archsetlocalechroot(){
  echo "locale-gen"
  locale-gen
  exit
}

archsettime(){
  items=$(ls -l /mnt/usr/share/zoneinfo/ | grep '^d' | gawk -F':[0-9]* ' '/:/{print $2}')
  options=()
  for item in ${items}; do
    options+=("${item}" "")
  done

  timezone=$(whiptail --backtitle "${apptitle}" --title "${txtsettime}" --menu "" 0 0 0 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    return 1
  fi


  items=$(ls /mnt/usr/share/zoneinfo/${timezone}/)
  options=()
  for item in ${items}; do
    options+=("${item}" "")
  done

  timezone=${timezone}/$(whiptail --backtitle "${apptitle}" --title "${txtsettime}" --menu "" 0 0 0 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  if [ ! "$?" = "0" ]; then
    return 1
  fi

  clear
  echo "ln -sf /mnt/usr/share/zoneinfo/${timezone} /mnt/etc/localtime"
  ln -sf /usr/share/zoneinfo/${timezone} /mnt/etc/localtime
  pressanykey

  if (whiptail --backtitle "${apptitle}" --title "${txtsettime}" --yesno "${txtuseutcclock}" 0 0) then
    clear
    archchroot settimeutc
  else
    clear
    archchroot settimelocal
  fi

  pressanykey

}
archsettimeutcchroot(){
  echo "hwclock --systohc --utc"
  hwclock --systohc --utc
  exit
}
archsettimelocalchroot(){
  echo "hwclock --systohc --localtime"
  hwclock --systohc --localtime
  exit
}

archsetrootpassword(){
  clear
  archchroot setrootpassword
  pressanykey
}
archsetrootpasswordchroot(){
  echo "passwd root"
  passwd root
  exit
}

archgenfstabmenu(){
  options=()
  options+=("UUID" "genfstab -U")
  options+=("LABEL" "genfstab -L")
  options+=("PARTUUID" "genfstab -t PARTUUID")
  options+=("PARTLABEL" "genfstab -t PARTLABEL")
  sel=$(whiptail --backtitle "${apptitle}" --title "${txtgenerate//%1/fstab}" --menu "" --cancel-button "${txtback}" --default-item "${nextitem}" 0 0 0 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  if [ "$?" = "0" ]; then
    case ${sel} in
      "UUID")
        clear
        echo "genfstab -U -p /mnt > /mnt/etc/fstab"
        genfstab -U -p /mnt > /mnt/etc/fstab
      ;;
      "LABEL")
        clear
        echo "genfstab -L -p /mnt > /mnt/etc/fstab"
        genfstab -L -p /mnt > /mnt/etc/fstab
      ;;
      "PARTUUID")
        clear
        echo "genfstab -t PARTUUID -p /mnt > /mnt/etc/fstab"
        genfstab -t PARTUUID -p /mnt > /mnt/etc/fstab
      ;;
      "PARTLABEL")
        clear
        echo "genfstab -t PARTLABEL -p /mnt > /mnt/etc/fstab"
        genfstab -t PARTLABEL -p /mnt > /mnt/etc/fstab
      ;;
    esac
  fi
  pressanykey
}

archgencrypttab(){
  clear
  echo "echo -e \"${crypttab}\" >> /mnt/etc/crypttab"
  echo -e "${crypttab}" >> /mnt/etc/crypttab
  pressanykey
}

archgenmkinitcpioluks(){
  clear
  echo "sed -i \"s/block filesystems/block encrypt filesystems/g\" /mnt/etc/mkinitcpio.conf"
  sed -i "s/block filesystems/block encrypt filesystems/g" /mnt/etc/mkinitcpio.conf
  archchroot genmkinitcpio
  pressanykey
}
archgenmkinitcpionvme(){
  clear
  echo "sed -i \"s/MODULES=()/MODULES=(nvme)/g\" /mnt/etc/mkinitcpio.conf"
  sed -i "s/MODULES=()/MODULES=(nvme)/g" /mnt/etc/mkinitcpio.conf
  archchroot genmkinitcpio
  pressanykey
}

archeditmkinitcpio(){
  ${EDITOR} /mnt/etc/mkinitcpio.conf
  if (whiptail --backtitle "${apptitle}" --title "${txtedit//%1/mkinitcpio.conf}" --yesno "${txtgenerate//%1/mkinitcpio} ?" 0 0) then
    clear
    archchroot genmkinitcpio
    pressanykey
  fi
}
archgenmkinitcpiochroot(){
  echo "mkinitcpio -p linux"
  mkinitcpio -p linux
  exit
}


archbootloadermenu(){
  options=()
  options+=("grub" "")
  if [ "${efimode}" == "1" ]; then
    options+=("systemd-boot" "")
    options+=("refind" "")
  fi
  if [ "${efimode}" != "2" ]; then
    options+=("syslinux" "")
  fi
  sel=$(whiptail --backtitle "${apptitle}" --title "${txtbootloadermenu}" --menu "" --cancel-button "${txtback}" 0 0 0 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  if [ "$?" = "0" ]; then
    case ${sel} in
      "grub") archbootloadergrubmenu;;
      "systemd-boot")archbootloadersystemdbmenu;;
      "refind") archbootloaderrefindmenu;;
      "syslinux")archbootloadersyslinuxbmenu;;
    esac
  fi
}


archbootloadergrubmenu(){
  if [ "${1}" = "" ]; then
    nextblitem="."
  else
    nextblitem=${1}
  fi
  options=()
  options+=("${txtinstall//%1/grub}" "pacstrap grub (efibootmgr), grub-mkconfig")
  options+=("${txtedit//%1/grub}" "(${txtoptional})")
  options+=("${txtinstall//%1/bootloader}" "grub-install")
  sel=$(whiptail --backtitle "${apptitle}" --title "${txtbootloadergrubmenu}" --menu "" --cancel-button "${txtback}" --default-item "${nextblitem}" 0 0 0 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  if [ "$?" = "0" ]; then
    case ${sel} in
      "${txtinstall//%1/grub}")
        archgrubinstall
        nextblitem="${txtinstall//%1/bootloader}"
      ;;
      "${txtedit//%1/grub}")
        ${EDITOR} /mnt/etc/default/grub
        if (whiptail --backtitle "${apptitle}" --title "${txtedit//%1/grub}" --yesno "${txtrungrubmakeconfig}" 0 0) then
          clear
          archchroot grubinstall
          pressanykey
        fi
        nextblitem="${txtinstall//%1/bootloader}"
      ;;
      "${txtinstall//%1/bootloader}")
        archgrubinstallbootloader
        nextblitem="${txtinstall//%1/bootloader}"
      ;;
    esac
    archbootloadergrubmenu "${nextblitem}"
  fi
}

archgrubinstall(){
  clear
  echo "pacstrap /mnt grub"
  pacstrap /mnt grub
  pressanykey

  if [ "${eficomputer}" == "1" ]; then
    if [ "${efimode}" == "1" ]||[ "${efimode}" == "2" ]; then
      if (whiptail --backtitle "${apptitle}" --title "${txtinstall//%1/efibootmgr}" --yesno "${txtefibootmgr}" 0 0) then
        clear
        echo "pacstrap /mnt efibootmgr"
        pacstrap /mnt efibootmgr
        pressanykey
      fi
    else
      if (whiptail --backtitle "${apptitle}" --title "${txtinstall//%1/efibootmgr}" --yesno "${txtefibootmgr}" --defaultno 0 0) then
        clear
        echo "pacstrap /mnt efibootmgr"
        pacstrap /mnt efibootmgr
        pressanykey
      fi
    fi
  fi

  if [ "${luksroot}" = "1" ]; then
    if (whiptail --backtitle "${apptitle}" --title "${txtinstall//%1/grub}" --yesno "${txtgrubluksdetected}" 0 0) then
      clear
      echo "sed -i /GRUB_CMDLINE_LINUX=/c\GRUB_CMDLINE_LINUX=\\\"cryptdevice=/dev/disk/by-uuid/${luksrootuuid}:root\\\" /mnt/etc/default/grub"
      sed -i /GRUB_CMDLINE_LINUX=/c\GRUB_CMDLINE_LINUX=\"cryptdevice=/dev/disk/by-uuid/${luksrootuuid}:root\" /mnt/etc/default/grub
      pressanykey
    fi
  fi

  clear
  archchroot grubinstall
  pressanykey
}
archgrubinstallchroot(){
  echo "mkdir /boot/grub"
  echo "grub-mkconfig -o /boot/grub/grub.cfg"
  mkdir /boot/grub
  grub-mkconfig -o /boot/grub/grub.cfg
  exit
}

archgrubinstallbootloader(){
    device=$( selectdisk "${txtinstall//%1/bootloader}" )
  if [ "$?" = "0" ]; then
    if [ "${eficomputer}" == "1" ]; then
      options=()
      if [ "${efimode}" = "1" ]; then
        options+=("EFI" "")
        options+=("BIOS" "")
        options+=("BIOS+EFI" "")
      elif [ "${efimode}" = "2" ]; then
        options+=("BIOS+EFI" "")
        options+=("BIOS" "")
        options+=("EFI" "")
      else
        options+=("BIOS" "")
        options+=("EFI" "")
        options+=("BIOS+EFI" "")
      fi
      sel=$(whiptail --backtitle "${apptitle}" --title "${txtinstall//%1/bootloader}" --menu "" --cancel-button "${txtback}" 0 0 0 \
        "${options[@]}" \
        3>&1 1>&2 2>&3)
      if [ "$?" = "0" ]; then
        clear
        case ${sel} in
          "BIOS") archchroot grubbootloaderinstall ${device};;
          "EFI") archchroot grubbootloaderefiinstall ${device};;
          "BIOS+EFI") archchroot grubbootloaderefiusbinstall ${device};;
        esac
        pressanykey
      fi
    else
      clear
      archchroot grubbootloaderinstall ${device}
      pressanykey
    fi
  fi
}
archgrubinstallbootloaderchroot(){
  if [ ! "${1}" = "none" ]; then
    echo "grub-install --target=i386-pc --recheck ${1}"
    grub-install --target=i386-pc --recheck ${1}
  fi
  exit
}
archgrubinstallbootloaderefichroot(){
  if [ ! "${1}" = "none" ]; then
    echo "grub-install --target=x86_64-efi --efi-directory=/boot --recheck ${1}"
    grub-install --target=x86_64-efi --efi-directory=/boot --recheck ${1}
    isvbox=$(lspci | grep "VirtualBox G")
    if [ "${isvbox}" ]; then
      echo "VirtualBox detected, creating startup.nsh..."
      echo "\EFI\arch\grubx64.efi" > /boot/startup.nsh
    fi
  fi
  exit
}
archgrubinstallbootloaderefiusbchroot(){
  if [ ! "${1}" = "none" ]; then
    echo "grub-install --target=i386-pc --recheck ${1}"
    grub-install --target=i386-pc --recheck ${1}
    echo "grub-install --target=x86_64-efi --efi-directory=/boot --removable --recheck ${1}"
    grub-install --target=x86_64-efi --efi-directory=/boot --removable --recheck ${1}
    isvbox=$(lspci | grep "VirtualBox G")
    if [ "${isvbox}" ]; then
      echo "VirtualBox detected, creating startup.nsh..."
      echo "\EFI\arch\grubx64.efi" > /boot/startup.nsh
    fi
  fi
  exit
}


archbootloadersyslinuxbmenu(){
  if [ "${1}" = "" ]; then
    nextblitem="."
  else
    nextblitem=${1}
  fi
  options=()
  options+=("${txtinstall//%1/syslinux}" "pacstrap syslinux (gptfdisk,mtools)")
  options+=("${txtedit//%1/syslinux}" "(${txtoptional})")
  options+=("${txtinstall//%1/bootloader}" "syslinux-install_update")
  sel=$(whiptail --backtitle "${apptitle}" --title "${txtbootloadersyslinuxmenu}" --menu "" --cancel-button "${txtback}" --default-item "${nextblitem}" 0 0 0 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  if [ "$?" = "0" ]; then
    case ${sel} in
      "${txtinstall//%1/syslinux}")
        archsyslinuxinstall
        nextblitem="${txtinstall//%1/bootloader}"
      ;;
      "${txtedit//%1/syslinux}")
        ${EDITOR} /mnt/boot/syslinux/syslinux.cfg
        nextblitem="${txtinstall//%1/bootloader}"
      ;;
      "${txtinstall//%1/bootloader}")
        archsyslinuxinstallbootloader
        nextblitem="${txtinstall//%1/bootloader}"
      ;;
    esac
    archbootloadersyslinuxbmenu "${nextblitem}"
  fi
}
archsyslinuxinstall(){
  clear

  if [ "${efimode}" == "1" ]||[ "${efimode}" == "2" ]; then
    echo "${txtsyslinuxaddefibootmgr}"
    additionalpkg=${additionalpkg}"efibootmgr "
  fi

  if [ "${isnvme}" = "1" ]; then
    if [ "$(parted ${realrootdev::(-2)} print|grep gpt)" != "" ]; then
      echo "${txtsyslinuxaddgptfdisk}"
      additionalpkg=${additionalpkg}"gptfdisk "
    fi
  else
    if [ "$(parted ${realrootdev::8} print|grep gpt)" != "" ]; then
      echo "${txtsyslinuxaddgptfdisk}"
      additionalpkg=${additionalpkg}"gptfdisk "
    fi
  fi

  if [ "${bootdev}" != "" ]; then
    if [ "$(parted ${bootdev} print|grep fat)" != "" ]; then
      echo "${txtsyslinuxaddmtools}"
      additionalpkg=${additionalpkg}"mtools "
    fi
  fi

  echo "pacstrap /mnt syslinux ${additionalpkg}"
  pacstrap /mnt syslinux ${additionalpkg}
  pressanykey

  clear
  echo "Updating /boot/syslinux/syslinux.cfg"
  if [ "${luksroot}" = "1" ]; then
    echo "sed -i \"/APPEND\ root=/c\    APPEND root=/dev/mapper/root cryptdevice=${realrootdev}:root rw\" /mnt/boot/syslinux/syslinux.cfg"
    sed -i "/APPEND\ root=/c\    APPEND root=/dev/mapper/root cryptdevice=${realrootdev}:root\ rw" /mnt/boot/syslinux/syslinux.cfg
  else
    echo "sed -i \"/APPEND\ root=/c\    APPEND root=${rootdev} rw\" /mnt/boot/syslinux/syslinux.cfg"
    sed -i "/APPEND\ root=/c\    APPEND root=${rootdev}\ rw" /mnt/boot/syslinux/syslinux.cfg
  fi

  pressanykey
}
archsyslinuxinstallbootloader(){
  clear
  if [ "${efimode}" == "1" ]||[ "${efimode}" == "2" ]; then
    archchroot syslinuxbootloaderefiinstall ${bootdev}
  else
    archchroot syslinuxbootloaderinstall ${bootdev}
  fi
  pressanykey
}
archsyslinuxinstallbootloaderchroot(){
  if [ ! "${1}" = "none" ]; then
    echo "syslinux-install_update -i -a -m"
    syslinux-install_update -i -a -m
  fi
  exit
}
archsyslinuxinstallbootloaderefichroot(){
  if [ ! "${1}" = "none" ]; then
    echo "cp -r /usr/lib/syslinux/efi64/* /boot/syslinux"
    cp -r /usr/lib/syslinux/efi64/* /boot/syslinux
    if [ "${1::8}" == "/dev/nvm" ]; then
      echo "efibootmgr --create --disk ${1::(-2)} --part ${1:(-1)} --loader /syslinux/syslinux.efi --label "Syslinux" --verbose"
      efibootmgr --create --disk ${1::(-2)} --part ${1:(-1)} --loader /syslinux/syslinux.efi --label "Syslinux" --verbose
    else
      echo "efibootmgr --create --disk ${1::8} --part ${1:(-1)} --loader /syslinux/syslinux.efi --label "Syslinux" --verbose"
      efibootmgr --create --disk ${1::8} --part ${1:(-1)} --loader /syslinux/syslinux.efi --label "Syslinux" --verbose
    fi
    isvbox=$(lspci | grep "VirtualBox G")
    if [ "${isvbox}" ]; then
      echo "VirtualBox detected, creating startup.nsh..."
      echo "\syslinux\syslinux.efi" > /boot/startup.nsh
    fi
  fi
  exit
}


archbootloadersystemdbmenu(){
  if [ "${1}" = "" ]; then
    nextblitem="."
  else
    nextblitem=${1}
  fi
  options=()
  options+=("${txtinstall//%1/systemd-boot}" "bootctl install")
  options+=("${txtedit//%1/loader.conf}" "(${txtoptional})")
  options+=("${txtedit//%1/entries}" "(${txtoptional})")
  sel=$(whiptail --backtitle "${apptitle}" --title "${txtbootloadersystemdmenu}" --menu "" --cancel-button "${txtback}" --default-item "${nextblitem}" 0 0 0 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  if [ "$?" = "0" ]; then
    case ${sel} in
      "${txtinstall//%1/systemd-boot}")
        archsystemdinstall
        nextblitem="${txtinstall//%1/loader.conf}"
      ;;
      "${txtedit//%1/loader.conf}")
        ${EDITOR} /mnt/boot/loader/loader.conf
        nextblitem="${txtedit//%1/entries}"
      ;;
      "${txtedit//%1/entries}")
        ${EDITOR} /mnt/boot/loader/entries/*
        nextblitem="${txtedit//%1/entries}"
      ;;
    esac
    archbootloadersystemdbmenu "${nextblitem}"
  fi
}
archsystemdinstall(){
  clear
  archchroot systemdbootloaderinstall ${realrootdev}

  partuuid=$(blkid -s PARTUUID -o value ${realrootdev})
  parttype=$(blkid -s TYPE -o value ${rootdev})

  echo "cp /mnt/usr/share/systemd/bootctl/arch.conf /mnt/boot/loader/entries"
  echo "echo \"timeout 2\" >> /mnt/boot/loader/loader.conf"
  echo "cp /mnt/usr/share/systemd/bootctl/loader.conf /mnt/boot/loader"
  if [ "${luksroot}" = "1" ]; then
    cryptuuid=$(blkid -s UUID -o value ${realrootdev})
    echo "sed -i \"s/PARTUUID=XXXX/\\/dev\\/mapper\\/root/\" /mnt/boot/loader/entries/arch.conf"
    echo "sed -i \"s/XXXX/${parttype}/\" /mnt/boot/loader/entries/arch.conf"
    echo "sed -i \"s/root=/cryptdevice=UUID=${cryptuuid}:root root=/\" /mnt/boot/loader/entries/arch.conf"
  else
    echo "sed -i \"s/PARTUUID=XXXX/PARTUUID=${partuuid}/\" /mnt/boot/loader/entries/arch.conf"
    echo "sed -i \"s/XXXX/${parttype}/\" /mnt/boot/loader/entries/arch.conf"
  fi
  echo "cp /mnt/boot/loader/entries/arch.conf /mnt/boot/loader/entries/arch-fallback.conf"
  echo "sed -i \"s/Arch Linux/Arch Linux Fallback/\" /mnt/boot/loader/entries/arch-fallback.conf"
  echo "sed -i \"s/initramfs-linux/initramfs-linux-fallback/\" /mnt/boot/loader/entries/arch-fallback.conf"

  cp /mnt/usr/share/systemd/bootctl/loader.conf /mnt/boot/loader
  echo "timeout 2" >> /mnt/boot/loader/loader.conf
  cp /mnt/usr/share/systemd/bootctl/arch.conf /mnt/boot/loader/entries


  if [ "${luksroot}" = "1" ]; then
    sed -i "s/PARTUUID=XXXX/\/dev\/mapper\/root/" /mnt/boot/loader/entries/arch.conf
    sed -i "s/XXXX/${parttype}/" /mnt/boot/loader/entries/arch.conf
    sed -i "s/root=/cryptdevice=UUID=${cryptuuid}:root root=/" /mnt/boot/loader/entries/arch.conf
  else
    sed -i "s/PARTUUID=XXXX/PARTUUID=${partuuid}/" /mnt/boot/loader/entries/arch.conf
    sed -i "s/XXXX/${parttype}/" /mnt/boot/loader/entries/arch.conf
  fi

  cp /mnt/boot/loader/entries/arch.conf /mnt/boot/loader/entries/arch-fallback.conf
  sed -i "s/Arch Linux/Arch Linux Fallback/" /mnt/boot/loader/entries/arch-fallback.conf
  sed -i "s/initramfs-linux/initramfs-linux-fallback/" /mnt/boot/loader/entries/arch-fallback.conf

  pressanykey
}
archsystemdinstallchroot(){
  echo "bootctl --path=/boot install"
  bootctl --path=/boot install
  isvbox=$(lspci | grep "VirtualBox G")
  if [ "${isvbox}" ]; then
    echo "VirtualBox detected, creating startup.nsh..."
    echo "\EFI\systemd\systemd-bootx64.efi" > /boot/startup.nsh
  fi
}


archbootloaderrefindmenu(){
  if [ "${1}" = "" ]; then
    nextblitem="."
  else
    nextblitem=${1}
  fi
  options=()
  options+=("${txtinstall//%1/refind}" "pacstrap refind-efi")
  options+=("${txtedit//%1/refind_linux.conf}" "(${txtoptional})")
  sel=$(whiptail --backtitle "${apptitle}" --title "${txtbootloaderrefindmenu}" --menu "" --cancel-button "${txtback}" --default-item "${nextblitem}" 0 0 0 \
    "${options[@]}" \
    3>&1 1>&2 2>&3)
  if [ "$?" = "0" ]; then
    case ${sel} in
      "${txtinstall//%1/refind}")
        archrefindinstall
        nextblitem="${txtedit//%1/refind_linux.conf}"
      ;;
      "${txtedit//%1/refind_linux.conf}")
        ${EDITOR} /mnt/boot/refind_linux.conf
        nextblitem="${txtedit//%1/refind_linux.conf}"
      ;;
    esac
    archbootloaderrefindmenu "${nextblitem}"
  fi

}
archrefindinstall(){
  clear

  echo "pacstrap /mnt refind-efi"
  echo "archchroot refindbootloaderinstall ${realrootdev}"
  echo "echo \"\\\"Arch Linux         \\\" \\\"root=UUID=${rootuuid} rw add_efi_memmap\\\"\" > /mnt/boot/refind_linux.conf"
  echo "echo \"\\\"Arch Linux Fallback\\\" \\\"root=UUID=${rootuuid} rw add_efi_memmap initrd=/initramfs-linux-fallback.img\\\"\" >> /mnt/boot/refind_linux.conf"
  echo "echo \"\\\"Arch Linux Terminal\\\" \\\"root=UUID=${rootuuid} rw add_efi_memmap systemd.unit=multi-user.target\\\"\" >> /mnt/boot/refind_linux.conf"

  pacstrap /mnt refind-efi
  archchroot refindbootloaderinstall ${realrootdev}
  rootuuid=$(blkid -s UUID -o value ${realrootdev})
  echo "\"Arch Linux         \" \"root=UUID=${rootuuid} rw add_efi_memmap\"" > /mnt/boot/refind_linux.conf
  echo "\"Arch Linux Fallback\" \"root=UUID=${rootuuid} rw add_efi_memmap initrd=/initramfs-linux-fallback.img\"" >> /mnt/boot/refind_linux.conf
  echo "\"Arch Linux Terminal\" \"root=UUID=${rootuuid} rw add_efi_memmap systemd.unit=multi-user.target\"" >> /mnt/boot/refind_linux.conf
  pressanykey
}
archrefindinstallchroot(){
  #--usedefault /dev/sdXY --alldrivers
  echo "refind-install"
  refind-install
  isvbox=$(lspci | grep "VirtualBox G")
  if [ "${isvbox}" ]; then
    echo "VirtualBox detected, creating startup.nsh..."
    echo "\EFI\refind\refind_x64.efi" > /boot/startup.nsh
  fi
}


archenabledhcpcd(){
  if (whiptail --backtitle "${apptitle}" --title "${txtenable//%1/dhcpcd}" --yesno "${txtenable//%1/dhcpcd} ?" 0 0) then
    clear

    echo "pacstrap /mnt dhcpcd"

    pacstrap /mnt dhcpcd
    archchroot enabledhcpcd
    pressanykey
  fi
}
archenabledhcpcdchroot(){
  echo "systemctl enable dhcpcd"
  systemctl enable dhcpcd
  exit
}
# --------------------------------------------------------



# --------------------------------------------------------
pressanykey(){
  read -n1 -p "${txtpressanykey}"
}

loadstrings(){

  locale=en_US.UTF-8
  #font=

  txtexit="Exit"
  txtback="Back"
  txtignore="Ignore"

  txtselectserver="Select source server :"

  txtmainmenu="Main Menu"
  txtlanguage="Language"
  txtsetkeymap="Set Keyboard Layout"
  txteditor="Editor"
  txtdiskpartmenu="Disk Partitions"
  txtselectpartsmenu="Select Partitions and Install"
  txthelp="Help"
  txtchangelog="Changelog"
  txtreboot="Reboot"

  txtautoparts="Auto Partitions"
  txteditparts="Edit Partitions"

  txtautopartsconfirm="Selected device : %1\n\nAll data will be erased ! \n\nContinue ?"

  txtautopartclear="Clear all partition data"
  txtautopartcreate="Create %1 partition"
  txthybridpartcreate="Set hybrid MBR"
  txtautopartsettype="Set %1 partition type"

  txtselectdevice="Select %1 device :"
  txtselecteddevices="Selected devices :"

  txtformatmountmenu="Format and Mount"
  txtformatdevices="Format Devices"
  txtformatdevice="Format Device"
  txtmount="Mount"
  txtunmount="Unmount"
  txtmountdesc="Install or Config"

  txtformatdeviceconfirm="Warning, all data on selected devices will be erased ! \nFormat devices ?"

  txtselectpartformat="Select partition format for %1 :"
  txtformatingpart="Formatting partition %1 as"
  txtcreateluksdevice="Create luks device :"
  txtopenluksdevice="Open luks device :"
  txtluksdevicecreated="luks device created !"

  txtinstallmenu="Install Menu"

  txtarchinstallmenu="Arch Install Menu"

  txteditmirrorlist="Edit mirrorlist"
  txtinstallarchlinux="Install Arch Linux"
  txtinstallfirmware="Install Firmware"
  txtconfigarchlinux="Config Arch Linux"

  txtsethostname="Set Computer Name"
  txtsetfont="Set Font"
  txtsetlocale="Set Locale"
  txtsettime="Set Time"
  txtsetrootpassword="Set root password"

  txtuseutcclock="Use UTC hardware clock ?"

  txtbootloader="Bootloader"
  txtbootloadermenu="Choose your bootloader"

  txtefibootmgr="efibootmgr is required for EFI computers."

  txtbootloadergrubmenu="Grub Install Menu"
  txtrungrubmakeconfig="Run grub-mkconfig ?"
  txtgrubluksdetected="Encrypted root partion !\n\nAdd cryptdevice= to GRUB_CMDLINE_LINUX in /etc/default/grub ?"

  txtbootloadersyslinuxmenu="Syslinux Install Menu"
  txtsyslinuxaddefibootmgr="EFI install require efibootmgr"
  txtsyslinuxaddgptfdisk="GPT disk require gptfdisk"
  txtsyslinuxaddmtools="FAT boot part require mtools"

  txtbootloadersystemdmenu="Systemd-boot Install Menu"

  txtbootloaderrefindmenu="rEFInd Install Menu"

  txtoptional="Optional"
  txtrecommandeasyinst="Recommanded for easy install"
  txtset="Set %1"
  txtgenerate="Generate %1"
  txtedit="Edit %1"
  txtinstall="Install %1"
  txtenable="Enable %1"

  txtpressanykey="Press any key to continue."

  txtarshdesc="Full desktop install script"
  txtinstallarsh="Arch Linux Desktop Install (arsh) is a second script who can help you to install a full workstation.\n\nYou can just launch the script or install it. Choose in the next menu.\n\nArch Linux Desktop Install as two dependencies: wget and libnewt.\n\npacstrap wget libnewt?"
}

# --------------------------------------------------------



# --------------------------------------------------------
while (( "$#" )); do
  case ${1} in
    --help)
      echo "arsh"
      echo "------"
      echo "-sf | --skip-font                  Skip setfont from language files"
      echo "-efiX                              -efi0 : disable EFI, -efi1 efi inst, -efi2 efi hybrid inst"
      echo "-t | --test ghusername ghbranch    Test language files"
      exit 0
    ;;
    -sf | --skip-font) skipfont=1;;
    -t | --test) baseurl="https://raw.githubusercontent"
                baseurl="${baseurl}.com/""${2}/arsh/${3}";;
    -efi0) efimode=0;;
    -efi1)
      eficomputer=1
      efimode=1
    ;;
    -efi2)
      eficomputer=1
      efimode=2
    ;;
    --chroot) chroot=1
              command=${2}
              args=${3};;
  esac
  shift
done

if [ "${chroot}" = "1" ]; then
  case ${command} in
    'setrootpassword') archsetrootpasswordchroot;;
    'setlocale') archsetlocalechroot;;
    'settimeutc') archsettimeutcchroot;;
    'settimelocal') archsettimelocalchroot;;
    'genmkinitcpio') archgenmkinitcpiochroot;;
    'enabledhcpcd') archenabledhcpcdchroot;;
    'grubinstall') archgrubinstallchroot;;
    'grubbootloaderinstall') archgrubinstallbootloaderchroot ${args};;
    'grubbootloaderefiinstall') archgrubinstallbootloaderefichroot ${args};;
    'grubbootloaderefiusbinstall') archgrubinstallbootloaderefiusbchroot ${args};;
    'syslinuxbootloaderinstall') archsyslinuxinstallbootloaderchroot ${args};;
    'syslinuxbootloaderefiinstall') archsyslinuxinstallbootloaderefichroot ${args};;
    'systemdbootloaderinstall') archsystemdinstallchroot ${args};;
    'refindbootloaderinstall') archrefindinstallchroot ${args};;
  esac
else
  pacman -S --needed arch-install-scripts wget libnewt
  dmesg |grep efi: > /dev/null
  if [ "$?" == "1" ]; then
    if [ "${eficomputer}" != "1" ]; then
      eficomputer=0
    fi
  else
    eficomputer=1
    if [ "${efimode}" == "" ]; then
      efimode=1
    fi
  fi
  loadstrings
  EDITOR=nano
  mainmenu
fi

exit 0
# --------------------------------------------------------
