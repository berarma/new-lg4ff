KVERSION := $(shell uname -r)
KDIR := /lib/modules/$(KVERSION)/build
MODULE_NAME := hid-logitech-new

default:
	$(MAKE) -C $(KDIR) M=$$PWD

build: default

install: default
	$(MAKE) -C $(KDIR) M=$$PWD modules_install
	depmod -A

remove:
	rmmod hid-logitech 2> /dev/null || true
	rmmod $(MODULE_NAME) 2> /dev/null || true

load: default remove
	insmod $(MODULE_NAME).ko ${OPTIONS}

load_debug: default remove
	insmod $(MODULE_NAME).ko dyndbg=+p ${OPTIONS}

unload:
	rmmod hid-logitech-new
	modprobe hid-logitech

clean:
	$(MAKE) -C $(KDIR) M=$$PWD clean

