//
//  AgoraChatBaseCell.m
//  ChatDemo-UI3.0
//
//  Created by liujinliang on 2021/7/15.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "AgoraChatCustomBaseCell.h"

@implementation AgoraChatCustomBaseCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self customColorForDarkMode];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self customColorForDarkMode];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)customColorForDarkMode {
    self.backgroundColor = UIColor.whiteColor;
    self.contentView.backgroundColor = UIColor.whiteColor;

    self.textLabel.textColor = [UIColor blackColor];
    self.detailTextLabel.textColor = [UIColor grayColor];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}


@end
