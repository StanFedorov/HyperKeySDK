///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBSHARINGModifySharedLinkSettingsArgs;
@class DBSHARINGSharedLinkSettings;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `ModifySharedLinkSettingsArgs` struct.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBSHARINGModifySharedLinkSettingsArgs : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// URL of the shared link to change its settings.
@property (nonatomic, readonly, copy) NSString *url;

/// Set of settings for the shared link.
@property (nonatomic, readonly) DBSHARINGSharedLinkSettings *settings;

/// If set to true, removes the expiration of the shared link.
@property (nonatomic, readonly) NSNumber *removeExpiration;

#pragma mark - Constructors

///
/// Full constructor for the struct (exposes all instance variables).
///
/// @param url URL of the shared link to change its settings.
/// @param settings Set of settings for the shared link.
/// @param removeExpiration If set to true, removes the expiration of the shared
/// link.
///
/// @return An initialized instance.
///
- (instancetype)initWithUrl:(NSString *)url
                   settings:(DBSHARINGSharedLinkSettings *)settings
           removeExpiration:(nullable NSNumber *)removeExpiration;

///
/// Convenience constructor (exposes only non-nullable instance variables with
/// no default value).
///
/// @param url URL of the shared link to change its settings.
/// @param settings Set of settings for the shared link.
///
/// @return An initialized instance.
///
- (instancetype)initWithUrl:(NSString *)url settings:(DBSHARINGSharedLinkSettings *)settings;

- (instancetype)init NS_UNAVAILABLE;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `ModifySharedLinkSettingsArgs` struct.
///
@interface DBSHARINGModifySharedLinkSettingsArgsSerializer : NSObject

///
/// Serializes `DBSHARINGModifySharedLinkSettingsArgs` instances.
///
/// @param instance An instance of the `DBSHARINGModifySharedLinkSettingsArgs`
/// API object.
///
/// @return A json-compatible dictionary representation of the
/// `DBSHARINGModifySharedLinkSettingsArgs` API object.
///
+ (nullable NSDictionary<NSString *, id> *)serialize:(DBSHARINGModifySharedLinkSettingsArgs *)instance;

///
/// Deserializes `DBSHARINGModifySharedLinkSettingsArgs` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBSHARINGModifySharedLinkSettingsArgs` API object.
///
/// @return An instantiation of the `DBSHARINGModifySharedLinkSettingsArgs`
/// object.
///
+ (DBSHARINGModifySharedLinkSettingsArgs *)deserialize:(NSDictionary<NSString *, id> *)dict;

@end

NS_ASSUME_NONNULL_END