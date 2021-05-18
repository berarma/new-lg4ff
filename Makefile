KVERSION := `uname -r`
KDIR := /lib/modules/${KVERSION}/build

default:
	$(MAKE) -C $(KDIR) M=$$PWD

install: default
	$(MAKE) -C $(KDIR) M=$$PWD modules_install
	depmod -A

remove:
	rmmod hid-logitech 2> /dev/null || true
	rmmod hid-logitech-new 2> /dev/null || true

load: install remove
	modprobe hid-logitech-new ${OPTIONS}

load_debug: install remove
	modprobe hid-logitech-new dyndbg=+p ${OPTIONS}

unload:
	rmmod hid-logitech-new
	modprobe hid-logitech

clean:
	$(MAKE) -C $(KDIR) M=$$PWD clean

