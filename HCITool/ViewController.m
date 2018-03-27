//
//  ViewController.m
//  HCITool
//
//  Created by Alsey Coleman Miller on 3/23/18.
//  Copyright © 2018 Pure Swift. All rights reserved.
//

@import IOKit;
@import IOBluetooth;

#import <stdlib.h>
#import <objc/objc.h>
@import ObjectiveC;

#import "ViewController.h"
#import "IOBluetoothHostController.h"

struct IOBluetoothHCIDispatchParams {
    uint64_t args[7];
    uint64_t sizes[7];
    uint64_t index;
};

struct BluetoothHCIUserClientNotificationDataInfo {
    unsigned long long _field1;
    unsigned long long _field2;
    struct BluetoothHCIRequestCallbackInfo _field3;
    unsigned int parameterSize;
    unsigned int _field5;
    unsigned short opcode;
    unsigned char _field7;
    unsigned char _field8;
    unsigned char _field9;
    unsigned char _field10;
    unsigned char _field11;
    unsigned char _field12;
};

struct IOBluetoothHCIEventNotificationMessage {
    struct BluetoothHCIUserClientNotificationDataInfo dataInfo;
    void *eventParameterData;
};

@interface ViewController ()

@property (nonatomic, weak) IBOutlet NSTextField *addressLabel;

@property (nonatomic, weak) IBOutlet NSTextField *messageLabel;

@property (nonatomic) _IOBluetoothHostController *hciController;

@end

@implementation ViewController

+ (void)initialize {
    /*
    Method originalMethod = class_getInstanceMethod(IOBluetoothHostController.class, @selector(processRawEventData:dataSize:));
    
    Method newMethod = class_getInstanceMethod(self.class, @selector(_processRawEventData:dataSize:));
    
    method_exchangeImplementations(originalMethod, newMethod);
    */
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hciController = [IOBluetoothHostController defaultController];
    self.hciController.delegate = self;
    
    NSString *address = [self.hciController addressAsString];
    
    NSString *addressMessage = [NSString stringWithFormat:@"%@ %@ %@", address, self.hciController.className, self.hciController.nameAsString];
    
    NSLog(@"%@", addressMessage);
    
    self.addressLabel.stringValue = addressMessage;
    
    //[self readConnectionTimeout:nil];
    //[self writeName:nil];
    //[self scan:nil];
    
    // int _IOBluetoothNotificationLibNotificationCreate(int arg0, int arg1, int arg2, int arg3, int arg4)
    //IOBluetoothNotificationLibNotificationCreate()
}

- (IBAction)scan:(id)sender {
    
    [self.hciController BluetoothHCILESetScanEnable:YES filterDuplicates:NO];
}

- (IBAction)readConnectionTimeout:(id)sender {
        
    uint16 connectionAcceptTimeout = 0;
    
    int readTimeout = [self.hciController BluetoothHCIReadConnectionAcceptTimeout:&connectionAcceptTimeout];
    
    if (readTimeout) {
        
        NSLog(@"Error %@", @(readTimeout));
        return;
    }
    
    NSLog(@"BluetoothHCIReadConnectionAcceptTimeout %@", @(connectionAcceptTimeout));
    
    // manually
    
    BluetoothHCIRequestID request = 0;
    uint16 output = 0;
    size_t outputSize = sizeof(output);
    
    int error = BluetoothHCIRequestCreate(&request, 1000, nil, 0);
    
    NSLog(@"Created request: %u", request);
    
    if (error) {
        
        BluetoothHCIRequestDelete(request);
        
        printf("Couldn't create error: %08x\n", error);
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
    
    unsigned char name[256];
    
    name[0] = 'C';
    name[1] = 'D';
    name[2] = 'A';
    
    int setNameError = [self.hciController BluetoothHCIWriteLocalName:&name];
    
    if (setNameError) {
        
        NSLog(@"Error %@", @(setNameError));
        return;
    }
    
    NSLog(@"BluetoothHCIWriteLocalName: CDA");
    
    // manually
    
    BluetoothHCIRequestID request;
    int error = BluetoothHCIRequestCreate(&request, 1000, nil, 0);
    
    NSLog(@"Created request: %lu", request);
    
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

- (void)_processRawEventData:(uint8 *)bytes
                    dataSize:(size_t)size {
    
    // call original implementation
    //[_hciController processRawEventData:data dataSize:size];
    
    NSData *data = [NSData dataWithBytes:bytes length:size];
    
    NSLog(@"HCI Event  %@", data);
    
    
}

- (void)BluetoothHCIEventNotificationMessage:(IOBluetoothHostController*)controller
                       inNotificationMessage:(struct IOBluetoothHCIEventNotificationMessage *)message {
    
    size_t size = message->dataInfo.parameterSize;
    
    NSData *data = [NSData dataWithBytes:&message->eventParameterData length:size];
    
    NSLog(@"HCI Event %16x %@", message->dataInfo.opcode, data);
}

@end

int _BluetoothHCISendRawCommand(BluetoothHCIRequestID request,
                                void *commandData,
                                size_t commmandSize,
                                void *returnParameter,
                                size_t returnParameterSize) {
    
    int errorCode = 0;
    
    struct IOBluetoothHCIDispatchParams call;
    size_t size = 0x74;
    memset(&call, 0x0, size);
    
    if ((commandData != 0x0) && (commmandSize > 0x0)) {
        
        // IOBluetoothHostController::
        // SendRawHCICommand(unsigned int, char*, unsigned int, unsigned char*, unsigned int)
        call.args[0] = (uintptr_t)&request;
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
