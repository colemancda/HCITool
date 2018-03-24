//
//  ViewController.h
//  HCITool
//
//  Created by Alsey Coleman Miller on 3/23/18.
//  Copyright © 2018 Pure Swift. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController


@end

int BluetoothHCIDispatchUserClientRoutine(void * arg0, void * arg1, size_t * arg2);

int sendRawHCIRequest(uint8 * arg0, int arg1, void * arg2, size_t * arg3);
/*
SendRawHCICommand(    BluetoothHCIRequestID    inID,
                  char *                      buffer,
                  IOByteCount                bufferSize );
*/

/*
int BluetoothHCISendRawCommand(const void *inputStruct, void * arg1, size_t * arg2);

int IOBluetoothCSRLibHCISendBCCMDMessage(int arg0);
*/

