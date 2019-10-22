ifneq ($(KERNELRELEASE),)
obj-m := hid-logitech-new.o
hid-logitech-new-y := hid-lg.o hid-lgff.o hid-lg2ff.o hid-lg3ff.o hid-lg4ff.o
ccflags-y := -Idrivers/hid
else
KDIR ?= /lib/modules/`uname -r`/build

default:
	$(MAKE) -C $(KDIR) M=$$PWD

install:
	$(MAKE) -C $(KDIR) M=$$PWD modules_install

endif
