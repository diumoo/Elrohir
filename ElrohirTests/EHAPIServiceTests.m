//
//  EHAPIServiceTests.m
//  Elrohir
//
//  Created by Chase Zhang on 8/12/13.
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "EHAPIServiceTests.h"
#import <dispatch/dispatch.h>

#define EHTestUsername @"macfmtest"
#define EHTestPassword @"1gemaimengdemima"

typedef void (^EHWraperBlock)(void);
const int64_t EHTestRequestTimeout = 15E9;

@implementation EHAPIServiceTests

- (void)setUp
{
  [super setUp];
  NSXPCConnection* connection = [[NSXPCConnection alloc]
                                 initWithServiceName:@"com.douban.Elrohir.APIService"];
  connection.remoteObjectInterface = [NSXPCInterface
                                      interfaceWithProtocol:@protocol(EHAPIService)];
  
  self.connection = connection;
  self.remoteObject = [connection remoteObjectProxyWithErrorHandler:^(NSError *e) {
    STFail(e.localizedDescription);
  }];
  [self.connection resume];
}

- (void)syncTestWithBlock:(void(^)(EHWraperBlock))block
{
  dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
  
  void (^operationFinished)(void) = ^(void) {
    dispatch_semaphore_signal(semaphore);
  };
  
  block(operationFinished);
  
  dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, EHTestRequestTimeout);
  if (dispatch_semaphore_wait(semaphore, delay)) {
    STFail(@"XPC operation timeout");
  }
}



#pragma mark - Test authentication
- (void)testAuthentication
{
  [self syncTestWithBlock:^(EHWraperBlock finish) {
    
    [self.remoteObject
     loginWithUsername:EHTestUsername
     password:EHTestPassword
     callback:^(NSDictionary *jsonDict) {
       STAssertNotNil(jsonDict, @"jsonDict should not be nil");
       STAssertNil(jsonDict[@"error"], @"Error should be nil");
       STAssertNotNil(jsonDict[@"user_id"], @"jsonDict should contains user_id");
       finish();
     }];
  }];
}


#pragma mark - Test fetch general channels
- (void)testFetchAppChannels
{
  [self syncTestWithBlock:^(EHWraperBlock finish) {
    
    [self.remoteObject
     fetchAppChannelsWithCallback:^(NSDictionary *jsonDict) {
       STAssertNotNil(jsonDict, @"jsonDict should not be nil");
       STAssertNil(jsonDict[@"error"], @"Error should be nil");
       NSArray *groups = jsonDict[@"groups"];
       STAssertNotNil(groups, @"jsonDict should contains groups");
       finish();
     }];
  }];
}

- (void)testFetchChannels
{
  [self syncTestWithBlock:^(EHWraperBlock finish) {
    
    [self.remoteObject
     fetchChannelsWithShowAsCategory:NO
     callback:^(NSDictionary *jsonDict) {
       STAssertNotNil(jsonDict, @"jsonDict should not be nil");
       STAssertNil(jsonDict[@"error"], @"Error should be nil");
       STAssertNotNil(jsonDict[@"channels"], @"jsonDict should contains channels");
       finish();
     }];
    
  }];
}

- (void)testFetchHotChannels
{
  [self syncTestWithBlock:^(EHWraperBlock finish) {
    [self.remoteObject
     fetchHotChannelsWithStart:0 limit:10 callback:^(NSDictionary *jsonDict) {
       STAssertNotNil(jsonDict, @"jsonDict should not be nil");
       STAssertNil(jsonDict[@"error"], @"Error should be nil");
       STAssertNotNil(jsonDict[@"channels"], @"jsonDict should contains channels");
       finish();
     }];
  }];
}

- (void)testFetchUptrendingChannels
{
  [self syncTestWithBlock:^(EHWraperBlock finish) {
    [self.remoteObject
     fetchUptrendingChannelsWithStart:0 limit:10 callback:^(NSDictionary *jsonDict) {
       STAssertNotNil(jsonDict, @"jsonDict should not be nil");
       STAssertNil(jsonDict[@"error"], @"Error should be nil");
       STAssertNotNil(jsonDict[@"channels"], @"jsonDict should contains channels");
       finish();
     }];
  }];
}


- (void)testFetchChannelInfo
{
  [self syncTestWithBlock:^(EHWraperBlock finish) {
    
    NSInteger channelId = 1;
    
    [self.remoteObject
     fetchChannelInfoWithChannelId:channelId
     callback:^(NSDictionary *jsonDict) {
       STAssertNotNil(jsonDict, @"jsonDict should not be nil");
       STAssertNil(jsonDict[@"error"], @"Error should be nil");
       STAssertNotNil(jsonDict[@"name"], @"jsonDict should contains name");
       finish();
     }];
  }];
}

- (void)testSearchChannel
{
  [self syncTestWithBlock:^(EHWraperBlock finish) {
    
    NSString *query = @"douban";
    
    [self.remoteObject
     searchChannelsWithQuery:query
     start:0
     limit:10
     callback:^(NSDictionary *jsonDict) {
       STAssertNotNil(jsonDict, @"jsonDict should not be nil");
       STAssertNil(jsonDict[@"error"], @"Error should be nil");
       STAssertNotNil(jsonDict[@"chls"], @"jsonDict should contains chls");
       finish();
     }];
  }];
}

#pragma mark - Test user specified operation
- (void)testFetchRecommendedChannels
{
  [self syncTestWithBlock:^(EHWraperBlock finish) {
    [self.remoteObject
     loginWithUsername:EHTestUsername
     password:EHTestPassword
     callback:^(NSDictionary *jsonDict) {
       
       [self.remoteObject
        fetchRecommendedChannelsWithLimit:10 callback:^(NSDictionary *jsonDict) {
          STAssertNotNil(jsonDict, @"jsonDict should not be nil");
          STAssertNil(jsonDict[@"error"], @"Error should be nil");
          STAssertNotNil(jsonDict[@"channels"], @"jsonDict should contains channels");
          finish();
        }];
       
     }];
  }];
}

- (void)testFetchRecentChannels
{
  [self syncTestWithBlock:^(EHWraperBlock finish) {
    [self.remoteObject
     loginWithUsername:EHTestUsername
     password:EHTestPassword
     callback:^(NSDictionary *jsonDict) {
       
       [self.remoteObject
        fetchRecentChannelsWithCallback:^(NSDictionary *jsonDict) {
          STAssertNotNil(jsonDict, @"jsonDict should not be nil");
          STAssertNil(jsonDict[@"error"], @"Error should be nil");
          STAssertNotNil(jsonDict[@"channels"], @"jsonDict should contains channels");
          finish();
        }];
       
     }];
  }];
}

- (void)testCollectChannel
{
  [self syncTestWithBlock:^(EHWraperBlock finish) {
    [self.remoteObject
     loginWithUsername:EHTestUsername
     password:EHTestPassword
     callback:^(NSDictionary *jsonDict) {
       
       NSInteger collectId = 1;
       
       [self.remoteObject
        collectChannelWithChannelId:collectId
        callback:^(NSDictionary *jsonDict) {
          STAssertNotNil(jsonDict, @"jsonDict should not be nil");
          STAssertNil(jsonDict[@"error"], @"Error should be nil");
          id status = jsonDict[@"status"];
          STAssertTrue([status boolValue], @"status should be ture");
          finish();
        }];
       
     }];
  }];
}

- (void)testUncollectChannel
{
  [self syncTestWithBlock:^(EHWraperBlock finish) {
    [self.remoteObject
     loginWithUsername:EHTestUsername
     password:EHTestPassword
     callback:^(NSDictionary *jsonDict) {
       
       NSInteger uncollectId = 1;
       
       [self.remoteObject
        uncollectChannelWithChannelId:uncollectId
        callback:^(NSDictionary *jsonDict) {
          STAssertNotNil(jsonDict, @"jsonDict should not be nil");
          STAssertNil(jsonDict[@"error"], @"Error should be nil");
          id status = jsonDict[@"status"];
          STAssertTrue([status boolValue], @"status should be ture");
          finish();
        }];
       
     }];
  }];
}
@end
