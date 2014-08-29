//
//  OverlayView.m
//  Lapse
//
//  Created by Kimberley Yu on 8/7/14.
//  Copyright (c) 2014 Appcoda. All rights reserved.
//

#import "OverlayImageView.h"

@implementation OverlayImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
