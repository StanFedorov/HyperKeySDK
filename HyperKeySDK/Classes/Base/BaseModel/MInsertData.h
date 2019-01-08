//
//  MInsertData.h
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 27.09.16.
//
//

#import <Foundation/Foundation.h>
#import "Config.h"

@interface MInsertData : NSObject

@property (assign, nonatomic) FeatureType featureType;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *urlString;
@property (strong, nonatomic) NSString *branchChannel;
@property (strong, nonatomic) NSString *branchFeature; // Default "sharing"

@property (assign, nonatomic) BOOL useDescription; // Default YES

@end
