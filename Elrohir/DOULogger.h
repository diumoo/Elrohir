//
//  DOULogger.h
//  DOULogger
//
//  Created by Chongyu Zhu on 9/04/13.
//  Copyright (c) 2013 Douban Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DOU_LOGGER_ALWAYS_LOG
//#define DOU_LOGGER_VERBOSE

#if defined(DEBUG) || defined(DOU_LOGGER_ALWAYS_LOG)
#ifdef DOU_LOGGER_VERBOSE
#define DOULogWithLevel(level, fmt, ...) [[DOULogger sharedLogger] logWithLevel:level \
                                                                    format:@"%s(%d):"fmt, \
                                                                    __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__]
#else /* DOU_LOGGER_VERBOSE */
#define DOULogWithLevel(level, fmt, ...) [[DOULogger sharedLogger] logWithLevel:level format:fmt, ##__VA_ARGS__]
#endif /* DOU_LOGGER_VERBOSE */
#else /* defined(DEBUG) || defined(DOU_LOGGER_ALWAYS_LOG) */
#define DOULogWithLevel(level, fmt, ...) ((void)0)
#endif /* defined(DEBUG) || defined(DOU_LOGGER_ALWAYS_LOG) */

#define DOULogEmergency(format, ...) DOULogWithLevel(DOUEmergencyLevel, format, ##__VA_ARGS__)
#define DOULogAlert(format, ...) DOULogWithLevel(DOUAlertLevel, format, ##__VA_ARGS__)
#define DOULogCritical(format, ...) DOULogWithLevel(DOUCriticalLevel, format, ##__VA_ARGS__)
#define DOULogError(format, ...) DOULogWithLevel(DOUErrorLevel, format, ##__VA_ARGS__)
#define DOULogWarning(format, ...) DOULogWithLevel(DOUWarningLevel, format, ##__VA_ARGS__)
#define DOULogNotice(format, ...) DOULogWithLevel(DOUNoticeLevel, format, ##__VA_ARGS__)
#define DOULogInfo(format, ...) DOULogWithLevel(DOUInfoLevel, format, ##__VA_ARGS__)
#define DOULogDebug(format, ...) DOULogWithLevel(DOUDebugLevel, format, ##__VA_ARGS__)

#define DOULog(format, ...) DOULogWarning(format, ##__VA_ARGS__)
#define DOUPrettyLog(format, ...) DOULog(@"[%@] %@", NSStringFromClass([self class]), [NSString stringWithFormat:format, ##__VA_ARGS__])

typedef NS_ENUM(NSUInteger, DOULoggingLevel) {
  DOUEmergencyLevel = 0,
  DOUAlertLevel,
  DOUCriticalLevel,
  DOUErrorLevel,
  DOUWarningLevel,
  DOUNoticeLevel,
  DOUInfoLevel,
  DOUDebugLevel
};

typedef NS_OPTIONS(NSUInteger, DOULoggingLevelMask) {
  DOUEmergencyLevelMask = 1 << DOUEmergencyLevel,
  DOUAlertLevelMask = 1 << DOUAlertLevel,
  DOUCriticalLevelMask = 1<< DOUCriticalLevel,
  DOUErrorLevelMask = 1 << DOUErrorLevel,
  DOUWarningLevelMask = 1 << DOUWarningLevel,
  DOUNoticeLevelMask = 1 << DOUNoticeLevel,
  DOUInfoLevelMask = 1 << DOUInfoLevel,
  DOUDebugLevelMask = 1 << DOUDebugLevel,

  DOUUpToEmergencyLevel = (DOUEmergencyLevelMask << 1) - 1,
  DOUUpToAlertLevel = (DOUAlertLevelMask << 1) - 1,
  DOUUpToCriticalLevel = (DOUCriticalLevelMask << 1) - 1,
  DOUUpToErrorLevel = (DOUErrorLevelMask << 1) - 1,
  DOUUpToWarningLevel = (DOUWarningLevelMask << 1) - 1,
  DOUUpToNoticeLevel = (DOUNoticeLevelMask << 1) - 1,
  DOUUpToInfoLevel = (DOUInfoLevelMask << 1) - 1,
  DOUUpToDebugLevel = (DOUDebugLevelMask << 1) - 1,

  DOUAllLevelsMask = DOUUpToDebugLevel
};

@interface DOULogger : NSObject

+ (DOULogger *)sharedLogger;

@property (nonatomic, assign, getter = isEnabled) BOOL enabled;
@property (nonatomic, assign) DOULoggingLevelMask loggingMask;

- (void)addDefaultFile;
- (void)addFileWithPath:(NSString *)path;
- (void)removeFileWithPath:(NSString *)path;

- (void)logWithLevel:(DOULoggingLevel)level format:(NSString *)format, ... NS_FORMAT_FUNCTION(2,3);
- (void)logWithLevel:(DOULoggingLevel)level format:(NSString *)format arguments:(va_list)argList NS_FORMAT_FUNCTION(2,0);

@end
