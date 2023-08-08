//
//  FacexManager.h
//  LibFaceRecognitionDemo
//
//  Created by SHAN on 2020/12/2.
//  Copyright © 2020 msxf. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FacexEnum.h"
#import "Facexdet.h"

NS_ASSUME_NONNULL_BEGIN

@interface FacexManager : NSObject
/// 人脸检测初始化*
/// @param modelDir 模型路径
/// @param status 状态
/// @param value 是否进行人脸遮挡判断
/// @param threshold 人脸遮挡阈值 遮挡的概率值 越大越难判断为遮挡  越小容易判断为遮挡 默认0.5f
/// 返回：人脸检测对象
- (instancetype)initWithModelDir:(NSString *)modelDir status:(FacexInitStatus *)status faceShelter:(BOOL)value threshold:(float)threshold;

/// 人脸检测反初始化，释放相关资源
- (void)unInit;

/// 人脸检测
/// @param image 人脸图片
/// @param boxRect 引导框
/// @param status 状态
/// 返回：人脸信息{x,y,w,h,token,faceScore,isFaceShelter,faceShelterScore}
- (FaceRecognizeResult *)maxFaceDetectWithImage:(UIImage *)image boxRect:(CGRect)boxRect status:(FacexDetectStatus *)status;

/// 多人脸检测
/// @param image 人脸图片
/// @param boxRect 引导框
/// @param status 状态
/// 返回：多人脸信息[{x,y,w,h,token,faceScore,isFaceShelter,faceShelterScore}, ...]
- (NSArray<FaceRecognizeResult *> *)mutableFaceDetectWithImage:(UIImage *)image boxRect:(CGRect)boxRect status:(FacexDetectStatus *)status;

/// 人脸比对 1:1
/// @param faceOneToken 人脸信息中token
/// @param faceTwoToken 人脸信息中token
/// @param status 状态
/// 返回：比对分数
- (float)compareWithFaceOneToken:(NSString *)faceOneToken
                    faceTwoToken:(NSString *)faceTwoToken
                          status:(FacexCompareStatus *)status;
/// 人脸比对 1:N
/// @param faceOneToken 人脸信息中token
/// @param otherFaceTokens 人脸信息中token数组
/// @param status 状态
/// 返回：比对分数数组
- (NSArray<NSNumber *> *)compareWithFaceOneToken:(NSString *)faceOneToken
                                 otherFaceTokens:(NSArray<NSString *> *)otherFaceTokens
                                          status:(FacexCompareStatus *)status;
/// 人脸比对 1:1 图片方式
/// @param faceOneImage 人脸图片
/// @param faceTwoImage 人脸图片
/// @param status 状态
/// 返回：比对分数
- (float)compareWithFaceOneImage:(UIImage *)faceOneImage
                    faceTwoImage:(UIImage *)faceTwoImage
                          status:(FacexCompareStatus *)status;

/// 人脸转正
/// @param image 人脸图片
/// 返回：转正后图片
- (UIImage *)getFrontFaceWithImage:(UIImage *)image;

/// 人脸抠图
/// @param image 图片
/// 返回：抠图后图片
- (UIImage *)getFaceCutoutWithImage:(UIImage *)image;

/// 图片裁剪
/// @param image 图片
/// @param rect 裁剪范围
- (UIImage *)cutImage:(UIImage *)image inRect:(CGRect)rect;


/// 修正图片方向信息
/// @param image 原始图片
- (UIImage *)fixOrientation:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
