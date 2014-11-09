//
//  RouletteViewController.m
//  SnapRoulette
//
//  Created by Nikolas Gelo on 11/8/14.
//  Copyright (c) 2014 Nikolas Gelo. All rights reserved.
//

#import "RouletteViewController.h"

#import <MBProgressHUD/MBProgressHUD.h>
#import <Parse/Parse.h>

@interface RouletteViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *snapImageView;

@property (nonatomic, strong) NSTimer *loadSnapsTimer;

@property (nonatomic) dispatch_queue_t loadSnapsTimerQueue;

- (void)loadSnaps;

@end

@implementation RouletteViewController

#pragma mark - RouletteViewController

- (void)loadSnaps
{
    // Initialize the snap query.
    PFQuery *snapQuery = [PFQuery queryWithClassName:@"Snap"];
    [snapQuery orderByAscending:@"createdAt"];
    [snapQuery whereKey:@"hasBeenViewed" equalTo:@NO];
    [snapQuery whereKey:@"deviceId" notEqualTo:[[PFInstallation currentInstallation] objectId]];
    
    [snapQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
        // A snap was returned.
        if (object && error == nil) {
            // Get the snap image file.
            PFFile *snapImageFile = object[@"imageFile"];
            
            // Load the snap image data in the background.
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                NSData *snapImageData = [snapImageFile getData];
                
                // Once the image data has been loaded, update the image view
                // & mark the snap as saved.
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIImage *snapImage = [UIImage imageWithData:snapImageData];
                    self.snapImageView.image = snapImage;
                    
                    // Mark the snap object as viewed and save the updated
                    // state to Parse.
                    object[@"hasBeenViewed"] = @YES;
                    [object saveInBackground];
                });
            });
            
        } else if (error) {
            NSLog(@"Error occured: %@", error);
            
            // Show a HUD to the user indicating that there are no more
            // snaps that can be loaded.
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.labelText = @"No more snaps...";
            
            // Set the default roulette image.
            self.snapImageView.image = [UIImage imageNamed:@"Roulette Start"];
            
            // Stop the load snaps timer.
            [self.loadSnapsTimer invalidate];
        } else if (!object) {
            NSLog(@"No object!");
        }
    }];
}

#pragma mark - UIResponder
#pragma mark Responding to Touch Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touches began");
    
    // Hide the HUDs.
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    
    // Create and start the load snaps timer.
    self.loadSnapsTimer = [NSTimer scheduledTimerWithTimeInterval:5
                                                           target:self
                                                         selector:@selector(loadSnaps)
                                                         userInfo:nil
                                                          repeats:YES];
    [self.loadSnapsTimer fire];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"Touches ended");
    
    // Stop the load snaps timer.
    [self.loadSnapsTimer invalidate];
    
    // Set the default roulette image.
    self.snapImageView.image = [UIImage imageNamed:@"Roulette Start"];
}

@end
