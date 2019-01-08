//
//  AutoCorrectionView.h
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 20.01.16.
//
//

#import <UIKit/UIKit.h>
#import "ThemeChangesResponderProtocol.h"
#import "AppsLineView.h"

extern CGFloat const kAutoCorrectionViewHeight;

@protocol AutoCorrectionViewDelegate;

@interface AutoCorrectionView : UIView <ThemeChangesResponderProtocol>

@property (weak, nonatomic) id<AutoCorrectionViewDelegate> delegate;
@property (assign, nonatomic) BOOL isAutoCorrect;
@property (assign, nonatomic) BOOL isAutoCapitalize;
@property (assign, nonatomic) BOOL isFullAccess;
@property (strong, nonatomic) NSString *text;
@property (strong, nonatomic) AppsLineView *appsLine;
@property (strong, nonatomic, readonly) NSString *correction;
@property (strong, nonatomic, readonly) NSCharacterSet *separatorCharacterSet;

- (void)createCorrectionData;
- (void)clearCorrectionData;

- (void)setHidden:(BOOL)hidden animation:(BOOL)animation;
- (void)addSeparate;

- (BOOL)checkNeedSeparateText:(NSString *)text before:(NSString *)before after:(NSString *)after;

@end

@protocol AutoCorrectionViewDelegate <NSObject>

@optional
- (void)autoCorrectionView:(AutoCorrectionView *)autoCorrectionView didSelectString:(NSString *)selectedString;
- (void)autoCorrectionView:(AutoCorrectionView *)autoCorrectionView didReplaceString:(NSString *)replaceString toString:(NSString *)toString;

@end
