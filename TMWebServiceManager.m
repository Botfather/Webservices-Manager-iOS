//
//  TMWebServieManager.m
//  WebserviceTrial
//
//  Created by Tushar Mohan on 12/10/16.
//  Copyright © 2016 Tushar Mohan. All rights reserved.
//

#import "TMWebServiceManager.h"

//Set this to NO if details of the Request are not required
#define DEBUG_MODE YES

@implementation TMWebServiceManager

#pragma mark -Web Service Utilities
//URL encodes the string and returns the encoded string
+ (NSString*)createEncodedURLFrom:(NSString *) stringToEncode{
    NSCharacterSet* URLCombinedCharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@" \"#%/:<>?@[\\]^`={|}"] invertedSet];
    NSString *escapedString = [stringToEncode stringByAddingPercentEncodingWithAllowedCharacters:URLCombinedCharacterSet];
    return escapedString;
}
#pragma mark

#pragma mark -Request Builders
//a generic GET request builder
+ (NSMutableURLRequest*)buildGETRequest:(NSString*) url{
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setHTTPMethod: @"GET"];
    return request;
}

//a generic POST request builder
+ (NSMutableURLRequest*)buildPOSTRequest:(NSString *)url
                             requestBody:(NSDictionary*)body{
    NSError* error;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSData *postBody = [NSJSONSerialization dataWithJSONObject:body options:0 error:&error];
    [request setHTTPBody:postBody];
    [request setValue:[NSString stringWithFormat:@"%lu",(unsigned long)[postBody length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPMethod:@"POST"];
    return request;
}
#pragma mark

#pragma mark -Network Call
//Actual call to the service. Returns the data received as a call back
+ (void)sendRequestWithURL:(NSMutableURLRequest*)request
     completionHandler:(void(^)(NSData* data,NSError* error))handler{
    if (DEBUG_MODE)
    {
        NSLog(@"Request# \n URL : %@ \n Headers : %@ \n Request Method : %@ \n Post body : %@\n",request.URL.absoluteString, request.allHTTPHeaderFields.description,request.HTTPMethod,request.HTTPBody?[NSJSONSerialization JSONObjectWithData:request.HTTPBody options:0 error:NULL]:request.HTTPBody);
    }
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request
                                     completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
                                         long statusCode = [(NSHTTPURLResponse*) response statusCode];
                                         if(statusCode == 200 || statusCode == 201 || statusCode == 202 ) {
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 handler(data, nil);
                                             });
                                         }
                                         else if (error) {
                                             if(response) {
                                                 NSLog(@"%@", response);
                                             }
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 handler(nil, error);
                                             });
                                         }
                                     }] resume];
}

@end
