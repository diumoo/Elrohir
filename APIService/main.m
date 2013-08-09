//
//  main.m
//  APIService
//
//  Created by Chase Zhang on 8/8/13.
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//


#include <Foundation/Foundation.h>
#import "EHAPIServiceDelegate.h"


int main(int argc, const char *argv[])
{
  EHAPIServiceDelegate *delegate = [[EHAPIServiceDelegate alloc] init];
  NSXPCListener *listener = [NSXPCListener serviceListener];
  listener.delegate = delegate;
  [listener resume];
  
  exit(EXIT_FAILURE);
}
