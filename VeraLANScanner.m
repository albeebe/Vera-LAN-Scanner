//
//  VeraLANScanner.m
//  VeraSDK
//
//  Created by Alan Beebe on 9/1/14.
//  Copyright (c) 2014 Al Beebe. All rights reserved.
//

#import "VeraLANScanner.h"
#import "VeraConstants.h"

@implementation VeraLANScanner


#pragma mark - Lifecycle Methods


/* ---------------------------------- */
-(id)init {
    /*
     
     Initialize
     
     */
    
    self = [super init];
    if (self) {
        // Initialization code
        _currentlyVerifyingDevice = [[NSMutableString alloc] init];
        _discoveredDevices = [[NSMutableArray alloc] init];
        _unverifiedVeras = [[NSMutableArray alloc] init];
    }
    return self;
}




/* ---------------------------------- */
-(void)dealloc {
    /*
     
     Deallocate
     
     */
    
    [self cancelDiscovery];
}


#pragma mark - Public Methods


/* ---------------------------------- */
-(void)cancelDiscovery {
    /*
     
     Cancel discovering Veras on the local network
     
     */
    
    // Cancel any current discovery attempts
    _connection = nil;
    [_discoveredDevices removeAllObjects];
    [_unverifiedVeras removeAllObjects];
    if (_ssdpSock) {
        [_ssdpSock close];
    }
    if (_timerFinish) {
        [_timerFinish invalidate];
        _timerFinish = nil;
    }
    _isDiscovering = NO;
    
    if (finishedBlock) finishedBlock(nil);
    finishedBlock = nil;
    discoveredBlock = nil;
}




/* ---------------------------------- */
-(void)discoverVerasWithTimeout:(int)seconds
                     discovered:(void (^)(VeraUnit *vera))discovered
                       finished:(void (^)(NSError *error))finished {
    /*
     
     Discover all the Veras on the local network
     
     */
    
    // Cancel any current discovery attempts
    [self cancelDiscovery];
    
    // Store the blocks
    if (discovered) discoveredBlock = [discovered copy];
    if (finished) finishedBlock = [finished copy];
    
    // Attempt to discovery all the Veras on the users network
    _isDiscovering = YES;
    _ssdpSock = [[AsyncUdpSocket alloc] initWithDelegate:self];
    [_ssdpSock enableBroadcast:TRUE error:nil];
    NSString *str = @"M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:1900\r\nMAN: \"ssdp:discover\"\r\nMX: 1\r\nST: urn:schemas-micasaverde-com:service:HaDevice:1\r\n\r\n";
    [_ssdpSock bindToPort:0 error:nil];
    [_ssdpSock joinMulticastGroup:@"239.255.255.250" error:nil];
    [_ssdpSock sendData:[str dataUsingEncoding:NSUTF8StringEncoding]
                 toHost: @"239.255.255.250"
                   port:1900
            withTimeout:-1
                    tag:1];
    [_ssdpSock receiveWithTimeout:-1 tag:1];
    
    // Schedule a timer to fire and complete the search
    _timerFinish = [NSTimer scheduledTimerWithTimeInterval:seconds
                                                    target:self
                                                  selector:@selector(discoveryFinished)
                                                  userInfo:self
                                                   repeats:NO];
}


#pragma mark - Private Methods


/* ---------------------------------- */
-(void)discoveryFinished {
    /*
     
     Finish the discovery process
     
     */

    // Close the connection
    _timerFinish = nil;
    [_ssdpSock close];
    _ssdpSock = nil;
    _isDiscovering = NO;
    
    // Check if all discovered veras have been verified
    if (_unverifiedVeras.count == 0) {
        // We're finished discovering devices
        if (finishedBlock) finishedBlock(nil);
        finishedBlock = nil;
    }
}




/* ---------------------------------- */
-(void)deviceFailedVerification:(NSString *)host {
    /*
     
     Called when a device fails verification
     
     */
    
    // Remove the device from the unverified list
    [_unverifiedVeras removeObject:host];
    
    // Check if we have any devices that need to be verified
    if (_unverifiedVeras.count == 0) {
        if (_isDiscovering == NO) {
            // We're finished discovering devices
            if (finishedBlock) finishedBlock(nil);
            finishedBlock = nil;
        }
    } else {
        // Verify the next device in our list
        [self verifyDevice:[_unverifiedVeras firstObject]];
    }
}




/* ---------------------------------- */
-(void)verifyDevice:(NSString *)host {
    /*
     
     Called to verify a device that was discovered is actually a Vera we can connect to
     
     */

    // Add the device to the unverified list
    [_unverifiedVeras addObject:host];
    
    // Check if we are in the middle of verifying another device
    if (_connection) {
        // Another device is currently being verified
        return;
    } else {
        [_currentlyVerifyingDevice setString:host];
    }
    
    // Connect to the device
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@:%i/data_request?id=lu_sdata", host, VERASDK_LISTEN_PORT]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:5.0f];
    _connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    // Check if the connection failed to be initialized
    if (!_connection) {
        [self deviceFailedVerification:host];
        return;
    }
}


#pragma mark - AsyncUdpSocket Delegate Methods


/* ---------------------------------- */
-(BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port {
    /*
     
     Called when a device responds to our discovery request
     
     */
    
    // Confirm we have a host
    if ((!host) || (host.length == 0)) return NO;
    
    // Add the address to the discovered list if it's not already in it
    if (![_discoveredDevices containsObject:host]) {
        [_discoveredDevices addObject:host];
        [self verifyDevice:host];
    }
    
    return YES;
}


#pragma mark - NSURLConnection Delegate Methods


/* ---------------------------------- */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    /*
     
     Called when the connection is established
     
     */
    
    _responseData = [[NSMutableData alloc] init];
}




/* ---------------------------------- */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    /*
     
     Called when data is received from the connection
     
     */
    
    [_responseData appendData:data];
}




/* ---------------------------------- */
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    /*
     
     Return NIL to avoid caching
     
     */
    
    return nil;
}




/* ---------------------------------- */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    /*
     
     Called when the connection finishes loading
     
     */
    
    _connection = nil;
    [_unverifiedVeras removeObject:_currentlyVerifyingDevice];
    
    // Parse the JSON response
    VeraUnit *vera = [[VeraUnit alloc] init];
    NSError *error;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:_responseData options:kNilOptions error:&error];
    if (error) {
        _connection = nil;
        [self deviceFailedVerification:_currentlyVerifyingDevice];
        return;
    } else {
        [vera setLocalAddress:_currentlyVerifyingDevice];
        [vera setLocalPort:VERASDK_LISTEN_PORT];
        if ([json objectForKey:@"fwd1"]) [vera.forwardServers addObject:[json objectForKey:@"fwd1"]];
        if ([json objectForKey:@"fwd2"]) [vera.forwardServers addObject:[json objectForKey:@"fwd2"]];
        if ([json objectForKey:@"model"]) [vera setModel:[json objectForKey:@"model"]];
        if ([json objectForKey:@"serial_number"]) [vera setSerialNumber:[json objectForKey:@"serial_number"]];
        if ([json objectForKey:@"temperature"]) [vera setTemperature:[json objectForKey:@"temperature"]];
        if ([json objectForKey:@"version"]) [vera setVersion:[json objectForKey:@"version"]];
        
    }
    
    // Pass the Vera to the Discovered block
    if (discoveredBlock) discoveredBlock(vera);
    
    // Check if we have any devices that need to be verified
    if (_unverifiedVeras.count == 0) {
        if (_isDiscovering == NO) {
            // We're finished discovering devices
            if (finishedBlock) finishedBlock(nil);
            finishedBlock = nil;
        }
    } else {
        [self verifyDevice:[_unverifiedVeras firstObject]];
    }
}




/* ---------------------------------- */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    /*
     
     Called when the connection fails
     
     */
    
    _connection = nil;
    [self deviceFailedVerification:_currentlyVerifyingDevice];
}


@end