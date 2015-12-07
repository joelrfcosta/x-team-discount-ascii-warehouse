//
//  XTCommunication.m
//  XTDiscountAsciiWarehouse
//
//  Created by Joel Costa on 07/12/15.
//  Copyright © 2015 X-Team. All rights reserved.
//

#import "XTCommunication.h"

@implementation XTCommunication

+ (id)sharedInstance
{
    SingletonWithBlock(^{
        return [self new];
    });
}

- (AFHTTPRequestOperation *)fetchData {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    NSURL *url = [NSURL URLWithString:@"http://74.50.59.155:5000/api/search"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/x-json-stream", nil];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        NSString *data = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSArray *items = [data componentsSeparatedByString:@"\n"];
        
        DDLogDebug(@"Response data\n%@", items);
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        DDLogError(@"%@", error);
    }];
    
    [manager.operationQueue addOperation:operation];
    
    return operation;
}

@end
