#!/usr/bin/env bash
#set -x
set -e

# https://docs.fedoraproject.org/en-US/fedora/rawhide/system-administrators-guide/kernel-module-driver-configuration/Working_with_Kernel_Modules/#sect-signing-kernel-modules-for-secure-boot

source "$(dirname "$0")/mok.sh"

MAIN_MOK_DIR="${MAIN_MOK_DIR:-/var/lib/shim-signed/mok}"
SECONDARY_MOK_DIR="${SECONDARY_MOK_DIR:-/var/lib/dkms}"

command -v openssl > /dev/null 2>&1 || warn "missing openssl, you will not be able to create a new MOK key"
command -v mokutil > /dev/null 2>&1 || warn "missing mokutil, you will not be able to sign the module"

function is_enrolled () {
  # Check MOK to use
  if mokutil --test-key "$1/MOK.der" 2> /dev/null | grep -q "already enrolled"
  then echo "$1/MOK.der"
  elif mokutil --test-key "$1/mok.pub" 2> /dev/null | grep -q "already enrolled"
  then echo "$1/mok.pub"
  else echo ""
  fi
}

function signing_ko () {
  mok_pub=$(check_enrolled "${MAIN_MOK_DIR}")
  if [ -z "$mok_pub" ]
  then 
    mok_pub=$(check_enrolled "${SECONDARY_MOK_DIR}")
    if [ -z "${mok_pub}" ]
    then error "No enrolled MOK found, cannot sign"
    fi
  fi
  mok_priv="${mok_pub/.der/.priv}"
  mok_priv="${mok_priv/.pub/.priv}"

  if [ -f "$/usr/src/kernels/$(uname -r)/scripts" ]
  then default_sign_file_dir="/usr/src/kernels/$(uname -r)/scripts}"
  else default_sign_file_dir="/usr/src/linux-headers-$(uname -r)/scripts"
  fi
  
  sign_file_dir="${sign_file_dir:-$default_sign_file_dir}"
  if [[ -f "/lib/modules/$(uname -r)/updates/hid-logitech-new.ko.xz" || -f "/lib/modules/$(uname -r)/updates/hid-logitech-new.ko" ]]
  then ko_folder="${ko_folder:-/lib/modules/$(uname -r)/updates}"
  elif [[ -f "/lib/modules/$(uname -r)/updates/hid-logitech-new/hid-logitech-new.ko.xz" || -f "/lib/modules/$(uname -r)/updates/hid-logitech-new/hid-logitech-new.ko" ]]
  then ko_folder="${ko_folder:-/lib/modules/$(uname -r)/updates/hid-logitech-new}"
  else
    warn "Can not locate the folder used for hid-logitech-new.ko.xz to unxz and sign. Find the file and try to set the var 'ko_folder'"
  fi
  if [ ! -f "${ko_folder}/hid-logitech-new.ko.xz" ] && [ ! -f "${ko_folder}/hid-logitech-new.ko" ]
  then
    warn "there might be no file to sign. Please check ${ko_folder}"
    ko_folder="${ko_folder:-/lib/modules/$(uname -r)/updates}"
  fi
  # Uncompress current module file
  unxz -f "${ko_folder}/hid-logitech-new.ko.xz"
  # Sign uncompressed module
  "${sign_file_dir}/sign-file" sha256 "${mok_pub}" "${mok_priv}" "${ko_folder}/hid-logitech-new.ko" && info "${ko_folder}/hid-logitech-new.ko"
  # Recompress signed module
  xz -f "${ko_folder}/hid-logitech-new.ko"

  info "finished signing_ko"
}

function install_new-lg4ff () {
  info "start install_new-lg4ff"

  # Uninstall previous version and install new one
  make remove install

  module_ko_file=$(modinfo hid_logitech_new | awk '/^filename:/ { print $2 }')
  if [ -z "$module_ko_file" ]
  then error "Module compilation or installation failed"
  fi

  info "Module installed, now Manually signing"
  signing_ko

  depmod -a
  
  if modprobe hid_logitech_new
  then  
    modinfo hid_logitech_new
    info "finished install_new-lg4ff"

    if [ -d /sys/module/hid_logitech_new ]
    then
      info "hid_logitech_new loaded!"

      echo "hid_logitech_new" > /etc/modules-load.d/new-lg4ff.conf
      # suggest to load uhid to support Bluetooth LE (for firmware 5.x)
      if [ ! -d /sys/devices/virtual/misc/uhid ]
      then modprobe uhid
      fi
    else warn "failed to load hid_logitech_new (check for errors by running 'sudo dmesg')"
    fi
  else warn "failed to load hid_logitech_new"
  fi 
}

if [ "$#" -ne "0" ]
then
  signing_help
  exit 0
else
  if mokutil --sb-state | grep -q "SecureBoot enabled"
  then info "Secure boot is enabled, signing is needed"
  else warn "Secure boot is disabled, no need to sign module!"
  fi

  if ! [ -d /sys/module/hid_logitech_new ]
  then
    # Check in shim and dkms directories (by default) and enroll if a MOK is present
    if check_keys "${MAIN_MOK_DIR}" "${SECONDARY_MOK_DIR}"
    then install_new-lg4ff
    fi
  else info "hid_logitech_new is already loaded"
  fi
fi
