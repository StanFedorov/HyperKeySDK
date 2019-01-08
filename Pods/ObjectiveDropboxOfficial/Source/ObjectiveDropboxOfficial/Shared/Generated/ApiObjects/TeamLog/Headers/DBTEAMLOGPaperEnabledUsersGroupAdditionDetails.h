///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBTEAMLOGPaperEnabledUsersGroupAdditionDetails;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `PaperEnabledUsersGroupAdditionDetails` struct.
///
/// Added users to Paper-enabled users list.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBTEAMLOGPaperEnabledUsersGroupAdditionDetails : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

#pragma mark - Constructors

///
/// Full constructor for the struct (exposes all instance variables).
///
/// @return An initialized instance.
///
- (instancetype)initDefault;

- (instancetype)init NS_UNAVAILABLE;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `PaperEnabledUsersGroupAdditionDetails`
/// struct.
///
@interface DBTEAMLOGPaperEnabledUsersGroupAdditionDetailsSerializer : NSObject

///
/// Serializes `DBTEAMLOGPaperEnabledUsersGroupAdditionDetails` instances.
///
/// @param instance An instance of the
/// `DBTEAMLOGPaperEnabledUsersGroupAdditionDetails` API object.
///
/// @return A json-compatible dictionary representation of the
/// `DBTEAMLOGPaperEnabledUsersGroupAdditionDetails` API object.
///
+ (nullable NSDictionary<NSString *, id> *)serialize:(DBTEAMLOGPaperEnabledUsersGroupAdditionDetails *)instance;

///
/// Deserializes `DBTEAMLOGPaperEnabledUsersGroupAdditionDetails` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBTEAMLOGPaperEnabledUsersGroupAdditionDetails` API object.
///
/// @return An instantiation of the
/// `DBTEAMLOGPaperEnabledUsersGroupAdditionDetails` object.
///
+ (DBTEAMLOGPaperEnabledUsersGroupAdditionDetails *)deserialize:(NSDictionary<NSString *, id> *)dict;

@end

NS_ASSUME_NONNULL_END
