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

@implementation NSArray (TestHelpers)


+(NSArray*)arrayWithRange:(NSRange)range
{
    
    
    
    
    if(range.length <= 0)
    {
        return @[];
    }
    NSMutableArray* mutableArray = [NSMutableArray arrayWithCapacity:range.length];
    for(int i=range.location; i<range.location + range.length; i++)
    {
        [mutableArray addObject:[NSNumber numberWithInt:i]];
    }
    return [NSArray arrayWithArray:mutableArray];
}

+(NSArray*)firstThousandNumbers
{
    return [self arrayWithRange:NSMakeRange(0, 1000)];
}

+(NSArray*)firstHundredThousandNumbers
{
    return [self arrayWithRange:NSMakeRange(0, 100000)];
}

-(int)sumIntArrayOfContents
{
    int sum = 0;
    for(NSNumber* number in self)
    {
        sum += number.intValue;
    }
    return sum;
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
    
    NSArray* keys = [testDictionary mapToArray:^id (Tuple *tuple) {
        return tuple.key;
    }];
    
    XCTAssertTrue([testDictionary.allKeys isEqualToArray:keys], @"Keys array must match.");
    
    NSArray* values = [testDictionary mapToArray:^id (Tuple *tuple) {
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
    
    NSArray* keysValues = [testDictionary mapToArray:^id (Tuple *tuple) {
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
    
    // filtering a dictionary to have no values should return an empty dictionary
    NSDictionary* anotherTestDictionary = @{@"key": @"val",
                                            @"key2":@"val2"};
    NSDictionary* filtered = [anotherTestDictionary filter:^BOOL(Tuple *tuple) {
        return NO;
    }];
    
    XCTAssert(filtered != nil, @"filtered dict should not be nil");
    XCTAssert(filtered.count == 0, @"filtered dict should have no entries.");
    
    
}

-(void)testDictionaryTuple
{
    // dictionaries created from tuples should look exactly like dictionaries created with other methods.
    
    NSArray* keys = @[@"key1",@"key2",@"key3"];
    NSArray* values = @[@"value1",@"value2",@"value3"];
    
    NSDictionary* truthDictionary = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
    NSMutableArray* tuples = [NSMutableArray array];
    for(int i=0; i<keys.count; i++)
    {
        Tuple* tuple = [Tuple tupleWithValue:values[i] forKey:keys[i]];
        [tuples addObject:tuple];
    }
    
    
    NSDictionary* dictMadeFromArrayOfTuples = [NSDictionary dictionaryWithTuples:tuples];
    
    XCTAssert([truthDictionary isEqualToDictionary:dictMadeFromArrayOfTuples], @"Dictionaries must match.");
    
    NSDictionary* dictInitedFromArrayOfTuples = [[NSDictionary alloc] initWithTuples:tuples];
    
    XCTAssert([truthDictionary isEqualToDictionary:dictInitedFromArrayOfTuples], @"Dictionaries must match.");
    
    [dictInitedFromArrayOfTuples release];
    
    NSMutableDictionary* mutableDictBuiltFromTuples = [NSMutableDictionary dictionary];
    for(Tuple* tuple in tuples)
    {
        [mutableDictBuiltFromTuples addTuple:tuple];
    }
    
    XCTAssert([truthDictionary isEqualToDictionary:mutableDictBuiltFromTuples], @"Dictionaries must match.");
    
    // test the tuples accessor
    NSArray* tuplesFromTruth = [truthDictionary tuples];
    
    // arrays must match, but dictionaries are unordered, so we have to just compare the counts and make sure both arrays contain all objects
    XCTAssert(tuplesFromTruth.count == tuples.count, @"Arrays must have same counts.");
    
    for(Tuple* tuple in tuples)
    {
        XCTAssert([tuplesFromTruth containsObject:tuple], @"Array must contain tuple.");
    }
    
    // assert the other way around, too...
    for(Tuple* tuple in tuplesFromTruth)
    {
        XCTAssert([tuples containsObject:tuple], @"Array must contain tuple.");
    }
    
    // test overwrite on mutable dictionaries
    NSMutableDictionary* overwriteTest = [NSMutableDictionary dictionary];
    Tuple* testTuple = [Tuple tupleWithValue:@"value" forKey:@"key"];
    Tuple* testTuple2 = [Tuple tupleWithValue:@"value2" forKey:@"key"];
    
    XCTAssert(overwriteTest.count == 0, @"Dictionary should start empty.");
    [overwriteTest addTuple:testTuple];
    XCTAssert(overwriteTest.count == 1, @"Dictionary should now have one tuple.");
    [overwriteTest addTuple:testTuple];
    XCTAssert(overwriteTest.count == 1, @"Dictionary should still only have one tuple.");
    [overwriteTest addTuple:testTuple2];
    XCTAssert(overwriteTest.count == 1, @"Dictionary should still only have one tuple.");
    
    
}


-(void)testArrayMap
{
    
    NSArray* testArray = [NSArray firstHundredThousandNumbers];
    
    NSArray* mappedSquares = [testArray map:^id (id object, int index) {
        NSNumber* input = (NSNumber*)object;
        int value = input.intValue;
        value = value * value;
        return [NSNumber numberWithInt:value];
    }];
    
    // first, maps should always have the same count.
    XCTAssert(mappedSquares.count == testArray.count);
    
    // verify that each number is, indeed, the square of its counterpart
    for(int i=0; i<testArray.count; i++)
    {
        int originalNumber = [testArray[i] intValue];
        int mappedSquare = [mappedSquares[i] intValue];
        XCTAssert(originalNumber * originalNumber == mappedSquare, @"square should equal the square of the original number.");
    }
}

-(void)testArrayMapAndJoin
{
    // let's make a test array of a hundred random strings of fifteen chars each
    NSArray* testArray = [self randomStringsWithChars:15 count:100];
    
    // now, let's map and join splitting each string into its component characters
    NSArray* mapAndJoinedArray = [testArray mapAndJoin:^id (id object, int index) {
        
        // if my input was @"hello" we will return @[@"h",@"e",@"l",@"l",@"o"]
        NSString* input = (NSString*)object;
        NSMutableArray* chars = [NSMutableArray arrayWithCapacity:input.length];
        for(int i=0; i<input.length; i++)
        {
            [chars addObject:[input substringWithRange:NSMakeRange(i, 1)]];
        }
        return chars;
    }];
    
    // now, we have an array of chars that is all of the individual characters from the strings in a single array
    // so if we started with ["cat","dog"] we now have ["c","a","t","d","o","g"]
    // joining the arrays with no delimiter should result in an equal return ("catdog" == "catdog")
    
    NSString* joinedTestArray = [testArray componentsJoinedByString:@""];
    NSString* joinedMapAndJoinedArray = [mapAndJoinedArray componentsJoinedByString:@""];
    
    XCTAssert([joinedTestArray isEqualToString:joinedMapAndJoinedArray], @"arrays combined should be equal");
    
    // the above assert verifies:
    // - ordering
    // - equality
    // - count
    
    
    
    
}

-(void)testArrayFilter
{
    NSArray* testArray = [NSArray firstThousandNumbers];
    
    NSArray* oddNumbers = [testArray filter:^BOOL(id object, int index) {
        int value = [(NSNumber*)object intValue];
        return value % 2 == 1;
    }];
    
    // we cannot make assumptions about the count of the returned array, except that it will be less than or equal to the original array
    XCTAssert(testArray.count >= oddNumbers.count, @"filtered result should have equal or less count than original array");
    
    // loop through the original array, and in cases where it is odd, make sure it IS in the result; otherwise, make sure it is NOT in the result.
    for(int i=0; i<testArray.count; i++)
    {
        NSNumber* number = testArray[i];
        int value = [number intValue];
        if(value % 2 == 1)
        {
            // odd - should be in oddNumbers
            XCTAssert([oddNumbers containsObject:number], @"Odd numbers should contain our odd number.");
        }
        else
        {
            //even - should NOT be contained
            XCTAssert([oddNumbers containsObject:number] == NO, @"Odd numbers array should not contain an even number");
        }
    }
}

-(void)testArrayFilterFirstObject
{
    NSArray* testArray = [NSArray firstThousandNumbers];
    
    NSNumber* firstPrimeAboveFiveHundred = [testArray firstObjectMatchingFilter:^BOOL(id object, int index) {
        
        int number = [(NSNumber*)object intValue];
        
        if(number <= 500)
        {
            return NO;
        }
        // is it prime?
        
        for (int i=2; i*i<=number; i++) {
            if (number % i == 0) return NO;
        }
        return YES;
        
    }];
    
    int value = [firstPrimeAboveFiveHundred intValue];
    
    // our first prime above 500 should be... 503
    XCTAssert(value == 503, @"first prime above 500 should be 503.");
    
    
    
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
