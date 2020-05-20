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
          self._isInitialized = YES;
          self._sessionId = 1;
          self._currentEventId = 1;
          
          // DO some stuff, make some network calls...
          
          // Invoke delegate
          if ([self.delegate respondsToSelector:@selector(IMSEALinitSDKSuccess)]){
              
              dispatch_async(dispatch_get_main_queue(), ^{
                  [self.delegate IMSEALinitSDKSuccess];
              });
              
              [self debugLog:@" SDK Initialized Successfully!"];
          } else {
              [self debugLog:@" SDK delegate not found!"];
          }
          
          
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








- (void)debugLog:(NSString *) string {
    // Do other stuff here;
    NSLog(logTag, string);
}



@end



