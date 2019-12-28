# new-lg4ff

Experimental Logitech Force Feedback module for driving wheels

This driver implements all possible FF effects for most Logitech wheels, except
the Logitech G920 Driving Force that should already support them by hardware.

## Differences with the in-tree module

This module adds the following features:

 - Support for most effects (except inertia) defined in the Linux FF API.
 - Asynchronous operations with realtime handling of effects.
 - Rate limited FF updates with best possible latency.
 - SYSFS entries for gain and autocenter.
 - Split user and application gain settings.
 - Combine accelerator and clutch.

## Requirements

 - GNU Make
 - GCC
 - `linux-kbuild` and `linux-headers` packages matching the installed kernel
   version.

## Build and install

The module can be installed with DKMS or manually. Follow just one of the
following procedures.

If you want to use DKMS but the module was previously installed with the manual
method delete the module by hand:

`$ sudo rm /lib/modules/$(uname -r)/extra/hid-logitech-new.ko`

### DKMS

The module will be installed in the `/usr/src` directory. Removal, updates, and
rebuilds for kernel upgrades will be managed by `dkms`. The module will load
automatically at system reboot.

Follow these steps:

 - Install `dkms` from the package manager in your system.

 - Download the project to `/usr/src/new-lg4ff`.

 - Install the module:

`$ sudo dkms install /usr/src/new-lg4ff`

When updating the module, update the code in `/usr/src/new-lg4ff` and repeat
the install step.

In case you want to rebuild the module, remove it and install again:

IMPORTANT: When using DKMS the module will be installed as `hid-logitech` so it
gets to automatically replace the old module. Once loaded, it will stil show as
`hid-logitech-new` though.

### Manual method

```
$ make
$ sudo make install
```

In some distributions, the install step might throw some SSL errors because
it's trying to sign the module. These errors can be ignored.

Load the module:

`$ sudo make load`

Unload the module (restoring the in-kernel module):

`$ sudo make unload`

### Check that the driver is loaded

Run:

`sudo dmesg`

You should see something like this (notice the word 'new' at the end of the
module description):

```
[347092.750524] logitech 0003:046D:C24F.000B: Force feedback support for Logitech Gaming Wheels (new)
[347092.750525] logitech 0003:046D:C24F.000B: Hires timer: period = 2 ms
```

## Options

You can use `modinfo` to query for available options.

New options available:

 - timer_msecs: Set the timer period. The timer is used to update the FF
   effects in the device. It changes the maximum latency and the maximum rate
   at which commands are sent. Maximum 4 commands every timer period get sent.
   When using the lowres timer it will be rounded to the nearest possible value
   (1ms for 1000Hz or 4ms for 250Hz kernels). The default value is 2ms, less
   will have no benefit and greater may add unrequired latency.

 - fixed_loop: Set the firmware loop mode to fixed or fast. In fixed mode it
   runs at about 500Hz. In fast mode it runs as fast as it can. The default is
   fast loop to try to minimize latencies.

 - timer_mode: Fixed (0), static (1) or dynamic (2). In fixed mode the timer
   period will not change. In static mode the period will increase as needed.
   In dynamic mode the timer period will be dynamic trying to maintain synch
   with the device to minimize latencies (default).

 - lowres_timer: Disabled by default. For compatibility testing, when set the
   hires timer is disabled.

## New SYSFS entries

They are located in a special directory named after the driver, for example:

`/sys/bus/hid/drivers/logitech/XXXX:XXXX:XXXX.XXXX/`

Entries in this directory can be read and written using normal file commands to
get and set property values.

### combine_pedals

This entry already existed. It has been extended, setting the value to 2
combines the clutch and gas pedals in the same axis.

### gain

Get/set the global FF gain (0-65535). This property is independent of the gain set by
applications using the Linux FF API.

### autocenter

Get/set the autocenter strength (0-65535). This property can be overwritten by
applications using the Linux FF API.

## Contributing

Please, use the issues to discuss bugs, ideas, etc.

## Disclaimer

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
