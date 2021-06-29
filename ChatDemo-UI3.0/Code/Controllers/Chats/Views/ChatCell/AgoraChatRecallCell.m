//
//  AgoraChatTimeRecallCell.m
//  ChatDemo-UI3.0
//
//  Created by liujinliang on 2021/6/16.
//  Copyright © 2021 easemob. All rights reserved.
//

#import "AgoraChatRecallCell.h"


@interface AgoraChatRecallCell ()
@property (nonatomic, strong) UILabel *timeLabel;
@end


@implementation AgoraChatRecallCell
#pragma mark life cycle
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self placeAndLayoutSubviews];
    }
    return  self;
}

- (void)placeAndLayoutSubviews {
    [self.contentView addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.contentView);
        make.height.equalTo(@30);
    }];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

#pragma mark update cell
- (void)updateCellWithType:(AgoraChatDemoWeakRemind)type
               withContent:(NSString *)content {
    if (type == AgoraChatDemoWeakRemindMsgTime) {
        _timeLabel.textColor = [UIColor colorWithHexString:@"#ADADAD"];
        _timeLabel.backgroundColor = [UIColor colorWithHexString:@"#F2F2F2"];
    } else {
        _timeLabel.textColor = [UIColor colorWithHexString:@"#ADADAD"];;
        _timeLabel.backgroundColor = [UIColor clearColor];
    }
    self.timeLabel.text = content;
}

#pragma mark gette and setter
- (UILabel *)timeLabel {
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:14];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _timeLabel;
}


@end
