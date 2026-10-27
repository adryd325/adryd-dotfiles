#!/usr/bin/bash

function gpuActive() {
    (qm config "$1" | grep -E "hostpci.: 0000:01:00") || return 1
}

if [[ "$2" == 'pre-start' && "$1" != "1000" ]] && gpuActive "$1"; then
  qm shutdown 1000
  sleep 5
fi

if [[ "$2" == 'post-stop' && "$1" != "1000" ]] && gpuActive "$1"; then
  sleep 5
  echo "0000:00:14.0" > /sys/bus/pci/drivers/vfio-pci/unbind
  sleep 5
  echo "0000:00:14.0" > /sys/bus/pci/drivers/xhci_hcd/bind
  qm start 1000
fi
