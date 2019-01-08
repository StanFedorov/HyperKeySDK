//
//  GTViewController.m
//  Better Word
//
//  Created by Sergey Vinogradov on 06.01.16.
//
//

#import "GTViewController.h"

#import "HKStreachableLabel.h"
#import "Config.h"
#import "GTMNSString+HTML.h"

CGFloat const kGTPasteButtonAnimationDuration = 0.5;

NSString *const kGTEmptyAnswer = @"Get empty answer from Google";
NSString *const kGTErrorAnswer = @"Error in translation";

NSString *const kGTUserDefaultsKeyToLangLang = @"GTRTranslateToLangLanguage";
NSString *const kGTUserDefaultsKeyToLangName = @"GTRTranslateToLangName";
NSString *const kGTUserDefaultsKeySecondStart = @"GTRFirstStartAlreadyPerformed";

NSString *const kGTEnLang = @"en";
NSString *const kGTKeyPathCS = @"contentSize";

NSString *const kGTKey = @"AIzaSyCA1X4K_WwGfMLc1z8Z6mf5EyWgn26zQWI";
NSString *const kGTLangListLang = @"language";
NSString *const kGTLangListName = @"name";

@interface GTViewController () <UIPickerViewDataSource, UIPickerViewDelegate, StrechableLabelDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIButton *changeLangButton;
@property (strong, nonatomic) IBOutlet UIButton *pasteTextButton;
@property (strong, nonatomic) IBOutlet UIPickerView *langPicker;
@property (strong, nonatomic) IBOutlet UIScrollView *shortTRScrollView;
@property (strong, nonatomic) IBOutlet HKStreachableLabel *streachableLabel;

@property (strong, nonatomic) NSString *langLang;
@property (strong, nonatomic) NSString *langName;
@property (strong, nonatomic) NSString *langPasteboard;

@property (strong, nonatomic) NSString *pasteboardContent;
@property (strong, nonatomic) NSString *translatedPasteboardContent;
@property (strong, nonatomic) NSTimer *pasteboardCheckTimer;
@property (assign, nonatomic) NSUInteger pasteboardchangeCount;
@property (strong, nonatomic) NSArray *pasteboardTypes;

@end

@implementation GTViewController

@synthesize delegate;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.textView addObserver:self forKeyPath:kGTKeyPathCS options:(NSKeyValueObservingOptionNew) context:NULL];
    [self hidePasteButton];
    
    [self loadDefaults];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self loadLanguages];
    });
    
    self.changeLangButton.layer.cornerRadius = 5;
    self.textView.layer.cornerRadius = 5;
    self.pasteboardchangeCount = [UIPasteboard generalPasteboard].changeCount;
    self.pasteboardTypes = @[@"public.utf8-plain-text", @"public.text"];
}

- (void)viewDidAppear:(BOOL)animated { //viewViewAppear: - did not start
    [super viewDidAppear:animated];
    
    // Start monitoring the paste board
    self.pasteboardCheckTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(monitorBoard:) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // Stop watch on the paste board
    [self.pasteboardCheckTimer invalidate];
    self.pasteboardCheckTimer = nil;
}

- (void)loadDefaults {
    NSUserDefaults *defaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    self.langLang = [defaults objectForKey:kGTUserDefaultsKeyToLangLang];
    self.langName = [defaults objectForKey:kGTUserDefaultsKeyToLangName];
    
    id theSecondStart = [defaults objectForKey:kGTUserDefaultsKeySecondStart];
    
    self.isItFirstStart = (theSecondStart) ? NO : YES;
    
    if (!self.langLang) {
        self.langLang = @"es";
        self.langName = @"  Spanish  ";
        [self saveSelectedLang];
    }
    
    [self.changeLangButton setTitle:self.langName forState:UIControlStateNormal];
    self.textView.text = @"Translate text into a different language as you type. Or copy text to get an English translation";
    self.streachableLabel.text = [NSString stringWithFormat:@"English >%@", self.langName];
}

- (void)loadLanguages {
    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"glanguages" ofType:@"plist"];
    self.languagesList = [NSArray arrayWithContentsOfFile:sourcePath];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.langPicker reloadAllComponents];
    });
}

- (void)saveSelectedLang {
    if (self.originText && self.originText.length) {
        [self translateOriginText];
    }
    
    NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
    [defaults setObject:self.langLang forKey:kGTUserDefaultsKeyToLangLang];
    [defaults setObject:self.langName forKey:kGTUserDefaultsKeyToLangName];
    [defaults synchronize];
}

- (IBAction)iconButtonTapped:(id)sender {
    [self.delegate functionButton:sender];
}

- (IBAction)replaceOriginTextToTranslated:(id)sender {
    
    if ([self.delegate respondsToSelector:@selector(changeOriginText:forTranslatedText:)]) {
        NSString *originText = self.isItTranslatedPasteboard ? nil : self.originText;
        NSString *translatedText = self.isItTranslatedPasteboard ? self.translatedPasteboardContent : self.translatedText;
        [self.delegate changeOriginText:originText forTranslatedText:translatedText];
    }
}

- (IBAction)changeLanguage:(id)sender {
    if (!self.langPicker.hidden) {
        if ([self.delegate respondsToSelector:@selector(showKeyboard)]) {
            [self.delegate showKeyboard];
        }
        
        self.streachableLabel.text = [NSString stringWithFormat:@"English >%@", self.langName];
        
        if (self.translatedText) {
            self.pasteTextButton.hidden = NO;
        }
        
        self.textView.hidden = NO;
        self.shortTRScrollView.hidden = NO;
        
        [UIView animateWithDuration:0.5 animations:^{
            if (self.translatedText) {
                self.pasteTextButton.alpha = 1.0;
            }
            self.textView.alpha = 1.0;
            self.shortTRScrollView.alpha = 1.0;
            self.langPicker.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.langPicker.hidden = YES;
        }];
    } else {
        if ([self.delegate respondsToSelector:@selector(hideKeyboard)]) {
            [self.delegate hideKeyboard];
        }
        
        self.langPicker.alpha = 0.0;
        self.langPicker.hidden = NO;
        
        [UIView animateWithDuration:0.5 animations:^{
            self.pasteTextButton.alpha = 0.0;
            self.textView.alpha = 0.0;
            self.shortTRScrollView.alpha = 0.0;
            self.langPicker.alpha = 1.0;
        } completion:^(BOOL finished) {
            self.pasteTextButton.hidden = YES;
            self.textView.hidden = YES;
            self.shortTRScrollView.hidden = YES;
            [self forceUpdateLangSelector];
        }];
    }
}

- (void)checkLanguageSelector {
    if (self.iconButton.hidden) {
        [self changeLanguage:nil];
    }
}

- (NSInteger)indexForSelectedLang {
    NSInteger result = NSNotFound;
    
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(id  _Nonnull evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        NSString *lang = [evaluatedObject objectForKey:kGTLangListLang];
        return [lang isEqualToString:self.langLang];
    }];
    
    NSArray *arr = [self.languagesList filteredArrayUsingPredicate:predicate];
    if (arr.count) {
        result = [self.languagesList indexOfObject:arr.firstObject];
    }
    
    return result;
}

- (void)forceUpdateLangSelector {
    NSInteger index = [self indexForSelectedLang];
    if (index != NSNotFound) {
        [self.langPicker selectRow:index inComponent:0 animated:YES];
    }
}


#pragma mark - Private with text

- (void)setOriginText:(NSString *)originText {
    if (!originText) {
        return;
    }
    
    self.isItTranslatedPasteboard = NO;
    
    if (self.isItFirstStart && self.originText && originText && ![originText isEqualToString:self.originText]) {
        self.isItFirstStart = NO;
        
        NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:kUserDefaultsSuiteName];
        [defaults setBool:YES forKey:kGTUserDefaultsKeySecondStart];
        [defaults synchronize];
    }
    
    if (self.isItFirstStart) {
        _originText = originText;
        self.translatedText = nil;
    } else {
        if ([_originText isEqualToString:originText]) {
            return;
        }
        
        _originText = originText;
        if (_originText) {
            [self translateOriginText];
        }
    }
}

- (void)updateAfterTranslation {
    NSString *translatedString = (self.isItTranslatedPasteboard) ? self.translatedPasteboardContent : self.translatedText;
    
    if (translatedString && translatedString.length) {
        self.streachableLabel.text = translatedString;
        
        if ([translatedString isEqualToString:kGTEmptyAnswer] || [translatedString isEqualToString:kGTErrorAnswer]) {
            [self hidePasteButton];
            
            if (self.isItTranslatedPasteboard) {
                self.translatedPasteboardContent = @"";
            } else {
                self.translatedText = @"";
            }
        } else {
            self.textView.text = self.isItTranslatedPasteboard ? self.translatedPasteboardContent : self.translatedText;
            
            if (self.translatedText && ![self.translatedText isEqualToString:self.originText]) {
                [self showPasteButton];
            }
        }
    } else {
        if (self.isItTranslatedPasteboard) {
            self.translatedPasteboardContent = @"";
        } else {
            self.translatedText = @"";
        }
        
        [self hidePasteButton];
    }
    
    if ([self.delegate respondsToSelector:@selector(textDidTranslated:)]) {
        [self.delegate textDidTranslated:translatedString];
    }
}


#pragma mark - Google translation

- (void)tryToDetectLangAndTranslateToEnglish {
    self.isItTranslatedPasteboard = YES;
    
    NSString *urlString = [NSString stringWithFormat:@"https://www.googleapis.com/language/translate/v2/detect?key=%@&q=%@", kGTKey, self.pasteboardContent];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSError *parsingError;
        NSDictionary *dict = [self parseJsonFromData:data possibleError:parsingError];
        
        if (parsingError) {
            self.translatedText = @"Error in detect lang";
        }else{
            NSDictionary *dictData = [dict objectForKey:@"data"];
            NSArray *array = [dictData objectForKey:@"detections"];
            NSArray *first = [array firstObject];
            NSDictionary *second = [first firstObject];
            self.langPasteboard = [second objectForKey:@"language"];
            
            if (![self.langPasteboard isEqualToString:@"en"]) {
                [self translateOriginText];
            }
        }
    }];
}

- (void)translateOriginText {
    NSString *urlString = [NSString stringWithFormat:@"https://www.googleapis.com/language/translate/v2?key=%@&q=%@&source=%@&target=%@",
                           kGTKey,
                           (self.isItTranslatedPasteboard) ? self.pasteboardContent : self.originText,
                           (self.isItTranslatedPasteboard) ? self.langPasteboard : kGTEnLang,
                           (self.isItTranslatedPasteboard) ? kGTEnLang : self.langLang];
    
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        NSError *parsingError;
        NSDictionary *dict = [self parseJsonFromData:data possibleError:parsingError];
        
        if (parsingError) {
            self.translatedText = kGTErrorAnswer;
            [self hidePasteButton];
        } else {
            NSDictionary *dictData = [dict objectForKey:@"data"];
            NSArray *arrTranslations = [dictData objectForKey:@"translations"];
            NSString *translatedText = [[arrTranslations firstObject] objectForKey:@"translatedText"];
            
            if (translatedText) {
                translatedText = [translatedText gtm_stringByUnescapingFromHTML];
            } else {
                translatedText = kGTEmptyAnswer;
            }
            
            if (self.isItTranslatedPasteboard) {
                self.translatedPasteboardContent = translatedText;
            } else {
                self.translatedText = translatedText;
            }
            
            [self updateAfterTranslation];
        }
    }];
}

- (id)parseJsonFromData:(NSData *)data possibleError:(NSError *)parsingError {
    if (!data) {
        return @{@"error": @"Empty data"};
    }
    
    id object = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&parsingError];
    if (parsingError) {
        NSLog(@"Parsig error %@", parsingError.userInfo);
    }
    
    return object;
}


#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.languagesList count];
}


#pragma mark - UIPickerViewDataSource

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSDictionary *dict = [self.languagesList objectAtIndex:row];
    NSString *result = [dict objectForKey:kGTLangListName];
    return result;
}

- (nullable NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    NSDictionary *dict = [self.languagesList objectAtIndex:row];
    NSString *string = [dict objectForKey:kGTLangListName];
    NSDictionary *attribute = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    NSAttributedString *result = [[NSAttributedString alloc] initWithString:string attributes:attribute];
    return result;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSDictionary *dict = [self.languagesList objectAtIndex:row];
    self.langLang = [dict objectForKey:kGTLangListLang];
    self.langName = [NSString stringWithFormat:@"  %@  ", [dict objectForKey:kGTLangListName]];

    [self.changeLangButton setTitle:self.langName forState:UIControlStateNormal];
    [self saveSelectedLang];
}


#pragma mark - StrechableLabelDelegate

- (void)presetWidth:(CGFloat)prefWidth {
    CGFloat textWidth = prefWidth + 20;
    CGFloat scrollViewWidth = self.shortTRScrollView.frame.size.width;
    CGFloat height = self.shortTRScrollView.contentSize.height;
    CGPoint anOffset = CGPointZero;
    CGSize contentSize = CGSizeZero;
    
    self.shortTRScrollView.userInteractionEnabled = NO;
    
    if (textWidth > scrollViewWidth) {
        contentSize = CGSizeMake(textWidth, height);
        anOffset = CGPointMake(textWidth - scrollViewWidth, 0);
    } else {
        contentSize = CGSizeMake(scrollViewWidth, height);
    }
    
    self.shortTRScrollView.contentSize = contentSize;
    self.shortTRScrollView.userInteractionEnabled = YES;
    [self.shortTRScrollView setContentOffset:anOffset animated:NO];
}


#pragma mark - UITapGestureRecognizer

- (IBAction)tapToWholeText:(id)sender {
    [self replaceOriginTextToTranslated:sender];
}

- (IBAction)tapToPicker:(UITapGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:self.langPicker];
    CGFloat halfViewHeight = self.langPicker.frame.size.height / 2;
    CGFloat rowHeight = [self.langPicker rowSizeForComponent:0].height;
    
    if (location.y >= (halfViewHeight - rowHeight / 2) && location.y <= (halfViewHeight + rowHeight / 2)) {
        [self checkLanguageSelector];
    }
}


#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


#pragma mark - Background UIPasteboard periodical check

- (void)stopCheckingPasteboard {
    [self.pasteboardCheckTimer invalidate];
    self.pasteboardCheckTimer = nil;
}

- (void)monitorBoard:(NSTimer *)timer {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSUInteger changeCount = pasteboard.changeCount;
    if (changeCount != self.pasteboardchangeCount) { // Means pasteboard was changed
        self.pasteboardchangeCount = changeCount;
        // Check what is on the paste board
        if ([pasteboard containsPasteboardTypes:self.pasteboardTypes]){
            self.pasteboardContent = pasteboard.string;
            
            [self tryToDetectLangAndTranslateToEnglish];
        }
    }
}


#pragma mark - ObserveValueForKeyPath "contentSize"


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ((object == self.textView) && [keyPath isEqualToString:kGTKeyPathCS]) {
        UITextView *textView = object;
        CGFloat topCorrect = ([textView bounds].size.height - textView.contentSize.height * textView.zoomScale) / 2.0;
        topCorrect = topCorrect < 0.0 ? 0.0 : topCorrect;
        textView.contentInset = UIEdgeInsetsMake(topCorrect, 0, 0, 0);
    }
}

#pragma mark - Paste button animation

- (void)showPasteButton {
    if (!self.pasteTextButton.hidden) {
        return;
    }
    
    self.pasteTextButton.alpha = 0.0;
    self.pasteTextButton.hidden = NO;
    
    [UIView animateWithDuration:kGTPasteButtonAnimationDuration animations:^{
        self.pasteTextButton.alpha = 1.0;
    }];
}

- (void)hidePasteButton {
    if (self.pasteTextButton.hidden) {
        return;
    }
    
    [UIView animateWithDuration:kGTPasteButtonAnimationDuration animations:^{
        self.pasteTextButton.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.pasteTextButton.hidden = YES;
    }];
}

- (void)textInInputDidEnd {
    _originText = nil;
    self.translatedText = nil;
    self.streachableLabel.text =  @"";
    self.textView.text = @"";
    [self hidePasteButton];
}

@end
