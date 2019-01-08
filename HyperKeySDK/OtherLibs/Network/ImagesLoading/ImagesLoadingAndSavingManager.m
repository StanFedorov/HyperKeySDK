//
//  ImagesLoadingAndSavingManager.m
//  Better Word
//
//  Created by Dmitriy gonchar on 29.03.16.
//
//

#import "ImagesLoadingAndSavingManager.h"

#import "UIImage+Resize.h"
#import "Config.h"
#import "LoadURLDataOperation.h"
#import "LoadFileDataOperation.h"

BOOL const kImagesLoadingAndSavingManagerLogEnabled = YES;

NSInteger const kLoadURLDataMaxConcurrentOperationCount = 3;
NSInteger const kLoadFileDataMaxConcurrentOperationCount = 2;

typedef NS_ENUM(NSUInteger, AsyncDataLoadingResultMethodType) {
    AsyncDataLoadingImage,
    AsyncDataLoadingData,
    AsyncDataLoadingUrl
};

@interface ImagesLoadingAndSavingManager () <NSURLConnectionDataDelegate>

@property (strong, nonatomic) NSMutableData *downloadingWithProgressImageData;
@property (assign, nonatomic) NSInteger downloadingWithProgressFileTotalBytes;
@property (assign, nonatomic) NSInteger downloadingWithProgressFileReceivedBytes;
@property (strong, nonatomic) NSURLConnection *downloadingWithProgressFileConnection;
@property (strong, nonatomic) NSIndexPath *downloadingWithProgressImageForIndexPath;
@property (assign, nonatomic) ServiceType downloadingWithProgressImageServiceType;

@property (strong, nonatomic) NSOperationQueue *loadURLDataQueue;
@property (strong, nonatomic) NSOperationQueue *loadFileDataQueue;

@end

@implementation ImagesLoadingAndSavingManager

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setup];
        
        self.downloadingWithProgressFileConnection = nil;
        self.downloadingWithProgressFileReceivedBytes = 0;
        self.downloadingWithProgressFileTotalBytes = 0;
        self.downloadingWithProgressImageData = nil;
        self.downloadingWithProgressImageForIndexPath = nil;
    }
    
    return self;
}


#pragma mark - Private Property

- (NSOperationQueue *)loadURLDataQueue {
    if (!_loadURLDataQueue) {
        _loadURLDataQueue = [[NSOperationQueue alloc] init];
        _loadURLDataQueue.maxConcurrentOperationCount = kLoadURLDataMaxConcurrentOperationCount;
        _loadURLDataQueue.qualityOfService = NSQualityOfServiceBackground;
    }
    return _loadURLDataQueue;
}

- (NSOperationQueue *)loadFileDataQueue {
    if (!_loadFileDataQueue) {
        _loadFileDataQueue = [[NSOperationQueue alloc] init];
        _loadFileDataQueue.maxConcurrentOperationCount = kLoadFileDataMaxConcurrentOperationCount;
        _loadFileDataQueue.qualityOfService = NSQualityOfServiceBackground;
    }
    return _loadFileDataQueue;
}


#pragma mark - Public

- (void)setup {
    [self createDirectoryForServiceType:ServiceTypeGIFs];
    [self createDirectoryForServiceType:ServiceTypeImoji];
    [self createDirectoryForServiceType:ServiceTypeMojiSM];
    [self createDirectoryForServiceType:ServiceTypeYelp];
    [self createDirectoryForServiceType:ServiceTypeDropBox];
    [self createDirectoryForServiceType:ServiceTypeGoogleDrive];
    [self createDirectoryForServiceType:ServiceTypeInstagram];
    [self createDirectoryForServiceType:ServiceTypeFacebook];
    [self createDirectoryForServiceType:ServiceTypeSpotify];
    [self createDirectoryForServiceType:ServiceTypeYoutube];
    [self createDirectoryForServiceType:ServiceTypeTwitter];
    [self createDirectoryForServiceType:ServiceTypeEbay];
    [self createDirectoryForServiceType:ServiceTypeImageDrawing];
    [self createDirectoryForServiceType:ServiceTypeMemes];
    [self createDirectoryForServiceType:ServiceTypeSounds];
    [self createDirectoryForServiceType:ServiceTypeRecentShared];
    [self createDirectoryForServiceType:ServiceTypeFeed];
    [self createDirectoryForServiceType:ServiceTypeGifCamera];
}

- (UIImage *)loadImageIfItNotExistsByPath:(NSString *)imagePath byServiceType:(ServiceType)serviceType andSelectedIndex:(NSIndexPath *)indexPath {
    UIImage *image = [self getImageByPath:imagePath andServiceType:serviceType];
    if (image) {
        return image;
    }
    
    [self asyncLoadDataByUrlPath:imagePath byServiceType:serviceType andSelectedIndex:indexPath withResultMethodType:AsyncDataLoadingImage];
    return nil;
}

- (UIImage *)loadSyncImageIfItNotExistsByPath:(NSString *)imagePath byServiceType:(ServiceType)serviceType andSelectedIndex:(NSIndexPath *)indexPath {
    UIImage *image = [UIImage imageWithContentsOfFile:[ImagesLoadingAndSavingManager fullFilePathForServiceType:serviceType imagePath:imagePath]];
    
    if (image) {
        return image;
    }
    
    NSURL *imageUrl = [NSURL URLWithString:imagePath];
    NSData *data = [NSData dataWithContentsOfURL:imageUrl];
    
    [ImagesLoadingAndSavingManager saveToFileData:data withFileName:[ImagesLoadingAndSavingManager fileNameByType:serviceType andImagePath:imagePath] forServiceType:serviceType];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL doesFileExist = [self existsFileAtPath:[NSString stringWithFormat:@"%@%@/%@", [ImagesLoadingAndSavingManager directoryPathForServiceType:serviceType], [ImagesLoadingAndSavingManager subdirectoryForServiceType:serviceType], [ImagesLoadingAndSavingManager fileNameByType:serviceType andImagePath:imagePath]]];
        
        if (doesFileExist) {
            if ([self.delegate respondsToSelector:@selector(image:wasLoadedByIndexPath:)]) {
                [self.delegate image:[UIImage imageWithData:data] wasLoadedByIndexPath:indexPath];
            }
        }
    });
    
    return nil;
}

- (NSData *)loadDataIfItNotExistsByPath:(NSString *)imagePath byServiceType:(ServiceType)serviceType andSelectedIndex:(NSIndexPath *)indexPath andType:(ImageDownloadingType)type {
    NSData *fileData = [self getDataByPath:imagePath andServiceType:serviceType];
    if (fileData) {
        return fileData;
    }
    
    if (type == ImageAsynchronicallySimpleDownload) {
        [self asyncLoadDataByUrlPath:imagePath byServiceType:serviceType andSelectedIndex:indexPath withResultMethodType:AsyncDataLoadingData];
    } else if (type == ImageBlockingDownload) {
        NSURL *imageUrl = [NSURL URLWithString:imagePath];
        
        NSData *data = [NSData dataWithContentsOfURL:imageUrl];
        [ImagesLoadingAndSavingManager saveToFileData:data withFileName:[ImagesLoadingAndSavingManager fileNameByType:serviceType andImagePath:imagePath] forServiceType:serviceType];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL doesFileExist = [self existsFileAtPath:[ImagesLoadingAndSavingManager fullFilePathForServiceType:serviceType imagePath:imagePath]];
            
            if (doesFileExist) {
                if ([self.delegate respondsToSelector:@selector(imageData:wasLoadedByIndexPath:)]) {
                    [self.delegate imageData:data wasLoadedByIndexPath:indexPath];
                }
            }
        });
    } else {
        if (self.downloadingWithProgressFileConnection) {
            [self cancelAllAsynchronicalWithProgressObservingDownloads];
        }
        
        self.downloadingWithProgressImageForIndexPath = indexPath;
        self.downloadingWithProgressImageServiceType = serviceType;
        
        NSURL *imageUrl = [NSURL URLWithString:imagePath];
        NSURLRequest *request = [NSURLRequest requestWithURL:imageUrl];
        self.downloadingWithProgressFileConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    }
    
    return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    self.downloadingWithProgressFileTotalBytes = (NSInteger)httpResponse.expectedContentLength;
    if (self.downloadingWithProgressFileTotalBytes == NSURLResponseUnknownLength) {
        self.downloadingWithProgressImageData = [[NSMutableData alloc] init];
    } else if (self.downloadingWithProgressFileTotalBytes > 0) {
        self.downloadingWithProgressImageData = [[NSMutableData alloc] initWithCapacity:self.downloadingWithProgressFileTotalBytes];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (self.downloadingWithProgressImageData) {
        [self.downloadingWithProgressImageData appendData:data];
    }
    self.downloadingWithProgressFileReceivedBytes += data.length;
    
    if ((self.delegate) && ([self.delegate respondsToSelector:@selector(imageAtIndexPath:downloadingProgressChangedTo:)])) {
        float progress = self.downloadingWithProgressFileReceivedBytes / (float)self.downloadingWithProgressFileTotalBytes;
        if (self.downloadingWithProgressFileTotalBytes == NSURLResponseUnknownLength) {
            progress = 1; // TODO: Fail progress for NSURLResponseUnknownLength
        }
        [self.delegate imageAtIndexPath:self.downloadingWithProgressImageForIndexPath downloadingProgressChangedTo:progress];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *fileName = [ImagesLoadingAndSavingManager fileNameByType:self.downloadingWithProgressImageServiceType andImagePath:connection.originalRequest.URL.absoluteString];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul);
    dispatch_async(queue, ^{
        [ImagesLoadingAndSavingManager saveToFileData:self.downloadingWithProgressImageData withFileName:fileName forServiceType:self.downloadingWithProgressImageServiceType];
        
        BOOL doesFileExist = [self existsFileAtPath:[NSString stringWithFormat:@"%@%@/%@", [ImagesLoadingAndSavingManager documentsDirectoryPath], [ImagesLoadingAndSavingManager subdirectoryForServiceType:self.downloadingWithProgressImageServiceType], fileName]];
        if (doesFileExist) {
            if ([self.delegate respondsToSelector:@selector(imageData:wasLoadedByIndexPath:)]) {
                [self.delegate imageData:self.downloadingWithProgressImageData wasLoadedByIndexPath:self.downloadingWithProgressImageForIndexPath];
            }
        }
    });
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.downloadingWithProgressFileConnection = nil;
    self.downloadingWithProgressFileReceivedBytes = 0;
    self.downloadingWithProgressFileTotalBytes = 0;
    self.downloadingWithProgressImageData = nil;
    self.downloadingWithProgressImageForIndexPath = nil;
    
    if ([self.delegate respondsToSelector:@selector(image:wasLoadedByIndexPath:)]) {
        [self.delegate image:nil wasLoadedByIndexPath:self.downloadingWithProgressImageForIndexPath];
    }
    if ([self.delegate respondsToSelector:@selector(imageData:wasLoadedByIndexPath:)]) {
        [self.delegate imageData:nil wasLoadedByIndexPath:self.downloadingWithProgressImageForIndexPath];
    }
    if ([self.delegate respondsToSelector:@selector(imageUrl:wasLoadedByIndexPath:)]) {
        [self.delegate imageUrl:nil wasLoadedByIndexPath:self.downloadingWithProgressImageForIndexPath];
    }
}

- (void)cancelAllAsynchronicalWithProgressObservingDownloads {
    if (self.downloadingWithProgressFileConnection) {
        [self.downloadingWithProgressFileConnection cancel];
    }
    
    self.downloadingWithProgressFileConnection = nil;
    self.downloadingWithProgressFileReceivedBytes = 0;
    self.downloadingWithProgressFileTotalBytes = 0;
    self.downloadingWithProgressImageData = nil;
    self.downloadingWithProgressImageForIndexPath = nil;
}

- (BOOL)existsFileAtPath:(NSString *)path {
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

- (UIImage *)getImageByPath:(NSString *)imagePath andServiceType:(ServiceType)serviceType {
    UIImage *image = [UIImage imageWithContentsOfFile:[ImagesLoadingAndSavingManager fullFilePathForServiceType:serviceType imagePath:imagePath]];
    return image;
}

- (NSData *)getDataByPath:(NSString *)imagePath andServiceType:(ServiceType)serviceType {
    NSData *imageData = [NSData dataWithContentsOfFile:[ImagesLoadingAndSavingManager fullFilePathForServiceType:serviceType imagePath:imagePath]];
    return imageData;
}


#pragma mark - Load & Save Images

- (void)asyncLoadDataByUrlPath:(NSString *)imagePath byServiceType:(ServiceType)serviceType andSelectedIndex:(NSIndexPath *)indexPath withResultMethodType:(AsyncDataLoadingResultMethodType)resultMethodType {
    NSURL *imageUrl = [NSURL URLWithString:imagePath];
    
    __weak typeof(self) weakSelf = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0ul);
    dispatch_async(queue, ^{
        NSData *data = [NSData dataWithContentsOfURL:imageUrl];
        [ImagesLoadingAndSavingManager saveToFileData:data withFileName:[ImagesLoadingAndSavingManager fileNameByType:serviceType andImagePath:imagePath] forServiceType:serviceType];
        NSString *fileLocalPath = [ImagesLoadingAndSavingManager fullFilePathForServiceType:serviceType imagePath:imagePath];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL doesFileExist = [weakSelf existsFileAtPath:fileLocalPath];
            
            if (doesFileExist) {
                if ((resultMethodType == AsyncDataLoadingImage) && ([weakSelf.delegate respondsToSelector:@selector(image:wasLoadedByIndexPath:)])) {
                    [weakSelf.delegate image:[UIImage imageWithData:data] wasLoadedByIndexPath:indexPath];
                }
                if ((resultMethodType == AsyncDataLoadingData) && ([weakSelf.delegate respondsToSelector:@selector(imageData:wasLoadedByIndexPath:)])) {
                    [weakSelf.delegate imageData:data wasLoadedByIndexPath:indexPath];
                }
                if ((resultMethodType == AsyncDataLoadingUrl) && ([weakSelf.delegate respondsToSelector:@selector(imageUrl:wasLoadedByIndexPath:)])) {
                    [weakSelf.delegate imageUrl:[NSURL fileURLWithPath:fileLocalPath] wasLoadedByIndexPath:indexPath];
                }
            }
        });
    });
}

+ (NSString *)subdirectoryForServiceType:(ServiceType)type {
    switch (type) {
            case ServiceTypeGIFs:
            return @"/GIF";
            
            case ServiceTypeImoji:
            return @"/IMOJI";
            
            case ServiceTypeMojiSM:
            return @"/MOJISM";
            
            case ServiceTypeYelp:
            return @"/YELP";
            
            case ServiceTypeDropBox:
            return @"/DROPBOX";
            
            case ServiceTypeGoogleDrive:
            return @"/GOOGLEDRIVE";
            
            case ServiceTypeInstagram:
            return @"/INSTAGRAM";
            
            case ServiceTypeFacebook:
            return @"/FACEBOOK";
            
            case ServiceTypeSpotify:
            return @"/SPOTIFY";
            
            case ServiceTypeYoutube:
            return @"/YOUTUBE";
            
            case ServiceTypeTwitter:
            return @"/TWITTER";
            
            case ServiceTypeEbay:
            return @"/EBAY";
            
            case ServiceTypeImageDrawing:
            return @"/IMAGE_DRAW";
            
            case ServiceTypeMemes:
            return @"/MEMES";
            
            case ServiceTypeSounds:
            return @"/SOUNDS";
            
            case ServiceTypeRecentShared:
            return @"/RECENT_SHARED";
            
            case ServiceTypeFeed:
            return @"/FEED";
            
            case ServiceTypeGifCamera:
            return @"/GIFCAMERA";
            
            case ServiceTypeCamFind:
            return @"/CAMFIND";
            
        default:
            break;
    }
}

+ (NSString *)fileNameByType:(ServiceType)type andImagePath:(NSString *)imagePath {
    NSArray *pathComponents = [imagePath componentsSeparatedByString:@"/"];
    
    switch (type) {
            case ServiceTypeGIFs:
            case ServiceTypeImoji:
            case ServiceTypeMojiSM:
            case ServiceTypeYoutube:
            case ServiceTypeTwitter:
            case ServiceTypeEbay:
            case ServiceTypeMemes:
            case ServiceTypeGoogleDrive:
            case ServiceTypeFacebook:
            case ServiceTypeSpotify:
            case ServiceTypeSounds:
            case ServiceTypeRecentShared:
            case ServiceTypeImageDrawing:
            case ServiceTypeFeed:
            case ServiceTypeInstagram:
            case ServiceTypeGifCamera:
            if (pathComponents.count >= 3) {
                return [NSString stringWithFormat:@"%@%@%@", pathComponents[pathComponents.count - 3], pathComponents[pathComponents.count - 2], pathComponents.lastObject];
            } else if (pathComponents.count >= 2) {
                return [NSString stringWithFormat:@"%@%@", pathComponents[pathComponents.count - 2], pathComponents.lastObject];
            } else {
                return [NSString stringWithFormat:@"%@", pathComponents.lastObject];
            }
            
            case ServiceTypeYelp:
            if ([imagePath containsString:@"/bphoto"]) {
                return [NSString stringWithFormat:@"%@%@", pathComponents[pathComponents.count - 2], pathComponents.lastObject];
            } else {
                return [NSString stringWithFormat:@"%@", pathComponents.lastObject];
            }
            
            case ServiceTypeDropBox:
            return @"/DROPBOX";
            
        default:
            return nil;
    }
}

+ (NSString *)pathToFolderForServiceType:(ServiceType)serviceType {
    return [NSString stringWithFormat:@"%@%@", [self directoryPathForServiceType:serviceType], [self subdirectoryForServiceType:serviceType]];
}

+ (NSString *)pathToFileName:(NSString *)fileName forServiceType:(ServiceType)serviceType {
    return [ImagesLoadingAndSavingManager fullFilePathForServiceType:serviceType imagePath:fileName];
}

- (NSURL *)getCachedUrlByPath:(NSString *)imagePath andServiceType:(ServiceType)serviceType {
    NSString *localPath = [ImagesLoadingAndSavingManager fullFilePathForServiceType:serviceType imagePath:imagePath];
    return ([self existsFileAtPath:localPath] ? [NSURL fileURLWithPath:localPath] : nil);
}

- (NSURL *)loadCachedUrlIfItNotExistsByPath:(NSString *)imagePath byServiceType:(ServiceType) serviceType andSelectedIndex:(NSIndexPath *)indexPath {
    NSURL *fileUrl = [self getCachedUrlByPath:imagePath andServiceType:serviceType];
    if (fileUrl) {
        return fileUrl;
    }
    
    [self asyncLoadDataByUrlPath:imagePath byServiceType:serviceType andSelectedIndex:indexPath withResultMethodType:AsyncDataLoadingUrl];
    return nil;
}


#pragma mark - Help Methods For Work With NSFileManager

- (void)showContentsOfDirrectoryForServiceType:(ServiceType)serviceType {
    if (kImagesLoadingAndSavingManagerLogEnabled) {
        NSString *dirrectoryPath = [[self class] subdirectoryForServiceType:serviceType];
        NSError *error = nil;
        NSString *path = [ImagesLoadingAndSavingManager directoryPathForServiceType:serviceType];
        if (dirrectoryPath) {
            path = [path stringByAppendingString:dirrectoryPath];
        }
        NSLog(@"Documents directory with Path: %@: andContent:%@", dirrectoryPath, [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error]);
    }
}

- (void)createDirectoryForServiceType:(ServiceType)serviceType {
    NSString *path = [ImagesLoadingAndSavingManager directoryPathForServiceType:serviceType];
    path = [path stringByAppendingString:[ImagesLoadingAndSavingManager subdirectoryForServiceType:serviceType]];
    
    NSError *error;
    if (![self existsFileAtPath:path]) {
        if (![[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:NO attributes:nil error:&error]) {
            NSLog(@"Create directory error: %@", error);
        } else {
            NSLog(@"Folder succesfully created at Path: %@", path);
        }
    }
}

+ (void)clearCacheForServiceType:(ServiceType)serviceType {
    NSString *path = [ImagesLoadingAndSavingManager directoryPathForServiceType:serviceType];
    path = [path stringByAppendingString:[ImagesLoadingAndSavingManager subdirectoryForServiceType:serviceType]];
    
    NSArray *fileNamesArray = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    if (fileNamesArray) {
        for (NSString *fileName in fileNamesArray) {
            [[NSFileManager defaultManager] removeItemAtPath:[path stringByAppendingPathComponent:fileName] error:nil];
        }
    }
}

- (void)removeFileOrDirrectoryByPath:(NSString *)filePath {
    NSString *path = [ImagesLoadingAndSavingManager documentsDirectoryPath];
    path = [path stringByAppendingString:filePath];
    
    NSError *error = nil;
    if ([self existsFileAtPath:path]) {
        if (![[NSFileManager defaultManager] removeItemAtPath:path error:&error]) {
            NSLog(@"Delete file error: %@", error);
        } else {
            NSLog(@"Folder succesfully deleted at Path: %@", path);
        }
    } else {
        NSLog(@"The is no file file by this path");
    }
}

+(void) saveToFileData:(NSData *)data withFileName:(NSString *)fileName forServiceType:(ServiceType)serviceType
{
    NSString *path = [ImagesLoadingAndSavingManager fullFilePathForServiceType:serviceType imagePath:fileName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path])
    {
        NSLog(@"saveToFileData: deleted old file at same path");
        [[NSFileManager defaultManager] removeItemAtPath:path error:NULL];
    }
    
    if (![[NSFileManager defaultManager] isWritableFileAtPath:path])
    {
        // FIXME: we can not use createDirectoryForServiceType because ATM we are using class method
        NSString *path = [ImagesLoadingAndSavingManager directoryPathForServiceType:serviceType];
        path = [path stringByAppendingString:[ImagesLoadingAndSavingManager subdirectoryForServiceType:serviceType]];
        
        NSError *error = NULL;
        if ([[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error])
            NSLog(@"Folder succesfully created at Path: %@", path);
        else
            NSLog(@"Create directory error: %@", error);
    }
    
    if ([data writeToFile:path atomically:YES])
    {
        if (![[NSFileManager defaultManager] isReadableFileAtPath:path])
            NSLog(@"Error on read saved data %s on line %i", __FILE__, __LINE__);
    }
    else
        NSLog(@"Error on save data %s on line %i", __FILE__, __LINE__);
}

+ (NSData *)dataByFilePath:(NSString *)filePath serviceType:(ServiceType)serviceType {
    NSString *path = [self fullFilePathForServiceType:serviceType imagePath:filePath];
    return [NSData dataWithContentsOfFile:path];
}

+ (void)removeDataByFilePath:(NSString *)filePath serviceType:(ServiceType)serviceType {
    NSString *path = [self fullFilePathForServiceType:serviceType imagePath:filePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
    }
}

+ (NSString *)directoryPathForServiceType:(ServiceType)serviceType
{
    NSString *path = nil;
    if (serviceType == ServiceTypeRecentShared)
    {
        NSURL *url = [self sharedContainerURL];
        if (url)
            path = [url path];
    }
    else
    {
        path = [self documentsDirectoryPath];
    }
    return path;
}

+ (NSString *)documentsDirectoryPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    return path;
}

+ (NSString *)fullFilePathForServiceType:(ServiceType)serviceType imagePath:(NSString *)imagePath {
    return [NSString stringWithFormat:@"%@%@/%@", [ImagesLoadingAndSavingManager directoryPathForServiceType:serviceType], [ImagesLoadingAndSavingManager subdirectoryForServiceType:serviceType], [ImagesLoadingAndSavingManager fileNameByType:serviceType andImagePath:imagePath]];
}

+ (NSURL *)sharedContainerURL {
    return [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:kUserDefaultsSuiteName];
}


#pragma mark - New methods Private

- (void)finishLoadData:(NSData *)data dataType:(DataType)dataType indexPath:(NSIndexPath *)indexPath fromCache:(BOOL)fromCache {
    switch (dataType) {
        case DataTypePNG: {
            UIImage *image = [UIImage imageWithData:data];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(dataLoadingManagerDidLoadImage:forIndexPath:fromCache:)]) {
                    [self.delegate dataLoadingManagerDidLoadImage:image forIndexPath:indexPath fromCache:fromCache];
                }
            });
        }   break;
            
        case DataTypeGIF:
        case DataTypeVideo:
        case DataTypeUnknown:
        default: {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self.delegate respondsToSelector:@selector(dataLoadingManagerDidLoadData:forIndexPath:fromCache:)]) {
                    [self.delegate dataLoadingManagerDidLoadData:data forIndexPath:indexPath fromCache:fromCache];
                }
            });
        }   break;
    }
}

- (void)loadDataWithURLString:(NSString *)urlString dataType:(DataType)dataType completion:(void (^)(id data, BOOL fromCache))completion {
    NSString *filePath = [ImagesLoadingAndSavingManager fullFilePathForServiceType:self.serviceType imagePath:urlString];
    
    BOOL exists = [self existsFileAtPath:filePath];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (exists) {
            id result = nil;
            if (filePath) {
                NSData *data = [NSData dataWithContentsOfFile:filePath];
                if (dataType == DataTypePNG && data) {
                    result = [UIImage imageWithData:data];
                } else {
                    result = data;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(result, YES);
                }
            });
        } else {
            id result = nil;
            if (urlString) {
                NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
                if (data) {
                    [data writeToFile:filePath atomically:YES];
                    
                    if (dataType == DataTypePNG) {
                        result = [UIImage imageWithData:data];
                    } else {
                        result = data;
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(result, NO);
                }
            });
        }
    });
}


#pragma mark - New methods

- (BOOL)existsDataWithURLString:(NSString *)urlString {
    return [self existsFileAtPath:[[self class] fullFilePathForServiceType:self.serviceType imagePath:urlString]];
}

- (void)addLoadImageWithURLString:(NSString *)urlString indexPath:(NSIndexPath *)indexPath {
    [self addLoadDataWithURLString:urlString serviceType:self.serviceType dataType:DataTypePNG indexPath:indexPath];
}

- (void)addLoadDataWithURLString:(NSString *)urlString indexPath:(NSIndexPath *)indexPath {
    [self addLoadDataWithURLString:urlString serviceType:self.serviceType dataType:DataTypeUnknown indexPath:indexPath];
}

- (void)addLoadDataWithURLString:(NSString *)urlString serviceType:(ServiceType)serviceType dataType:(DataType)dataType indexPath:(NSIndexPath *)indexPath {
    NSString *filePath = [[self class] fullFilePathForServiceType:serviceType imagePath:urlString];
    
    BOOL exists = [self existsFileAtPath:filePath];
    if (exists) {
        NSArray *operations = self.loadFileDataQueue.operations;
        for (LoadFileDataOperation *operation in operations) {
            if ([operation.filePath isEqualToString:filePath] && (!indexPath || (indexPath && [operation.indexPath isEqual:indexPath]))) {
                return;
            }
        }
        
        LoadFileDataOperation *operation = [[LoadFileDataOperation alloc] initWithFilePath:filePath indexPath:indexPath];
        
        __weak __typeof(self)weakSelf = self;
        operation.willCompletionBlock = ^(NSData *data) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (strongSelf) {
                [strongSelf finishLoadData:data dataType:dataType indexPath:indexPath fromCache:YES];
            }
        };
        
        [self.loadFileDataQueue addOperation:operation];
    } else {
        NSArray *operations = self.loadURLDataQueue.operations;
        for (LoadURLDataOperation *operation in operations) {
            if ([operation.urlString isEqualToString:urlString] && (!indexPath || (indexPath && [operation.indexPath isEqual:indexPath]))) {
                return;
            }
        }
        
        LoadURLDataOperation *operation = [[LoadURLDataOperation alloc] initWithURLSting:urlString indexPath:indexPath];
        
        __weak __typeof(self)weakSelf = self;
        operation.willCompletionBlock = ^(NSData *data) {
            __strong __typeof(weakSelf)strongSelf = weakSelf;
            if (strongSelf) {
                [data writeToFile:filePath atomically:YES];
                
                [strongSelf finishLoadData:data dataType:dataType indexPath:indexPath fromCache:NO];
            }
        };
        
        [self.loadURLDataQueue addOperation:operation];
    }
}

- (void)loadImageWithURLString:(NSString *)urlString completion:(void (^)(UIImage *image, BOOL fromCache))completion {
    [self loadDataWithURLString:urlString dataType:DataTypePNG completion:^(id data, BOOL fromCache) {
        if (completion) {
            completion(data, fromCache);
        }
    }];
}

- (void)loadDataWithURLString:(NSString *)urlString completion:(void (^)(NSData *data, BOOL fromCache))completion {
    [self loadDataWithURLString:urlString dataType:DataTypeUnknown completion:^(id data, BOOL fromCache) {
        if (completion) {
            completion(data, fromCache);
        }
    }];
}

@end
