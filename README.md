# new-lg4ff

Experimental new Logitech Force Feedback module for driving wheels

This driver implements all possible FF effects for Logitech wheels, except the
Logitech G920 that should already support them.

## Differences with the in-tree module

This module adds the following features:

 - Support for most effects (except inertia) defined in the Linux FF API.
 - Asynchronous operations with realtime handling of effects.
 - Rate limited data transfers to the device with some latency.
 - Combine accelerator and clutch.

## Requirements

 - GNU Make
 - GCC
 - `linux-kbuild` and `linux-headers` packages matching the installed kernel version.

## Build and install

```
$ make
$ sudo make install
$ sudo depmod -A
```

Unload the in-tree module:
`$ sudo rmmod hid-logitech`

Load the new module:
`$ sudo modprobe hid-logitech-new`

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
