//
//  XTCommunication.h
//  XTDiscountAsciiWarehouse
//
//  Created by Joel Costa on 07/12/15.
//  Copyright © 2015 X-Team. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef struct XTCommunicationSearchParameters {
    __unsafe_unretained NSArray *tags;
    NSUInteger limit;
    NSUInteger skip;
    BOOL onlyInStock;
} XTCommunicationSearchParameters ;

FOUNDATION_EXPORT XTCommunicationSearchParameters const XTCommunicationSearchParametersNull;
FOUNDATION_EXPORT NSString *const XTCommunicationAPIEndPoint;

BOOL XTCommunicationSearchParametersISNull(struct XTCommunicationSearchParameters);
XTCommunicationSearchParameters XTMakeCommunicationSearchParameters(NSArray *tags, NSUInteger limit, NSUInteger skip, BOOL onlyInStock);

@interface XTCommunication : NSObject

+ (id)sharedInstance;

- (AFHTTPRequestOperation *)fetchWithParameters:(struct XTCommunicationSearchParameters)parameters succeed:(void (^)(NSArray *items))succeed failed:(void (^)(NSError *error))failed;

@end
