//
//  Facexdet.h
//  LibFaceRecognition
//
//  Created by 张杨 on 2020/11/11.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/// **************结果类**************
@interface FaceRecognizeResult : NSObject
/// RECT
@property (nonatomic, assign) int x;
@property (nonatomic, assign) int y;
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
/// token
@property (nonatomic, copy) NSString *token;
/// 人脸检测分数
@property (nonatomic, assign) float faceScore;
/// 人脸上半部是否遮挡
@property (nonatomic, assign) BOOL isFaceUpShelter;
/// 人脸下半部是否遮挡
@property (nonatomic, assign) BOOL isFaceDownShelter;
/// 人脸轮廓是否遮挡
@property (nonatomic, assign) BOOL isFaceOutLineShelter;
/// 人脸坐标98点 CGPoint数组
@property (nonatomic, strong) NSMutableArray<NSValue *> *faceLmd98;

@end

/// **************配置类**************
@interface FaceQualityConfig : NSObject
/// 人脸遮挡判断开关 默认NO
@property (nonatomic, assign) BOOL faceShelterSwitch;
/// 人脸遮挡阈值 遮挡的概率值 越大越难判断为遮挡  越小容易判断为遮挡 默认0.5f
@property (nonatomic, assign) float faceShelterThr;
@end

@interface Facexdet : NSObject

/// 当前算法版本
+ (NSString *)currentVersion;

/// 人脸检测初始化 【双证书校验 debug包 && release包】
/// @param bundleDir Bundle资源路径 eg:[[NSBundle mainBundle] pathForResource:@"xxx" ofType:@"bundle"];
/// @brief faceQualityConfig 配置类
/// 返回：1 ：初始化成功
///      0 ：初始化失败
///      100 ：授权成功
///      101 ：授权证书读取失败
///      102 ：授权证书校验失败(不匹配)
///      103 ：应用包名错误
///      104 ：应用包名长度错误
///      105 ：设备类型错误
///      106 ：证书未到有效期
///      107 ：证书已过有效期
+ (int)initWithBundleDir:(NSString *)bundleDir;
+ (int)initWithBundleDir:(NSString *)bundleDir
       faceQualityConfig:(nullable FaceQualityConfig *)faceQualityConfig;


/// 人脸检测初始化【单证书校验】
/// @param bundleDir Bundle资源路径 eg:[[NSBundle mainBundle] pathForResource:@"xxx" ofType:@"bundle"];
/// @param licenseName 授权证书名称 eg:facex_record_ios
/// @brief faceQualityConfig 配置类
/// 返回：1 ：初始化成功
///      0 ：初始化失败
///      100 ：授权成功
///      101 ：授权证书读取失败
///      102 ：授权证书校验失败(不匹配)
///      103 ：应用包名错误
///      104 ：应用包名长度错误
///      105 ：设备类型错误
///      106 ：证书未到有效期
///      107 ：证书已过有效期
+ (int)initWithBundleDir:(NSString *)bundleDir
             licenseName:(NSString *)licenseName;
+ (int)initWithBundleDir:(NSString *)bundleDir
             licenseName:(nullable NSString *)licenseName
       faceQualityConfig:(nullable FaceQualityConfig *)faceQualityConfig;

/// 校验授权证书有效性
/// @param licenseName 授权证书名称 eg:facex_record_ios
/// 返回：
///      100 ：授权成功
///      101 ：授权证书读取失败
///      102 ：授权证书校验失败(不匹配)
///      103 ：应用包名错误
///      104 ：应用包名长度错误
///      105 ：设备类型错误
///      106 ：证书未到有效期
///      107 ：证书已过有效期
+ (int)authorizationWithLicenseName:(NSString *)licenseName;

/// 人脸检测反初始化,释放相关资源
+ (void)unInit;

/// 人脸检测-自动矫正图片
/// @param image 图片 - RGBA或RGB格式
/// @param completion 回调结果Result数组
+ (void)faceDetectWithImage:(UIImage *)image
                completion:(void (^)(NSArray<FaceRecognizeResult*> *results))completion;

/// 人脸检测
/// @param image 图片 - RGBA或RGB格式
/// @param correctImage 是否矫正图片 YES-不返回faceLmd98 NO-返回faceLmd98
/// @param completion 回调结果Result数组
+ (void)faceDetectWithImage:(UIImage *)image
               correctImage:(BOOL)correctImage
                 completion:(void (^)(NSArray<FaceRecognizeResult*> *results))completion;

/// 人脸1:1比对
/// @param featureTokenOne 人脸特征Token
/// @param featureTokenTwo 人脸特征Token
/// return 比对分数
+ (double)comparisonFace:(NSString *)featureTokenOne
            faceTokenTwo:(NSString *)featureTokenTwo;

/// 人脸1:N比对
/// @param featureTokenOne 人脸特征Token
/// @param featureOther 人脸特征Token数组
/// @param completion 回调结果Result数组
+ (void)recognizeFaces:(NSString *)featureTokenOne
          featureOther:(NSArray<NSString*> *)featureOther
            completion:(void (^)(NSArray<FaceRecognizeResult*> *results))completion;

/// 人脸纠正
/// @param image 待纠正图片 - RGBA或RGB格式
/// @param bestImagePath 转正图片存储路径
+ (void)getFrontFaceWithImage:(UIImage *)image
                bestImagePath:(NSString *)bestImagePath;

@end

NS_ASSUME_NONNULL_END
