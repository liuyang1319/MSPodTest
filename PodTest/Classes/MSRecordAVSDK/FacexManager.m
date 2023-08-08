//
//  FacexManager.m
//  LibFaceRecognitionDemo
//
//  Created by SHAN on 2020/12/2.
//  Copyright © 2020 张杨. All rights reserved.
//

#import "FacexManager.h"
#import "MSSDKGlobalConfig.h"

#define TempFrontFaceFolder [NSString stringWithFormat:@"%@/tempFrontFaceFolder", NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject]

@implementation FacexManager

- (instancetype)initWithModelDir:(NSString *)modelDir status:(FacexInitStatus *)status faceShelter:(BOOL)value threshold:(float)threshold{
    self = [super init];
    if (self) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:TempFrontFaceFolder]) {
            [fileManager removeItemAtPath:TempFrontFaceFolder error:nil];
        }
//        if (isEmptyString(licDir)) {
//            NSLog(@"Facex缺少授权文件");
//            *status = FacexInitStatus_LICENSE_ERROR;
//            return nil;
//        }
        if (isEmptyString(modelDir)) {
            NSLog(@"Facex缺少模型文件");
            *status = FacexInitStatus_MODEL_ERROR;
            return nil;
        }
        
        threshold = threshold > 1 ? 1 : threshold;
        threshold = threshold < 0 ? 0 : threshold;
        
        FaceQualityConfig *config = [[FaceQualityConfig alloc] init];
        config.faceShelterSwitch = value;
        config.faceShelterThr = threshold;
        
        int code = [Facexdet initWithBundleDir:modelDir licenseName:[MSSDKGlobalConfig shareConfig].faceRecordLicName faceQualityConfig:config];
        
        if (code == 1) {
            *status = FacexInitStatus_OK;
            NSLog(@"Facex初始化成功");
        } else {
            *status = FacexInitStatus_ERROR;
            NSLog(@"Facex初始化失败");
            return nil;
        }
    }
    return self;
}


- (void)unInit {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:TempFrontFaceFolder]) {
        [fileManager removeItemAtPath:TempFrontFaceFolder error:nil];
    }
    [Facexdet unInit];
    NSLog(@"Facex反初始化成功");
}

- (FaceRecognizeResult *)maxFaceDetectWithImage:(UIImage *)image boxRect:(CGRect)boxRect status:(FacexDetectStatus *)status {
    if (isEmptyImage(image)) {
        *status = FacexDetectStatus_NONE;
        return nil;
    }
    
    image = [self fixOrientation:image];
    image = [self cutImage:image inRect:boxRect];
    
    __block FaceRecognizeResult *recgnizeResult = nil;
    [Facexdet faceDetectWithImage:image correctImage:NO completion:^(NSArray<FaceRecognizeResult *> * _Nonnull results) {
        if (isEmptyArray(results)) {
            *status = FacexDetectStatus_NONE;
        } else {
            recgnizeResult = results[0];
            *status = FacexDetectStatus_OK;
        }
    }];
    // 裁剪还原
    recgnizeResult.x = recgnizeResult.x + boxRect.origin.x;
    recgnizeResult.y = recgnizeResult.y + boxRect.origin.y;
    return recgnizeResult;
}

- (NSArray<FaceRecognizeResult *> *)mutableFaceDetectWithImage:(UIImage *)image boxRect:(CGRect)boxRect status:(FacexDetectStatus *)status {
    if (isEmptyImage(image)) {
        *status = FacexDetectStatus_NONE;
        return nil;
    }
    
    image = [self fixOrientation:image];
    image = [self cutImage:image inRect:boxRect];

    __block NSArray<FaceRecognizeResult *> *recgnizeResults = nil;
    [Facexdet faceDetectWithImage:image correctImage:NO completion:^(NSArray<FaceRecognizeResult *> * _Nonnull results) {
        if (isEmptyArray(results)) {
            *status = FacexDetectStatus_NONE;
        } else {
            recgnizeResults = results;
            *status = FacexDetectStatus_OK;
        }
    }];
    // 裁剪还原
    for (FaceRecognizeResult *recgnizeResult in recgnizeResults) {
        recgnizeResult.x = recgnizeResult.x + boxRect.origin.x;
        recgnizeResult.y = recgnizeResult.y + boxRect.origin.y;
    }

    return recgnizeResults;
}

- (float)compareWithFaceOneToken:(NSString *)faceOneToken faceTwoToken:(NSString *)faceTwoToken status:(FacexCompareStatus *)status {
    if (isEmptyString(faceOneToken)) {
        NSLog(@"图一未检测到人脸");
        *status = FacexCompareStatus_FACE_ONE_NONE;
        return 0;
    }
    if (isEmptyString(faceTwoToken)) {
        NSLog(@"图二未检测到人脸");
        *status = FacexCompareStatus_FACE_TWO_NONE;
        return 0;
    }
    float score = [Facexdet comparisonFace:faceOneToken faceTokenTwo:faceTwoToken];
    *status = FacexCompareStatus_OK;
    return score;
}

- (NSArray<NSNumber *> *)compareWithFaceOneToken:(NSString *)faceOneToken otherFaceTokens:(NSArray<NSString *> *)otherFaceTokens status:(FacexCompareStatus *)status {
    if (isEmptyString(faceOneToken)) {
        NSLog(@"图一未检测到人脸");
        *status = FacexCompareStatus_FACE_ONE_NONE;
        return nil;
    }
    if (isEmptyArray(otherFaceTokens)) {
        NSLog(@"图二未检测到人脸");
        *status = FacexCompareStatus_FACE_TWO_NONE;
        return nil;
    }
    __block NSArray *scoreArray = nil;
    [Facexdet recognizeFaces:faceOneToken featureOther:otherFaceTokens completion:^(NSArray<FaceRecognizeResult *> * _Nonnull results) {
        if (!isEmptyArray(results)) {
            NSMutableArray *mArr = [NSMutableArray array];
            for (FaceRecognizeResult *result in results) {
                [mArr addObject:[NSNumber numberWithFloat:result.faceScore]];
            }
            scoreArray = [mArr copy];
        }
    }];
    *status = FacexCompareStatus_OK;
    return scoreArray;
}

- (float)compareWithFaceOneImage:(UIImage *)faceOneImage faceTwoImage:(UIImage *)faceTwoImage status:(FacexCompareStatus *)status {
    if (isEmptyImage(faceOneImage)) {
        NSLog(@"图一未检测到人脸");
        *status = FacexCompareStatus_FACE_ONE_NONE;
        return 0;
    }
    
    faceOneImage = [self fixOrientation:faceOneImage];

    __block FaceRecognizeResult *faceOneResult = nil;
    [Facexdet faceDetectWithImage:faceOneImage correctImage:NO completion:^(NSArray<FaceRecognizeResult *> * _Nonnull results) {
            if (!isEmptyArray(results)) {
                faceOneResult = results[0];
            }
    }];
    if (isEmptyString(faceOneResult.token)) {
        NSLog(@"图一未检测到人脸");
        *status = FacexCompareStatus_FACE_ONE_NONE;
        return 0;
    }
    
    if (isEmptyImage(faceTwoImage)) {
        NSLog(@"图二未检测到人脸");
        *status = FacexCompareStatus_FACE_TWO_NONE;
        return 0;
    }
    
    faceTwoImage = [self fixOrientation:faceTwoImage];

    __block FaceRecognizeResult *faceTwoResult = nil;
    [Facexdet faceDetectWithImage:faceTwoImage correctImage:NO completion:^(NSArray<FaceRecognizeResult *> * _Nonnull results) {
            if (!isEmptyArray(results)) {
                faceTwoResult = results[0];
            }
    }];
    if (isEmptyString(faceTwoResult.token)) {
        NSLog(@"图二未检测到人脸");
        *status = FacexCompareStatus_FACE_TWO_NONE;
        return 0;
    }
    
    float score = [Facexdet comparisonFace:faceOneResult.token faceTokenTwo:faceTwoResult.token];
    *status = FacexCompareStatus_OK;
    return score;
}


- (UIImage *)getFrontFaceWithImage:(UIImage *)image {
    if (isEmptyImage(image)) {
        NSLog(@"图片异常");
        return nil;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:TempFrontFaceFolder]) {
       [fileManager createDirectoryAtPath:TempFrontFaceFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    // 修正图片方向
    image = [self fixOrientation:image];
    // 每次随机生成名字
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@.jpg", TempFrontFaceFolder, [self getRandomName:6]];
    [Facexdet getFrontFaceWithImage:image bestImagePath:fullPath];
    UIImage *afterImage = [UIImage imageWithContentsOfFile:fullPath];
    return afterImage;
}

- (UIImage *)getFaceCutoutWithImage:(UIImage *)image {
    if (isEmptyImage(image)) {
        NSLog(@"图片异常");
        return nil;
    }
    image = [self fixOrientation:image];
    
    FacexDetectStatus detStatus = FacexDetectStatus_OK;
    FaceRecognizeResult *result = [self maxFaceDetectWithImage:image boxRect:CGRectMake(0, 0, image.size.width, image.size.height) status:&detStatus];
    if (detStatus == FacexDetectStatus_OK) {
        // 裁剪范围扩大1倍
        CGFloat x = result.x - result.width / 2;
        CGFloat y = result.y - result.height / 2;
        CGFloat w = result.width * 2;
        CGFloat h = result.height * 2;
        return [self cutImage:image inRect:CGRectMake(x, y, w, h)];
    }
    return image;
}

- (UIImage *)fixOrientation:(UIImage *)image {
    if (isEmptyImage(image)) {
        NSLog(@"图片异常");
        return nil;
    }
    // No-op if the orientation is already correct
    if (image.imageOrientation == UIImageOrientationUp)
        return image;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

// MARK: - 工具类
- (NSString *)getRandomName:(int)length {
    NSMutableString *mString = [NSMutableString string];
    for (int i = 0; i < length; i++) {
        [mString appendFormat:@"%d", arc4random()%10];
    }
    return [mString copy];
}
- (UIImage *)cutImage:(UIImage *)image inRect:(CGRect)rect {
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *newImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return newImage;
}
static inline BOOL isEmptyImage(UIImage *image) {
    if (image == nil) {
        return YES;
    }
    return NO;
}
static inline BOOL isEmptyString(NSString *string) {
    if (string == nil) {
        return YES;
    }
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if ([string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length == 0) {
        return YES;
    }
    return NO;
}

static inline BOOL isEmptyArray(NSArray *array) {
    if (array == nil) {
        return YES;
    }
    if ([array isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (array.count == 0) {
        return YES;
    }
    return NO;
}


@end
