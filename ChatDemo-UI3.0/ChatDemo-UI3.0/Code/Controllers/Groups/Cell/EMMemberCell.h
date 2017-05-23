/************************************************************
 *  * Hyphenate
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Inc.
 */

#import <UIKit/UIKit.h>

@interface EMMemberCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *imgView;
@property (nonatomic, weak) IBOutlet UILabel *leftLabel;
@property (nonatomic, weak) IBOutlet UILabel *rightLabel;

@property (nonatomic) BOOL showAccessoryViewInDelete;
@property (nonatomic, strong) UIView *accessoryDefaultView;
@property (nonatomic, strong) UIView *accessoryDeleteView;

@end
