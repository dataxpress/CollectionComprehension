//
//  DXCollectionComprehensions.m
//  CollectionComprehensionSample
//
//  Created by Tim Gostony on 9/12/13.
//  Copyright (c) 2013 Tim Gostony. All rights reserved.
//

#import "DXCollectionComprehensions.h"

#pragma mark - Dictionary categories

@implementation NSDictionary (Comprehensions)

-(NSDictionary *)map:(TupleToTupleBlock)mapFunction
{
    
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [result addTuple:mapFunction([Tuple tupleWithValue:obj forKey:key])];
    }];
    
    NSDictionary* retVal = [NSDictionary dictionaryWithDictionary:result];
    [result release];
    return retVal;
    
}

-(NSArray *)mapToArray:(TupleToObjectBlock)mapFunction
{
    NSMutableArray* result = [[NSMutableArray alloc] init];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        Tuple* tuple = [[Tuple alloc] initWithValue:obj forKey:key];
        [result addObject:mapFunction(tuple)];
        [tuple release];
    }];
    
    NSArray* retVal = [NSArray arrayWithArray:result];
    [result release];
    return retVal;
}

@end

@implementation NSDictionary (Filter)

-(NSDictionary *)filter:(TupleToBoolBlock)filterFunction
{
    NSMutableDictionary* result = [[NSMutableDictionary alloc] init];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        Tuple* tuple = [[Tuple alloc] initWithValue:obj forKey:key];
        if(filterFunction(tuple))
        {
            [result addTuple:tuple];
        }
        [tuple release];
    }];
    
    
    NSDictionary* retVal = [NSDictionary dictionaryWithDictionary:result];
    [result release];
    return retVal;
}

@end

@implementation NSDictionary (Tuple)

+(NSDictionary*)dictionaryWithTuples:(NSArray*)tuples;
{
    return [[[NSDictionary alloc] initWithTuples:tuples] autorelease];
}

-(NSDictionary *)initWithTuples:(NSArray *)tuples
{
    return [[NSDictionary alloc] initWithObjects:[tuples valueForKey:@"value"] forKeys:[tuples valueForKey:@"key"]];
}

@end

@implementation NSMutableDictionary (Tuple)

-(void)addTuple:(Tuple *)tuple
{
    [self setObject:tuple.value forKey:tuple.key];
}

@end

#pragma mark - Array categories

@implementation NSArray (Map)

-(NSArray *)map:(ObjectAndIndexToObjectBlock)mapFunction
{
    dispatch_queue_t queue = dispatch_queue_create("map queue", DISPATCH_QUEUE_CONCURRENT);
    NSArray* result = [self map:mapFunction onQueue:queue];
    dispatch_release(queue);
    return result;
}

-(NSArray *)map:(ObjectAndIndexToObjectBlock)mapFunction onQueue:(dispatch_queue_t)queue
{
    
    NSArray* retVal;
    @synchronized(self)
    {
        NSUInteger count = self.count;
        id* results = malloc(count * sizeof(id));
        dispatch_apply(count, queue, ^(size_t index)
        {
            id obj = mapFunction(self[(int)index], (int)index);
            results[index] = [obj retain];
        });
        retVal = [NSArray arrayWithObjects:results count:count];
        dispatch_apply(count, queue, ^(size_t index)
        {
            [results[index] release];
        });
        free(results);
    }
    
    return retVal;
}

@end

@implementation NSArray (MapAndJoin)

-(NSArray *)mapAndJoin:(ObjectAndIndexToArrayBlock)mapFunction
{
    
    dispatch_queue_t queue = dispatch_queue_create("map and join queue", DISPATCH_QUEUE_CONCURRENT);
    NSArray* result = [self mapAndJoin:mapFunction onQueue:queue];
    dispatch_release(queue);
    return result;
}

-(NSArray *)mapAndJoin:(ObjectAndIndexToArrayBlock)mapFunction onQueue:(dispatch_queue_t)queue
{
    NSMutableArray* result = [[NSMutableArray alloc] init];
    
    NSArray* mapped = [self map:mapFunction onQueue:queue];
    
    for(NSArray* array in mapped)
    {
        [result addObjectsFromArray:array];
    }
    
    NSArray* retVal = [NSArray arrayWithArray:result];
    [result release];
    return retVal;
}

@end



@implementation NSArray (Filter)

-(NSArray *)filter:(ObjectAndIndexToBoolBlock)filterFunction
{
    dispatch_queue_t queue = dispatch_queue_create("filter queue", DISPATCH_QUEUE_CONCURRENT);
    NSArray* result = [self filter:filterFunction onQueue:queue];
    dispatch_release(queue);
    return result;
}

-(NSArray *)filter:(ObjectAndIndexToBoolBlock)filterFunction onQueue:(dispatch_queue_t)queue
{    
    NSArray* retVal;
    @synchronized(self)
    {
        NSUInteger count = self.count;
        id* results = malloc(count * sizeof(id));
        __block int resultCount = 0;
        dispatch_apply(count, queue, ^(size_t index)
        {
            id obj = self[(int)index];
            BOOL add = filterFunction(self[(int)index], (int)index);
            if(add == YES)
            {
                results[resultCount++] = [obj retain];
            }
        });
        retVal = [NSArray arrayWithObjects:results count:resultCount];
        dispatch_apply(resultCount, queue, ^(size_t index)
        {
            [results[index] release];
        });
        free(results);
    }
    
    return retVal;
    
}

@end



@implementation NSArray (FilterFirstObject)

-(NSObject *)firstObjectMatchingFilter:(ObjectAndIndexToBoolBlock)filterFunction
{
    dispatch_queue_t queue = dispatch_queue_create("filter first queue", DISPATCH_QUEUE_CONCURRENT);
    NSObject* result = [self firstObjectMatchingFilter:filterFunction onQueue:queue];
    dispatch_release(queue);
    return result;
}

-(NSObject *)firstObjectMatchingFilter:(ObjectAndIndexToBoolBlock)filterFunction onQueue:(dispatch_queue_t)queue
{
    NSObject* retVal = nil;
    @synchronized(self)
    {
        NSUInteger count = self.count;
        id* results = malloc(count * sizeof(id));
        __block int resultCount = 0;
        dispatch_apply(count, queue, ^(size_t index)
        {
            if(resultCount == 0)
            {
                id obj = self[(int)index];
                BOOL add = filterFunction(self[(int)index], (int)index);
                if(add == YES)
                {
                   results[resultCount++] = [obj retain];
                }
            }
        });
        if(resultCount > 0)
        {
            retVal = [results[0] retain];
        }
        dispatch_apply(resultCount, queue, ^(size_t index)
        {
            [results[index] release];
        });
        free(results);
    }
    
    return retVal;
    
}

@end

#pragma mark - Set categories

@implementation NSSet (Map)

-(NSSet *)map:(ObjectToObjectBlock)mapFunction
{
    NSMutableSet* result = [[NSMutableSet alloc] init];
    
    [self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [result addObject:mapFunction(obj)];
    }];
    
    NSSet* retVal = [NSSet setWithSet:result];
    [result release];
    return retVal;
}

@end

@implementation NSSet (Filter)

-(NSSet *)filter:(ObjectToBoolBlock)filterFunction
{
    NSMutableSet* result = [[NSMutableSet alloc] init];
    
    [self enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        if(filterFunction(obj))
        {
            [result addObject:obj];
        }
    }];
    
    NSSet* retVal = [NSSet setWithSet:result];
    [result release];
    return retVal;
}



@end

#pragma mark - Tuple

@implementation Tuple

-(Tuple *)initWithValue:(NSObject*)value forKey:(NSObject<NSCopying>*)key
{
    if(self = [super init])
    {
        _key = [key retain];
        _value = [value retain];
    }
    return self;
}

+(Tuple *)tupleWithValue:(NSObject*)value forKey:(NSObject<NSCopying>*)key
{
    return [[[Tuple alloc] initWithValue:value forKey:key] autorelease];
}

-(void)dealloc
{
    [_key release];
    [_value release];
    [super dealloc];
}

@end
