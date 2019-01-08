///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBSerializableProtocol.h"

@class DBSHARINGListSharedLinksResult;
@class DBSHARINGSharedLinkMetadata;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `ListSharedLinksResult` struct.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBSHARINGListSharedLinksResult : NSObject <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// Shared links applicable to the path argument.
@property (nonatomic, readonly) NSArray<DBSHARINGSharedLinkMetadata *> *links;

/// Is true if there are additional shared links that have not been returned
/// yet. Pass the cursor into `listSharedLinks` to retrieve them.
@property (nonatomic, readonly) NSNumber *hasMore;

/// Pass the cursor into `listSharedLinks` to obtain the additional links.
/// Cursor is returned only if no path is given.
@property (nonatomic, readonly, copy, nullable) NSString *cursor;

#pragma mark - Constructors

///
/// Full constructor for the struct (exposes all instance variables).
///
/// @param links Shared links applicable to the path argument.
/// @param hasMore Is true if there are additional shared links that have not
/// been returned yet. Pass the cursor into `listSharedLinks` to retrieve them.
/// @param cursor Pass the cursor into `listSharedLinks` to obtain the
/// additional links. Cursor is returned only if no path is given.
///
/// @return An initialized instance.
///
- (instancetype)initWithLinks:(NSArray<DBSHARINGSharedLinkMetadata *> *)links
                      hasMore:(NSNumber *)hasMore
                       cursor:(nullable NSString *)cursor;

///
/// Convenience constructor (exposes only non-nullable instance variables with
/// no default value).
///
/// @param links Shared links applicable to the path argument.
/// @param hasMore Is true if there are additional shared links that have not
/// been returned yet. Pass the cursor into `listSharedLinks` to retrieve them.
///
/// @return An initialized instance.
///
- (instancetype)initWithLinks:(NSArray<DBSHARINGSharedLinkMetadata *> *)links hasMore:(NSNumber *)hasMore;

- (instancetype)init NS_UNAVAILABLE;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `ListSharedLinksResult` struct.
///
@interface DBSHARINGListSharedLinksResultSerializer : NSObject

///
/// Serializes `DBSHARINGListSharedLinksResult` instances.
///
/// @param instance An instance of the `DBSHARINGListSharedLinksResult` API
/// object.
///
/// @return A json-compatible dictionary representation of the
/// `DBSHARINGListSharedLinksResult` API object.
///
+ (nullable NSDictionary<NSString *, id> *)serialize:(DBSHARINGListSharedLinksResult *)instance;

///
/// Deserializes `DBSHARINGListSharedLinksResult` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBSHARINGListSharedLinksResult` API object.
///
/// @return An instantiation of the `DBSHARINGListSharedLinksResult` object.
///
+ (DBSHARINGListSharedLinksResult *)deserialize:(NSDictionary<NSString *, id> *)dict;

@end

NS_ASSUME_NONNULL_END
