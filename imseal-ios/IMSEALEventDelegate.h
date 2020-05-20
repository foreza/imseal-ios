//
//  IMSEALEventDelegate.h
//  imseal-ios
//
//  Created by Jason C on 5/18/20.
//  Copyright © 2020 foreza. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol IMSEALEventDelegate <NSObject>

//@optional - making these mandatory for now

- (void)IMSEALinitSDKSuccess;
- (void)IMSEALinitSDKFailWithError:(NSError *)err;

- (void)IMSEALstartEventLogSuccess;
- (void)IMSEALstartEventLogFail;

- (void)IMSEALrecordEventLogSuccess;
- (void)IMSEALrecordEventLogFail;


@end

NS_ASSUME_NONNULL_END
