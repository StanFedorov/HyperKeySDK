//
//  DrawImageView.m
//  DrawImage
//
//  Created by Maxim Popov popovme@gmail.com on 23.12.15.
//  Copyright © 2015 Popovme. All rights reserved.
//

#import "DrawImageCanvasView.h"

#import "DrawImageMPoint.h"
#import "DrawImageConfig.h"
#import "Macroses.h"

NSInteger const kDrawImageCalculatePointCount = 4;
Float32 const kDrawImageStartFillInterval = 0.3;
Float32 const kDrawImageDrawFillInterval = 0.04;
Float32 const kDrawImageDrawFillIncrementFactor = 1.08;
Float32 const kDrawImageMaxDistanceForStartFill = 3;
Float32 const kDrawImageViewAspectFillSize = 640;

@interface DrawImageCanvasView ()

@property (strong, nonatomic) NSMutableArray *basePath;
@property (strong, nonatomic) NSMutableArray *path;
@property (assign, nonatomic) CGFloat lastWidth;
@property (strong, nonatomic) NSTimer *startFillTimer;
@property (strong, nonatomic) NSTimer *drawFillTimer;
@property (assign, nonatomic) CGFloat scaleFactor;
@property (assign, nonatomic) CGPoint fillPoint;
@property (assign, nonatomic) CGFloat fillRadius;
@property (assign, nonatomic) CGFloat fillIncrementRadius;

@end

@implementation DrawImageCanvasView

- (void)dealloc {
    [self removeStartFillTimer];
    [self removeDrawFillTimer];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialization];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initialization];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize aspectFillSize = self.aspectFillSize;
    CGFloat widthFactor = aspectFillSize.width / self.bounds.size.width;
    CGFloat heightFactor = aspectFillSize.height / self.bounds.size.height;
    
    self.scaleFactor = fmin(widthFactor, heightFactor);
}


#pragma mark - Initialization

- (void)initialization {
    self.backgroundColor = [UIColor whiteColor];
    self.contentMode = UIViewContentModeScaleAspectFill;
    
    self.basePath = [[NSMutableArray alloc] init];
    self.lastWidth = kDrawImageLineMinWidth;
    
    self.color = [UIColor blackColor];
    
    self.isEnabled = YES;
    
    // Data for testing
    /*[self drawToPoint:CGPointMake(20, 50)];
    [self drawToPoint:CGPointMake(25, 50)];
    [self drawToPoint:CGPointMake(35, 50)];
    [self drawToPoint:CGPointMake(50, 50)];
    [self drawToPoint:CGPointMake(70, 50)];
    [self drawToPoint:CGPointMake(95, 50)];
    [self drawToPoint:CGPointMake(125, 50)];
    [self drawToPoint:CGPointMake(160, 50)];
    [self drawToPoint:CGPointMake(200, 50)];
    [self drawToPoint:CGPointMake(250, 50)];*/
}


#pragma mark - Property

- (CGSize)aspectFillSize {
    CGFloat scale = [UIScreen mainScreen].scale;
    return  CGSizeMake(kDrawImageViewAspectFillSize / scale, kDrawImageViewAspectFillSize / scale);
}


#pragma mark - Public

- (void)clear {
    self.image = nil;
    [self.basePath removeAllObjects];
}


#pragma mark - Private Calculation

CGFloat calculate(CGFloat p0, CGFloat p1, CGFloat p2, CGFloat p3, CGFloat c) {
    return 0.5 * (2 * p1 + (p2 - p0) * c + (2 * p0 - 5 * p1 + 4 * p2 - p3) * powf(c, 2) + (3 * p1 - p0 - 3 * p2 + p3) * powf(c, 3));
}

CGFloat distance(CGPoint p0, CGPoint p1) {
    return sqrtf(powf(p1.x - p0.x, 2) + powf(p1.y - p0.y, 2));
}


#pragma mark - Private Draw

- (CGPoint)scaledPoint:(CGPoint)point {
    return CGPointMake(point.x * self.scaleFactor, point.y * self.scaleFactor);
}

- (void)drawToPoint:(CGPoint)currentPoint {
    currentPoint = [self scaledPoint:currentPoint];
    
    [self checkStopDrawFillWithDrawPoint:currentPoint];
   
    CGRect bounds = self.bounds;
    if (self.image) {
        bounds.size = self.image.size;
    } else {
        bounds.size.width *= self.scaleFactor;
        bounds.size.height *= self.scaleFactor;
    }
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, bounds);
    
    if (self.image) {
        [self.image drawInRect:bounds];
    }
    
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetStrokeColorWithColor(context, self.color.CGColor);
    
    CGPoint p0 = [self pointAtIndex:0];
    CGPoint p1 = [self pointAtIndex:1];
    CGPoint p2 = [self pointAtIndex:2];
    CGPoint p3 = currentPoint;
    
    // Data for testing
    /*CGContextSetLineWidth(context, 0.5);
    CGFloat startAngle = -((float)M_PI / 2);
    CGFloat endAngle = ((2 * (float)M_PI) + startAngle);
    CGContextMoveToPoint(context, p0.x, p0.y);
    CGContextAddArc(context, p0.x, p0.y, 3, startAngle, endAngle, 0);
    CGContextMoveToPoint(context, p1.x, p1.y);
    CGContextAddArc(context, p1.x, p1.y, 3, startAngle, endAngle, 0);
    CGContextMoveToPoint(context, p2.x, p2.y);
    CGContextAddArc(context, p2.x, p2.y, 3, startAngle, endAngle, 0);
    CGContextMoveToPoint(context, p3.x, p3.y);
    CGContextAddArc(context, p3.x, p3.y, 3, startAngle, endAngle, 0);
    CGContextStrokePath(context);*/
        
    if (self.basePath.count > 0) {
        // Draw interpolation line beetwen p1 and p3 !!!!
        
        CGFloat distance1 = distance(p0, p1);
        CGFloat distance2 = distance(p1, p2);
        CGFloat distance3 = distance(p2, p3);
        CGFloat distance = (distance1 + distance2 + distance3) / 3;
        
        NSInteger count = MAX(ceilf(distance / kDrawImagePixelsStep), 1);
        CGFloat widthTemp = distance / 2;
        CGFloat width = MAX(MIN(widthTemp, kDrawImageLineMaxWidth), kDrawImageLineMinWidth);
        
        CGFloat lineMaxDWidth = distance / 10;
        if (ABS(self.lastWidth - width) > lineMaxDWidth) {
            width = self.lastWidth + (self.lastWidth > width ? -lineMaxDWidth : lineMaxDWidth);
        }
        
        CGPoint lastPoint = p1;
        
        for (NSInteger i = 1; i <= count; i++) {
            CGFloat c = (CGFloat) i * (1.0 / (CGFloat) count);
            CGPoint point = CGPointMake(calculate(p0.x, p1.x, p2.x, p3.x, c), calculate(p0.y, p1.y, p2.y, p3.y, c));
            
            CGFloat currentWidth = self.lastWidth + (width - self.lastWidth) / count * i;
            
            CGContextSetLineWidth(context, currentWidth);
            CGContextMoveToPoint(context, lastPoint.x, lastPoint.y);
            CGContextAddLineToPoint(context, point.x, point.y);
            CGContextStrokePath(context);
            
            [self.path addObject:[[DrawImageMPoint alloc] initWithX:point.x y:point.y width:currentWidth]];
            
            // Data for test
            /*CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
            CGContextSetLineWidth(context, 0.5);
            CGFloat startAngle = -((float)M_PI / 2);
            CGFloat endAngle = ((2 * (float)M_PI) + startAngle);
            CGContextAddArc(context, point.x, point.y, currentWidth / 2, startAngle, endAngle, 0);
            CGContextStrokePath(context);*/
            
            lastPoint = point;
        }
        
        self.lastWidth = width;
        
        // Data for test
        /*CGContextSetStrokeColorWithColor(context, RGBA(255, 0, 0, 0.5).CGColor);
        CGContextSetLineWidth(context, widthTemp);
        CGContextMoveToPoint(context, p2.x, p2.y);
        CGContextAddLineToPoint(context, p2.x, p2.y);
        CGContextStrokePath(context);*/
    } else {
        CGContextSetLineWidth(context, self.lastWidth);
        CGContextMoveToPoint(context, p3.x, p3.y);
        CGContextAddLineToPoint(context, p3.x, p3.y);
        CGContextStrokePath(context);
        
        [self.path addObject:[[DrawImageMPoint alloc] initWithX:p3.x y:p3.y width:self.lastWidth]];
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.image = image;
    
    [self addPoint:currentPoint];
}

- (CGPoint)pointAtIndex:(NSInteger)index {
    if (self.basePath.count > 0) {
        NSInteger actualIndex = index;
        if (self.basePath.count < (kDrawImageCalculatePointCount - 1)) {
            NSInteger newIndex = index - ((kDrawImageCalculatePointCount - 1) - self.basePath.count);
            actualIndex = MAX(newIndex, 0);
        }
        
        return [self.basePath[actualIndex] CGPointValue];
    } else {
        return CGPointZero;
    }
}

- (void)addPoint:(CGPoint)point {
    [self.basePath addObject:[NSValue valueWithCGPoint:point]];
    if (self.basePath.count > (kDrawImageCalculatePointCount - 1)) {
        [self.basePath removeObjectAtIndex:0];
    }
}

- (void)drawFill {
    CGRect bounds = self.bounds;
    if (self.image) {
        bounds.size = self.image.size;
    } else {
        bounds.size.width *= self.scaleFactor;
        bounds.size.height *= self.scaleFactor;
    }
    
    self.fillIncrementRadius *= kDrawImageDrawFillIncrementFactor;
    self.fillRadius += self.fillIncrementRadius;
    if (self.fillRadius > MAX(bounds.size.width * 2, bounds.size.height * 2)) {
        [self removeDrawFillTimer];
        return;
    }
    CGRect ellipseRect = CGRectMake(self.fillPoint.x - self.fillRadius, self.fillPoint.y - self.fillRadius, self.fillRadius * 2, self.fillRadius * 2);
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, bounds);
    
    if (self.image) {
        [self.image drawInRect:bounds];
    }
    
    CGContextSetFillColorWithColor(context, self.color.CGColor);
    CGContextFillEllipseInRect(context, ellipseRect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.image = image;
}

- (void)checkStopDrawFillWithDrawPoint:(CGPoint)drawPoint {
    if (self.startFillTimer || self.drawFillTimer) {
        for (NSInteger i = 0; i < self.basePath.count; i ++) {
            CGPoint point = [self pointAtIndex:i];
            if (distance(point, drawPoint) > kDrawImageMaxDistanceForStartFill) {
                [self removeStartFillTimer];
                [self removeDrawFillTimer];
                return;
            }
        }
    }
}

- (void)finishDrawWithFillDrawing:(BOOL)fillDrawing {
    if (self.basePath.count > 0 || fillDrawing) {
        if (self.basePath.count > 0) {
            [self.basePath removeAllObjects];
            
            if (self.path.count > 0) {
                self.path = nil;
            }
        }
        
        if ([self.delegate respondsToSelector:@selector(drawImageCanvasViewDidFinishDraw)]) {
            [self.delegate drawImageCanvasViewDidFinishDraw];
        }
    }
}


#pragma mark - Private Fill Timer

- (void)createStartFillTimer {
    [self removeStartFillTimer];
    
    self.startFillTimer = [NSTimer scheduledTimerWithTimeInterval:kDrawImageStartFillInterval target:self selector:@selector(actionStartFillTimer) userInfo:nil repeats:NO];
}

- (void)removeStartFillTimer {
    if (self.startFillTimer) {
        [self.startFillTimer invalidate];
        self.startFillTimer = nil;
    }
}

- (void)actionStartFillTimer {
    [self drawFill];
    [self createDrawFillTimer];
    
    if (self.basePath.count == 0) {
        if ([self.delegate respondsToSelector:@selector(drawImageCanvasViewDidStartDraw)]) {
            [self.delegate drawImageCanvasViewDidStartDraw];
        }
    }
}

- (void)createDrawFillTimer {
    [self removeDrawFillTimer];
    
    self.drawFillTimer = [NSTimer scheduledTimerWithTimeInterval:kDrawImageDrawFillInterval target:self selector:@selector(actionDrawFillTimer) userInfo:nil repeats:YES];
}

- (void)removeDrawFillTimer {
    if (self.drawFillTimer) {
        [self.drawFillTimer invalidate];
        self.drawFillTimer = nil;
    }
}

- (void)actionDrawFillTimer {
    [self drawFill];
}


#pragma mark - Touches

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    if (!self.isEnabled) {
        return;
    }
    
    CGPoint currentPoint = [[touches anyObject] locationInView:self];
    self.fillPoint = [self scaledPoint:currentPoint];
    self.fillRadius = 2;
    self.fillIncrementRadius = 0.4;
    
    [self createStartFillTimer];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    if (!self.isEnabled) {
        if (self.basePath.count > 0) {
            [self touchesCancelled:touches withEvent:event];
        }
        return;
    }
    
    if (self.basePath.count == 0) {
        self.lastWidth = kDrawImageLineMinWidth;
        self.path = [[NSMutableArray alloc] init];
        
        if ([self.delegate respondsToSelector:@selector(drawImageCanvasViewDidStartDraw)]) {
            [self.delegate drawImageCanvasViewDidStartDraw];
        }
    }
    
    CGPoint currentPoint = [[touches anyObject] locationInView:self];
    [self drawToPoint:currentPoint];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    BOOL isFillDrawing = (self.drawFillTimer != nil);
    
    [self removeStartFillTimer];
    [self removeDrawFillTimer];
    
    if (!self.isEnabled) {
        return;
    }

    if (self.basePath.count > 0 || isFillDrawing) {
        [self finishDrawWithFillDrawing:isFillDrawing];
    } else if (!isFillDrawing) {
        if ([self.delegate respondsToSelector:@selector(drawImageCanvasViewDidTapField)]) {
            [self.delegate drawImageCanvasViewDidTapField];
        }
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    BOOL isFillDrawing = (self.drawFillTimer != nil);
    
    [self removeStartFillTimer];
    [self removeDrawFillTimer];
    
    [self finishDrawWithFillDrawing:isFillDrawing];
}

@end
