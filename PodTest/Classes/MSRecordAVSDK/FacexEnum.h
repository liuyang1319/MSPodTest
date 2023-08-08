//
//  FacexEnum.h
//  LibFaceRecognitionDemo
//
//  Created by SHAN on 2020/12/7.
//  Copyright © 2020 msxf. All rights reserved.
//

#ifndef FacexEnum_h
#define FacexEnum_h

/// 初始化
typedef NS_ENUM(NSInteger, FacexInitStatus) {
    FacexInitStatus_OK,            // 成功
    FacexInitStatus_MODEL_ERROR,   // 模型错误
    FacexInitStatus_ERROR          // 错误
};

/// 人脸检测
typedef NS_ENUM(NSInteger, FacexDetectStatus) {
    FacexDetectStatus_OK,      // 成功
    FacexDetectStatus_NONE     // 未检测到
};

/// 人脸遮挡
typedef NS_ENUM(NSInteger, FacexShelterStatus) {
    FacexShelterStatus_YES,      // 检测到遮挡
    FacexShelterStatus_NO        // 检测到未遮挡
};

/// 人脸比对
typedef NS_ENUM(NSInteger, FacexCompareStatus) {
    FacexCompareStatus_OK,             // 成功
    FacexCompareStatus_FACE_ONE_NONE,  // 图一未检测到
    FacexCompareStatus_FACE_TWO_NONE   // 图二未检测到
};

#endif /* FacexEnum_h */
