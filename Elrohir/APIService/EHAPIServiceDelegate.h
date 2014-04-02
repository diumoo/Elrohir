//
//  EHAPIServiceDelegate.h
//  Elrohir
//
//  Created by Chase Zhang on 8/9/13.
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EHAPIService.h"

@interface EHAPIServiceDelegate : NSObject <NSXPCListenerDelegate, EHAPIService>

@end
