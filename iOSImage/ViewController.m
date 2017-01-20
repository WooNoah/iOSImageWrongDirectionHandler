//
//  ViewController.m
//  iOSImage
//
//  Created by tb on 17/1/20.
//  Copyright © 2017年 com.tb. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic,strong) IBOutlet UIButton *chooseBtn;

@property (nonatomic,strong) IBOutlet UIImageView *showImgView;

@property (nonatomic,strong) UIImagePickerController *imagePicker;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}



- (IBAction)chooseAction:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"title" message:@"choose images from Photo Library" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"Camera" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [self loadImagePickerControllerWithType:UIImagePickerControllerSourceTypeCamera];
        }else {
            NSLog(@"您的设备不支持拍照功能");
        }
    }];
    [alert addAction:cameraAction];
    
    
    UIAlertAction *chooseAction = [UIAlertAction actionWithTitle:@"Photo Library" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
            [self loadImagePickerControllerWithType:UIImagePickerControllerSourceTypePhotoLibrary];
        }else {
            NSLog(@"您的设备不支持相册功能");
        }
    }];
    [alert addAction:chooseAction];
    
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alert addAction:cancelAction];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)loadImagePickerControllerWithType:(UIImagePickerControllerSourceType)type {
    //实例化一个 UIImagePickerController (内部有 相册和拍照功能模块)
    self.imagePicker = [[UIImagePickerController alloc] init];
    //设置 UIImagePickerController 类型 是相册 还是 拍照
    self.imagePicker.sourceType = type;
    //如果要处理 choose 和cancel 按钮 那么 要设置代理 实现方法
    self.imagePicker.delegate = self;
    //是否允许 编辑
    //    imagePicker.allowsEditing = YES;
    
    //imagePicker 内部自带导航 所以要用模态 跳转
    [self presentViewController:self.imagePicker animated:YES completion:nil];
}

#pragma mark - UIImagePickerController delegate
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    
    if (info[UIImagePickerControllerEditedImage]) {
        UIImage *img = (UIImage *)info[UIImagePickerControllerEditedImage];
        UIImageOrientation imageOrientation = img.imageOrientation;
        [self saveImage:img withDirection:imageOrientation];
    }else {
        UIImage *img = (UIImage *)info[UIImagePickerControllerOriginalImage];
        UIImageOrientation imageOrientation = img.imageOrientation;
        [self saveImage:img withDirection:imageOrientation];
    }
    
    [picker dismissViewControllerAnimated:true completion:nil];
}

- (void)saveImage:(UIImage *)image withDirection:(UIImageOrientation)direction {
    
    if(direction != UIImageOrientationUp)
    {
        // 原始图片可以根据照相时的角度来显示，但UIImage无法判定，于是出现获取的图片会向左转９０度的现象。
        // 以下为调整图片角度的部分
        UIGraphicsBeginImageContext(image.size);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        // 调整图片角度完毕
    }
    
    
    //获取图片的长宽，然后截取其中居中部分的正方形
    CGImageRef imgRef = image.CGImage;
    
    CGFloat imgWidth  = CGImageGetWidth(imgRef);
    CGFloat imgHeight = CGImageGetHeight(imgRef);
    
    CGImageRef clipImgRef;
    if (imgWidth > imgHeight) {
        clipImgRef = CGImageCreateWithImageInRect(imgRef, CGRectMake((imgWidth - imgHeight)/2, 0, imgHeight, imgHeight));
    }else if (imgHeight > imgWidth) {
        clipImgRef = CGImageCreateWithImageInRect(imgRef, CGRectMake(0,(imgHeight - imgWidth)/2, imgWidth, imgWidth));
    }
    UIImage *scaleImg = [UIImage imageWithCGImage:clipImgRef];
    
    
    NSData *data = UIImageJPEGRepresentation([self scaleFromImage:scaleImg size:CGSizeMake(150, 150)], 1);
    
    self.showImgView.image = [UIImage imageWithData:data];
}


/** 改变图片的宽高*/
- (UIImage *)scaleFromImage:(UIImage *)image size:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return newImage;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
