//
//  DXAppDelegate.m
//  CollectionComprehensionSample
//
//  Created by Tim Gostony on 9/12/13.
//  Copyright (c) 2013 Tim Gostony. All rights reserved.
//

#import "DXAppDelegate.h"
#import "DXCollectionComprehensions.h"

@implementation DXAppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    [self examples];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;

    
    
    
}


-(void)examples
{

    
    // Convert a dict of keys/values to an encoded URL
    NSDictionary* params = @{
                                   @"username": @"test_user",
                             @"favorite_color": @"blue",
                                        @"age": @(99)};
    
    
    NSString* encodedURL = [[params mappedArrayUsingBlock:^NSObject *(Tuple *tuple) {
        
        // we're pretending that stringByAddingPercentEscape properly escapes URLs... which it technically does not... so substitute here your own real encoding code
        NSObject* encodedValue = [[tuple.value description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        return [NSString stringWithFormat:@"%@=%@",tuple.key, encodedValue];
        
    }] componentsJoinedByString:@"&"];
    
    NSLog(@"Encoded URL is %@",encodedURL);
    
    
    // Filter a dict based on key name
    NSDictionary* credentials = @{@"username": @"test_user",
                                  @"password": @"P@ssw0rd!",
                            @"password_hint" : @"Its the same password you use at the bank",
                                     @"email": @"user@example.com"};
    
    NSDictionary* filteredCredentials = [credentials filteredDictionaryUsingBlock:^BOOL(Tuple *tuple) {
        return [(NSString*)tuple.key rangeOfString:@"password"].location == NSNotFound;
    }];
    
    NSLog(@"User's credentials are %@",filteredCredentials);
    
    
    // Filter an array of cities so that only those with length >= 5 and < 8 are present
    NSArray* myStrings = @[@"Chicago", @"Los Angeles", @"Bern", @"Blythe", @"Miami", @"San Diego"];

    NSArray* filteredStrings = [myStrings filteredArrayUsingBlock:^BOOL(NSObject *object, NSUInteger index) {
        int length = [(NSString*)object length];
        return length >= 5 && length < 8;
    }];
    
    NSLog(@"Filtered cities are %@",filteredStrings);
    
    
    // First-letter uppercase an array of strings using double-mapping
    NSArray* names = @[@"PRINCE", @"john Smith", @"JANE DOE", @"jIMMY jOHNS", @"john jacob jingleheimer schmidt", @"", @"k"];
    
    NSArray* namesCorrectCase = [names mappedArrayUsingBlock:^NSObject *(NSObject *object, NSUInteger index) {
        
        NSArray* parts = [(NSString*)object componentsSeparatedByString:@" "];
        
        NSArray* correctedParts = [parts mappedArrayUsingBlock:^NSObject *(NSObject *object, NSUInteger index) {
            return [(NSString*)object capitalizedString];
        }];
        
        return [correctedParts componentsJoinedByString:@" "];
        
    }];
    
    NSLog(@"Names correct case are %@",namesCorrectCase);
    
    
    
    // Find the square root of an array of many many numbers, in parallel.
    NSMutableArray* numbers = [NSMutableArray array];
    for(int i=0; i < 150000; i++)
    {
        [numbers addObject:[NSNumber numberWithFloat:(float)i]];
    }
    
    
    // Example 3.5, find all numbers not divisible by 5 (testing filter ordering)
    NSObject* notFivable = [numbers firstObjectMatchingFilter:^BOOL(NSObject *object, NSUInteger index) {
        return [(NSNumber*)object integerValue]  > 10000 && [(NSNumber*)object integerValue] % 5 != 0;
    }];
    NSLog(@"The first non-fivable above 10k is: %@",notFivable);
    
    NSArray* roots = [numbers mappedArrayUsingBlock:^NSObject *(NSObject *object, NSUInteger index) {
        float num = [(NSNumber*)object floatValue];
        return @(sqrtf(num));
    }];
    NSLog(@"Calculated %d roots.",roots.count);
    
    
    // Filter numbers by which is prime (naively) (in parallel)
    NSArray* primes = [numbers filteredArrayUsingBlock:^BOOL(NSObject *object, NSUInteger index) {
        int number = [(NSNumber*)object intValue];
        
        for(int i=2; i <= number/2; i++)
        {
            if(number % i == 0)
            {
                return NO;
            }
        }
        return YES;
        
    }];
    NSLog(@"Found %d primes.",primes.count);
    
    
    // Example 6: find the first number divisible by 4 different numbers
    NSNumber* leastCommonMultiplier = (NSNumber*)[numbers firstObjectMatchingFilter:^BOOL(NSObject *object, NSUInteger index) {
        int num = [(NSNumber*)object integerValue];
        return num > 1 && (num % 5)  == 0 && (num % 6) == 0 && (num % 11) == 0 && (num % 16) == 0;
    }];
    NSLog(@"The first number divisible by 5, 6, 11, and 16 is %@",leastCommonMultiplier);
    
    
    
    // Example 7: split input values into individual strings, then return a flattened array of all parts
    // A note: mapAndJoin's block takes in an object and returns an array, then combines all members of the resultant arrays into one array (in order).
    NSArray* colorGroups = @[@"blue cyan green", @"red brown orange", @"black white gray", @"rainbow"];
    
    NSArray* allColors = [colorGroups mappedAndJoinedArrayUsingBlock:^NSArray *(NSObject *object, NSUInteger index) {
        return [(NSString*)object componentsSeparatedByString:@" "];
    }];
    NSLog(@"All the colors are %@",allColors);
    
    
}


@end
