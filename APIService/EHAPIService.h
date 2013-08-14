//
//  EHAPIService.h
//  Elrohir
//
//  Created by Chase Zhang on 8/12/13.
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Error Message

#define EHInvalidResponseError @"invalid_response"
#define EHNotLoggedInError @"not_logged_in"
#define EHNoUsernameError @"no_username"
#define EHUsernameTooLongError @"username_too_long"
#define EHNoLettersInUsernameError @"no_letter_in_username"
#define EHInvalidUsernameError @"invalid_username"
#define EHNoPasswordError @"no_password"
#define EHPasswordTooShortError @"password_too_short"
#define EHDuplicateUidError @"duplicate_uid"

#pragma mark - Protocol

@protocol EHAPIService <NSObject>

// login, logout and register
- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
                 callback:(void (^)(NSDictionary *))callback;
- (void)logout;
- (void)registerWithUsername:(NSString *)username
                    password:(NSString *)password
                    callback:(void (^)(NSDictionary *))callback;

// user specified content
- (void)fetchUserInfoWithCallback:(void (^)(NSDictionary *))callback;
- (void)fetchRecommendedChannelsWithLimit:(NSInteger)limit
                                 callback:(void (^)(NSDictionary *))callback;
- (void)fetchRecentChannelsWithCallback:(void (^)(NSDictionary *))callback;
- (void)collectChannelWithChannelId:(NSInteger)channelId
                           callback:(void (^)(NSDictionary *))callback;
- (void)uncollectChannelWithChannelId:(NSInteger)channelId
                             callback:(void (^)(NSDictionary *))callback;

// general channels
- (void)fetchAppChannelsWithCallback:(void (^)(NSDictionary *))callback;
- (void)fetchChannelsWithShowAsCategory:(BOOL)showAsCategory
                               callback:(void (^)(NSDictionary *))callback;
- (void)fetchHotChannelsWithStart:(NSInteger)start
                            limit:(NSInteger)limit
                         callback:(void (^)(NSDictionary *))callback;
- (void)fetchUptrendingChannelsWithStart:(NSInteger)start
                                   limit:(NSInteger)limit
                                callback:(void (^)(NSDictionary *))callback;
- (void)fetchChannelInfoWithChannelId:(NSInteger)channelId
                             callback:(void (^)(NSDictionary *))callback;
- (void)searchChannelsWithQuery:(NSString *)query
                          start:(NSInteger)start
                          limit:(NSInteger)limit
                       callback:(void (^)(NSDictionary *))callback;

@end
