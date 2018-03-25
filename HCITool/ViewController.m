//
//  ViewController.m
//  HCITool
//
//  Created by Alsey Coleman Miller on 3/23/18.
//  Copyright © 2018 Pure Swift. All rights reserved.
//

#import "ViewController.h"
#import "IOBluetoothHostController.h"
@import IOKit;
@import IOBluetooth;

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

@interface ViewController ()

@property (nonatomic, weak) IBOutlet NSTextField *addressLabel;

@property (nonatomic, weak) IBOutlet NSTextField *messageLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _IOBluetoothHostController *hciController = [IOBluetoothHostController defaultController];
    
    NSString *address = [hciController addressAsString];
    
    NSString *addressMessage = [NSString stringWithFormat:@"Address: %@ %@", address, hciController.className];
    
    NSLog(@"%@", addressMessage);
    
    self.addressLabel.stringValue = addressMessage;
    
    //[self readConnectionTimeout:nil];
    //[self writeName:nil];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)readConnectionTimeout:(id)sender {
    
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
    
    error = _BluetoothHCISendRawCommand(request, command, 3, &output, outputSize);
    
    if (error) {
        
        BluetoothHCIRequestDelete(request);
        printf("Send HCI command Error: %08x\n", error);
    }
    
    sleep(0x1);
    
    BluetoothHCIRequestDelete(request);
    
    NSString *message = [NSString stringWithFormat:@"BluetoothHCIReadConnectionAcceptTimeout %@", @(output)];
    
    NSLog(@"%@", message);
    
    self.messageLabel.stringValue = message;
}

- (IBAction)writeName:(id)sender {
    
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
    
    NSLog(@"BluetoothHCIWriteLocalName: CDA");
    
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
    
    NSString *message = @"BluetoothHCIWriteLocalName: ABC";
    
    NSLog(@"%@", message);
    
    self.messageLabel.stringValue = message;
}

@end

int _BluetoothHCISendRawCommand(struct HCIRequest request,
                                void *commandData,
                                size_t commmandSize,
                                void *returnParameter,
                                size_t returnParameterSize) {
    
    int errorCode = 0;
    
    struct BluetoothCall call;
    size_t size = 0x74;
    memset(&call, 0x0, size);
    
    if ((commandData != 0x0) && (commmandSize > 0x0)) {
        
        // IOBluetoothHostController::
        // SendRawHCICommand(unsigned int, char*, unsigned int, unsigned char*, unsigned int)
        call.args[0] = (uintptr_t)&request.identifier;
        call.args[1] = (uintptr_t)commandData;
        call.args[2] = (uintptr_t)&commmandSize;
        call.sizes[0] = sizeof(uint32);
        call.sizes[1] = commmandSize;
        call.sizes[2] = sizeof(uintptr_t);
        call.index = 0x000060c000000062;
        
        errorCode = BluetoothHCIDispatchUserClientRoutine(&call, returnParameter, &returnParameterSize);
    }
    else {
        errorCode = 0xe00002c2;
    }
    
    return errorCode;
}
