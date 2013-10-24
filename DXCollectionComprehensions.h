//
//  DXCollectionComprehensions.h
//  CollectionComprehensionSample
//
//  Created by Tim Gostony on 9/12/13.
//  Copyright (c) 2013 Tim Gostony. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Types

@class Tuple;

typedef Tuple* (^TupleToTupleBlock)(Tuple* tuple);
typedef id (^TupleToObjectBlock)(Tuple* tuple);
typedef id (^ObjectToObjectBlock)(id object);
typedef id (^ObjectAndIndexToObjectBlock)(id object, NSUInteger index);
typedef NSArray* (^ObjectAndIndexToArrayBlock)(id object, NSUInteger index);
typedef BOOL (^TupleToBoolBlock)(Tuple* tuple);
typedef BOOL (^ObjectAndIndexToBoolBlock)(id object, NSUInteger index);
typedef BOOL (^ObjectToBoolBlock)(id object);

#pragma mark - Dictionary categories

@interface NSDictionary (Map)

/// Map: For each tuple (key/value pair) in the dictionary, return a tuple.  This method returns a new dictionary made of all tuples returned from the blocks.  Duplicated keys in tuples are overwritten in an undefined fashion.
- (NSDictionary*)mappedDictionaryUsingBlock:(TupleToTupleBlock)mapFunction;

/// Map to Array: For each tuple (key/pair) in the dictionary, return an object.  This method returns an array of all objects returned from the blocks.  Because dictionaries are not ordered, the resulting array has an undefined order.
- (NSArray*)mappedArrayUsingBlock:(TupleToObjectBlock)mapFunction;

@end

@interface NSDictionary (Filter)

/// Filter:  For each tuple (key/pair) in the dictionary, return a boolean.  This method returns a dictionary which only has the tuples the block returned YES for.
- (NSDictionary*)filteredDictionaryUsingBlock:(TupleToBoolBlock)filterFunction;

@end

@interface NSDictionary (Tuple)

/// Create a dictionary with the given array of tuples.  Duplicated keys within the tuples are overwritten in an undefined fashion.
+ (NSDictionary*)dictionaryWithTuples:(NSArray*)tuples;

/// Create an autoreleased dictionary with the given array of tuples.  Duplicated keys within the tuples are overwritten in an undefined fashion.
- (NSDictionary*)initWithTuples:(NSArray*)tuples;

/// Convert the dictionary into an array of tuples (key/value pairs).  Because dictionaries are unordered, the array has an undefined order.
- (NSArray *)tuples;

@end

@interface NSMutableDictionary (Tuple)

/// Add a tuple (key/value pair) to a dictionary.  If the key already exists in the dictionary, its value is overwritten.
- (void)addTuple:(Tuple*)tuple;

@end

#pragma mark - Array categories

@interface NSArray (Map)

/// Map: For all of the objects in the array, return an object.  This method returns a new array of all objects returned from the blocks.  The map function block should not mutate objects passed into it.  Map runs in parallel and as such, side effects which are not threadsafe should be avoided.  The order that the block is called on each object in the array is undefined and not guaranteed to be sequential.  The returned array is, however, guaranteed to be in the same order as the original array.
- (NSArray*)mappedArrayUsingBlock:(ObjectAndIndexToObjectBlock)mapFunction;

@end

@interface NSArray (MapAndJoin)

/// Map and Join: For all of the objects in the array, return an array of objects.  The resulting arrays are then joined together into a single array, which is returned.  All caveats of -[NSArray mappedArrayUsingBlock:] apply to Map and Join.  The resulting array is guaranteed to be in the same order as the original objects.  Note that this does not return an array of arrays - it returns a single array containing all of the objects that were in the arrays returned by the map function block.
- (NSArray*)mappedAndJoinedArrayUsingBlock:(ObjectAndIndexToArrayBlock)mapFunction;

@end

@interface NSArray (Filter)

/// Filter:  For all of the objects in the array, return a BOOL value.  The resulting array is an array that only has objects where the block returned YES.  The filter function block is not guaranteed to be called in order, however, the resulting array is guaranteed to be returned in the right order.
- (NSArray*)filteredArrayUsingBlock:(ObjectAndIndexToBoolBlock)filterFunction;

@end


@interface NSArray (FilterFirstObject)

/// First Object Matching Filter:  For all of the objects in the array, return a BOOL value.  This method returns the first object for which the block returned YES.  This method is not guaranteed to call the filter function on objects in order, and is not guaranteed to call the filter function on all objects as it stops calling it once an object is found.  This method has more aggressive performance charactersistics than simply calling -filteredArrayUsingBlock: and then -firstObject.
- (id)firstObjectMatchingFilter:(ObjectAndIndexToBoolBlock)filterFunction;

@end

#pragma mark - Tuple

@interface Tuple : NSObject

/// Creates a new autoreleased tuple with the specified key/value pair.
+(Tuple*)tupleWithValue:(id)value forKey:(id<NSCopying,NSObject>)key;

/// Creates a new tuple with the specified key/value pair.
-(Tuple*)initWithValue:(id)value forKey:(id<NSCopying,NSObject>)key;

/// The key of the tuple.  Requires conformance to NSCopying per NSDictionary's spec, but is not copied.
@property (nonatomic, retain) id<NSCopying,NSObject> key;

/// The value of the tuple.  Does not require NSCopying, but is retained.
@property (nonatomic, retain) id value;

@end
