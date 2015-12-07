//
//  XTCommunication.h
//  XTDiscountAsciiWarehouse
//
//  Created by Joel Costa on 07/12/15.
//  Copyright © 2015 X-Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

@interface XTCommunication : NSObject

+ (id)sharedInstance;

- (AFHTTPRequestOperation *)fetchData;

@end
