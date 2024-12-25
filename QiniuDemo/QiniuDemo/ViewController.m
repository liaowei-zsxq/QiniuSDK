//
//  ViewController.m
//  QiniuDemo
//
//  Created by   何舒 on 16/3/2.
//  Copyright © 2016年 Aaron. All rights reserved.
//

#if __has_include("Configure.h")
#import "Configure.h" // 测试参数配置，暂时只有token，可删除
#else
#define YourToken @""
#endif

#import "ViewController.h"
//#import "QNTransactionManager.h"
#import <HappyDNS/HappyDNS.h>
#import <Photos/Photos.h>
#import <TZImagePickerController/TZImagePickerController.h>

typedef NS_ENUM(NSInteger, UploadState){
    UploadStatePrepare,
    UploadStateUploading,
    UploadStateCancelling
};
@interface DnsItem : NSObject <QNIDnsNetworkAddress,TZImagePickerControllerDelegate>
@property(nonatomic,   copy)NSString *hostValue;
@property(nonatomic,   copy)NSString *ipValue;
@property(nonatomic, strong)NSNumber *ttlValue;
@property(nonatomic,   copy)NSString *sourceValue;
@property(nonatomic, strong)NSNumber *timestampValue;
@end
@implementation DnsItem
@end

@interface ViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, QNDnsDelegate>

@property (nonatomic, weak) IBOutlet UIButton* chooseBtn;
@property (nonatomic, weak) IBOutlet UIButton* uploadBtn;
@property (nonatomic, weak) IBOutlet UIImageView* preViewImage;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;

@property (nonatomic, assign) UploadState uploadState;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) UIImage *pickImage;
@property (nonatomic, strong) PHAsset *pickFile;

@end

@implementation ViewController

#define kUploadFixHost00 @"up-z0.qbox.me"
#define kUploadFixHost01 @"upload.qbox.me"

- (void)viewDidLoad {
    [super viewDidLoad];
    [QNLogUtil setLogLevel:QNLogLevelInfo];
    
    // Do any additional setup after loading the view, typically from a nib.
    [self changeUploadState:UploadStatePrepare];
    self.title = @"七牛云上传";
}

- (IBAction)chooseAction:(UIButton *)sender {
    [self gotoImageLibrary];
}

- (IBAction)uploadAction:(UIButton *)sender {
    if (self.uploadState == UploadStatePrepare) {
    
#ifdef YourToken
        NSString *path = [[NSBundle mainBundle] pathForResource:@"UploadResource.dmg" ofType:nil];
        path = [[NSBundle mainBundle] pathForResource:@"image.png" ofType:nil];
        path = [[NSBundle mainBundle] pathForResource:@"image.jpg" ofType:nil];
        path = [[NSBundle mainBundle] pathForResource:@"UploadResource_14M.zip" ofType:nil];
//        path = [[NSBundle mainBundle] pathForResource:@"UploadResource_9M.zip" ofType:nil];
//        path = [[NSBundle mainBundle] pathForResource:@"UploadResource_49M.zip" ofType:nil];
//        path = [[NSBundle mainBundle] pathForResource:@"UploadResource_1G.zip" ofType:nil];
        
//        NSFileManager *manager = [NSFileManager defaultManager];
//        NSURL *desktopUrl = [manager URLsForDirectory:NSDesktopDirectory inDomains:NSUserDomainMask].firstObject;
//        path = [desktopUrl URLByAppendingPathComponent:@"pycharm.dmg"].path;
        
        [self uploadImageToQNFilePath:path index:0];
//        [self uploadImageToQNFilePath:path complete:nil];
        [self changeUploadState:UploadStateUploading];
#else
        if (self.pickImage == nil) {
            [self alertMessage:@"还未选择图片"];
        } else {
            [self uploadImageToQNFilePath:[self getImagePath:self.pickImage]];
            [self changeUploadState:UploadStateUploading];
        }
#endif
        
    } else {
        [self changeUploadState:UploadStateCancelling];
    }
}

- (void)changeUploadState:(UploadState)uploadState{
    
    self.uploadState = uploadState;
    if (uploadState == UploadStatePrepare) {
        [self.uploadBtn setTitle:@"上传" forState:UIControlStateNormal];
        self.uploadBtn.enabled = true;
    } else if (uploadState == UploadStateUploading) {
        [self.uploadBtn setTitle:@"取消上传" forState:UIControlStateNormal];
        self.uploadBtn.enabled = true;
    } else {
        [self.uploadBtn setTitle:@"取消上传" forState:UIControlStateNormal];
        self.uploadBtn.enabled = false;
    }
}

- (void)uploadImageToQNFilePath:(NSString *)filePath index:(NSInteger)index {
    index++;
    NSDate *start = [NSDate date];
    NSLog(@"\n======= 第 %ld 次上传开始", index);
    
    [self uploadImageToQNFilePath:filePath complete:^{
        NSDate *end = [NSDate date];
        NSLog(@"\n======= 第 %ld 次上传结束 耗时：%lfs", index, [end timeIntervalSinceDate:start]);
//        [self uploadImageToQNFilePath:filePath index:index];
    }];
}

- (void)uploadImageToQNFilePath:(NSString *)filePath complete:(dispatch_block_t)complete {
    
//    kQNGlobalConfiguration.isDnsOpen = NO;
//    kQNGlobalConfiguration.connectCheckEnable = false;
//    kQNGlobalConfiguration.dnsCacheMaxTTL = 600;
//    kQNGlobalConfiguration.partialHostFrozenTime = 20*60;
//    kQNGlobalConfiguration.dns = self;
    
//    [QNServerConfigMonitor removeConfigCache];
    
    kQNGlobalConfiguration.udpDnsIpv4Servers = @[@"223.5.5.5", @"114.114.114.114"];
    kQNGlobalConfiguration.dohIpv4Servers = @[@"https://223.6.6.6/dns-query"];
    
    NSString *key = [NSString stringWithFormat:@"iOS_Demo_%@", [NSDate date]];
    key = @"iOS-Test";
    self.token = YourToken;
    self.token = @"5cJEzNSnh3PjOHZR_E0u1HCkXw4Bw1ZSuWQI9ufz:-ul1AJ8Fvpc7WhtpVT91Pvdfreo=:eyJzY29wZSI6InpvbmUwLXNwYWNlIiwiZGVhZGxpbmUiOjM0MzM3NDYyNTl9";
    
    
    QNConfiguration *configuration = [QNConfiguration build:^(QNConfigurationBuilder *builder) {
        builder.timeoutInterval = 90;
        builder.retryMax = 1;
//        builder.useHttps = NO;

        builder.useConcurrentResumeUpload = false;
        builder.concurrentTaskCount = 2;
        builder.resumeUploadVersion = QNResumeUploadVersionV2;
        builder.putThreshold = 4*1024*1024;
        builder.chunkSize = 5*1024*1024;
        builder.accelerateUploading = true;
//        builder.zone = [[QNFixedZone alloc] initWithAccUpDomainList:@[@"zone0-space.kodo-accelerate.cn-east-1.qiniucs.com"]
//                                                             upList:@[kUploadFixHost00]
//                                                          oldUpList:@[]
//                                                           regionId:@"custom"];
        // [[QNFixedZone alloc] initWithUpDomainList:@[kUploadFixHost00, kUploadFixHost01]];
        NSString *recorderPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSLog(@"== record path:%@", recorderPath);
        builder.recorder = [QNFileRecorder fileRecorderWithFolder:recorderPath error:nil];
    }];
    
    
    QNUploadManager *upManager = [[QNUploadManager alloc] initWithConfiguration:configuration];
    
    __weak typeof(self) weakSelf = self;
    QNUploadOption *uploadOption = [[QNUploadOption alloc] initWithMime:nil progressHandler:^(NSString *key, float percent) {
        NSLog(@"percent == %.2f", percent);
        weakSelf.progressView.progress = percent;
    }
                                                                 params:nil
                                                               checkCrc:NO
                                                     cancellationSignal:^BOOL{
        return weakSelf.uploadState == UploadStateCancelling;
    }];

    // File
//    [upManager putFile:filePath key:key token:self.token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
//        NSLog(@"info ===== %@", info);
//        NSLog(@"resp ===== %@", resp);
//
//        [weakSelf changeUploadState:UploadStatePrepare];
//        [weakSelf alertMessage:info.message];
//        
//        if (complete) {
//            complete();
//        }
//    }
//                option:uploadOption];
   
    // NSInputStream no size
//    NSDate *startData = [NSDate date];
//    long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
//    NSInputStream *stream = [NSInputStream inputStreamWithFileAtPath:filePath];
//    [upManager putInputStream:stream sourceId:filePath.lastPathComponent size:fileSize fileName:filePath.lastPathComponent key:key token:self.token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
//        NSLog(@"info ===== %@", info);
//        NSLog(@"resp ===== %@", resp);
//
//        [weakSelf changeUploadState:UploadStatePrepare];
//        [weakSelf alertMessage:[NSString stringWithFormat:@"%@ \n duration:%f", info.message, [[NSDate date] timeIntervalSinceDate:startData]]];
//    } option:uploadOption];
    
    
    // NSInputStream has size
//    long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil] fileSize];
//    NSInputStream *stream = [NSInputStream inputStreamWithFileAtPath:filePath];
//    [upManager putInputStream:stream sourceId:filePath.lastPathComponent size:fileSize fileName:filePath.lastPathComponent key:key token:self.token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
//
//        NSLog(@"info ===== %@", info);
//        NSLog(@"resp ===== %@", resp);
//
//        [weakSelf changeUploadState:UploadStatePrepare];
//        [weakSelf alertMessage:info.message];
//    } option:uploadOption];

    
    // PHAsset
//    NSURL *url = [NSURL fileURLWithPath:filePath];
//    PHFetchResult *fetchResult = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
//    [upManager putPHAsset:self.pickFile key:key token:self.token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
//        NSLog(@"info ===== %@", info);
//        NSLog(@"resp ===== %@", resp);
//
//        [weakSelf changeUploadState:UploadStatePrepare];
//        [weakSelf alertMessage:info.message];
//    }
//                option:uploadOption];
    
    
    // PHAssetResource
    // 注意：这里可能还需要包括其他你需要的资源类型
    PHAssetResource *source = [PHAssetResource assetResourcesForAsset:self.pickFile].firstObject;
    [upManager putPHAssetResource:source key:source.assetLocalIdentifier token:self.token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        NSLog(@"info ===== %@", info);
        NSLog(@"resp ===== %@", resp);
        NSLog(@"key  ===== %@", self.pickFile.burstIdentifier);

        [weakSelf changeUploadState:UploadStatePrepare];
        [weakSelf alertMessage:info.message];
        
    } option:uploadOption];
    
    
}

- (PHAsset *)getPHAssert {
    
    PHFetchOptions *option = [[PHFetchOptions alloc] init];
    option.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld",PHAssetMediaTypeVideo];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    
    __block PHAsset *phAsset = nil;
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionSubtypeAny subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in smartAlbums) {
        // 有可能是PHCollectionList类的的对象，过滤掉
        if (![collection isKindOfClass:[PHAssetCollection class]]) continue;
        // 过滤空相册
        if (collection.estimatedAssetCount <= 0) continue;

        PHFetchResult<PHAsset *> *fetchResult = [PHAsset fetchAssetsInAssetCollection:collection options:option];
        if (fetchResult.count > 0) {
            return fetchResult.firstObject;
        }
    }
    
    return phAsset;
}

- (void)gotoImageLibrary {
    
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self];

    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto) {
        if (assets.firstObject) {
            self.pickFile = assets.firstObject;
            self.preViewImage.image = photos.firstObject;
//            [[TZImageManager manager] getOriginalPhotoWithAsset:self.pickFile completion:^(UIImage *photo, NSDictionary *info) {
//                self.preViewImage.image = photo;
//            }];
        }
    }];
    [imagePickerVc setDidFinishPickingVideoHandle:^(UIImage *coverImage, PHAsset *asset) {
        self.pickFile = asset;
        self.preViewImage.image = coverImage;
//        [[TZImageManager manager] getVideoWithAsset:asset completion:^(AVPlayerItem *playerItem, NSDictionary *info) {
//            self.preViewImage.image = photo;
//        }];
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}

//照片获取本地路径转换
- (NSString *)getImagePath:(UIImage *)Image {
    NSString *filePath = nil;
    NSData *data = nil;
    if (UIImagePNGRepresentation(Image) == nil) {
        data = UIImageJPEGRepresentation(Image, 1.0);
    } else {
        data = UIImagePNGRepresentation(Image);
    }

    //图片保存的路径
    //这里将图片放在沙盒的documents文件夹中
    NSString *DocumentsPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];

    //文件管理器
    NSFileManager *fileManager = [NSFileManager defaultManager];

    //把刚刚图片转换的data对象拷贝至沙盒中
    [fileManager createDirectoryAtPath:DocumentsPath withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *ImagePath = [[NSString alloc] initWithFormat:@"/theFirstImage.png"];
    [fileManager createFileAtPath:[DocumentsPath stringByAppendingString:ImagePath] contents:data attributes:nil];

    //得到选择后沙盒中图片的完整路径
    filePath = [[NSString alloc] initWithFormat:@"%@%@", DocumentsPath, ImagePath];
    return filePath;
}


- (void)alertMessage:(NSString *)message{
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
//    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//    }]];
//    [self presentViewController:alert animated:YES completion:nil];
    NSLog(@"======== alert:%@", message);
}

- (NSArray<id<QNIDnsNetworkAddress>> *)lookup:(NSString *)host {
    NSMutableArray *array = [NSMutableArray array];
    if ([host containsString:@"uc.qbox.me"]) {
        DnsItem *item = [[DnsItem alloc] init];
        item.hostValue = host;
        item.ipValue = @"180.101.136.19";
        item.sourceValue = @"custom";
        [array addObject:item];
    } else if ([host containsString:kUploadFixHost00]) {
        DnsItem *item = [[DnsItem alloc] init];
        item.hostValue = host;
        item.ipValue = @"220.181.38.148";
        item.sourceValue = @"custom";
        [array addObject:item];
        
        item = [[DnsItem alloc] init];
        item.hostValue = host;
        item.ipValue = @"180.101.136.28";
        item.sourceValue = @"custom";
        [array addObject:item];
    }
    return [array copy];
}

@end
