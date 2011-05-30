//
//  PhotoAppLinkMoreAppsTableCellView.h
//  PhotoAppLinkTestApp
//
//  Created by Hendrik Kueck on 11-05-23.
//  Copyright 2011 Pocket Pixels Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PALAppInfo;

@interface PALMoreAppsTableCellView : UIView {
    PALAppInfo* appInfo;
}

@property (nonatomic, retain) PALAppInfo *appInfo;

@end
