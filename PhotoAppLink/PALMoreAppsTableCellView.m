//
//  PALMoreAppsTableCellView.m
//  Created by Hendrik Kueck on 11-05-23.
//

#import "PALMoreAppsTableCellView.h"
#import "PALManager.h"
#import "PALAppInfo.h"
#import "PALConfig.h"


@implementation PALMoreAppsTableCellView
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
        
        icon = [[UIImage imageNamed:PLACEHOLDER_APP_ICON] retain];

        NSURL* requestorThumbnailURL = [appInfo thumbnailURL];
        [[PALManager sharedPALManager] asyncIconForApp:appInfo withCompletion:^(UIImage *image, NSError *error) {
            
            // if this object's content has changed (because it's been reused), or if the new
            // icon is the same as the current one, don't update
            if (![self.appInfo.thumbnailURL isEqual:requestorThumbnailURL]) return;
            if ([icon isEqual:image]) return;
            
            [icon release];
            
            if (error != nil) {
                NSLog(@"error getting icon: %@", [error localizedDescription]);
                icon = [UIImage imageNamed:GENERIC_APP_ICON];
            }
            else {
                icon = image;
            }
            [icon retain];
            
            // icon has changed, so we have to redraw the cell
            [self setNeedsDisplay];
        }];
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
    // Workaround for (presumably) a bug in which the shadow direction is reversed
    // betwen iOS 3.2+ and earlier iOS versions
    
    float shadowDirection = ([[[UIDevice currentDevice] systemVersion] floatValue] < 3.2f)? -1.0f : 1.0f;
    CGContextSetShadow(context, CGSizeMake(1.0f, 3.0f * shadowDirection), 3.0f);
    CGRect iconRect = CGRectMake(thumbnailLeftMargin, thumbnailTopMargin, thumbnailSize, thumbnailSize);
    [icon drawInRect:iconRect];
    
    CGContextSetShadowWithColor(context, CGSizeMake(0, shadowDirection), 0, [[UIColor whiteColor]CGColor]);
    UIColor* titleColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.3 alpha:1.0];
    UIFont* titleFont = [UIFont boldSystemFontOfSize:16];
    [titleColor set];
    [appInfo.name drawAtPoint:CGPointMake(leftTextBoundary, titleTopPosition) 
                        forWidth:totalWidth - titleRightMargin - leftTextBoundary 
                        withFont:titleFont 
                   lineBreakMode:UILineBreakModeTailTruncation];
    CGContextRestoreGState(context);

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
