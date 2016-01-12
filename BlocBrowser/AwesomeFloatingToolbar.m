//
//  AwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by eric on 12/13/15.
//  Copyright © 2015 eric j beasley. All rights reserved.
//

#import "AwesomeFloatingToolbar.h"

@interface AwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSMutableArray *colors;
@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, weak) UILabel *currentLabel;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;

@end

@implementation AwesomeFloatingToolbar

- (instancetype) initWithFourTitles:(NSArray *)titles {
    self = [super init];
    
    if (self) {
        //Get the titles, set the colors
        self.currentTitles = titles;
        self.colors = [[NSMutableArray alloc] initWithObjects:
                        [UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1], nil];
        
        NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];

        // Make the 4 buttons
        for (NSString *currentTitle in self.currentTitles) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.userInteractionEnabled = NO;
            button.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle];
            NSString *titleForThisButton = [self.currentTitles objectAtIndex:currentTitleIndex];
            
            button.titleLabel.tintColor = nil;
            button.titleLabel.textColor = [UIColor whiteColor];
            button.titleLabel.font = [UIFont systemFontOfSize:12];
            [button setTitle:titleForThisButton forState:UIControlStateNormal];
            [buttonsArray addObject:button];
        }
        
        self.buttons = buttonsArray;
        
        for (UIButton *thisButton in self.buttons) {
            [thisButton addTarget:self action:@selector(browserButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        [self addGestureRecognizer:self.pinchGesture];
        
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        [self.longPressGesture setMinimumPressDuration:1.0];
        [self addGestureRecognizer:self.longPressGesture];

    }
    
    return self;
}

- (void) layoutSubviews {
    // Set the frames for the labels.
        for (UIButton *thisButton in self.buttons) {
            NSUInteger currentButtonIndex = [self.buttons indexOfObject:thisButton];
            CGFloat buttonHeight = CGRectGetHeight(self.bounds) / 2;
            CGFloat buttonWidth = CGRectGetWidth(self.bounds) / 2;
            CGFloat buttonX = 0;
            CGFloat buttonY = 0;
            
            // Adjust labelX and labelY for each label
            if (currentButtonIndex < 2) {
                // 0 or 1, go on top
                buttonY = 0;
            } else {
                // 2 or 3, go on bottom
                buttonY = CGRectGetHeight(self.bounds) / 2;
            }
            
            if (currentButtonIndex % 2 == 0) {
                //Is label divisable by 2? Goes on left.
                buttonX = 0;
            } else {
                // Otherwise, goes on right.
                buttonX = CGRectGetWidth(self.bounds) / 2;
            }
            
            thisButton.backgroundColor = [self.colors objectAtIndex:currentButtonIndex];
            thisButton.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
            [thisButton sizeThatFits:thisButton.frame.size];
            [self addSubview:thisButton];
        }
}

#pragma mark - Touch Handling

- (IBAction)browserButtonPressed:(UIButton *)button {
    [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UIButton *)button).titleLabel.text];
}

- (void)panFired:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self];
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

- (void)pinchFired:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = [recognizer scale];
        NSLog(@"Pinch fired with scale of %f", scale);
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPinchWithScale:)]) {
            [self.delegate floatingToolbar:self didTryToPinchWithScale:scale];
        }
    }
    
    recognizer.scale = 1;
}

- (void)longPressFired:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        //Get colors and shuffle them, set toolbar to redraw
        NSUInteger colorCount = self.colors.count;
        
        for (NSUInteger i = 0; i < colorCount; ++i) {
            NSUInteger nObjects = colorCount - i;
            NSUInteger n = (arc4random() % nObjects) + i;
            [self.colors exchangeObjectAtIndex:i withObjectAtIndex:n];
            [self layoutSubviews];
        }
        
    }
}
#pragma mark - Button Enabling

- (void)setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        UIButton *button = [self.buttons objectAtIndex:index];
        button.userInteractionEnabled = enabled;
        button.alpha = enabled ? 1.0 : 0.25;
    }
}

@end
