//
//  XTCommunication.m
//  XTDiscountAsciiWarehouse
//
//  Created by Joel Costa on 07/12/15.
//  Copyright © 2015 X-Team. All rights reserved.
//

#import "XTCommunication.h"
#import "XTItem.h"
#import "XTCoreData.h"

NSString *const XTCommunicationAPIEndPoint = @"http://74.50.59.155:5000/api/search";

XTCommunicationSearchParameters const XTCommunicationSearchParametersNull = {nil, 0, 0, false};
BOOL XTCommunicationSearchParametersISNull(struct XTCommunicationSearchParameters p) {
    return (p.tags == nil && p.limit == 0 && p.skip == 0 && p.onlyInStock == false);
}
XTCommunicationSearchParameters XTMakeCommunicationSearchParameters(NSArray *tags, NSUInteger limit, NSUInteger skip, BOOL onlyInStock) {
    XTCommunicationSearchParameters p;
    
    p.limit = limit > 0 ? limit : 0;
    p.onlyInStock = onlyInStock;
    p.skip = skip > 0 ? skip : 0;
    p.tags = tags;
    
    return p;
}

@implementation XTCommunication {
    AFHTTPRequestOperation *_fetchingOperation;
}

+ (id)sharedInstance
{
    SingletonWithBlock(^{
        return [self new];
    });
}

- (AFHTTPRequestOperation *)fetchWithParameters:(struct XTCommunicationSearchParameters)parameters succeed:(void (^)(NSArray *items))succeed failed:(void (^)(NSError *error))failed {
    
    if (_fetchingOperation && !_fetchingOperation.finished) {
        return _fetchingOperation;
    }
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSMutableArray *queryParameters = [NSMutableArray new];
    if (!XTCommunicationSearchParametersISNull(parameters)) {
        if (parameters.limit > 0) {
            [queryParameters addObject:[NSString stringWithFormat:@"limit=%lu", (unsigned long)parameters.limit]];
        }
        if (parameters.tags.count > 0) {
            [queryParameters addObject:[NSString stringWithFormat:@"q=%@", [[parameters.tags componentsJoinedByString:@" "] stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]]]];
        }
        if (parameters.skip > 0) {
            [queryParameters addObject:[NSString stringWithFormat:@"skip=%lul", (unsigned long)parameters.skip]];
        }
        if (parameters.onlyInStock) {
            [queryParameters addObject:[NSString stringWithFormat:@"onlyInStock=%d", parameters.onlyInStock]];
        }
    }
    
    NSURL *url;;
    if (queryParameters.count > 0) {
        url = [NSURL URLWithString:[XTCommunicationAPIEndPoint stringByAppendingFormat:@"?%@", [queryParameters componentsJoinedByString:@"&"]]];
    } else {
        url = [NSURL URLWithString:XTCommunicationAPIEndPoint];
    }
    
    DDLogDebug(@"Fetching data: %@", url);
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"GET";
    
    request.timeoutInterval = 10;
    
    _fetchingOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    _fetchingOperation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/x-json-stream", nil];
    [_fetchingOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSString *data = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSArray *items = [data componentsSeparatedByString:@"\n"];
        DDLogDebug(@"Response data\n%@", items);
        if (succeed) {
            succeed(items);
        }
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        if (failed) {
            failed(error);
        }
    }];
    
    [manager.operationQueue addOperation:_fetchingOperation];
    
    return _fetchingOperation;
}

@end
