Vera-LAN-Scanner
================

Class that will quickly (as in milliseconds) discover all Veras on the local network using UPnP.


Example
=======

```objc
#import "VeraLANScanner.h"

VeraLANScanner *scanner = [[VeraLANScanner alloc] init];
[scanner discoverVerasWithTimeout:10
       discovered:^(VeraUnit *vera) {
           // A Vera was discovered
           NSLog(@"Discovered a Vera: %@", vera);
       }finished:^(NSError *error){
           // Finished discovering Veras
           if (error) {
               NSLog(@"Finished due to an error: %@", error.localizedDescription);
           } else {
               NSLog(@"Finished discovering Veras");
           }
       }];
```

Output...

```
Discovered a Vera : {
   forward_servers = (
      "vera-us-oem-relay11.mios.com",
      "vera-us-oem-relay12.mios.com"
   );
   local_address = 10.0.0.10;
   local_port = 3480;
   model = MiCasaVerde VeraLite;
   serial_number = 12345678;
   temperature = F;
   version = *1.6.641*;
}
```
