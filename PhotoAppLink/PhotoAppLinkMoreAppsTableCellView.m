//
//  PhotoAppLinkMoreAppsTableCellView.m
//  PhotoAppLinkTestApp
//
//  Created by Hendrik Kueck on 11-05-23.
//  Copyright 2011 Pocket Pixels Inc. All rights reserved.
//

#import "PhotoAppLinkMoreAppsTableCellView.h"
#import "PhotoAppLinkManager.h"
#import <QuartzCore/QuartzCore.h>

@implementation PhotoAppLinkMoreAppsTableCellView
@synthesize appInfo;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setAppInfo:(PALAppInfo *)anAppInfo
{
    if (appInfo != anAppInfo) {
        [appInfo release];
        appInfo = [anAppInfo retain];
    }
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    static int thumbnailSize = 57;
    static int thumbnailTopMargin = 15;
    static int thumbnailLeftMargin = 10;
    static int leftTextBoundary = 78;
    static int titleTopPosition = 10;
    static int titleRightMargin = 10;
    
    static int capabilitiesTextTopPosition = 64;
    
    static int appDescriptionTopPostion = 31;
    static int appDescriptionMaxHeight = 30;
    static int appDescriptionRightMargin = 70;
    static int appDescriptionSingleLineOffset = 5;
    
    float totalWidth = self.frame.size.width;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextSetShadow(context, CGSizeMake(1.0f, 3.0f), 3.0f);
    CGRect thumbnailRect = CGRectMake(thumbnailLeftMargin, thumbnailTopMargin, thumbnailSize, thumbnailSize);
    UIImage* thumbnail = [appInfo thumbnail];
    [thumbnail drawInRect:thumbnailRect];
    
    CGContextSetShadowWithColor(context, CGSizeMake(0, 1), 0, [[UIColor whiteColor]CGColor]);
    UIColor* titleColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.3 alpha:1.0];
    UIFont* titleFont = [UIFont boldSystemFontOfSize:16];
    [titleColor set];
    [appInfo.appName drawAtPoint:CGPointMake(leftTextBoundary, titleTopPosition) 
                        forWidth:totalWidth - titleRightMargin - leftTextBoundary 
                        withFont:titleFont 
                   lineBreakMode:UILineBreakModeTailTruncation];
    CGContextRestoreGState(context);

//    UIColor* capabilitiesTextColor = [UIColor colorWithRed:0.5 green:0.35 blue:0.20 alpha:1.0];
    UIColor* capabilitiesTextColor = [UIColor colorWithRed:0.4 green:0.4 blue:0.5 alpha:1.0];
    UIFont* capabilitiesTextFont = [UIFont systemFontOfSize:13];
    [capabilitiesTextColor set];
    NSString* capabilitiesText;
    if (self.appInfo.canSend && self.appInfo.canReceive) {
        capabilitiesText = NSLocalizedString(@"can send and receive images", 
                                             @"PhotoAppLink");
    }
    else if (self.appInfo.canReceive) {
        capabilitiesText = NSLocalizedString(@"can receive images", 
                                             @"PhotoAppLink");
    }
    else {
        capabilitiesText = NSLocalizedString(@"can send images", 
                                             @"PhotoAppLink");
    }
    [capabilitiesText drawAtPoint:CGPointMake(leftTextBoundary, capabilitiesTextTopPosition) 
                         withFont:capabilitiesTextFont];
    
    

    if (appInfo.appDescription && [appInfo.appDescription length] > 0) {
        UIColor* descriptionColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
        UIFont* descriptionFont = [UIFont systemFontOfSize:13];
        [descriptionColor set];
        int descriptionMaxWidth = totalWidth - leftTextBoundary - appDescriptionRightMargin;
        CGSize maxSize = CGSizeMake(descriptionMaxWidth, appDescriptionMaxHeight);
        CGSize descriptionSize = [appInfo.appDescription sizeWithFont:descriptionFont 
                                                    constrainedToSize:maxSize];
        BOOL singleLineDescription = descriptionSize.height < 22;
        int yOffset = (singleLineDescription) ? appDescriptionSingleLineOffset : 0;
        CGRect descriptionBox = CGRectMake(leftTextBoundary, 
                                           appDescriptionTopPostion + yOffset, 
                                           descriptionMaxWidth,
                                           appDescriptionMaxHeight);
        [appInfo.appDescription drawInRect:descriptionBox withFont:descriptionFont
                             lineBreakMode:UILineBreakModeWordWrap];
    }
    
}

- (void)dealloc
{
    [appInfo release];
    [super dealloc];
}

@end
