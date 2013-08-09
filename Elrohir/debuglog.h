//
//  debuglog.h
//  Elrohir
//
//  Created by Chase Zhang on 8/9/13.
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//


#ifdef DEBUG
#define EHLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define EHLog(format, ...)
#endif
