//
//  CameraViewController.m
//  SnapRoulette
//
//  Created by Nikolas Gelo on 11/8/14.
//  Copyright (c) 2014 Nikolas Gelo. All rights reserved.
//

#import "CameraViewController.h"

#import <GPUImage/GPUImage.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <Parse/Parse.h>

@interface CameraViewController ()

@property (nonatomic, weak) IBOutlet GPUImageView *cameraView;

@property (nonatomic, strong) GPUImageStillCamera *camera;
@property (nonatomic, strong) GPUImageGammaFilter *gammaFilter;

- (IBAction)sendPhoto:(id)sender;

@end

@implementation CameraViewController

#pragma mark - CameraViewController

- (IBAction)sendPhoto:(id)sender
{
    NSLog(@"Send that photo!!");

    [self.camera capturePhotoAsImageProcessedUpToFilter:self.gammaFilter withCompletionHandler:^(UIImage *processedImage, NSError *error) {
        // Display a HUD to the user to indicate that the span is being sent.
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeIndeterminate;
        hud.labelText = @"Sending Photo";
        
        // Create a file for the image that was just taken.
        PFFile *imageFile = [PFFile fileWithName:@"snap.jpg" data:UIImageJPEGRepresentation(processedImage, 0.8)];
        
        // Create the snap object and save it.
        PFObject *snap = [PFObject objectWithClassName:@"Snap"];
        snap[@"imageFile"] = imageFile;
        snap[@"hasBeenViewed"] = @NO;
        snap[@"deviceId"] = [[PFInstallation currentInstallation] objectId];
        [snap saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [hud hide:YES];
        }];
    }];
}

#pragma mark - UIViewController
#pragma mark Managing the View

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Instantiate the camera.
    self.camera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480
                                                      cameraPosition:AVCaptureDevicePositionBack];
    self.camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    // Use a gamma filter so that image can be retrieved.
    //
    // Found here: http://www.sunsetlakesoftware.com/forum/capture-image-gpuimagestillcamera-without-filter
    self.gammaFilter = [[GPUImageGammaFilter alloc] init];
    
    // Setup the camera filter chain with a gamma filter that will be used just so that pictures
    // can be extracted and a camera view that will display the feed from the camera.
    [self.camera addTarget:self.gammaFilter];
    [self.gammaFilter addTarget:self.cameraView];
}

#pragma mark Responding to View Events

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Start the camera.
    [self.camera startCameraCapture];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    // Stop the camera.
    [self.camera stopCameraCapture];
}

@end
