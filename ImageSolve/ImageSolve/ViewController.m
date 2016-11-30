//
//  ViewController.m
//  ImageSolve
//
//  Created by at on 2016/11/28.
//  Copyright © 2016年 at. All rights reserved.
//

#import "ViewController.h"
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
//    UIImage *image =[UIImage imageNamed:@"22.jpg"];
    
    //保存图片到相册
//    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);

    
    //格式转换
    [self jpgToPng];
    
    //把gif分解成png
    [self gifDevice];

    //展示合成gif
    [self showGif];
    
    //合成gif文件
    [self CreateGif];
    
    
    
    
    
}

//图片类型转换
-(void)jpgToPng{
    
     UIImage *image =[UIImage imageNamed:@"22.jpg"];
    //转换
    NSData *data= UIImagePNGRepresentation(image);
    UIImage *newImage =[[UIImage alloc]initWithData:data];
    
    //保存
    UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil);
    
    UIImageView *im=[[UIImageView alloc]initWithFrame:CGRectMake(30, 100, 200, 200)];
    im.image=newImage;
    [self.view addSubview:im];
}
//jpg转换jpg
-(void)jpgToJpg{
    
    UIImage *image =[UIImage imageNamed:@"22.jpg"];
    //转换 参数1是源文件 参数二是质量参数因子 越小 清晰度和模糊度越差 0-1之间
    NSData *data= UIImageJPEGRepresentation(image, 1);
    
    UIImage *newImage =[[UIImage alloc]initWithData:data];
    
    //保存
    UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil);
    
    UIImageView *im=[[UIImageView alloc]initWithFrame:CGRectMake(30, 100, 200, 200)];
    im.image=newImage;
    [self.view addSubview:im];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)gifDevice{
    //获取资源路径
    NSString *path =[[NSBundle mainBundle]pathForResource:@"arrowDirctions" ofType:@"gif"];
    //获取资源
    NSData *data=[NSData dataWithContentsOfFile:path];
    CGImageSourceRef source= CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    
    //转换成帧
    size_t count =CGImageSourceGetCount(source);
    NSLog(@"共有=%zu",count);
    //
    NSMutableArray *arry =[NSMutableArray array];
    for (size_t i=0; i<count; i++) {
        
        //获取每一帧的数据源
        CGImageRef imageref=CGImageSourceCreateImageAtIndex(source, i, NULL);
        //将数据转换成image
        UIImage *image= [UIImage imageWithCGImage:imageref scale:[UIScreen mainScreen].scale orientation:UIImageOrientationUp];
    
        [arry addObject:image];
    
        //释放数据源 避免内存泄露
        CGImageRelease(imageref);
        
    }
    CFRelease(source);
    
    
    //单帧照片保存
    int i=0;
    for (UIImage *image in arry) {
        
        NSData *data =UIImagePNGRepresentation(image);
        //获取沙盒路径
        NSArray *path=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *paths=path[0];
//        NSLog(@"paths==%@",paths);
        NSString *pathNum=[paths stringByAppendingString:[NSString stringWithFormat:@"%d.png",i++]];
        //写入沙盒路径下
        [data writeToFile:pathNum atomically:NO];
        
    
    }
    
    
    
    
}

//显示gif动画
-(void)showGif{
    
    NSMutableArray *arry=[[NSMutableArray alloc]init];
    
        UIImageView *im=[[UIImageView alloc]initWithFrame:CGRectMake(30, 230, 200, 200)];
        [self.view addSubview:im];
    
    for (int i=0; i<24; i++) {
        
        UIImage *image=[UIImage imageNamed:[NSString stringWithFormat:@"Documents%d.png",i]];
        [arry addObject:image];
        
    }
    
    
    [im setAnimationImages:arry];
    [im setAnimationRepeatCount:10];
    [im setAnimationDuration:3];
    [im startAnimating];
    
    
}
-(void)CreateGif{
    
    NSArray *images=@[[UIImage imageNamed:@"Documents0.png"],[UIImage imageNamed:@"Documents1.png"],[UIImage imageNamed:@"Documents2.png"],[UIImage imageNamed:@"Documents3.png"]];
    //创建gif文件夹
    NSArray *patharry=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path=patharry[0];
    NSFileManager *manger=[NSFileManager defaultManager];
    NSString *gifPath=[path stringByAppendingString:@"/gif"];
    //创建文件夹
    [manger createDirectoryAtPath:gifPath withIntermediateDirectories:YES attributes:nil error:nil];
    //文件地址
    NSString *endPath=[gifPath stringByAppendingString:@"/test.gif"];
    NSLog(@"文件地址=====%@",endPath);
    //配置gif属性
    CGImageDestinationRef destion;
    CFURLRef url = CFURLCreateWithFileSystemPath(kCFAllocatorDefault, (CFStringRef)endPath, kCFURLPOSIXPathStyle, false);
    destion = CGImageDestinationCreateWithURL(url, kUTTypeGIF, images.count, NULL);
    //设置持续时间
    NSDictionary *framedic=[NSDictionary dictionaryWithObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithFloat:0.3],(NSString*)kCGImagePropertyGIFDelayTime, nil] forKey:(NSString*)kCGImagePropertyGIFDelayTime];
    //设置gif属性
    NSMutableDictionary *gitDic =[NSMutableDictionary dictionaryWithCapacity:2];
    
    [gitDic setObject:[NSNumber numberWithBool:YES] forKey:(NSString*)kCGImagePropertyGIFHasGlobalColorMap];
    //设置gif的颜色模式
    [gitDic setObject:(NSString*)kCGImagePropertyColorModelRGB forKey:(NSString*)kCGImagePropertyColorModel];
    //是否循环
    [gitDic setObject:[NSNumber numberWithInt:0] forKey:(NSString*)kCGImagePropertyGIFLoopCount];
    //设置gif属性的字典
    NSDictionary *girpropertyDic =[NSDictionary dictionaryWithObject:gitDic forKey:(NSString*)kCGImagePropertyGIFDictionary];
    //将单帧照片添加gif里并设置时间延迟属性
    for (UIImage *dimage in images) {
        
        CGImageDestinationAddImage(destion, dimage.CGImage, (__bridge CFDictionaryRef)framedic);
        
    }
    CGImageDestinationSetProperties(destion, (__bridge CFDictionaryRef)girpropertyDic);
    //完成合成gif
    CGImageDestinationFinalize(destion);
    //释放资源，避免内存泄露
    CFRelease(destion);
    
    
    
}


@end
