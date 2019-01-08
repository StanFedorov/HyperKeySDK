//
//  BaseCollectionViewCell.m
//  Better Word
//
//  Created by Maxim Popov popovme@gmail.com on 07.11.16.
//
//

#import "BaseCollectionViewCell.h"

NSTimeInterval const kBaseCollectionViewCellHideReportInterval = 5;
NSTimeInterval const kBaseCollectionViewCellAnimationDuration = 0.3;

@interface BaseCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *reportButton;

@property (strong, nonatomic) NSTimer *reportTimer;

@end

@implementation BaseCollectionViewCell

#pragma mark - Override

- (void)dealloc {
    [self removeReportTimer];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    if (self.reportButton) {
        self.reportButton.alpha = 0;
        [self.reportButton addTarget:self action:@selector(actionReport) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    if (self.reportButton) {
        self.reportButton.alpha = 0;
        
        [self removeReportTimer];
    }
}

- (void)showReportButton {
    if (self.reportButton.alpha == 0) {
        [self addReportTimer];
        
        [UIView animateWithDuration:kBaseCollectionViewCellAnimationDuration animations:^{
            self.reportButton.alpha = 1;
        }];
    }
}

- (void)hideReportButton {
    if (self.reportButton.alpha > 0) {
        [UIView animateWithDuration:kBaseCollectionViewCellAnimationDuration animations:^{
            self.reportButton.alpha = 0;
        }];
    }
}


#pragma mark - Actions

- (void)actionReport {
    if ([self.delegate respondsToSelector:@selector(baseCollectionViewCellDidReport:)]) {
        [self.delegate baseCollectionViewCellDidReport:self];
    }
}

- (void)actionReportTimer {
    [self hideReportButton];
}


#pragma mark - Report Timer

- (void)removeReportTimer {
    if (self.reportTimer) {
        [self.reportTimer invalidate];
        self.reportTimer = nil;
    }
}

- (void)addReportTimer {
    [self removeReportTimer];
    
    self.reportTimer = [NSTimer scheduledTimerWithTimeInterval:kBaseCollectionViewCellHideReportInterval target:self selector:@selector(actionReportTimer) userInfo:nil repeats:NO];
}

@end
