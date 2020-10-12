//
//  HoshiTextField.m
//  CCTextFieldEffects
//
//  Created by Kelvin on 6/25/16.
//  Copyright © 2016 Cokile. All rights reserved.
//

#import "HoshiTextField.h"

@interface HoshiTextField ()

@property (strong, nonatomic) CALayer *inactiveBorderLayer;
@property (strong, nonatomic) CALayer *activeBorderLayer;
@property (nonatomic) CGPoint activePlaceholderPoint;

@end

@implementation HoshiTextField

#pragma mark - Constants
static CGFloat const activeBorderThickness = 2;
static CGFloat const inactiveBorderThickness = 0.7;
static CGPoint const textFieldInsets = {30, 12};
static CGPoint const placeholderInsets = {0, 4};

#pragma mark - Custom accessorys
- (void)setBorderInactiveColor:(UIColor *)borderInactiveColor {
    _borderInactiveColor = borderInactiveColor;
    
    [self updateBorder];
}

//- (void)setBorderActiveColor:(UIColor *)borderActiveColor {
//    _borderActiveColor = borderActiveColor;
//
//    [self updateBorder];
//}

-(void)setborderInvalidColor:(UIColor *)color
{
    _borderInvalidColor = color;
    [self updateBorder];
}

-(void)setborderValidColor:(UIColor *)color
{
    _borderValidColor = color;
    [self updateBorder];
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    _placeholderColor = placeholderColor;
    
    [self updatePlaceholder];
}

- (void)setPlaceholderFontScale:(CGFloat)placeholderFontScale {
    _placeholderFontScale = placeholderFontScale;
    
    [self updatePlaceholder];
}

- (void)setPlaceholder:(NSString *)placeholder {
    [super setPlaceholder:placeholder];
    
    [self updatePlaceholder];
}

- (void)setBounds:(CGRect)bounds {
    [super setBounds:bounds];
    
    [self updateBorder];
    [self updatePlaceholder];
}

#pragma mark - Lifecycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self commonInit];
    }
    
    return self;
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void) commonInit {
    
    self.isActivated = NO;

    self.inactiveBorderLayer = [[CALayer alloc] init];
    self.activeBorderLayer = [[CALayer alloc] init];
    self.placeholderLabel = [[UILabel alloc] init];    
    
    self.borderInactiveColor = [UIColor colorWithRed:0.7255 green:0.7569 blue:0.7922 alpha:1.0];
//    self.borderActiveColor = [UIColor colorWithRed:0.4157 green:0.4745 blue:0.5373 alpha:1.0];
    self.placeholderColor = self.borderInactiveColor;
    self.cursorColor = [UIColor colorWithRed:0.349 green:0.3725 blue:0.4314 alpha:1.0];
    self.textColor = [UIColor colorWithRed:0.2785 green:0.2982 blue:0.3559 alpha:1.0];
    
    self.image = nil;
    self.imageColor = self.cursorColor;
    
    self.placeholderFontScale = 0.75;
    self.activePlaceholderPoint = CGPointZero;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(textDidChange)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(BOOL)isValidated
{
    return ![[self.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""];
}

-(CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, 50);
}

-(BOOL)resignFirstResponder
{
    self.isActivated = YES;
    
    [self updateBorderColors];
    
    return [super resignFirstResponder];
}

-(void)textDidChange
{
    [self updateBorderColors];
}

#pragma mark - Overridden methods
- (void)drawRect:(CGRect)rect {
    CGRect frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
    self.placeholderLabel.frame = CGRectInset(frame, placeholderInsets.x, placeholderInsets.y);
    self.placeholderLabel.font = [self placeholderFontFromFont:self.font];
    
    [self updateBorder];
    [self updatePlaceholder];
    
    [self.layer addSublayer:self.inactiveBorderLayer];
    [self.layer addSublayer:self.activeBorderLayer];
    [self addSubview:self.placeholderLabel];
    
    if(self.image)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
        imageView.frame = CGRectMake(0, textFieldInsets.y + 12, 24, 24);
        imageView.tintColor = self.imageColor;
        [self addSubview:imageView];
    }
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    int xInset = self.image ? textFieldInsets.x : 0;
    
    return CGRectOffset(bounds, xInset, textFieldInsets.y);
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    int xInset = self.image ? textFieldInsets.x : 0;
    
    return CGRectOffset(bounds, xInset, textFieldInsets.y);
}

- (void)animateViewsForTextEntry {
    if (self.text.length == 0) {
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.placeholderLabel.frame = CGRectMake(self.activePlaceholderPoint.x, self.placeholderLabel.frame.origin.y, CGRectGetWidth(self.placeholderLabel.frame), CGRectGetHeight(self.placeholderLabel.frame));
            self.placeholderLabel.alpha = 0;
        } completion:^(BOOL finished) {
            if (self.didBeginEditingHandler != nil) {
                self.didBeginEditingHandler();
            }
        }];
    }
    
    [self layoutPlaceholderInTextRect];
    self.placeholderLabel.frame = CGRectMake(self.activePlaceholderPoint.x, self.activePlaceholderPoint.y, CGRectGetWidth(self.placeholderLabel.frame), CGRectGetHeight(self.placeholderLabel.frame));
    
    [UIView animateWithDuration:0.2 animations:^{
        self.placeholderLabel.alpha = 0.5;
    }];
    
    self.activeBorderLayer.frame = [self rectForBorderThickness:activeBorderThickness isFilled:YES];
    self.inactiveBorderLayer.hidden = YES;
}

- (void)animateViewsForTextDisplay {
    if (self.text.length == 0) {
        [UIView animateWithDuration:0.35 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:2.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [self layoutPlaceholderInTextRect];
            self.placeholderLabel.alpha = 1.0;
        } completion:^(BOOL finished) {
            if (self.didEndEditingHandler != nil) {
                self.didEndEditingHandler();
            }
        }];
        
        self.activeBorderLayer.frame = [self rectForBorderThickness:activeBorderThickness isFilled:NO];
        self.inactiveBorderLayer.hidden = NO;
    }
}

#pragma mark - Private methods
- (void)updateBorder{
    self.inactiveBorderLayer.frame = [self rectForBorderThickness:inactiveBorderThickness isFilled:YES];
    //self.inactiveBorderLayer.backgroundColor = self.borderInactiveColor.CGColor;
    
    self.activeBorderLayer.frame = [self rectForBorderThickness:activeBorderThickness isFilled:NO];
    //self.activeBorderLayer.backgroundColor = self.borderActiveColor.CGColor;
    
    [self updateBorderColors];
}

-(void)updateBorderColors
{
    self.inactiveBorderLayer.backgroundColor = self.isActivated ? self.borderInvalidColor.CGColor : self.borderValidColor.CGColor;
    self.activeBorderLayer.backgroundColor = (self.isActivated && !self.isValidated) ? self.borderInvalidColor.CGColor : self.borderValidColor.CGColor;
}

- (void)updatePlaceholder {
    self.placeholderLabel.text = self.placeholder;
    self.placeholderLabel.textColor = self.placeholderColor;
    [self.placeholderLabel sizeToFit];
    [self layoutPlaceholderInTextRect];
    
    if ([self isFirstResponder] || self.text.length!=0) {
        [self animateViewsForTextEntry];
    }
}

- (UIFont *)placeholderFontFromFont:(UIFont *)font {
    UIFont *smallerFont = [UIFont fontWithName:font.fontName size:font.pointSize*self.placeholderFontScale];
    
    return smallerFont;
}

- (CGRect)rectForBorderThickness:(CGFloat)thickness isFilled:(BOOL)isFilled {
    if (isFilled) {
        return CGRectMake(0, CGRectGetHeight(self.frame)-thickness, CGRectGetWidth(self.frame), thickness);
    } else {
        return CGRectMake(0, CGRectGetHeight(self.frame)-thickness, 0, thickness);
    }
}

- (void)layoutPlaceholderInTextRect {
    CGRect textRect = [self textRectForBounds:self.bounds];
    CGFloat originX = textRect.origin.x;
    
    switch (self.textAlignment) {
        case NSTextAlignmentCenter:
            originX += textRect.size.width/2-self.placeholderLabel.bounds.size.width/2;
            break;
        case NSTextAlignmentRight:
            originX += textRect.size.width-self.placeholderLabel.bounds.size.width;
            break;
        default:
            break;
    }
    
    self.placeholderLabel.frame = CGRectMake(originX, textRect.size.height/2 + 4, CGRectGetWidth(self.placeholderLabel.bounds), CGRectGetHeight(self.placeholderLabel.bounds));
    self.activePlaceholderPoint = CGPointMake(self.placeholderLabel.frame.origin.x, self.placeholderLabel.frame.origin.y-self.placeholderLabel.frame.size.height-placeholderInsets.y);
}

@end
