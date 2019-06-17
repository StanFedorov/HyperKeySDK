//
//  HoverView.m
//  Better Word
//
//  Created by Dmitriy Gonchar on 03.11.15.
//
//

#import "AuthView.h"

@interface AuthView ()
@property (weak,nonatomic) IBOutlet UIView *mainBg;
@property (weak,nonatomic) IBOutlet UIButton *settings;
@property (weak,nonatomic) IBOutlet UILabel *label1;
@property (weak,nonatomic) IBOutlet UILabel *label2;
@property (weak,nonatomic) IBOutlet UILabel *label3;
@property (weak,nonatomic) IBOutlet NSLayoutConstraint *paddingTop;
@end

@implementation AuthView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.mainBg.bounds;
    gradient.startPoint = CGPointMake(0, 1);
    gradient.endPoint = CGPointMake(1, 1);
    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithRed:46/255.0 green:144/255.0 blue:233/255.0 alpha:1.0] CGColor],(id)[[UIColor colorWithRed:0/255.0 green:105/255.0 blue:187/255.0 alpha:1.0] CGColor], nil];
    [self.mainBg.layer addSublayer:gradient];
    
    self.settings.layer.cornerRadius = 6;
    NSDictionary * linkAttributes1 = @{NSForegroundColorAttributeName:self.label3.textColor, NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)};
    NSAttributedString *attributedString1 = [[NSAttributedString alloc] initWithString:self.label3.text attributes:linkAttributes1];
    [self.label3 setAttributedText:attributedString1];
    
    self.label3.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openPolicy)];
    [self.label3 addGestureRecognizer:tapGesture];
}

- (void)openPolicy {
    UIResponder *responder = self;
    while ((responder = [responder nextResponder]) != nil) {
        if ([responder respondsToSelector:@selector(openURL:)] == YES) {
            [responder performSelector:@selector(openURL:) withObject:[NSURL URLWithString:@"http://hyperkey.com/privacy.html"]];
        }
    }
}

- (void)hideLine {
    self.paddingTop.constant = 0;
}

- (IBAction)openSettings:(id)sender {
    UIResponder *responder = self;
    while ((responder = [responder nextResponder]) != nil) {
        if ([responder respondsToSelector:@selector(openURL:)] == YES) {
            NSLog(@"%@",[NSString stringWithFormat:@"%@%@",UIApplicationOpenSettingsURLString,@"net.hyperkey"]);
            [responder performSelector:@selector(openURL:) withObject:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",UIApplicationOpenSettingsURLString,@"net.hyperkey"]]];
        }
    }
}

@end
