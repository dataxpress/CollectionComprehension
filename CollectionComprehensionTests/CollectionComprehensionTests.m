//
//  CollectionComprehensionTests.m
//  CollectionComprehensionTests
//
//  Created by Tim Gostony on 9/15/13.
//  Copyright (c) 2013 Tim Gostony. All rights reserved.
//

#import "CollectionComprehensionTests.h"
#import "DXCollectionComprehensions.h"

#import <mach/mach_time.h>


@implementation NSString (ReversedString)

-(NSString*)reversed
{
    NSMutableString* newValue = [NSMutableString stringWithCapacity:self.length];
    for(int i=0; i<self.length; i++)
    {
        [newValue appendString:[[self substringFromIndex:self.length - 1 - i] substringToIndex:1]];
    }
    return newValue;
}

@end


@implementation CollectionComprehensionTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

#pragma mark - Helper methods

-(NSDictionary*)userInfoDictionary
{
    return @{@"name": @"dataxpress",
             @"password" : @"P4ssw0rd!",
             @"password_hash" : @"pwhash",
             @"country":@"USA",
             @"age":@"24"};
}

-(NSArray*)firstHundredThousandNumbers
{
    NSMutableArray* mutableArray = [NSMutableArray arrayWithCapacity:100000];
    for(int i=0; i<100000; i++)
    {
        [mutableArray addObject:[NSNumber numberWithInt:i]];
    }
    return [NSArray arrayWithArray:mutableArray];
}

-(NSArray*)randomStringsWithChars:(int)chars count:(int)count
{
    NSMutableArray* mutableArray = [NSMutableArray arrayWithCapacity:count];
    for(int i=0; i<count; i++)
    {
        NSMutableString* stringBuilder = [[NSMutableString alloc] initWithCapacity:chars];
        for(int j=0; j<chars; j++)
        {
            [stringBuilder appendFormat:@"%c",(char)('A' + arc4random_uniform(25))];
        }
        [mutableArray addObject:[NSString stringWithString:stringBuilder]];
        [stringBuilder release];
    }
    return [NSArray arrayWithArray:mutableArray];
}

#pragma mark - Testing helper methods


-(void)testReverse
{
    STAssertTrue([@"An odd-length string of chars".reversed isEqualToString:@"srahc fo gnirts htgnel-ddo nA"], @"Reversed string must be reverse.");
    STAssertTrue([@"An even-length string of chars".reversed isEqualToString:@"srahc fo gnirts htgnel-neve nA"], @"Reversed string must be reverse.");
    STAssertTrue([@"".reversed isEqualToString:@""], @"Empty string reversed must match itself.");
}


#pragma mark - Dictionary tests


-(void)testDictionaryMap
{
    NSDictionary* testDictionary = [self userInfoDictionary];
    

    // map - reverse all of the values for each key
    NSDictionary* reversed = [testDictionary map:^Tuple *(Tuple *tuple) {
        
        return [Tuple tupleWithValue:[(NSString*)tuple.value reversed] forKey:tuple.key];
    }];
    
    // now, loop through the old dict and compare it to the new one
    for(NSString* key in testDictionary)
    {
        STAssertNotNil(reversed[key], @"Key must be present.");
        STAssertTrue([reversed[key] isEqualToString:((NSString*)testDictionary[key]).reversed], @"Reversed string must match reverse of original.");
        
    }
    
}

-(void)testDictionaryMapToArray
{
    NSDictionary* testDictionary = [self userInfoDictionary];
    
    NSArray* keys = [testDictionary mapToArray:^NSObject *(Tuple *tuple) {
        return tuple.key;
    }];
    
    STAssertTrue([testDictionary.allKeys isEqualToArray:keys], @"Keys array must match.");
    
    NSArray* values = [testDictionary mapToArray:^NSObject *(Tuple *tuple) {
        return tuple.value;
    }];
    
    STAssertTrue([testDictionary.allValues isEqualToArray:values], @"Value array must match.");
    
    NSMutableArray* keysValuesCombined = [NSMutableArray arrayWithCapacity:testDictionary.count];
    
    for(int i=0; i<testDictionary.count; i++)
    {
        STAssertTrue([keys[i] isEqualToString:testDictionary.allKeys[i]], @"Keys must match.");
        STAssertTrue([values[i] isEqualToString:testDictionary.allValues[i]], @"Values must match.");
        [keysValuesCombined addObject:[NSString stringWithFormat:@"%@=%@",keys[i],values[i]]];
        
    }
    
    NSArray* keysValues = [testDictionary mapToArray:^NSObject *(Tuple *tuple) {
        return [NSString stringWithFormat:@"%@=%@",tuple.key,tuple.value];
    }];
    
    STAssertTrue([keysValuesCombined isEqualToArray:keysValues], @"Original and map-built arrays must match.");
    
}

-(void)testDictionaryFilter
{
    NSDictionary* testDictionary = [self userInfoDictionary];

    // only get values containing a lowercase "a"
    NSDictionary* lowercaseA = [testDictionary filter:^BOOL(Tuple *tuple) {
        return [(NSString*)tuple.value rangeOfString:@"a"].location != NSNotFound;
    }];
    
    // now actually make sure each result HAS this, and each non-result does NOT
    for(NSString* key in testDictionary)
    {
        if(lowercaseA[key] != nil)
        {
            STAssertTrue([lowercaseA[key] rangeOfString:@"a"].location != NSNotFound, @"'a' must be present in the value");
        }
        else
        {
            STAssertTrue([testDictionary[key] rangeOfString:@"a"].location == NSNotFound, @"values not in the result dictionary should not contain lowercase a");
        }
    }
}

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

    STAssertTrue(mapMethodTime < normalMethodTime, @"Map method time should be faster than normal method time.");

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


- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

@end
