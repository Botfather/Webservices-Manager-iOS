//
//  TMWebServieManager.h
//  WebserviceTrial
//
//  Created by Tushar Mohan on 12/10/16.
//  Copyright © 2016 Tushar Mohan. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TMWebServiceManager : NSObject

+ (NSString*)createEncodedURLFrom:(NSString*)stringToEncode;

+ (NSMutableURLRequest*)buildGETRequest:(NSString*)url;

+ (NSMutableURLRequest*)buildPOSTRequest:(NSString *)url
                        requestBody:(NSDictionary*)body;

+ (void)sendRequestWithURL:(NSMutableURLRequest*)request
         completionHandler:(void(^)(NSData* data,NSError* error))handler;
@end
