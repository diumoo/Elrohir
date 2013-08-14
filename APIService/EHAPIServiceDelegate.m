//
//  EHAPIServiceDelegate.m
//  Elrohir
//
//  Created by Chase Zhang on 8/9/13.
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "EHAPIServiceDelegate.h"
#import <AFNetworking/AFNetworking.h>

#define EHBaseUrl @"https://www.douban.com"
#define EHAPIBaseUrl @"https://api.douban.com"

#define EHAPIAuthPath @"/service/auth2/token"
#define EHAPIRegisterPath @"/v2/fm/register"

#define EHAPIUserInfoPath @"/v2/fm/user_info"
#define EHAPIRecommendedChannelPath @"/v2/fm/rec_channels"
#define EHAPIRecentChannelPath @"/v2/fm/recent_channels"
#define EHAPICollectChannelPath @"/v2/fm/app_collect_channel"
#define EHAPIUncollectChannelPath @"/v2/fm/app_uncollect_channel"

#define EHAPIAppChannelsPath @"/v2/fm/app_channels"
#define EHAPIChannelsPath @"/v2/fm/channels"
#define EHAPIHotChannelsPath @"/v2/fm/hot_channels"
#define EHAPIUptrendingChannelsPath @"/v2/fm/up_trending_channels"
#define EHAPIChannelInfoPath @"/v2/fm/channel_info"
#define EHAPISearchChannelPath @"/v2/fm/search_channel"

#define EHAPIPlaylistPath @"/v2/fm/playlist"

#define EHAPPClientId @"02801f67346e5c7b07805e359d4b1571"
#define EHAPPClientSecret @"9ed132b0dda4550f"
#define EHAPPRedirectUri @"http://douban.fm"
#define EHAPPGrantType @"password"


@interface EHAPIServiceDelegate()
@property(retain)NSString *accessToken;
@property(retain)NSString *refreshToken;
@end

@implementation EHAPIServiceDelegate

- (BOOL)listener:(NSXPCListener *)listener
shouldAcceptNewConnection:(NSXPCConnection *)connection
{
  connection.exportedInterface = [NSXPCInterface
                                  interfaceWithProtocol: @protocol(EHAPIService)];
  connection.exportedObject = self;
  [connection resume];
  return YES;
}


#pragma mark - Helpers
- (AFHTTPClient *)HTTPClient
{
  NSURL *baseUrl = [NSURL URLWithString:EHAPIBaseUrl];
  AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:baseUrl];
  
  [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
  [client setParameterEncoding:AFFormURLParameterEncoding];
  
  if (self.accessToken) {
    NSString *authHeader = nil;
    authHeader = [NSString stringWithFormat:@"Bearer %@", self.accessToken];
    [client setDefaultHeader:@"Authorization" value:authHeader];
  }
  return client;
}

- (void)sendRequestWithMethod:(NSString *)method
                      APIPath:(NSString *)path
                       params:(NSDictionary *)params
                loginRequired:(BOOL)loginRequired
                     callback:(void (^)(NSDictionary *))callback
{
  if (loginRequired && (self.accessToken == nil)) {
    callback(@{@"error":EHNotLoggedInError});
  }
  else {
    AFHTTPClient *client = [self HTTPClient];
    NSMutableURLRequest * request = [client requestWithMethod:method
                                                         path:path
                                                   parameters:params];
    
    AFJSONRequestOperation *operation = nil;
    operation = [AFJSONRequestOperation
                 JSONRequestOperationWithRequest:request
                 success:^(NSURLRequest *request,
                           NSHTTPURLResponse *response,
                           id JSON) {
                   
                   if (JSON) {
                     NSDictionary *jsonDict = (NSDictionary *)JSON;
                     callback(jsonDict);
                   }
                   else {
                     callback(@{@"error":EHInvalidResponseError});
                   }
                 }
                 
                 failure:^(NSURLRequest *request,
                           NSHTTPURLResponse *response,
                           NSError *error,
                           id JSON) {
                   if (JSON) {
                     NSDictionary *jsonDict = (NSDictionary *)JSON;
                     NSString *msg = jsonDict[@"msg"];
                     if (msg == nil) msg = jsonDict[@"error"];
                     if (msg) {
                       callback(@{@"error":msg});
                       return;
                     }
                   }
                   callback(@{@"error":error.localizedDescription});
                 }];
    [operation start];
  }
}

- (NSDictionary *)channelsFromJsonDict:(NSDictionary *)jsonDict
{
  id status = jsonDict[@"status"];
  if (status && [status boolValue]) {
    NSDictionary *data = jsonDict[@"data"];
    NSArray *channels = data[@"channels"];
    if (channels==nil) channels = @[];
    return @{@"status":status,
             @"channels":channels};
  }
  else {
    return @{@"error":EHInvalidResponseError};
  }
}

#pragma mark - login, logout and register
- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
                 callback:(void (^)(NSDictionary *))callback
{
  if (self.accessToken) [self logout];
  NSDictionary* params = nil;
  params = @{
             @"client_id":EHAPPClientId,
             @"client_secret":EHAPPClientSecret,
             @"redirect_uri":EHAPPRedirectUri,
             @"grant_type":EHAPPGrantType,
             @"username":username,
             @"password":password
             };
  NSURL *baseUrl = [NSURL URLWithString:EHBaseUrl];
  AFHTTPClient *authClient = [AFHTTPClient clientWithBaseURL:baseUrl];
  [authClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
  NSMutableURLRequest *request = [authClient requestWithMethod:@"POST"
                                                          path:EHAPIAuthPath
                                                    parameters:params];
  
  AFJSONRequestOperation *operation = nil;
  operation = [AFJSONRequestOperation
               JSONRequestOperationWithRequest:request
               success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                 if (JSON) {
                   NSDictionary *jsonDict = (NSDictionary *)JSON;
                   
                   NSString *accessToken = jsonDict[@"access_token"];
                   NSString *refreshToken = jsonDict[@"refresh_token"];
                   
                   if (accessToken && refreshToken) {
                     self.accessToken = accessToken;
                     self.refreshToken = refreshToken;
                     [self fetchUserInfoWithCallback:callback];
                     return;
                   }
                   callback(jsonDict);
                 }
                 else {
                   callback(@{@"error":EHInvalidResponseError});
                 }
               }
               failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                 if (JSON) callback(JSON);
                 else callback(@{@"error":error.localizedDescription});
               }];
  [operation start];
}

- (void)logout
{
  self.accessToken = nil;
  self.refreshToken = nil;
}


- (void)registerWithUsername:(NSString *)username
                    password:(NSString *)password
                    callback:(void (^)(NSDictionary *))callback
{
  NSDictionary* params = nil;
  params = @{
             @"username":username,
             @"password":password,
             };
  [self sendRequestWithMethod:@"POST"
                      APIPath:EHAPIRegisterPath
                       params:params
                loginRequired:NO
                     callback:^(NSDictionary *jsonDict) {
                       if (jsonDict[@"error"] == nil) {
                         self.accessToken = jsonDict[@"access_token"];
                         self.refreshToken = jsonDict[@"refresh_token"];
                         [self fetchUserInfoWithCallback:callback];
                       }
                       else {
                         callback(jsonDict);
                       }
                     }];
}

#pragma mark - User specified functions
- (void)fetchUserInfoWithCallback:(void (^)(NSDictionary *))callback
{
  [self sendRequestWithMethod:@"GET"
                      APIPath:EHAPIUserInfoPath
                       params:nil
                loginRequired:YES
                     callback:callback];
}

- (void)fetchRecommendedChannelsWithLimit:(NSInteger)limit
                                 callback:(void (^)(NSDictionary *))callback
{
  [self sendRequestWithMethod:@"GET"
                      APIPath:EHAPIRecommendedChannelPath
                       params:nil
                loginRequired:NO
                     callback:^(NSDictionary *jsonDict) {
                       callback([self channelsFromJsonDict:jsonDict]);
                     }];
}

- (void)fetchRecentChannelsWithCallback:(void (^)(NSDictionary *))callback
{
  [self sendRequestWithMethod:@"GET"
                      APIPath:EHAPIRecentChannelPath
                       params:nil
                loginRequired:YES
                     callback:^(NSDictionary *jsonDict) {
                       callback([self channelsFromJsonDict:jsonDict]);
                     }];
}

- (void)collectChannelWithChannelId:(NSInteger)channelId
                           callback:(void (^)(NSDictionary *))callback
{
  NSDictionary *params = @{@"id":@(channelId)};
  
  [self sendRequestWithMethod:@"POST"
                      APIPath:EHAPICollectChannelPath
                       params:params
                loginRequired:NO
                     callback:^(NSDictionary *jsonDict) {
                       NSInteger status = 0;
                       if (jsonDict && jsonDict[@"groups"]) status = 1;
                       callback(@{@"status":@(status)});
                     }];
  
}

- (void)uncollectChannelWithChannelId:(NSInteger)channelId
                             callback:(void (^)(NSDictionary *))callback
{
  NSDictionary *params = @{@"id":@(channelId)};
  
  [self sendRequestWithMethod:@"POST"
                      APIPath:EHAPIUncollectChannelPath
                       params:params
                loginRequired:NO
                     callback:^(NSDictionary *jsonDict) {
                       NSInteger status = 0;
                       if (jsonDict && jsonDict[@"groups"]) status = 1;
                       callback(@{@"status":@(status)});
                     }];
  
}

#pragma mark - General Channels
- (void)fetchAppChannelsWithCallback:(void (^)(NSDictionary *))callback
{
  [self sendRequestWithMethod:@"GET"
                      APIPath:EHAPIAppChannelsPath
                       params:nil
                loginRequired:NO
                     callback:callback];
}

- (void)fetchChannelsWithShowAsCategory:(BOOL)showAsCategory
                               callback:(void (^)(NSDictionary *))callback
{
  NSDictionary *params = nil;
  if (showAsCategory) params = @{@"cate":@"y"};
  else params = nil;
  [self sendRequestWithMethod:@"GET"
                      APIPath:EHAPIChannelsPath
                       params:params
                loginRequired:NO
                     callback:callback];
}

- (void)fetchHotChannelsWithStart:(NSInteger)start
                            limit:(NSInteger)limit
                         callback:(void (^)(NSDictionary *))callback
{
  NSDictionary *params = nil;
  params = @{@"start":@(start),
             @"limit":@(limit)};
  [self sendRequestWithMethod:@"GET"
                      APIPath:EHAPIHotChannelsPath
                       params:params
                loginRequired:NO
                     callback:^(NSDictionary *jsonDict) {
                       callback([self channelsFromJsonDict:jsonDict]);
                     }];
}

- (void)fetchUptrendingChannelsWithStart:(NSInteger)start
                                   limit:(NSInteger)limit
                                callback:(void (^)(NSDictionary *))callback
{
  NSDictionary *params = nil;
  params = @{@"start":@(start),
             @"limit":@(limit)};
  [self sendRequestWithMethod:@"GET"
                      APIPath:EHAPIUptrendingChannelsPath
                       params:params
                loginRequired:NO
                     callback:^(NSDictionary *jsonDict) {
                       callback([self channelsFromJsonDict:jsonDict]);
                     }];
}

- (void)fetchChannelInfoWithChannelId:(NSInteger)channelId
                             callback:(void (^)(NSDictionary *))callback
{
  NSDictionary *params = @{@"id":@(channelId)};
  [self sendRequestWithMethod:@"GET"
                      APIPath:EHAPIChannelInfoPath
                       params:params
                loginRequired:NO
                     callback:^(NSDictionary *jsonDict) {
                       id status = jsonDict[@"status"];
                       if (status && [status boolValue]) {
                         NSDictionary *data = jsonDict[@"data"];
                         NSArray *channels = data[@"channels"];
                         callback(channels[0]);
                       }
                       else {
                         callback(@{@"error":EHInvalidResponseError});
                       }
                     }];
}

- (void)searchChannelsWithQuery:(NSString *)query
                          start:(NSInteger)start
                          limit:(NSInteger)limit
                       callback:(void (^)(NSDictionary *))callback
{
  NSDictionary *params = nil;
  params = @{@"start":@(start),
             @"limit":@(limit),
             @"query":query};
  [self sendRequestWithMethod:@"GET"
                      APIPath:EHAPISearchChannelPath
                       params:params
                loginRequired:NO
                     callback:callback];
}

@end
