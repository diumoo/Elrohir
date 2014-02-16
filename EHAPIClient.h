//
//  EHAPIClient.h
//  Elrohir
//
//  Created by akron on 1/15/14.
//  Copyright (c) 2014 Douban Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EHAPIClient : NSObject

#pragma mark - login, logout and register
- (void)loginWithUsername:(NSString *)username
                 password:(NSString *)password
                 callback:(void (^)(NSDictionary *))callback;
- (void)logout;
- (void)registerWithUsername:(NSString *)username
                    password:(NSString *)password
                    callback:(void (^)(NSDictionary *))callback;

#pragma mark - User specified functions
- (void)fetchUserInfoWithCallback:(void (^)(NSDictionary *))callback;
- (void)fetchRecommendedChannelsWithLimit:(NSInteger)limit
                                 callback:(void (^)(NSDictionary *))callback;
- (void)fetchRecentChannelsWithCallback:(void (^)(NSDictionary *))callback;
- (void)collectChannelWithChannelId:(NSInteger)channelId
                           callback:(void (^)(NSDictionary *))callback;
- (void)uncollectChannelWithChannelId:(NSInteger)channelId
                             callback:(void (^)(NSDictionary *))callback;

#pragma mark - General Channels
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

#pragma mark - Playlist
- (void)fetchPlaylistWithType:(NSString *)type
                          sid:(NSInteger)sid
                      channel:(NSInteger)channel
                           pt:(float)pt
                           pb:(NSInteger)pb
                         kbps:(NSInteger)kbps
                      isLogin:(BOOL)isLogin
                     callback:(void (^)(NSDictionary *))callback;

#pragma mark - Event
- (void)fetchEventWithId:(NSString *)id
                 isLogin:(BOOL)isLogin
                callback:(void (^)(NSDictionary *))callback;
- (void)fetchEventParticipantsWithId:(NSString *)id
                             isLogin:(BOOL)isLogin
                            callback:(void (^)(NSDictionary *))callback;
- (void)fetchEventWishersWithId:(NSString *)id
                        isLogin:(BOOL)isLogin
                       callback:(void (^)(NSDictionary *))callback;
- (void)fetchEventUserCreatedWithId:(NSString *)id
                            isLogin:(BOOL)isLogin
                           callback:(void (^)(NSDictionary *))callback;
- (void)fetchEventUserParticipatedWithId:(NSString *)id
                                 isLogin:(BOOL)isLogin
                                callback:(void (^)(NSDictionary *))callback;
- (void)fetchEventUserWishedWithId:(NSString *)id
                            status:(NSString*)status
                           isLogin:(BOOL)isLogin
                          callback:(void (^)(NSDictionary *))callback;
- (void)fetchEventListWithisLogin:(BOOL)isLogin
                            locId:(NSInteger)locId
                          dayType:(NSString*)dayType
                             type:(NSString*)type
                         callback:(void (^)(NSDictionary *))callback;
- (void)fetchLocListWithisLogin:(BOOL)isLogin
                       callback:(void (^)(NSDictionary *))callback;
- (void)fetchLocWithId:(NSString *)id
               isLogin:(BOOL)isLogin
            callback:(void (^)(NSDictionary *))callback;
- (void)participateEventWithId:(NSString *)id
                       isLogin:(BOOL)isLogin
               participateDate:(NSString *)participateDate
                      callback:(void (^)(NSDictionary *))callback;
- (void)notParticipateEventWithId:(NSString *)id
                          isLogin:(BOOL)isLogin
                         callback:(void (^)(NSDictionary *))callback;
- (void)wishEventWithId:(NSString *)id
                isLogin:(BOOL)isLogin
               callback:(void (^)(NSDictionary *))callback;
- (void)notWishEventWithId:(NSString *)id
                   isLogin:(BOOL)isLogin
                  callback:(void (^)(NSDictionary *))callback;

@end
