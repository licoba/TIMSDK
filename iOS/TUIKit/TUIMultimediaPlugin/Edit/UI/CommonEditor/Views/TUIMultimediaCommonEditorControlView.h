// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import <UIKit/UIKit.h>
#include "TUIMultimediaPlugin/TUIMultimediaPasterConfig.h"
#include "TUIMultimediaPlugin/TUIMultimediaSticker.h"
#include "TUIMultimediaPlugin/TUIMultimediaSubtitleInfo.h"
#include "TUIMultimediaStickerView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol TUIMultimediaCommonEditorControlViewDelegate;
@class TUIMultimediaCommonEditorConfig;

/**
 编辑页面View
 */
@interface TUIMultimediaCommonEditorControlView : UIView
@property(readonly, nonatomic) UIView *previewView;
@property(nonatomic) BOOL isGenerating;
@property(nonatomic) CGFloat progressBarProgress;
@property(nonatomic) BOOL musicEdited;
@property(nonatomic) CGSize previewSize;
@property(nonatomic) BOOL modifyButtonsHidden;
@property(nonatomic) BOOL isStartCrop;
@property(nonatomic) int sourceType;
@property(weak, nullable, nonatomic) id<TUIMultimediaCommonEditorControlViewDelegate> delegate;
@property (nonatomic, strong) UIImage *mosaciOriginalImage;
@property(nonatomic) CGRect previewLimitRect;

- (instancetype)initWithConfig:(TUIMultimediaCommonEditorConfig *)config;

- (void)addPaster:(UIImage *)paster;
- (void)addSubtitle:(TUIMultimediaSubtitleInfo *)subtitle;

// crop相关
- (void)previewScale:(CGFloat)scale center:(CGPoint)center;
- (void)previewMove:(CGPoint)offset;
- (void)previewRotation90:(CGPoint)center;
- (void)previewRotationToZero;
- (void)previewAdjustToLimitRect;
@end

@protocol TUIMultimediaCommonEditorControlViewDelegate <NSObject>
- (void)onCommonEditorControlViewComplete:(TUIMultimediaCommonEditorControlView *)view stickers:(NSArray<TUIMultimediaSticker *> *)stickers;
- (void)onCommonEditorControlViewCrop:(NSInteger)rotationAngle normalizedCropRect:(CGRect)normalizedCropRect
                             stickers:(NSArray<TUIMultimediaSticker *> *)stickers;
- (void)onCommonEditorControlViewCancel:(TUIMultimediaCommonEditorControlView *)view;
- (void)onCommonEditorControlViewNeedAddPaster:(TUIMultimediaCommonEditorControlView *)view;
- (void)onCommonEditorControlViewNeedModifySubtitle:(TUIMultimediaSubtitleInfo *)info callback:(void (^)(TUIMultimediaSubtitleInfo *newInfo, BOOL isOk))callback;
- (void)onCommonEditorControlViewNeedEditMusic:(TUIMultimediaCommonEditorControlView *)view;
- (void)onCommonEditorControlViewCancelGenerate:(TUIMultimediaCommonEditorControlView *)view;
@end

@interface TUIMultimediaCommonEditorConfig : NSObject
@property(nonatomic) BOOL pasterEnabled;
@property(nonatomic) BOOL subtitleEnabled;
@property(nonatomic) BOOL drawGraffitiEnabled;
@property(nonatomic) BOOL drawMosaicEnabled;
@property(nonatomic) BOOL musicEditEnabled;
@property(nonatomic) BOOL cropEnabled;
+ (instancetype)configForVideoEditor;
+ (instancetype)configForPictureEditor;
@end

NS_ASSUME_NONNULL_END
