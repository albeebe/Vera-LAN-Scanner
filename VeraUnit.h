//
//  VeraUnit.h
//  VeraSDK
//
//  Created by Alan Beebe on 9/1/14.
//  Copyright (c) 2014 Al Beebe. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 *  This object represents a physical Vera unit such as a Vera Lite or a Vera3
 */
@interface VeraUnit : NSObject {
    
    // Variables
    NSMutableArray *_forwardServers;
    
}

/**
 *  Array of forward servers that can be used to remotely access the Vera
 */
@property (nonatomic, strong) NSMutableArray *forwardServers;

/**
 *  IP address of the Vera on the local network
 */
@property (nonatomic, strong) NSString *localAddress;

/**
 *  Port number that the Vera is listening on, on the local network
 */
@property (nonatomic, assign) int localPort;

/**
 *  Example: MiCasaVerde VeraLite
 */
@property (nonatomic, strong) NSString *model;

/**
 *  Vera serial number
 */
@property (nonatomic, strong) NSString *serialNumber;

/**
 *  Temperature format that the Vera is configured to use. Example: F
 */
@property (nonatomic, strong) NSString *temperature;

/**
 *  Firmware version
 */
@property (nonatomic, strong) NSString *version;

@end
