//
//  DOULogger.m
//  DOULogger
//
//  Created by Chongyu Zhu on 9/04/13.
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import "DOULogger.h"
#include <asl.h>
#include <pthread.h>
#include <mach/mach.h>

@interface DOULoggerTSD : NSObject {
@private
  __unsafe_unretained DOULogger *_logger;
  aslclient _client;
}
@property (nonatomic, readonly) DOULogger *logger;
- (id)initWithLogger:(DOULogger *)logger facility:(NSString *)facility fileHandles:(NSArray *)fileHandles;
- (void)addFileHandle:(NSFileHandle *)fileHandle;
- (void)removeFileHandle:(NSFileHandle *)fileHandle;
- (void)logWithLevel:(DOULoggingLevel)level format:(NSString *)format arguments:(va_list)argList NS_FORMAT_FUNCTION(2,0);
@end
@implementation DOULoggerTSD
@synthesize logger = _logger;

- (NSString *)_clientIdentifier
{
  NSString *threadName = nil;
  {
    char buffer[2048];
    if (pthread_getname_np(pthread_self(), buffer, sizeof(buffer)) == 0 && strlen(buffer) > 0) {
      threadName = [NSString stringWithUTF8String:buffer];
    }
    else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated"
      dispatch_queue_t queue = dispatch_get_current_queue();
#pragma clang diagnostic pop
      const char *label = NULL;
      if (queue != NULL && (label = dispatch_queue_get_label(queue)) != NULL && strlen(label) > 0) {
        threadName = [NSString stringWithUTF8String:label];
      }
      else {
        uint64_t tid = 0;
        pthread_threadid_np(pthread_self(), &tid);
        threadName = [NSString stringWithFormat:@"%lld", tid];
      }
    }
  }

  NSString *executableName = [[[NSBundle mainBundle] executablePath] lastPathComponent];
  return [NSString stringWithFormat:@"%@[%d:%x(%@)]", executableName, getpid(), mach_thread_self(), threadName];
}

- (id)initWithLogger:(DOULogger *)logger facility:(NSString *)facility fileHandles:(NSArray *)fileHandles
{
  self = [super init];
  if (self) {
    _logger = logger;
    _client = asl_open([[self _clientIdentifier] UTF8String], [facility UTF8String], ASL_OPT_STDERR | ASL_OPT_NO_DELAY | ASL_OPT_NO_REMOTE);

    for (NSFileHandle *fileHandle in fileHandles) {
      [self addFileHandle:fileHandle];
    }
  }

  return self;
}

- (void)dealloc
{
  asl_close(_client);
  _client = NULL;
}

- (void)addFileHandle:(NSFileHandle *)fileHandle
{
  if (fileHandle != nil) {
    asl_add_log_file(_client, [fileHandle fileDescriptor]);
  }
}

- (void)removeFileHandle:(NSFileHandle *)fileHandle
{
  if (fileHandle != nil) {
    asl_remove_log_file(_client, [fileHandle fileDescriptor]);
  }
}

- (void)logWithLevel:(DOULoggingLevel)level format:(NSString *)format arguments:(va_list)argList
{
  int asllevel;
  switch (level) {
  case DOUEmergencyLevel:
    asllevel = ASL_LEVEL_EMERG;
    break;
  case DOUAlertLevel:
    asllevel = ASL_LEVEL_ALERT;
    break;
  case DOUCriticalLevel:
    asllevel = ASL_LEVEL_CRIT;
    break;
  case DOUErrorLevel:
    asllevel = ASL_LEVEL_ERR;
    break;
  case DOUWarningLevel:
  default:
    asllevel = ASL_LEVEL_WARNING;
    break;
  case DOUNoticeLevel:
    asllevel = ASL_LEVEL_NOTICE;
    break;
  case DOUInfoLevel:
    asllevel = ASL_LEVEL_INFO;
    break;
  case DOUDebugLevel:
    asllevel = ASL_LEVEL_DEBUG;
    break;
  }

  NSString *message = [[NSString alloc] initWithFormat:format arguments:argList];
  asl_log(_client, NULL, asllevel, "%s", [message UTF8String]);
}
@end

@interface DOULogger () {
@private
  BOOL _enabled;
  DOULoggingLevelMask _loggingMask;

  pthread_key_t _tsdKey;
  pthread_mutex_t _mutex;

  NSString *_facility;
  NSMutableDictionary *_fileHandles;
  NSMutableSet *_tsdSet;
}
@end

@implementation DOULogger

@synthesize enabled = _enabled;
@synthesize loggingMask = _loggingMask;

+ (DOULogger *)sharedLogger
{
  static DOULogger *logger = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    logger = [[DOULogger alloc] init];
    [logger addDefaultFile];
    [logger setEnabled:YES];
  });

  return logger;
}

static void destruct_tsd(void *data)
{
  if (data == NULL) {
    return;
  }

  DOULoggerTSD *tsd = CFBridgingRelease((CFTypeRef)data);

  DOULogger *logger = [tsd logger];
  if (logger != nil) {
    pthread_mutex_lock(&logger->_mutex);
    [logger->_tsdSet removeObject:tsd];
    pthread_mutex_unlock(&logger->_mutex);
  }
}

- (id)init
{
  self = [super init];
  if (self) {
    _enabled = NO;
    _loggingMask = DOUAllLevelsMask;

    pthread_key_create(&_tsdKey, destruct_tsd);
    pthread_mutex_init(&_mutex, NULL);

    _facility = [[[NSBundle mainBundle] bundleIdentifier] copy];
    _fileHandles = [[NSMutableDictionary alloc] init];
    _tsdSet = [[NSMutableSet alloc] init];
  }

  return self;
}

- (void)dealloc
{
  pthread_key_delete(_tsdKey);
  pthread_mutex_destroy(&_mutex);

  for (NSFileHandle *fileHandle in [_fileHandles allValues]) {
    [fileHandle closeFile];
  }
}

- (DOULoggerTSD *)_tsd
{
  void *data = pthread_getspecific(_tsdKey);
  if (data == NULL) {
    DOULoggerTSD *tsd;

    pthread_mutex_lock(&_mutex);
    tsd = [[DOULoggerTSD alloc] initWithLogger:self facility:_facility fileHandles:[_fileHandles allValues]];
    [_tsdSet addObject:tsd];
    pthread_mutex_unlock(&_mutex);

    data = (void *)CFBridgingRetain(tsd);
    pthread_setspecific(_tsdKey, data);
  }

  return (__bridge DOULoggerTSD *)data;
}

- (void)addDefaultFile
{
  NSString *baseDirectory = nil;
#if TARGET_OS_IPHONE
  baseDirectory = NSTemporaryDirectory();
#else /* TARGET_OS_IPHONE */
  NSString *bundleName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"];
  if (bundleName != nil) {
    NSString *appSupport = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    baseDirectory = [appSupport stringByAppendingPathComponent:bundleName];
  }
  else {
    NSString *processName = [[NSProcessInfo processInfo] processName];
    baseDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:processName];
  }
#endif /* TARGET_OS_IPHONE */

  NSString *directory = [baseDirectory stringByAppendingPathComponent:@"Logs"];
  [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL];

  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  NSLocale * locale = [NSLocale currentLocale];
  [dateFormatter setLocale:locale];
  
  [dateFormatter setDateFormat:@"yyyy-MM-dd-HHmmss"];
  NSString *filename = [NSString stringWithFormat:@"%@.log", [dateFormatter stringFromDate:[NSDate date]]];

  NSString *path = [directory stringByAppendingPathComponent:filename];
  [self addFileWithPath:path];
}

- (void)addFileWithPath:(NSString *)path
{
  if (path == nil || [_fileHandles objectForKey:path] != nil) {
    return;
  }

  if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
    if (![[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil]) {
      return;
    }
  }

  NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:path];
  if (fileHandle == nil) {
    return;
  }

  pthread_mutex_lock(&_mutex);
  [_fileHandles setObject:fileHandle forKey:path];
  for (DOULoggerTSD *tsd in _tsdSet) {
    [tsd addFileHandle:fileHandle];
  }
  pthread_mutex_unlock(&_mutex);
}

- (void)removeFileWithPath:(NSString *)path
{
  if (path == nil) {
    return;
  }

  NSFileHandle *fileHandle = [_fileHandles objectForKey:path];
  if (fileHandle == nil) {
    return;
  }

  pthread_mutex_lock(&_mutex);
  for (DOULoggerTSD *tsd in _tsdSet) {
    [tsd removeFileHandle:fileHandle];
  }
  [_fileHandles removeObjectForKey:path];
  pthread_mutex_unlock(&_mutex);

  [fileHandle closeFile];
}

- (void)logWithLevel:(DOULoggingLevel)level format:(NSString *)format, ...
{
  va_list argList;
  va_start(argList, format);
  [self logWithLevel:level format:format arguments:argList];
  va_end(argList);
}

- (void)logWithLevel:(DOULoggingLevel)level format:(NSString *)format arguments:(va_list)argList
{
  if (!_enabled) {
    return;
  }

  if (!(_loggingMask & level)) {
    return;
  }

  DOULoggerTSD *tsd = [self _tsd];
  pthread_mutex_lock(&_mutex);
  [tsd logWithLevel:level format:format arguments:argList];
  pthread_mutex_unlock(&_mutex);
}

@end
