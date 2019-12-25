//
//  WDCPersonCell.h
//  WDCSqlite_Example
//
//  Created by 熊伟 on 2019/12/9.
//  Copyright © 2019 xiongwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WDCPersonCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *idCardLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *otherInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *tagsLabel;
@property (weak, nonatomic) IBOutlet UILabel *extraDictLabel;
@property (weak, nonatomic) IBOutlet UILabel *customDataLabel;

@end

