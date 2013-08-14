//
//  EHAPIServiceTests.h
//  Elrohir
//
//  Created by Chase Zhang on 8/12/13.
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "EHAPIService.h"

@interface EHAPIServiceTests : SenTestCase
@property(retain) NSXPCConnection *connection;
@property(retain) id<EHAPIService> remoteObject;
@end
