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
    // example 1: convert a dict of keys/values to an encoded URL
    NSDictionary* params = @{
                                   @"username": @"test_user",
                             @"favorite_color": @"blue",
                                        @"age": @(99)};
    
    
    NSString* encodedURL = [[params mapToArray:^NSObject *(Tuple *tuple) {
        
        // we're pretending that stringByAddingPercentEscape properly escapes URLs... which it technically does not... so substitute here your own real encoding code
        NSObject* encodedValue = [[tuple.value description] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        return [NSString stringWithFormat:@"%@=%@",tuple.key, encodedValue];
        
    }] componentsJoinedByString:@"&"];
    
    NSLog(@"Encoded URL is %@",encodedURL);
    
    
    // example 2: filter a dict based on key name
    NSDictionary* credentials = @{@"username": @"test_user",
                                  @"password": @"P@ssw0rd!",
                            @"password_hint" : @"Its the same password you use at the bank",
                                     @"email": @"user@example.com"};
    
    NSDictionary* filteredCredentials = [credentials filter:^BOOL(Tuple *tuple) {
        return [(NSString*)tuple.key rangeOfString:@"password"].location == NSNotFound;
    }];
    
    NSLog(@"User's credentials are %@",filteredCredentials);
    
    
    // example 3: filter an array of cities so that only those with length >= 5 and < 8 are present
    NSArray* myStrings = @[@"Chicago", @"Los Angeles", @"Bern", @"Blythe", @"Miami", @"San Diego"];

    NSArray* filteredStrings = [myStrings filter:^BOOL(NSObject *object, int index) {
        int length = [(NSString*)object length];
        return length >= 5 && length < 8;
    }];
    
    NSLog(@"Filtered cities are %@",filteredStrings);
    
    // example 3: first-letter uppercase an array of strings using double-mapping
    NSArray* names = @[@"PRINCE", @"john Smith", @"JANE DOE", @"jIMMY jOHNS", @"john jacob jingleheimer schmidt", @"", @"k"];
    
    NSArray* namesCorrectCase = [names map:^NSObject *(NSObject *object, int index) {
        NSArray* parts = [(NSString*)object componentsSeparatedByString:@" "];
        
        NSArray* correctedParts = [parts map:^NSObject *(NSObject *object, int index) {
            NSString* string = (NSString*)object;
            
            if(string.length == 0)
            {
                return @"";
            }
            else if(string.length == 1)
            {
                return [string uppercaseString];
            }
            else
            {
                return [NSString stringWithFormat:@"%@%@", [[string substringToIndex:1] uppercaseString], [[string substringFromIndex:1] lowercaseString]];
            }
        }];
        
        return [correctedParts componentsJoinedByString:@" "];
        
    }];
    
    NSLog(@"Names correct case are %@",namesCorrectCase);
    
    
    // example 3: filter all numbers from a set that are even
    NSSet* someNumbers = [NSSet setWithObjects:@(1), @(2), @(5), @(100), @(87224), nil];
    
    NSSet* evenNumbers = [someNumbers filter:^BOOL(NSObject *object) {
        return [(NSNumber*)object intValue] % 2 == 0;
    }];
    NSLog(@"Even numbers are %@",evenNumbers);
    
}


@end
