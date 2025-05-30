//
//  TUISelectGroupMemberViewController.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/6.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUISelectGroupMemberViewController_Minimalist.h"
#import <TUICore/TUICore.h>
#import <TUICore/TUIDarkModel.h>
#import <TUICore/TUIGlobalization.h>
#import <TUICore/TUIThemeManager.h>
#import "ReactiveObjC/ReactiveObjC.h"
#import "TUIMemberPanelCell.h"
#import "TUISelectGroupMemberCell.h"

#define kUserBorder 44.0
#define kUserSpacing 2
#define kUserPanelLeftSpacing 15

@interface TUISelectGroupMemberViewController_Minimalist () <UICollectionViewDelegate,
                                                             UICollectionViewDataSource,
                                                             UICollectionViewDelegateFlowLayout,
                                                             UITableViewDelegate,
                                                             UITableViewDataSource>
@property(nonatomic, strong) UIButton *cancelBtn;
@property(nonatomic, strong) UIButton *doneBtn;
@property(nonatomic, strong) UICollectionView *userPanel;
@property(nonatomic, strong) UITableView *selectTable;
@property(nonatomic, strong) UIActivityIndicatorView *indicatorView;
@property(nonatomic, strong) NSMutableArray<TUIUserModel *> *selectedUsers;

@property(nonatomic, assign) CGFloat topStartPosition;
@property(nonatomic, assign) CGFloat userPanelWidth;
@property(nonatomic, assign) CGFloat userPanelHeight;
@property(nonatomic, assign) CGFloat realSpacing;
@property(nonatomic, assign) NSInteger userPanelColumnCount;
@property(nonatomic, assign) NSInteger userPanelRowCount;

@property(nonatomic, strong) NSMutableArray *memberList;
@property(nonatomic, assign) NSInteger pageIndex;
@property(nonatomic, assign) BOOL isNoData;
@end

@implementation TUISelectGroupMemberViewController_Minimalist {
    UICollectionView *_userPanel;
    UITableView *_selectTable;
    UIButton *_cancelBtn;
    UIButton *_doneBtn;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = self.name ?: TIMCommonLocalizableString(Make_a_call);
    titleLabel.font = [UIFont boldSystemFontOfSize:17.0];
    titleLabel.textColor = TIMCommonDynamicColor(@"nav_title_text_color", @"#000000");
    [titleLabel sizeToFit];
    self.navigationItem.titleView = titleLabel;

    self.view.backgroundColor = TIMCommonDynamicColor(@"controller_bg_color", @"#F2F3F5");

    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:self.cancelBtn];
    self.navigationItem.leftBarButtonItem = item;

    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:self.doneBtn];
    self.navigationItem.rightBarButtonItem = item2;

    CGFloat topPadding = 44.f;

    if (@available(iOS 11.0, *)) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        topPadding = window.safeAreaInsets.top;
    }

    topPadding = MAX(26, topPadding);
    CGFloat navBarHeight = self.navigationController.navigationBar.bounds.size.height;
    self.topStartPosition = topPadding + (navBarHeight > 0 ? navBarHeight : 44);
    CGRect rect = self.view.bounds;
    self.memberList = [NSMutableArray array];
    self.selectedUsers = [NSMutableArray array];
    self.indicatorView.frame = CGRectMake(0, 0, self.view.bounds.size.width, TMessageController_Header_Height);
    self.selectTable.tableFooterView = self.indicatorView;
    [self getMembers];
}

#pragma mark UI

- (UIButton *)cancelBtn {
    if (!_cancelBtn.superview) {
        _cancelBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_cancelBtn setTitle:TIMCommonLocalizableString(Cancel) forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:TIMCommonDynamicColor(@"nav_title_text_color", @"#000000") forState:UIControlStateNormal];
        [_cancelBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelBtn;
}

- (UIButton *)doneBtn {
    if (!_doneBtn.superview) {
        _doneBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [_doneBtn setTitle:TIMCommonLocalizableString(Done) forState:UIControlStateNormal];
        [_doneBtn setAlpha:0.5];
        [_doneBtn setTitleColor:TIMCommonDynamicColor(@"nav_title_text_color", @"#000000") forState:UIControlStateNormal];
        [_doneBtn addTarget:self action:@selector(onNext) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneBtn;
}

- (UICollectionView *)userPanel {
    if (!_userPanel.superview) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _userPanel = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _userPanel.backgroundColor = [UIColor clearColor];
        [_userPanel registerClass:[TUIMemberPanelCell class] forCellWithReuseIdentifier:@"TUIMemberPanelCell"];
        if (@available(iOS 10.0, *)) {
            _userPanel.prefetchingEnabled = YES;
        } else {
            // Fallback on earlier versions
        }
        _userPanel.showsVerticalScrollIndicator = NO;
        _userPanel.showsHorizontalScrollIndicator = NO;
        _userPanel.contentMode = UIViewContentModeScaleAspectFit;
        _userPanel.scrollEnabled = NO;
        _userPanel.delegate = self;
        _userPanel.dataSource = self;
        [self.view addSubview:_userPanel];
    }
    return _userPanel;
}

- (UITableView *)selectTable {
    if (!_selectTable.superview) {
        _selectTable = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _selectTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [_selectTable registerClass:[TUISelectGroupMemberCell class] forCellReuseIdentifier:@"TUISelectGroupMemberCell"];
        if (@available(iOS 15.0, *)) {
            _selectTable.sectionHeaderTopPadding = 0;
        }
        _selectTable.delegate = self;
        _selectTable.dataSource = self;
        [self.view addSubview:_selectTable];
        _selectTable.mm_width(self.view.mm_w).mm_top(self.topStartPosition + 10).mm_flexToBottom(0);
    }
    return _selectTable;
}

- (UIActivityIndicatorView *)indicatorView {
    if (_indicatorView == nil) {
        _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicatorView.hidesWhenStopped = YES;
    }
    return _indicatorView;
}

- (void)updateUserPanel {
    self.userPanel.mm_height(self.userPanelHeight).mm_left(kUserPanelLeftSpacing).mm_flexToRight(0).mm_top(self.topStartPosition);
    self.selectTable.mm_width(self.view.mm_w).mm_top(self.userPanel.mm_maxY).mm_flexToBottom(0);
    @weakify(self);
    [self.userPanel
        performBatchUpdates:^{
          @strongify(self);
          [self.userPanel reloadSections:[NSIndexSet indexSetWithIndex:0]];
        }
                 completion:nil];
    [self.selectTable reloadData];
    self.doneBtn.alpha = (self.selectedUsers.count == 0 ? 0.5 : 1);
}

#pragma mark action

- (void)onNext {
    if (self.selectedUsers.count == 0) {
        return;
    }
    NSMutableArray *users = [NSMutableArray array];
    for (TUIUserModel *model in self.selectedUsers) {
        [users addObject:[model copy]];
    }
    if (self.selectedFinished) {
        [self cancel];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
          self.selectedFinished(users);
        });
    }
    if (self.optionalStyle == TUISelectMemberOptionalStyleTransferOwner) {
        [self cancel];
        return;
    }
    [self cancel];

    NSDictionary *result = @{TUICore_TUIContactObjectFactory_SelectGroupMemberVC_ResultUserList : users};
    if (self.navigateValueCallback) {
        self.navigateValueCallback(result);
    }
}

- (void)cancel {
    if (self.isModal) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (BOOL)isModal {
    NSArray *viewControllers = self.navigationController.viewControllers;
    if (viewControllers.count > 1 && [viewControllers.lastObject isEqual:self]) {
        return NO;
    }
    return YES;
}

#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.memberList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"TUISelectGroupMemberCell";
    TUISelectGroupMemberCell *cell = (TUISelectGroupMemberCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[TUISelectGroupMemberCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (indexPath.row < self.memberList.count) {
        TUIUserModel *model = self.memberList[indexPath.row];
        BOOL isSelect = [self isUserSelected:model];
        [cell fillWithData:model isSelect:isSelect];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    UITableViewHeaderFooterView *footer = (UITableViewHeaderFooterView *)view;
    footer.textLabel.textColor = [UIColor d_systemGrayColor];
    footer.textLabel.font = [UIFont systemFontOfSize:14];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return TIMCommonLocalizableString(TUIKitGroupProfileMember);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return 44;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BOOL isSelected = NO;
    TUIUserModel *userSelected = [[TUIUserModel alloc] init];
    if (indexPath.row < self.memberList.count) {
        TUIUserModel *user = self.memberList[indexPath.row];
        isSelected = [self isUserSelected:user];
        userSelected = [user copy];
    }

    if (userSelected.userId.length == 0) {
        return;
    }

    if ([userSelected.userId isEqualToString:kImSDK_MesssageAtALL]) {
        [self.selectedUsers removeAllObjects];
        [self.selectedUsers addObject:userSelected];
        [self onNext];
        return;
    }

    if (self.optionalStyle == TUISelectMemberOptionalStyleTransferOwner) {
        [self.selectedUsers removeAllObjects];
    }
    if (isSelected) {
        for (TUIUserModel *user in self.selectedUsers) {
            if ([user.userId isEqualToString:userSelected.userId]) {
                [self.selectedUsers removeObject:user];
                break;
            }
        }
    } else {
        [self.selectedUsers addObject:userSelected];
    }
    [self updateUserPanel];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y > 0 && (scrollView.contentOffset.y >= scrollView.bounds.origin.y)) {
        if (self.indicatorView.isAnimating) {
            return;
        }
        [self.indicatorView startAnimating];
        @weakify(self);
        [self loadData:^(BOOL success, NSString *desc, NSArray<TUIUserModel *> *datas) {
          @strongify(self);
          [self.indicatorView stopAnimating];
          if (!success) {
              return;
          }
          [self.memberList addObjectsFromArray:datas];
          [self.selectTable reloadData];
          [self.selectTable layoutIfNeeded];
          if (datas.count == 0) {
              [self.selectTable setContentOffset:CGPointMake(0, scrollView.contentOffset.y - TMessageController_Header_Height) animated:YES];
          }
        }];
    }
}

#pragma mark UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.selectedUsers.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"TUIMemberPanelCell";
    TUIMemberPanelCell *cell = (TUIMemberPanelCell *)[collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    if (indexPath.row < self.selectedUsers.count) {
        [cell fillWithData:self.selectedUsers[indexPath.row]];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kUserBorder, kUserBorder);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:NO];
    if (indexPath.row < self.selectedUsers.count) {
        // to do
    }
}

#pragma mark data
- (NSInteger)userPanelColumnCount {
    if (self.selectedUsers.count == 0) {
        return 0;
    }
    CGFloat totalWidth = self.view.mm_w - kUserPanelLeftSpacing;
    int columnCount = (int)(totalWidth / (kUserBorder + kUserSpacing));
    return columnCount;
}

- (CGFloat)realSpacing {
    CGFloat totalWidth = self.view.mm_w - kUserPanelLeftSpacing;
    if (self.userPanelColumnCount == 0 || self.userPanelColumnCount == 1) {
        return 0;
    }
    return (totalWidth - (CGFloat)self.userPanelColumnCount * kUserBorder) / ((CGFloat)self.userPanelColumnCount - 1);
}

- (NSInteger)userPanelRowCount {
    NSInteger userCount = self.selectedUsers.count;
    NSInteger columnCount = MAX(self.userPanelColumnCount, 1);
    NSInteger rowCount = userCount / columnCount;
    if (userCount % columnCount != 0) {
        rowCount += 1;
    }
    return rowCount;
}

- (CGFloat)userPanelWidth {
    return (CGFloat)self.userPanelColumnCount * kUserBorder + ((CGFloat)self.userPanelColumnCount - 1) * self.realSpacing;
}

- (CGFloat)userPanelHeight {
    return (CGFloat)self.userPanelRowCount * kUserBorder + ((CGFloat)self.userPanelRowCount - 1) * self.realSpacing;
}

- (void)getMembers {
    @weakify(self);
    [self getMembersWithOptionalStyle];
    [self loadData:^(BOOL success, NSString *desc, NSArray<TUIUserModel *> *datas) {
      @strongify(self);
      if (!success) {
          return;
      }
      [self.memberList addObjectsFromArray:datas];
      [self.selectTable reloadData];
    }];
}

- (void)loadData:(void (^)(BOOL, NSString *, NSArray<TUIUserModel *> *))completion {
    if (self.isNoData) {
        if (completion) {
            completion(YES, @"there is no more data", @[]);
        }
        return;
    }
    __weak typeof(self) weakSelf = self;
    [[V2TIMManager sharedInstance] getGroupMemberList:self.groupId
        filter:V2TIM_GROUP_MEMBER_FILTER_ALL
        nextSeq:self.pageIndex
        succ:^(uint64_t nextSeq, NSArray<V2TIMGroupMemberFullInfo *> *memberList) {
          weakSelf.pageIndex = nextSeq;
          weakSelf.isNoData = (nextSeq == 0);
          NSMutableArray *arrayM = [NSMutableArray array];
          for (V2TIMGroupMemberFullInfo *info in memberList) {
              if ([info.userID isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]]) {
                  continue;
              }
              if (weakSelf.optionalStyle & TUISelectMemberOptionalStylePublicMan) {
                  BOOL isSuper = (info.role == V2TIM_GROUP_MEMBER_ROLE_SUPER);
                  BOOL isAdMin = (info.role == V2TIM_GROUP_MEMBER_ROLE_ADMIN);
                  if (isSuper || isAdMin) {
                      continue;
                  }
              }

              if (self.selectedUserIDList && [self.selectedUserIDList containsObject:info.userID]) {
                  continue;
              }

              TUIUserModel *model = [[TUIUserModel alloc] init];
              model.userId = info.userID;
              if (info.nameCard.length > 0) {
                  model.name = info.nameCard;
              } else if (info.friendRemark.length > 0) {
                  model.name = info.friendRemark;
              } else if (info.nickName.length > 0) {
                  model.name = info.nickName;
              } else {
                  model.name = info.userID;
              }
              if (info.faceURL != nil) {
                  model.avatar = info.faceURL;
              }
              [arrayM addObject:model];
          }
          if (completion) {
              completion(YES, nil, [NSArray arrayWithArray:arrayM]);
          }
        }
        fail:^(int code, NSString *desc) {
          if (completion) {
              completion(NO, desc, @[]);
          }
        }];
}

- (void)getMembersWithOptionalStyle {
    if (!NSThread.isMainThread) {
        __weak typeof(self) weakSelf = self;
        dispatch_async(dispatch_get_main_queue(), ^{
          [weakSelf getMembersWithOptionalStyle];
        });
        return;
    }

    if (self.optionalStyle == TUISelectMemberOptionalStyleNone) {
        return;
    }

    if (self.optionalStyle & TUISelectMemberOptionalStyleAtAll) {
        TUIUserModel *model = [[TUIUserModel alloc] init];
        model.userId = kImSDK_MesssageAtALL;
        model.name = TIMCommonLocalizableString(All);
        [self.memberList addObject:model];
    }
}

- (BOOL)isUserSelected:(TUIUserModel *)user {
    BOOL isSelected = NO;
    for (TUIUserModel *selectUser in self.selectedUsers) {
        if ([selectUser.userId isEqualToString:user.userId] && ![selectUser.userId isEqualToString:[[V2TIMManager sharedInstance] getLoginUser]]) {
            isSelected = YES;
            break;
        }
    }
    return isSelected;
}
@end
