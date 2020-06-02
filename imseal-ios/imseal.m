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
          self._sessionId = -1;
          self._currentEventId = -1;
          
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
    [self logNewEventToEventAPI];
}

- (void)recordAdLoaded {
    [self logAdEventLoadedToEventAPI];
}

- (void)recordAdNoFill {
    [self logAdEventNoFillToEventAPI];
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
                 
                 // Set the session ID for the remainder of the active session
                 self._sessionId = (int)[[results objectForKey:@"id"] integerValue];
                 
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

    
            [self postSessionWithData:self.localParams]; // Call Session API to get session ID
                
            
            } else {
                [self debugLog:[NSString stringWithFormat:@"Error with request: %@", error.localizedDescription]];
            }

        }];
    [dataTask resume];

}



#pragma mark - Event API calls

- (void) logNewEventToEventAPI {
    
     if (!self._isInitialized){
    //        [self helper_logInitFailReason];
            return;
        }
    
    // Configure dictionary for sending data.
    NSDictionary *eventDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                               [NSString stringWithFormat:@"%d", self._sessionId] ,@"session_id",           // Session ID
                               [self getCurrentDateString], @"timestamp",                   // TimeStamp
                               nil];
        
    // Setup the request with URL
    NSURL *url = [NSURL URLWithString: kSEALAPIEVENTURL];

    
    void (^newAdEventCompletion)(NSData*, NSURLResponse*, NSError*) = ^(NSData *data, NSURLResponse *response, NSError *error) {
            NSDictionary *results = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
           if(error == nil){
               [self debugLog:[NSString stringWithFormat:@"return data is %@", results]];
               self._currentEventId = (int)[[results objectForKey:@"event_id"] integerValue];
               [self debugLog:[NSString stringWithFormat:@"new ad request with event id %d", self._currentEventId]];
               if ([self.delegate respondsToSelector:@selector(IMSEALstartEventLogSuccess)]){
                   [self.delegate IMSEALstartEventLogSuccess];
               }
               // TODO: Handle case where selector is not found
           } else {
               // On fail, set the event id to -1
               self._currentEventId = kDEFAULT_CURRENT_EVENT_ID;
               if ([self.delegate respondsToSelector:@selector(IMSEALstartEventLogFail)]){
                   [self.delegate IMSEALstartEventLogFail];     // TODO: Add error handling here
               }
               // TODO: Handle case where selector is not found
           }
    };
    
    [self createAndRunLogTaskForURL:url andDict:eventDict withCompletionHandler:newAdEventCompletion];
}



- (void) logAdEventLoadedToEventAPI {
    
    if (!self._isInitialized){
//        [self helper_logInitFailReason];
        return;
    }

    // TODO: Add logic here
    
//    if (!util_checkForExistingEventID()) {
//        [self helper_logPostEventFailureToListener];
//        return;
//    }

    

    // Configure dictionary for sending data.
    NSDictionary *adLoadEventDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                               [NSString stringWithFormat:@"%d", self._currentEventId] ,@"session_id",          // Event ID
                               [NSNumber numberWithInt:1], @"type",                                             // Event type
                               [self getCurrentDateString], @"timestamp",                                       // TimeStamp
                               nil];

    
    // Setup the request with URL
    NSString *remote = [NSString stringWithFormat:@"%@%@%d", kSEALAPIEVENTURL, @"/", self._currentEventId];
    NSURL *url = [NSURL URLWithString: remote];
        
    // Setup completion block
    void (^adLoadCompletion)(NSData*, NSURLResponse*, NSError*) = ^(NSData *data, NSURLResponse *response, NSError *error){
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
        
        // If the request was successful (payload is not returned from remote)
        if ([httpResponse statusCode] == 200){
            [self debugLog:[NSString stringWithFormat:@"logAdEventLoadedToEventAPI: %d", self._currentEventId]];
                if ([self.delegate respondsToSelector:@selector(IMSEALrecordEventLogSuccess)]){
                    [self.delegate IMSEALrecordEventLogSuccess];
                }
            // TODO: If the delegate doesn't exist, handle
        } else {
            // On fail, set the event id to -1
            self._currentEventId = kDEFAULT_CURRENT_EVENT_ID;
            // TODO: Add error handling here
            if ([self.delegate respondsToSelector:@selector(IMSEALrecordEventLogFail)]){
                [self.delegate IMSEALrecordEventLogFail];
            }
            // TODO: If the delegate doesn't exist, handle
        }
    };
    
    [self createAndRunLogTaskForURL:url andDict:adLoadEventDict withCompletionHandler:adLoadCompletion];
    
}


- (void) logAdEventNoFillToEventAPI {
    
    if (!self._isInitialized){
//        [self helper_logInitFailReason];
        return;
    }

    // TODO: Add logic here
    
//    if (!util_checkForExistingEventID()) {
//        [self helper_logPostEventFailureToListener];
//        return;
//    }

    

    // Configure dictionary for sending data.
    NSDictionary *adNoFillEventDict = [[NSDictionary alloc] initWithObjectsAndKeys:
                               [NSString stringWithFormat:@"%d", self._currentEventId] ,@"session_id",          // Event ID
                               [NSNumber numberWithInt:2], @"type",                                             // Event type
                               [self getCurrentDateString], @"timestamp",                                       // TimeStamp
                               nil];

    
    // Setup the request with URL
    NSString *remote = [NSString stringWithFormat:@"%@%@%d", kSEALAPIEVENTURL, @"/", self._currentEventId];
    NSURL *url = [NSURL URLWithString: remote];
        
    // Setup completion block
    void (^adLoadCompletion)(NSData*, NSURLResponse*, NSError*) = ^(NSData *data, NSURLResponse *response, NSError *error){
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
        NSLog(@"response status code: %ld", (long)[httpResponse statusCode]);
        
        // If the request was successful (payload is not returned from remote)
        if ([httpResponse statusCode] == 200){
            [self debugLog:[NSString stringWithFormat:@"logAdEventNoFillToEventAPI: %d", self._currentEventId]];
                if ([self.delegate respondsToSelector:@selector(IMSEALrecordEventLogSuccess)]){
                    [self.delegate IMSEALrecordEventLogSuccess];
                }
            // TODO: If the delegate doesn't exist, handle
        } else {
            // On fail, set the event id to -1
            self._currentEventId = kDEFAULT_CURRENT_EVENT_ID;
            // TODO: Add error handling here
            if ([self.delegate respondsToSelector:@selector(IMSEALrecordEventLogFail)]){
                [self.delegate IMSEALrecordEventLogFail];
            }
            // TODO: If the delegate doesn't exist, handle
        }
    };
    
    [self createAndRunLogTaskForURL:url andDict:adNoFillEventDict withCompletionHandler:adLoadCompletion];
    
}




- (void) createAndRunLogTaskForURL:(NSURL*)url andDict: (NSDictionary*)postDict withCompletionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))handler {
    
    NSURLSessionConfiguration *defaultSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration:defaultSessionConfiguration];
    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:postDict options:0 error:nil];

    [urlRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:jsonData];
    
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:handler];
    [dataTask resume];
}


- (void)debugLog:(NSString *) string {
    // Do other stuff here;
    NSLog(logTag, string);
}

- (NSString *) getCurrentDateString {
    return [NSString stringWithFormat: @"%lld", (long long)([[NSDate date] timeIntervalSince1970] * 1000.0)];
}


@end



