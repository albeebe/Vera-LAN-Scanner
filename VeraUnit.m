//
//  VeraUnit.m
//  VeraSDK
//
//  Created by Alan Beebe on 9/1/14.
//  Copyright (c) 2014 Al Beebe. All rights reserved.
//

#import "VeraUnit.h"


@implementation VeraUnit


/* ---------------------------------- */
-(id)init {
    /*
     
     Initialize
     
     */
    
    self = [super init];
    if (self) {
        // Initialization code
        _forwardServers = [[NSMutableArray alloc] init];
    }
    return self;
}




/* ---------------------------------- */
- (void)encodeWithCoder:(NSCoder *)encoder {
    /*
     
     Encode the object with a coder
     
     */
    
    [encoder encodeObject:self.forwardServers forKey:@"forward_servers"];
    [encoder encodeObject:self.localAddress forKey:@"local_address"];
    [encoder encodeObject:[NSNumber numberWithInt:self.localPort] forKey:@"local_port"];
    [encoder encodeObject:self.model forKey:@"model"];
    [encoder encodeObject:self.serialNumber forKey:@"serial_number"];
    [encoder encodeObject:self.temperature forKey:@"temperature"];
    [encoder encodeObject:self.version forKey:@"version"];
    
}




/* ---------------------------------- */
- (id)initWithCoder:(NSCoder *)decoder {
    /*
     
     Initialize the object with a coder
     
     */
    
    if ((self = [super init])) {
        self.forwardServers = [decoder decodeObjectForKey:@"forward_servers"];
        self.localAddress = [decoder decodeObjectForKey:@"local_address"];
        self.localPort = [[decoder decodeObjectForKey:@"local_port"] intValue];
        self.model = [decoder decodeObjectForKey:@"model"];
        self.serialNumber = [decoder decodeObjectForKey:@"serial_number"];
        self.temperature = [decoder decodeObjectForKey:@"temperature"];
        self.version = [decoder decodeObjectForKey:@"version"];
    }
    return self;
}




/* ---------------------------------- */
-(NSString *)description {
    /*
     
     Returns a string describing this object
     
     */
    
    NSMutableString *description = [[NSMutableString alloc] init];
    if (self.forwardServers) [description appendFormat:@"forward_servers = %@;\r", self.forwardServers];
    if (self.localAddress) [description appendFormat:@"local_address = %@;\r", self.localAddress];
    if (self.localPort) [description appendFormat:@"local_port = %i;\r", self.localPort];
    if (self.model) [description appendFormat:@"model = %@;\r", self.model];
    if (self.serialNumber) [description appendFormat:@"serial_number = %@;\r", self.serialNumber];
    if (self.temperature) [description appendFormat:@"temperature = %@;\r", self.temperature];
    if (self.version) [description appendFormat:@"version = %@;\r", self.version];
    
    return [NSString stringWithFormat:@"{\r%@}", description];
}


@end
