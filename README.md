# new-lg4ff

Experimental Logitech Force Feedback module for driving wheels

This driver implements all possible FF effects for Logitech wheels, except the
Logitech G920 that should already support them by hardware.

## Differences with the in-tree module

This module adds the following features:

 - Support for most effects (except inertia) defined in the Linux FF API.
 - Asynchronous operations with realtime handling of effects.
 - Rate limited data transfers to the device with some latency.
 - Combine accelerator and clutch.

## Requirements

 - GNU Make
 - GCC
 - `linux-kbuild` and `linux-headers` packages matching the installed kernel
   version.

## Build and install

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

Check that the driver is loaded:

`sudo dmesg`

You should see something like this (notice the word 'new' at the end of the
module description):

```
[347092.750524] logitech 0003:046D:C24F.000B: Force feedback support for Logitech Gaming Wheels (new)
[347092.750525] logitech 0003:046D:C24F.000B: HZ (jiffies) = 250, timer period = 4
```

## Options

Use modinfo to query for available options.

 - timer_msecs: Set the timer period. The timer is used to render and send
   commands to the device. It affects the maximum latency and the maximum rate
   for commands to be sent. Maximum 4 commands every timer period. It will be
   rounded up to 4ms in kernels with 250HZ timer clock. It defaults to 4ms.
 - fixed_loop: Set fixed or fast loop. By default fast loop is used.

Write '2' to the `combine_pedals` file to combine accelerator and clutch
(change 0000:0000:0000.0000 in path as appropiate):

`$ echo 2 > /sys/bus/hid/drivers/logitech/0000:0000:0000.0000/combine_pedals`

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
