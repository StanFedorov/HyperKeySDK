//
//  ImagesLoadingAndSavingManager.h
//  Better Word
//
//  Created by Dmitriy gonchar on 29.03.16.
//
//

#import <UIKit/UIKit.h>
#import "Config.h"

// FIXME:This enum should be changed for FeatureType from Config.h
typedef NS_ENUM(NSInteger, ServiceType) {
    ServiceTypeGIFs,
    ServiceTypeImoji,
    ServiceTypeMojiSM,
    ServiceTypeYelp,
    ServiceTypeDropBox,
    ServiceTypeGoogleDrive,
    ServiceTypeInstagram,
    ServiceTypeFacebook,
    ServiceTypeSpotify,
    ServiceTypeYoutube,
    ServiceTypeTwitter,
    ServiceTypeEbay,
    ServiceTypeImageDrawing,
    ServiceTypeMemes,
    ServiceTypeSounds,
    ServiceTypeRecentShared,
    ServiceTypeFeed,
    ServiceTypeCamFind,
    ServiceTypeGifCamera
};

typedef NS_ENUM(NSUInteger, ImageDownloadingType) {
    ImageBlockingDownload,
    ImageAsynchronicallySimpleDownload,
    ImageAsynchronicallWithProgressDownload
};

@protocol ImagesLoadingAndSavingManagerDelegate;

@interface ImagesLoadingAndSavingManager : NSObject

@property (weak, nonatomic) id<ImagesLoadingAndSavingManagerDelegate> delegate;
@property (assign, nonatomic) ServiceType serviceType;

- (void)setup;

+ (void)clearCacheForServiceType:(ServiceType)serviceType;
- (void)showContentsOfDirrectoryForServiceType:(ServiceType)serviceType;

- (UIImage *)getImageByPath:(NSString *)imagePath andServiceType:(ServiceType)serviceType;
- (UIImage *)loadImageIfItNotExistsByPath:(NSString *)imagePath byServiceType:(ServiceType)serviceType andSelectedIndex:(NSIndexPath *)indexPath;
- (UIImage *)loadSyncImageIfItNotExistsByPath:(NSString *)imagePath byServiceType:(ServiceType)serviceType andSelectedIndex:(NSIndexPath *)indexPath;

- (NSData *)getDataByPath:(NSString *)imagePath andServiceType:(ServiceType)serviceType;
- (NSData *)loadDataIfItNotExistsByPath:(NSString *)imagePath byServiceType:(ServiceType)serviceType andSelectedIndex:(NSIndexPath *)indexPath andType:(ImageDownloadingType)type;
- (void)cancelAllAsynchronicalWithProgressObservingDownloads;

- (NSURL *)getCachedUrlByPath:(NSString *)imagePath andServiceType:(ServiceType)serviceType;
- (NSURL *)loadCachedUrlIfItNotExistsByPath:(NSString *)imagePath byServiceType:(ServiceType)serviceType andSelectedIndex:(NSIndexPath *)indexPath;

+ (void)saveToFileData:(NSData *)data withFileName:(NSString *)fileName forServiceType:(ServiceType)serviceType;

+ (NSString *)fileNameByType:(ServiceType)type andImagePath:(NSString *)imagePath;
+ (NSString *)pathToFolderForServiceType:(ServiceType)serviceType;
+ (NSString *)pathToFileName:(NSString *)fileName forServiceType:(ServiceType)serviceType;
+ (NSData *)dataByFilePath:(NSString *)filePath serviceType:(ServiceType)serviceType;
+ (void)removeDataByFilePath:(NSString *)filePath serviceType:(ServiceType)serviceType;

+ (NSURL *)sharedContainerURL;


// New Methods
- (BOOL)existsDataWithURLString:(NSString *)urlString;
- (void)addLoadImageWithURLString:(NSString *)urlString indexPath:(NSIndexPath *)indexPath;
- (void)addLoadDataWithURLString:(NSString *)urlString indexPath:(NSIndexPath *)indexPath;
- (void)addLoadDataWithURLString:(NSString *)urlString serviceType:(ServiceType)serviceType dataType:(DataType)dataType indexPath:(NSIndexPath *)indexPath;

- (void)loadImageWithURLString:(NSString *)urlString completion:(void (^)(UIImage *image, BOOL fromCache))completion;
- (void)loadDataWithURLString:(NSString *)urlString completion:(void (^)(NSData *data, BOOL fromCache))completion;

@end

@protocol ImagesLoadingAndSavingManagerDelegate <NSObject>

@optional
- (void)image:(UIImage *)image wasLoadedByIndexPath:(NSIndexPath *)indexPath;
- (void)imageData:(NSData *)data wasLoadedByIndexPath:(NSIndexPath *)path;
- (void)imageUrl:(NSURL *)url wasLoadedByIndexPath:(NSIndexPath *)path;

- (void)imageAtIndexPath:(NSIndexPath *)indexPath downloadingProgressChangedTo:(float)progressValue;

// New Protocols
- (void)dataLoadingManagerDidLoadImage:(UIImage *)image forIndexPath:(NSIndexPath *)indexPath fromCache:(BOOL)fromCache;
- (void)dataLoadingManagerDidLoadData:(NSData *)data forIndexPath:(NSIndexPath *)indexPath fromCache:(BOOL)fromCache;

@end
