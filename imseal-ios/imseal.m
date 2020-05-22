//
//  IMSEAL.m
//  imseal-ios
//
//  Created by Jason C on 5/18/20.
//  Copyright © 2020 foreza. All rights reserved.
//

#import "IMSEAL.h"

@implementation IMSEAL


- (id) initWithUID:(NSString *)uid forDelegate:(nonnull id<IMSEALEventDelegate>)delegate{
 
    self = [super init];
      if (self)
      {
          self.delegate = delegate;
          self.uid = uid;
          self._isInitialized = YES;
          self._sessionId = 1;
          self._currentEventId = 1;
          
          // DO some stuff, make some network calls...
          [self initializeLocalParamsObject];
          [self doConfigNetworkCallToLocationAPI];

          
      }
    
      return self;
}


- (BOOL)isInitialized {
    
    return self.isInitialized;
}

- (void)recordAdRequest {
    
    [self debugLog:@"Ad request recorded"];

    
    if ([self.delegate respondsToSelector:@selector(IMSEALstartEventLogSuccess)]){
        [self.delegate IMSEALstartEventLogSuccess];
    }
}

- (void)recordAdLoaded {
    if ([self.delegate respondsToSelector:@selector(IMSEALrecordEventLogSuccess)]){
        [self.delegate IMSEALrecordEventLogSuccess];
    }
    [self debugLog:@"Ad loaded recorded"];
}

- (void)recordAdNoFill{
    if ([self.delegate respondsToSelector:@selector(IMSEALrecordEventLogSuccess)]){
        [self.delegate IMSEALrecordEventLogSuccess];
    }
    [self debugLog:@"Ad no fill recorded"];
}


# pragma mark - Private methods:


#pragma mark - Session Setup and Init

-(void) initializeLocalParamsObject {

    self.localParams = [[NSMutableDictionary alloc] init];

    [self.localParams setValue: self.uid forKey:@"device_id"];
    [self.localParams setValue: [NSNumber numberWithBool:YES] forKey:@"isActive"];
    [self.localParams setValue: [NSNumber numberWithBool:NO] forKey:@"cellular"];
    [self.localParams setValue: @"iOS" forKey:@"os"];
    [self.localParams setValue: @"3890000" forKey:@"placement_id"];
    [self.localParams setValue: @"Unknown IP" forKey:@"request_ip"];
    [self.localParams setValue: @"Unknown continent" forKey:@"continent"];
    [self.localParams setValue: @"Unknown Country" forKey:@"country"];
    [self.localParams setValue: @"Unknown City" forKey:@"city"];
    [self.localParams setValue: @"0.0" forKey:@"lat"];
    [self.localParams setValue: @"0.0" forKey:@"long"];
    [self.localParams setValue: @"Unknown Region" forKey:@"region"];
    
}

-(void) postSessionWithData:(NSDictionary *) dict
{

    NSURLSessionConfiguration *defaultSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultSessionConfiguration];

    // Setup the request with URL
    NSURL *url = [NSURL URLWithString: kSEALAPISESSIONURL];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];

    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:jsonData];
    
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
             if(error == nil){
                 [self debugLog:[NSString stringWithFormat:@"return data is %@", results]];
                
                if ([self.delegate respondsToSelector:@selector(IMSEALinitSDKSuccess)]){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.delegate IMSEALinitSDKSuccess];
                    [self debugLog:@" SDK Initialized Successfully!"];
                    });
                    
                } else {
                    [self debugLog:@" SDK delegate not found!"];
                }
             }
    }];

    [dataTask resume];
}

#pragma mark - Location API call

- (void) doConfigNetworkCallToLocationAPI {

    NSURLSessionConfiguration *defaultSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultSessionConfiguration];
    NSURL *url = [NSURL URLWithString:@"http://free.ipwhois.io/json/"];
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError * error) {
        
        NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
        if(error == nil){
    
            [self.localParams setValue: [results objectForKey:@"ip"] forKey:@"request_ip"];
            [self.localParams setValue: [results objectForKey:@"continent"] forKey:@"continent"];
            [self.localParams setValue: [results objectForKey:@"country"] forKey:@"country"];
            [self.localParams setValue: [results objectForKey:@"city"] forKey:@"city"];
            [self.localParams setValue: [results objectForKey:@"latitude"] forKey:@"lat"];
            [self.localParams setValue: [results objectForKey:@"longitude"] forKey:@"long"];
            [self.localParams setValue: [results objectForKey:@"region"] forKey:@"region"];
            [self.localParams setValue: [results objectForKey:@"completed_requests"] forKey:@"completed_requests"];

    
            [self postSessionWithData:self.localParams];
                
            
            } else {
                [self debugLog:[NSString stringWithFormat:@"Error with request: %@", error.localizedDescription]];
            }

        }];
    [dataTask resume];

}





- (void)debugLog:(NSString *) string {
    // Do other stuff here;
    NSLog(logTag, string);
}



@end



