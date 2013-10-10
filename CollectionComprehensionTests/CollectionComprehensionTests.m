//
//  CollectionComprehensionTests.m
//  CollectionComprehensionTests
//
//  Created by Tim Gostony on 9/15/13.
//  Copyright (c) 2013 Tim Gostony. All rights reserved.
//


#import <XCTest/XCTest.h>

#import "DXCollectionComprehensions.h"

#import <mach/mach_time.h>

@interface CollectionComprehensionTests : XCTestCase

@end


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
    XCTAssertTrue([@"An odd-length string of chars".reversed isEqualToString:@"srahc fo gnirts htgnel-ddo nA"], @"Reversed string must be reverse.");
    XCTAssertTrue([@"An even-length string of chars".reversed isEqualToString:@"srahc fo gnirts htgnel-neve nA"], @"Reversed string must be reverse.");
    XCTAssertTrue([@"".reversed isEqualToString:@""], @"Empty string reversed must match itself.");
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
        XCTAssertNotNil(reversed[key], @"Key must be present.");
        XCTAssertTrue([reversed[key] isEqualToString:((NSString*)testDictionary[key]).reversed], @"Reversed string must match reverse of original.");
        
    }
    
}

-(void)testDictionaryMapToArray
{
    NSDictionary* testDictionary = [self userInfoDictionary];
    
    NSArray* keys = [testDictionary mapToArray:^NSObject *(Tuple *tuple) {
        return tuple.key;
    }];
    
    XCTAssertTrue([testDictionary.allKeys isEqualToArray:keys], @"Keys array must match.");
    
    NSArray* values = [testDictionary mapToArray:^NSObject *(Tuple *tuple) {
        return tuple.value;
    }];
    
    XCTAssertTrue([testDictionary.allValues isEqualToArray:values], @"Value array must match.");
    
    NSMutableArray* keysValuesCombined = [NSMutableArray arrayWithCapacity:testDictionary.count];
    
    for(int i=0; i<testDictionary.count; i++)
    {
        XCTAssertTrue([keys[i] isEqualToString:testDictionary.allKeys[i]], @"Keys must match.");
        XCTAssertTrue([values[i] isEqualToString:testDictionary.allValues[i]], @"Values must match.");
        [keysValuesCombined addObject:[NSString stringWithFormat:@"%@=%@",keys[i],values[i]]];
        
    }
    
    NSArray* keysValues = [testDictionary mapToArray:^NSObject *(Tuple *tuple) {
        return [NSString stringWithFormat:@"%@=%@",tuple.key,tuple.value];
    }];
    
    XCTAssertTrue([keysValuesCombined isEqualToArray:keysValues], @"Original and map-built arrays must match.");
    
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
            XCTAssertTrue([lowercaseA[key] rangeOfString:@"a"].location != NSNotFound, @"'a' must be present in the value");
        }
        else
        {
            XCTAssertTrue([testDictionary[key] rangeOfString:@"a"].location == NSNotFound, @"values not in the result dictionary should not contain lowercase a");
        }
    }
}


- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

@end
