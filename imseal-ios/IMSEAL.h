//
//  IMSEAL.h
//  imseal-ios
//
//  Created by Jason C on 5/18/20.
//  Copyright © 2020 foreza. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IMSEALEventDelegate.h"

NS_ASSUME_NONNULL_BEGIN




@interface IMSEAL : NSObject <NSURLSessionDelegate>

#define logTag @"[IMSEAL]%@"
#define kSEALAPISESSIONURL @"http://127.0.0.1:3000/sessions"
#define kSEALAPIEVENTURL @"http://127.0.0.1:3000/events"

#define kDEFAULT_CURRENT_EVENT_ID -1
#define kERROR_HIGHLIGHT @"********************************************************************************"
#define kERROR_REASON_AD_REQUEST_NOT_MADE  "Did you try beginning an ad request with recordAdRequest()?"
#define kERROR_REASON_LISTENER_NOT_IMPLEMENTED  "To make full use of IMSEAL, please consider implementing IMSEALEventListener and the required interface methods."
#define kString ERROR_REASON_INSTANCE_NOT_INITIALIZEDß  "Did you init() the IMSEALSDK instance? \nEvent logging is disabled until init is performed."

@property (nonatomic, assign) NSString* uid;
@property (nonatomic, assign) BOOL _isInitialized;
@property (nonatomic, assign) int _sessionId;
@property (nonatomic, assign) int _currentEventId;
@property (nonatomic, strong) NSMutableDictionary *localParams;
@property (nonatomic, weak) id <IMSEALEventDelegate> delegate;


// Instance methods:

- (id)initWithUID:(NSString *)uuid forDelegate:(id<IMSEALEventDelegate>)delegate;
- (BOOL)isInitialized;
- (void)recordAdRequest;
- (void)recordAdLoaded;
- (void)recordAdNoFill;

// TODO: Support more methods



@end

NS_ASSUME_NONNULL_END
