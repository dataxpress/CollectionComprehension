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
typedef NSObject* (^TupleToObjectBlock)(Tuple* tuple);
typedef NSObject* (^ObjectToObjectBlock)(NSObject* object);
typedef NSObject* (^ObjectAndIndexToObjectBlock)(NSObject* object, int index);
typedef NSArray* (^ObjectAndIndexToArrayBlock)(NSObject* object, int index);
typedef BOOL (^TupleToBoolBlock)(Tuple* tuple);
typedef BOOL (^ObjectAndIndexToBoolBlock)(NSObject* object, int index);
typedef BOOL (^ObjectToBoolBlock)(NSObject* object);

#pragma mark - Dictionary categories

@interface NSDictionary (Map)

- (NSDictionary*)map:(TupleToTupleBlock)mapFunction;
- (NSArray*)mapToArray:(TupleToObjectBlock)mapFunction;

@end

@interface NSDictionary (Filter)

- (NSDictionary*)filter:(TupleToBoolBlock)filterFunction;

@end

@interface NSDictionary (Tuple)

+ (NSDictionary*)dictionaryWithTuples:(NSArray*)tuples;
- (NSDictionary*)initWithTuples:(NSArray*)tuples;

@end

@interface NSMutableDictionary (Tuple)

- (void)addTuple:(Tuple*)tuple;

@end

#pragma mark - Array categories

@interface NSArray (Map)

- (NSArray*)map:(ObjectAndIndexToObjectBlock)mapFunction;
- (NSArray*)map:(ObjectAndIndexToObjectBlock)mapFunction onQueue:(dispatch_queue_t)queue;

@end

@interface NSArray (MapAndJoin)

- (NSArray*)mapAndJoin:(ObjectAndIndexToArrayBlock)mapFunction;
- (NSArray*)mapAndJoin:(ObjectAndIndexToArrayBlock)mapFunction onQueue:(dispatch_queue_t)queue;

@end

@interface NSArray (Filter)

- (NSArray*)filter:(ObjectAndIndexToBoolBlock)filterFunction;
- (NSArray*)filter:(ObjectAndIndexToBoolBlock)filterFunction onQueue:(dispatch_queue_t)queue;

@end


@interface NSArray (FilterFirstObject)

- (NSObject*)firstObjectMatchingFilter:(ObjectAndIndexToBoolBlock)filterFunction;
- (NSObject*)firstObjectMatchingFilter:(ObjectAndIndexToBoolBlock)filterFunction onQueue:(dispatch_queue_t)queue;

@end

#pragma mark - Set categories

@interface NSSet (Map)

- (NSSet*)map:(ObjectToObjectBlock)mapFunction;

@end

@interface NSSet (Filter)

- (NSSet*)filter:(ObjectToBoolBlock)filterFunction;

@end

#pragma mark - Tuple

@interface Tuple : NSObject

+(Tuple*)tupleWithValue:(NSObject*)value forKey:(NSObject<NSCopying>*)key;

-(Tuple*)initWithValue:(NSObject*)value forKey:(NSObject<NSCopying>*)key;

@property (nonatomic, retain) NSObject<NSCopying>* key;
@property (nonatomic, retain) NSObject* value;

@end
