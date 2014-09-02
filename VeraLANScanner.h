//
//  VeraLANScanner.h
//  VeraSDK
//
//  Created by Alan Beebe on 9/1/14.
//  Copyright (c) 2014 Al Beebe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncUdpSocket.h"
#import "VeraUnit.h"

/**
 *  Class that will attempt to discover all Veras on the local network
 */
@interface VeraLANScanner : NSObject {
    
    // Variables
    AsyncUdpSocket *_ssdpSock;
    BOOL _isDiscovering;
    NSMutableArray *_discoveredDevices;
    NSMutableArray *_unverifiedVeras;
    NSMutableData *_responseData;
    NSMutableString *_currentlyVerifyingDevice;
    NSTimer *_timerFinish;
    NSURLConnection *_connection;
    
    // Blocks
    void (^discoveredBlock)(VeraUnit *vera);
    void (^finishedBlock)(NSError *error);
}


/**
 *  TRUE if we're currently scanning for Veras on the local network
 */
@property (nonatomic, readonly) BOOL isDiscovering;


#pragma mark - Public Methods


/**
 *  Cancel discovering Veras on the local network
 */
-(void)cancelDiscovery;

/**
 *  Discover all the Veras on the local network
 *
 *  @param seconds    Number of seconds to spend looking for Veras
 *  @param discovered Block that is called when a Vera is discovered
 *  @param finished   Block that is called when we're finished discovering Veras
 *                    on the local network, or an error occurs halting discovery
 */
-(void)discoverVerasWithTimeout:(int)seconds
                     discovered:(void (^)(VeraUnit *vera))discovered
                       finished:(void (^)(NSError *error))finished;


#pragma mark - Private Methods


/**
 *  Called when a device fails verification
 *
 *  @param host Device address
 */
-(void)deviceFailedVerification:(NSString *)host;

/**
 *  Called to verify a device that was discovered is actually a Vera we can connect to
 *
 *  @param host Device address
 */
-(void)verifyDevice:(NSString *)host;


@end
