///
/// Copyright (c) 2016 Dropbox, Inc. All rights reserved.
///
/// Auto-generated by Stone, do not modify.
///

#import <Foundation/Foundation.h>

#import "DBFILESFileOpsResult.h"
#import "DBSerializableProtocol.h"

@class DBFILESCreateFolderBatchResult;
@class DBFILESCreateFolderBatchResultEntry;

NS_ASSUME_NONNULL_BEGIN

#pragma mark - API Object

///
/// The `CreateFolderBatchResult` struct.
///
/// This class implements the `DBSerializable` protocol (serialize and
/// deserialize instance methods), which is required for all Obj-C SDK API route
/// objects.
///
@interface DBFILESCreateFolderBatchResult : DBFILESFileOpsResult <DBSerializable, NSCopying>

#pragma mark - Instance fields

/// Each entry in `paths` in `DBFILESCreateFolderBatchArg` will appear at the
/// same position inside `entries` in `DBFILESCreateFolderBatchResult`.
@property (nonatomic, readonly) NSArray<DBFILESCreateFolderBatchResultEntry *> *entries;

#pragma mark - Constructors

///
/// Full constructor for the struct (exposes all instance variables).
///
/// @param entries Each entry in `paths` in `DBFILESCreateFolderBatchArg` will
/// appear at the same position inside `entries` in
/// `DBFILESCreateFolderBatchResult`.
///
/// @return An initialized instance.
///
- (instancetype)initWithEntries:(NSArray<DBFILESCreateFolderBatchResultEntry *> *)entries;

@end

#pragma mark - Serializer Object

///
/// The serialization class for the `CreateFolderBatchResult` struct.
///
@interface DBFILESCreateFolderBatchResultSerializer : NSObject

///
/// Serializes `DBFILESCreateFolderBatchResult` instances.
///
/// @param instance An instance of the `DBFILESCreateFolderBatchResult` API
/// object.
///
/// @return A json-compatible dictionary representation of the
/// `DBFILESCreateFolderBatchResult` API object.
///
+ (nullable NSDictionary<NSString *, id> *)serialize:(DBFILESCreateFolderBatchResult *)instance;

///
/// Deserializes `DBFILESCreateFolderBatchResult` instances.
///
/// @param dict A json-compatible dictionary representation of the
/// `DBFILESCreateFolderBatchResult` API object.
///
/// @return An instantiation of the `DBFILESCreateFolderBatchResult` object.
///
+ (DBFILESCreateFolderBatchResult *)deserialize:(NSDictionary<NSString *, id> *)dict;

@end

NS_ASSUME_NONNULL_END