//
//  ViewController.m
//  imseal-testapp
//
//  Created by Jason C on 5/18/20.
//  Copyright © 2020 foreza. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imseal = [[IMSEAL alloc] initWithUID: @"someUIDiOS" forDelegate: self];
    
}


- (void)IMSEALinitSDKFailWithError:(nonnull NSError *)err { 
    NSLog(@"IMSEALinitSDKFailWithError %@", err.description);
}

- (void)IMSEALinitSDKSuccess {
    NSLog(@"IMSEALinitSDKSuccess");

    [self.imseal recordAdRequest];
}

- (void)IMSEALstartEventLogFail {
    NSLog(@"IMSEALstartEventLogFail");
}

- (void)IMSEALstartEventLogSuccess {
    NSLog(@"IMSEALstartEventLogSuccess");
    [self.imseal recordAdLoaded];
}

- (void)IMSEALrecordEventLogFail {
    NSLog(@"IMSEALrecordEventLogFail");
}

- (void)IMSEALrecordEventLogSuccess {
    NSLog(@"IMSEALrecordEventLogSuccess");
}



@end
