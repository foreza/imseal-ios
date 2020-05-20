//
//  ViewController.h
//  imseal-testapp
//
//  Created by Jason C on 5/18/20.
//  Copyright © 2020 foreza. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IMSEAL.h"

@interface ViewController : UIViewController<IMSEALEventDelegate>

@property (nonatomic, strong) IMSEAL *imseal;

@end

