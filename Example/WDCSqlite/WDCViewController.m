//
//  WDCViewController.m
//  WDCSqlite
//
//  Created by xiongwei on 12/06/2019.
//  Copyright (c) 2019 xiongwei. All rights reserved.
//

#import "WDCViewController.h"
#import "WDCPerson.h"
#import "WDCPersonCell.h"
#import <WDCSqliteAPI.h>

@interface WDCViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *resultTableView;
@property (nonatomic, strong) NSMutableArray<WDCPerson *> *personArray;

@property (nonatomic, strong) NSMutableDictionary *cellHeightsDict;

@end

@implementation WDCViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.resultTableView.estimatedRowHeight = 100.0;
    self.resultTableView.rowHeight = UITableViewAutomaticDimension;
    [self.resultTableView registerNib:[UINib nibWithNibName:NSStringFromClass([WDCPersonCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([WDCPersonCell class])];
}

///插入模型到数据库
- (IBAction)insertAction:(id)sender {
    BOOL batchInsert = YES;
    ///批量插入
    if(batchInsert){
        NSMutableArray<WDCPerson *> *insertPersons = [NSMutableArray array];
        for(NSInteger i = 0; i < 100; i ++){
            @autoreleasepool {
                [insertPersons addObject:[self createOnePerson]];
            }
        }
        CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
        ///注：不要大批量插入含有图片属性的model
        [WDCSqliteAPI insertModels:insertPersons uid:nil completionHandler:^(BOOL res) {
            NSLog(@"批量插入%zd条数据%@, 消耗时间%lf", insertPersons.count, res?@"成功":@"失败", CFAbsoluteTimeGetCurrent()-startTime);
            if(res){
                [self queryAction:nil];
            }
        }];
    ///单条插入
    }else{
        WDCPerson *insertPerson = [self createOnePerson];
        [WDCSqliteAPI insertModel:insertPerson uid:nil completionHandler:^(BOOL res) {
            NSLog(@"插入%@%@", insertPerson, res?@"成功":@"失败");
            if(res){
                [self queryAction:nil];
            }
        }];
    }
}

///查询数据库中的所有模型，展示到tableView
- (IBAction)queryAction:(id)sender {
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    [WDCSqliteAPI queryModels:[WDCPerson class] uid:nil condition:nil completionHandler:^(NSArray *models) {
        NSLog(@"查询到%zd条数据，消耗时间%lf", models.count, CFAbsoluteTimeGetCurrent()-startTime);
        self.personArray = [models mutableCopy];
        [self.resultTableView reloadData];
    }];
}

///删除数据库中的一些模型
- (IBAction)deleteAction:(id)sender {
    
    BOOL deleteByCondition = NO;
    CFAbsoluteTime startTime = CFAbsoluteTimeGetCurrent();
    ///按条件删除
    if(deleteByCondition){
        __block NSString *whereStr;
        ///注:每行代码产生一个子条件，子条件间是'或'的关系(order by除外)
        ///每个子条件需要调用begin、end()标志开始、结束
        ///orderBy条件需要写在最后一行

        ///删除条件: (name = '老'野'猪' and age > 18) or (height < 170) order by height asc limit 0, 10
        [WDCSqliteAPI deleteModels:[WDCPerson class] uid:nil condition:^(WDCSqliteConditionMaker *maker) {
            maker.begin.prop(@"name").equalTo(@"老'野'猪").and.prop(@"age").moreThan(@(18)).end();
            maker.begin.prop(@"height").lessThan(@(170)).end();
            maker.begin.orderBy(@"height", YES).limit(0, 10).end();
            whereStr = maker.result;
        } completionHandler:^(BOOL res) {
            NSLog(@"删除%@%@ 消耗时间%lf", whereStr, res?@"成功":@"失败", CFAbsoluteTimeGetCurrent()-startTime);
            if(res){
                [self queryAction:nil];
            }
        }];
        
//        whereStr = @"(name = '老'野'猪' and age > 18) or (height < 170) order by height asc limit 0, 2000";
//        [WDCSqliteAPI deleteModels:[WDCPerson class] whereStr:whereStr uid:nil completionHandler:^(BOOL res) {
//            NSLog(@"删除%@%@ 消耗时间%lf", whereStr, res?@"成功":@"失败", CFAbsoluteTimeGetCurrent()-startTime);
//            if(res){
//                [self queryAction:nil];
//            }
//        }];
    ///按查询出来的模型删除
    }else{
        NSArray<WDCPerson *> *deletedPersons = [self.personArray subarrayWithRange:NSMakeRange(0, self.personArray.count/2)];
        [WDCSqliteAPI deleteModels:deletedPersons uid:nil completionHandler:^(BOOL res) {
            NSLog(@"删除%zd条数据%@ 消耗时间%lf", deletedPersons.count, res?@"成功":@"失败", CFAbsoluteTimeGetCurrent()-startTime);
            if(res){
                [self queryAction:nil];
            }
        }];
    }
}


#pragma mark - 解决SelfSizingCell reloadData时跳跃的问题
- (NSMutableDictionary *)cellHeightsDict{
    if(_cellHeightsDict == nil){
        _cellHeightsDict = [NSMutableDictionary dictionary];
    }
    return _cellHeightsDict;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.cellHeightsDict setObject:@(cell.frame.size.height) forKey:indexPath];
}
- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSNumber *height = [self.cellHeightsDict objectForKey:indexPath];
    if(height){
        return height.doubleValue;
    }
    return UITableViewAutomaticDimension;
}

#pragma mark -  <UITableViewDataSource, UITableViewDelegate>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.personArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WDCPersonCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([WDCPersonCell class])];
    WDCPerson *person = self.personArray[indexPath.row];
    [self bindEntity:person toCell:cell];
    return cell;
}

#pragma mark - other
- (NSMutableArray<WDCPerson *> *)personArray{
    if(_personArray == nil){
        _personArray = [NSMutableArray array];
    }
    return _personArray;
}
- (void)bindEntity:(WDCPerson *)person toCell:(WDCPersonCell *)cell{
    cell.avatarImageView.image = person.avatar;
    cell.nameLabel.text = person.name;
    cell.idCardLabel.text = person.idCard;
    cell.dateLabel.text = [person.importantDate description];
    cell.otherInfoLabel.text = [NSString stringWithFormat:@"age:%zd, height:%f", person.age, person.height];
    cell.tagsLabel.text = [person.tagArray componentsJoinedByString:@","];
    if(person.extraDict){
        cell.extraDictLabel.text = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:person.extraDict options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
    }else{
        cell.extraDictLabel.text = nil;
    }
    cell.customDataLabel.text = [[NSString alloc] initWithData:person.customData encoding:NSUTF8StringEncoding];;
}

- (WDCPerson *)createOnePerson{
    WDCPerson *person = [[WDCPerson alloc] init];
    person.idCard = arc4random_uniform(2) ? @"360122199101010111" : @"360122199202020222";
    person.name = arc4random_uniform(2) ? @"老'野'猪" : @"小'白'兔";
    person.age = arc4random_uniform(2) ? 20 : 18;
    person.height = arc4random_uniform(2) ? 175 : 160;
    person.tagArray = arc4random_uniform(2) ? @[@"程序员", @"北京", @"lol玩家"] : @[@"地下城玩家", @"撸猫", @"肥宅快乐水"];
    person.extraDict = arc4random_uniform(2) ? @{@"手机型号": @"坚果Pro",
                    @"桌上的书": @[@"Effextive Objective-C", @"算法设计"],
                                                 } : @{
                                                       @"一只电脑": @{
                                                               @"cpu": @"AMD Ryzen7 1700",
                                                               @"硬盘": @"东芝TR200",
                                                               @"内存": @"威刚万紫千红DDR4",
                                                               }
                                                       };
    person.customData = [NSJSONSerialization dataWithJSONObject:person.extraDict options:NSJSONWritingPrettyPrinted error:nil];
//    person.avatar = [UIImage imageNamed:@"avatar"];
    person.importantDate = arc4random_uniform(2) ? [NSDate dateWithTimeIntervalSinceNow:1000] : [NSDate date];
    return person;
}
@end
