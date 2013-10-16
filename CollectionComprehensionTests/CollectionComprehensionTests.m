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

-(NSArray*)arrayWithRange:(NSRange)range
{
    NSMutableArray* mutableArray = [NSMutableArray arrayWithCapacity:range.length];
    for(int i=range.location; i<range.location+range.length; i++)
    {
        [mutableArray addObject:[NSNumber numberWithInt:i]];
    }
    return [NSArray arrayWithArray:mutableArray];
}

-(NSArray*)firstThousandNumbers
{
    return [self arrayWithRange:NSMakeRange(0, 1000)];
}

-(NSArray*)firstHundredThousandNumbers
{
    return [self arrayWithRange:NSMakeRange(0, 100000)];
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
    XCTAssertTrue([@"a".reversed isEqualToString:@"a"], @"Single-letter string reversed must match itself.");
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



-(void)testTuple
{
    NSString* key = @"key";
    NSString* value = @"value";
    NSString* key2 = @"key2";
    NSString* value2 = @"value2";
    

    
    Tuple* tuple = [Tuple tupleWithValue:value forKey:key];
    
    XCTAssertNotNil(tuple.key, @"tuple key should not be nil");
    XCTAssertNotNil(tuple.value, @"tuple value should not be nil");
    

    XCTAssert([tuple.key isEqual:key], @"Key must equal original key.");
    XCTAssert([tuple.value isEqual:value], @"Key must equal original key.");
    
    Tuple* identicalTuple = [Tuple tupleWithValue:value forKey:key];

    XCTAssert([tuple isEqual:identicalTuple], @"Tuple equality should match for identical tuples.");
    
    Tuple* sameKeyDifferentValue = [Tuple tupleWithValue:value2 forKey:key];
    Tuple* differentKeySameValue = [Tuple tupleWithValue:value forKey:key2];
    Tuple* differentKeyDifferentValue = [Tuple tupleWithValue:value2 forKey:key2];
    
    XCTAssert([tuple isEqual:sameKeyDifferentValue] == NO, @"Differing values should not be equal.");
    XCTAssert([tuple isEqual:differentKeySameValue] == NO, @"Differing keys should not be equal.");
    XCTAssert([tuple isEqual:differentKeyDifferentValue] == NO, @"Different key and value should not be equal.");
    
    
    Tuple* initConstructorTuple = [[Tuple alloc] initWithValue:value forKey:key];
    
    XCTAssert([tuple isEqual:initConstructorTuple], @"creating a tuple via quick constructor and init should be equal");
    [initConstructorTuple release];
    
    
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

@end
