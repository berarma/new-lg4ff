# new-lg4ff

Experimental new Logitech Force Feedback module for driving wheels

This work is unfinished and highly experimental. Expect the unexpected.

## Goals

I'm testing some ideas to improve the force feedback support on most Logitech
wheels. These include all Logitech driving wheels with force feedback support
in Linux except the Logitech Driving Force G920.

The final goal is having a better force feedback support module that fully
supports all hardware capabilities and provides a set of features similar to
the Logitech Driving Force G920.

## Requirements

 - GNU Make
 - GCC
 - `linux-kbuild` and `linux-headers` packages matching the installed kernel version.

## Build and install

```
# make
# sudo make install
# sudo depmod -A
# sudo rmmod hid-logitech
# sudo modprobe hid-logitech-new
```

## Contributing

Please, use the issues to discuss ideas, direction, etc.

## Disclaimer

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
