//
//  main.m
//  AudioStreamer
//
//  Created by Chase Zhang on 8/8/13.
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//


#include <Foundation/Foundation.h>
#import "EHAudioStreamerDelegate.h"

	
int main(int argc, const char *argv[])
{
  EHAudioStreamerDelegate *delegate = [[EHAudioStreamerDelegate alloc] init];
  NSXPCListener *listener = [NSXPCListener serviceListener];
  listener.delegate = delegate;
  [listener resume];
  
  exit(EXIT_FAILURE);
}
