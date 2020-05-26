//
//  Inputbar.h
//  Whatsapp
//
//  Created by Chandrachud Patil on 7/11/15.
//  Copyright (c) 2015 HummingBird. All rights reserved.
//

#import "Inputbar.h"
#import "HPGrowingTextView.h"
#import "Header.h"
#import "MZTimerLabel.h"
#import <AudioToolbox/AudioServices.h>

@interface Inputbar() <HPGrowingTextViewDelegate>
@property (nonatomic, strong) HPGrowingTextView *textView;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UIButton *mikeButton;
@property (strong, nonatomic) UIButton *mikeFlashButton;
@property (strong, nonatomic) MZTimerLabel *timer;
@property (nonatomic, strong) UIButton *leftButton;
@end

#define RIGHT_BUTTON_SIZE 60
#define LEFT_BUTTON_SIZE 45

@implementation Inputbar

-(id)init
{
    self = [super init];
    if (self)
    {
        [self addContent];
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    {
        [self addContent];
    }
    return self;
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder]))
    {
        [self addContent];
    }
    return self;
}
-(void)addContent
{
    [self addTextView];
    [self addRightButton];
    [self addLeftButton];
    [self addMikeButton];
    [self addMikeFlashButton];
    
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}
-(void)addTextView
{
    CGSize size = self.frame.size;
    _textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(LEFT_BUTTON_SIZE,
                                                                    5,
                                                                    size.width - LEFT_BUTTON_SIZE - RIGHT_BUTTON_SIZE,
                                                                    size.height)];
    _textView.isScrollable = NO;
    _textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);
    
    _textView.minNumberOfLines = 1;
    _textView.maxNumberOfLines = 6;
    // you can also set the maximum height in points with maxHeight
    // textView.maxHeight = 200.0f;
    _textView.returnKeyType = UIReturnKeyGo; //just as an example
    _textView.font = [UIFont systemFontOfSize:15.0f];
    _textView.delegate = self;
    _textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    _textView.backgroundColor = [UIColor whiteColor];
    _textView.placeholder = _placeholder;
    
    //textView.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    _textView.keyboardType = UIKeyboardTypeDefault;
    _textView.returnKeyType = UIReturnKeyDefault;
    _textView.enablesReturnKeyAutomatically = YES;
    //textView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, -1.0, 0.0, 1.0);
    //textView.textContainerInset = UIEdgeInsetsMake(8.0, 4.0, 8.0, 0.0);
    _textView.layer.cornerRadius = 5.0;
    [_textView setPlaceholder:@"Type a message"];
//    _textView.layer.borderWidth = 0.5;
    _textView.layer.borderColor =  [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:205.0/255.0 alpha:1.0].CGColor;
    
    _textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
    [self addSubview:_textView];
}

-(void)addRightButton
{
    CGSize size = self.frame.size;
    self.rightButton = [[UIButton alloc] init];
    self.rightButton.frame = CGRectMake(size.width - RIGHT_BUTTON_SIZE, 0, RIGHT_BUTTON_SIZE, size.height);
    self.rightButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.rightButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.rightButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
    [self.rightButton setTitle:@"Done" forState:UIControlStateNormal];
    self.rightButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
    
    [self.rightButton addTarget:self action:@selector(didPressRightButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.rightButton];
    
    [self.rightButton setHidden:YES];
}

-(void)addMikeFlashButton
{
    CGSize size = self.frame.size;
    self.mikeFlashButton = [[UIButton alloc] init];
    self.mikeFlashButton.frame = CGRectMake(size.width + RIGHT_BUTTON_SIZE, 0, RIGHT_BUTTON_SIZE, size.height);
    [self.mikeFlashButton setImage:[UIImage imageNamed:@"mike"] forState:UIControlStateNormal];
    
    [self addSubview:self.mikeFlashButton];
    [self.mikeFlashButton setHidden:NO];
    [self flashOn:self.mikeFlashButton];
}

-(void)addMikeButton
{
    CGSize size = self.frame.size;
    self.mikeButton = [[UIButton alloc] init];
    self.mikeButton.frame = CGRectMake(size.width - LEFT_BUTTON_SIZE, 0, LEFT_BUTTON_SIZE, size.height);
    self.mikeButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    [self.mikeButton setImage:[UIImage imageNamed:@"mike"] forState:UIControlStateNormal];
    
    [self addSubview:self.mikeButton];
    [self.mikeButton setHidden:NO];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [self.mikeButton addGestureRecognizer:longPress];

}
-(void)addLeftButton
{
    CGSize size = self.frame.size;
    self.leftButton = [[UIButton alloc] init];
    self.leftButton.frame = CGRectMake(0, 0, LEFT_BUTTON_SIZE, size.height);
    self.leftButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
    [self.leftButton setImage:self.leftButtonImage forState:UIControlStateNormal];
    
    [self.leftButton addTarget:self action:@selector(didPressLeftButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.leftButton];
}

-(void)addTimerLabel
{
    CGSize size = self.frame.size;
    _timer = [[MZTimerLabel alloc] initWithFrame:CGRectMake(size.width + RIGHT_BUTTON_SIZE, 0, RIGHT_BUTTON_SIZE + RIGHT_BUTTON_SIZE, size.height)];
    _timer.timerType = MZTimerLabelTypeStopWatch;
    [self addSubview:_timer];
    _timer.timeLabel.backgroundColor = [UIColor clearColor];
    _timer.timeLabel.font = [UIFont systemFontOfSize:20.0f];
    _timer.timeLabel.textColor = navBarColor;
    _timer.timeFormat = @"mm:ss";
    _timer.timeLabel.textAlignment = NSTextAlignmentCenter; //UITextAlignmentCenter is deprecated in iOS 7.0
    //fire

}
- (void)longPress:(UILongPressGestureRecognizer*)gesture
{
    if ( gesture.state == UIGestureRecognizerStateBegan )
    {
        AudioServicesPlayAlertSound(kSystemSoundID_Vibrate);
        [self animateViews];
    }
   else if ( gesture.state == UIGestureRecognizerStateEnded )
   {
       [self animateBack];
   }
    [self.delegate inputbarDidPressLeftBarButtonForLong:gesture];

}

-(void)resignFirstResponder
{
    [_textView resignFirstResponder];
}
-(NSString *)text
{
    return _textView.text;
}

#pragma mark - Delegate

-(void)didPressRightButton:(UIButton *)sender
{
    if (self.rightButton.isSelected) return;
    
    [self.delegate inputbarDidPressRightButton:self];
    self.textView.text = @"";
}

-(void)didPressLeftButton:(UIButton *)sender
{
    [self.delegate inputbarDidPressLeftButton:self];
}

#pragma mark - Set Methods

-(void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    _textView.placeholder = placeholder;
}
-(void)setLeftButtonImage:(UIImage *)leftButtonImage
{
    [self.leftButton setImage:leftButtonImage forState:UIControlStateNormal];
}
-(void)setRightButtonTextColor:(UIColor *)righButtonTextColor
{
    [self.rightButton setTitleColor:navBarColor forState:UIControlStateNormal];
}
-(void)setRightButtonText:(NSString *)rightButtonText
{
    [self.rightButton setTitle:rightButtonText forState:UIControlStateNormal];
}

#pragma mark - TextViewDelegate

-(void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect r = self.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    self.frame = r;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputbarDidChangeHeight:)])
    {
        [self.delegate inputbarDidChangeHeight:self.frame.size.height];
    }
}
-(void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(inputbarDidBecomeFirstResponder:)])
    {
        [self.delegate inputbarDidBecomeFirstResponder:self];
    }
}
- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView
{
    NSString *text = [growingTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    if ([text isEqualToString:@""])
    {
        [self.rightButton setHidden:YES];
        [self.mikeButton setHidden:NO];
    }
    else
    {
        [self.rightButton setHidden:NO];
    [self.mikeButton setHidden:YES];
    }
}

#pragma mark - Animation Method
-(void)animateViews
{
    [self addTimerLabel];
    __weak MZTimerLabel *timerLabel = _timer;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.mikeFlashButton.hidden = NO;
                         self.timer.hidden = NO;
                         CGSize size = self.frame.size;
                         self.leftButton.frame = CGRectMake(-350, 0, LEFT_BUTTON_SIZE, size.height);
                         self.textView.frame = CGRectMake(-350 + LEFT_BUTTON_SIZE,
                                                          5,
                                                          size.width - LEFT_BUTTON_SIZE - RIGHT_BUTTON_SIZE,
                                                          size.height);

                         self.mikeFlashButton.frame = CGRectMake(0, 0, LEFT_BUTTON_SIZE, size.height);
                         self.timer.frame = CGRectMake(LEFT_BUTTON_SIZE, 0, LEFT_BUTTON_SIZE + LEFT_BUTTON_SIZE, size.height);
                         [timerLabel start];
                    }
                     completion:^(BOOL finished){
                     }];
}

-(void)animateBack
{
    __weak MZTimerLabel *timerLabel = _timer;
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         CGSize size = self.frame.size;
                         self.mikeFlashButton.hidden = YES;
                         self.timer.hidden = YES;

                         self.leftButton.frame = CGRectMake(0, 0, LEFT_BUTTON_SIZE, size.height);
                         self.textView.frame = CGRectMake(LEFT_BUTTON_SIZE,
                                                          5,
                                                          size.width - LEFT_BUTTON_SIZE - RIGHT_BUTTON_SIZE,
                                                          size.height);
                         _textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 5);

                         self.mikeFlashButton.frame = CGRectMake(size.width + RIGHT_BUTTON_SIZE, 0, RIGHT_BUTTON_SIZE, size.height);
                         self.timer.frame = CGRectMake(size.width + RIGHT_BUTTON_SIZE, 0, RIGHT_BUTTON_SIZE, size.height);
                         [self.layer removeAllAnimations];
                         [self.mikeFlashButton.layer removeAllAnimations];

                     }
                     completion:^(BOOL finished){
                         [timerLabel reset];
                         [timerLabel removeFromSuperview];

                     }];

}
- (void)flashOn:(UIView *)v
{
    [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^ {
        v.alpha = 1;
    } completion:^(BOOL finished) {
        [self flashOff:v];
    }];
}
- (void)flashOff:(UIView *)v
{
    [UIView animateWithDuration:.5 delay:0 options:UIViewAnimationOptionAllowUserInteraction animations:^ {
        v.alpha = .01;  //don't animate alpha to 0, otherwise you won't be able to interact with it
    } completion:^(BOOL finished) {
        [self flashOn:v];
    }];
}
@end
