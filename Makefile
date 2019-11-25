obj-m := hid-logitech-new.o
hid-logitech-new-y := hid-lg.o hid-lgff.o hid-lg2ff.o hid-lg3ff.o hid-lg4ff.o
ccflags-y := -Idrivers/hid
KDIR ?= /lib/modules/`uname -r`/build

default:
	$(MAKE) -C $(KDIR) M=$$PWD

install:
	$(MAKE) -C $(KDIR) M=$$PWD modules_install
	depmod -A

load:
	rmmod hid-logitech 2> /dev/null || true
	rmmod hid-logitech-new 2> /dev/null || true
	modprobe hid-logitech-new

unload:
	rmmod hid-logitech-new
	modprobe hid-logitech

dkms:
	mkdir -p /usr/src/new-lg4ff-0.1
	cp -R . /usr/src/new-lg4ff-0.1
	dkms install -m new-lg4ff -v 0.1

