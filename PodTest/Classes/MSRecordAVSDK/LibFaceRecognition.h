//
//  LibFaceRecognition.h
//  LibFaceRecognition
//
//  Created by 张杨 on 2020/11/10.
//  Copyright © 2020 张杨. All rights reserved.
//

//  v1.0.0 更新MNN框架 2020/11/11
//  v1.0.1 人脸检测是否自动矫正 2020/12/28
//  v1.0.2 反初始化崩溃问题修复 2021/01/06
//  v1.0.3 某些图片无法矫正修复 2021/01/20
//  v1.0.4 并行线程调用崩溃修复 2021/01/29
//  v1.0.5 误检到多个人脸问题修复 2021/03/08
//  v1.0.6 更新了人脸检测的模型，修复特定角度图片无法识别的问题 2021/03/26
//  v1.0.7 拆分MNN.framework和算法库 2021/03/30
//  v1.0.8 优化人脸遮挡模型，提升用户体验 2021/04/22
//  v1.0.9 针对上一版本不足优化人脸遮挡模型，提高模型精度，提升用户体验 2021/06/22
//  v1.1.0 解决其他第三方库引用冲突问题 2021/09/28
//  v1.1.1 优化转正方法图片写入 2022/03/31
//  v1.1.2 按需加载模型，优化内存占用率 2022/07/01
//  v2.0.0 适配定制化MNN和Opencv库，避免库冲突 2022/10/19

#if __has_include(<LibFaceRecognition/Facexdet.h>)
#import <LibFaceRecognition/Facexdet.h>
#else
#import "Facexdet.h"
#endif
