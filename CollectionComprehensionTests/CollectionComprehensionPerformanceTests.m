//
//  CollectionComprehensionPerformanceTests.m
//  CollectionComprehensionSample
//
//  Created by Tim Gostony on 10/9/13.
//  Copyright (c) 2013 Tim Gostony. All rights reserved.
//

#import "CollectionComprehensionPerformanceTests.h"


@implementation CollectionComprehensionPerformanceTests



-(double)secondsForIterations:(int)iterations ofBlock:(void(^)(void))block
{
    struct mach_timebase_info tbinfo;
    mach_timebase_info( &tbinfo );
    
    uint64_t startTime = mach_absolute_time();
    for(int i=0; i<iterations; i++)
    {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        block();
        [pool release];
    }
    uint64_t endTime = mach_absolute_time();
    
    
    uint64_t duration = endTime - startTime;
    double floatDuration = duration * tbinfo.numer / tbinfo.denom;
    
    floatDuration /= 1000000000.0;
    
    return floatDuration;
}

-(double)classicMapTimeWithIterations:(int)iterations onArray:(NSArray*)array forBlock:(ObjectAndIndexToObjectBlock)block
{
    return [self secondsForIterations:iterations ofBlock:^{
        NSMutableArray* result = [[NSMutableArray alloc] init];
        for(int i=0; i<array.count; i++)
        {
            NSObject* object = array[i];
            [result addObject:block(object, i)];
            
        }
        [result release];
    }];
}

-(double)blockMapTimeOnWithIterations:(int)iterations onArray:(NSArray*)array forBlock:(ObjectAndIndexToObjectBlock)block
{
    return [self secondsForIterations:iterations ofBlock:^{
        [array map:^NSObject *(NSObject *object, int index) {
            return block(object, index);
        }];
    }];
}

-(void)comparePerformanceOfMapWithIterations:(int)iterations onArray:(NSArray*)input forBlock:(ObjectAndIndexToObjectBlock)block
{
    double normalMethodTime = [self classicMapTimeWithIterations:iterations onArray:input forBlock:block];
    
    double mapMethodTime = [self blockMapTimeOnWithIterations:iterations onArray:input forBlock:block];
    
    NSLog(@"PERF RESULT: Map ran %2.2f%% faster than the regular method.",((normalMethodTime/mapMethodTime)-1.0)*100);
    
    XCTAssertTrue(mapMethodTime < normalMethodTime, @"Map method time should be faster than normal method time.");
    
}

-(void)testMapPerformance
{
    
    NSArray* inputNumbers = [self firstHundredThousandNumbers];
    
    ObjectAndIndexToObjectBlock squareNumber  = ^NSObject *(NSObject *object, int index) {
        return @([(NSNumber*)object integerValue] * [(NSNumber*)object integerValue]);
    };
    
    [self comparePerformanceOfMapWithIterations:10 onArray:inputNumbers forBlock:squareNumber];
    
    ObjectAndIndexToObjectBlock addOne  = ^NSObject *(NSObject *object, int index) {
        return @(1 + [(NSNumber*)object integerValue]);
    };
    
    [self comparePerformanceOfMapWithIterations:10 onArray:inputNumbers forBlock:addOne];
    
    
    NSArray* randomStrings = [self randomStringsWithChars:150 count:150];
    
    ObjectAndIndexToObjectBlock reverse = ^NSObject *(NSObject *object, int index) {
        return [(NSString*)object reversed];
    };
    
    [self comparePerformanceOfMapWithIterations:50 onArray:randomStrings forBlock:reverse];
    
    ObjectAndIndexToObjectBlock truncate = ^NSObject *(NSObject *object, int index) {
        return [(NSString*)object substringToIndex:8];
    };
    
    [self comparePerformanceOfMapWithIterations:50 onArray:randomStrings forBlock:truncate];
    
    ObjectAndIndexToObjectBlock lowercase = ^NSObject *(NSObject *object, int index) {
        return [(NSString*)object lowercaseString];
    };
    
    [self comparePerformanceOfMapWithIterations:50 onArray:randomStrings forBlock:lowercase];
    
    
}


@end
