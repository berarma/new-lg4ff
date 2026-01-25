/*
 * RS50 Diagnostic Tool
 * 
 * This tool helps identify the Logitech RS50 USB device ID and capabilities.
 * Compile with: gcc -o rs50-diagnose rs50-diagnose.c -lusb-1.0
 * Run with: sudo ./rs50-diagnose
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libusb-1.0/libusb.h>

#define LOGITECH_VENDOR_ID 0x046d

void print_device_info(libusb_device *dev) {
    struct libusb_device_descriptor desc;
    int r = libusb_get_device_descriptor(dev, &desc);
    if (r < 0) {
        fprintf(stderr, "Failed to get device descriptor\n");
        return;
    }

    if (desc.idVendor != LOGITECH_VENDOR_ID)
        return;

    printf("\n=== Logitech Device Found ===\n");
    printf("Vendor ID:  0x%04x\n", desc.idVendor);
    printf("Product ID: 0x%04x\n", desc.idProduct);
    printf("Device Class: 0x%02x\n", desc.bDeviceClass);
    printf("USB Version: %d.%d\n", (desc.bcdUSB >> 8) & 0xff, (desc.bcdUSB >> 4) & 0x0f);
    printf("Device Version: %d.%d\n", (desc.bcdDevice >> 8) & 0xff, (desc.bcdDevice >> 4) & 0x0f);
    
    libusb_device_handle *handle;
    r = libusb_open(dev, &handle);
    if (r == 0) {
        unsigned char manufacturer[256] = {0};
        unsigned char product[256] = {0};
        unsigned char serial[256] = {0};
        
        libusb_get_string_descriptor_ascii(handle, desc.iManufacturer, manufacturer, sizeof(manufacturer));
        libusb_get_string_descriptor_ascii(handle, desc.iProduct, product, sizeof(product));
        if (desc.iSerialNumber)
            libusb_get_string_descriptor_ascii(handle, desc.iSerialNumber, serial, sizeof(serial));
        
        printf("Manufacturer: %s\n", manufacturer);
        printf("Product: %s\n", product);
        if (desc.iSerialNumber)
            printf("Serial: %s\n", serial);
        
        printf("\nConfiguration Information:\n");
        struct libusb_config_descriptor *config;
        r = libusb_get_config_descriptor(dev, 0, &config);
        if (r == 0) {
            printf("  Number of interfaces: %d\n", config->bNumInterfaces);
            for (int i = 0; i < config->bNumInterfaces; i++) {
                const struct libusb_interface *intf = &config->interface[i];
                printf("  Interface %d: %d alternate settings\n", i, intf->num_altsetting);
                for (int j = 0; j < intf->num_altsetting; j++) {
                    const struct libusb_interface_descriptor *intf_desc = &intf->altsetting[j];
                    printf("    Alt %d: Class=0x%02x, Subclass=0x%02x, Protocol=0x%02x, %d endpoints\n",
                           j, intf_desc->bInterfaceClass, intf_desc->bInterfaceSubClass,
                           intf_desc->bInterfaceProtocol, intf_desc->bNumEndpoints);
                    for (int k = 0; k < intf_desc->bNumEndpoints; k++) {
                        const struct libusb_endpoint_descriptor *ep = &intf_desc->endpoint[k];
                        printf("      Endpoint %d: Address=0x%02x, Attributes=0x%02x, MaxPacketSize=%d\n",
                               k, ep->bEndpointAddress, ep->bmAttributes, ep->wMaxPacketSize);
                    }
                }
            }
            libusb_free_config_descriptor(config);
        }
        
        libusb_close(handle);
    }
    printf("=============================\n\n");
}

int main(void) {
    libusb_context *ctx;
    int r = libusb_init(&ctx);
    if (r < 0) {
        fprintf(stderr, "Failed to initialize libusb: %s\n", libusb_error_name(r));
        return 1;
    }

    libusb_set_option(ctx, LIBUSB_OPTION_LOG_LEVEL, LIBUSB_LOG_LEVEL_INFO);

    printf("Scanning for Logitech USB devices...\n");
    printf("Please plug in your RS50 wheel now if it's not already connected.\n\n");

    libusb_device **list;
    ssize_t cnt = libusb_get_device_list(ctx, &list);
    if (cnt < 0) {
        fprintf(stderr, "Failed to get device list\n");
        libusb_exit(ctx);
        return 1;
    }

    int found = 0;
    for (ssize_t i = 0; i < cnt; i++) {
        struct libusb_device_descriptor desc;
        r = libusb_get_device_descriptor(list[i], &desc);
        if (r == 0 && desc.idVendor == LOGITECH_VENDOR_ID) {
            print_device_info(list[i]);
            found++;
        }
    }

    if (found == 0) {
        printf("No Logitech devices found. Make sure the RS50 is connected.\n");
    } else {
        printf("\nFound %d Logitech device(s).\n", found);
        printf("\nIf your RS50 is listed above, note the Product ID (0xXXXX).\n");
        printf("This value will be used to add RS50 support to the driver.\n");
    }

    libusb_free_device_list(list, 1);
    libusb_exit(ctx);
    return 0;
}
