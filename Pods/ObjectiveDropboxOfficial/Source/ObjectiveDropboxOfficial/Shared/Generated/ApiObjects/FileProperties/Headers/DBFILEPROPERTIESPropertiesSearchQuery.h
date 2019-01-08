///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBFILEPROPERTIESLogicalOperator;
@class DBFILEPROPERTIESPropertiesSearchMode;
@class DBFILEPROPERTIESPropertiesSearchQuery;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `PropertiesSearchQuery` struct.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBFILEPROPERTIESPropertiesSearchQuery : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// The property field value for which to search across templates.
@property (nonatomic, readonly, copy) NSString *query;

/// The mode with which to perform the search.
@property (nonatomic, readonly) DBFILEPROPERTIESPropertiesSearchMode *mode;

/// The logical operator with which to append the query.
@property (nonatomic, readonly) DBFILEPROPERTIESLogicalOperator *logicalOperator;

#pragma mark - Constructors

///
/// Full constructor for the struct (exposes all instance variables).
///
/// @param query The property field value for which to search across templates.
/// @param mode The mode with which to perform the search.
/// @param logicalOperator The logical operator with which to append the query.
///
/// @return An initialized instance.
///
- (instancetype)initWithQuery:(NSString *)query
                         mode:(DBFILEPROPERTIESPropertiesSearchMode *)mode
              logicalOperator:(nullable DBFILEPROPERTIESLogicalOperator *)logicalOperator;

///
/// Convenience constructor (exposes only non-nullable instance variables with
/// no default value).
///
/// @param query The property field value for which to search across templates.
/// @param mode The mode with which to perform the search.
///
/// @return An initialized instance.
///
- (instancetype)initWithQuery:(NSString *)query mode:(DBFILEPROPERTIESPropertiesSearchMode *)mode;

- (instancetype)init NS_UNAVAILABLE;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `PropertiesSearchQuery` struct.
///
@interface DBFILEPROPERTIESPropertiesSearchQuerySerializer : NSObject

///
/// Serializes `DBFILEPROPERTIESPropertiesSearchQuery` instances.
///
/// @param instance An instance of the `DBFILEPROPERTIESPropertiesSearchQuery`
/// API object.
///
/// @return A json-compatible dictionary representation of the
/// `DBFILEPROPERTIESPropertiesSearchQuery` API object.
///
+ (nullable NSDictionary<NSString *, id> *)serialize:(DBFILEPROPERTIESPropertiesSearchQuery *)instance;

///
/// Deserializes `DBFILEPROPERTIESPropertiesSearchQuery` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBFILEPROPERTIESPropertiesSearchQuery` API object.
///
/// @return An instantiation of the `DBFILEPROPERTIESPropertiesSearchQuery`
/// object.
///
+ (DBFILEPROPERTIESPropertiesSearchQuery *)deserialize:(NSDictionary<NSString *, id> *)dict;

@end

NS_ASSUME_NONNULL_END
