CollectionComprehension
=======================

A collection of categories for mapping and filtering on Objective-C collections.

```objective-c
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
        return [(NSString*)object capitalizedString];
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


// example 4: find the square root of an array of many many numbers, in parallel.
NSMutableArray* numbers = [NSMutableArray array];
for(int i=0; i < 150000; i++)
{
    [numbers addObject:[NSNumber numberWithFloat:(float)i]];
}

NSArray* roots = [numbers map:^NSObject *(NSObject *object, int index) {
    float num = [(NSNumber*)object floatValue];
    return @(sqrtf(num));
}];
NSLog(@"Calculated %d roots.",roots.count);


// example 5: filter numbers by which is prime (naively) (in parallel)
NSArray* primes = [numbers filter:^BOOL(NSObject *object, int index) {
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


// example 6: find the first number divisible by 4 different numbers
NSNumber* leastCommonMultiplier = (NSNumber*)[numbers firstObjectMatchingFilter:^BOOL(NSObject *object, int index) {
    int num = [(NSNumber*)object integerValue];
    return num > 1 && (num % 5)  == 0 && (num % 6) == 0 && (num % 11) == 0 && (num % 16) == 0;
}];
NSLog(@"The first number divisible by 5, 6, 11, and 16 is %@",leastCommonMultiplier);



// example 7: split input values into individual strings, then return a flattened array of all parts
// a note: mapAndJoin's block takes in an object and returns an array, then combines all members of the resultant arrays into one array (in order).
NSArray* colorGroups = @[@"blue cyan green", @"red brown orange", @"black white gray", @"rainbow"];

NSArray* allColors = [colorGroups mapAndJoin:^NSArray *(NSObject *object, int index) {
    return [(NSString*)object componentsSeparatedByString:@" "];
}];
NSLog(@"All the colors are %@",allColors);
```
