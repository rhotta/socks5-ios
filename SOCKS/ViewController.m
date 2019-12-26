//
//  ViewController.m
//  SOCKS
//
//  Created by Robert Xiao on 8/19/18.
//  Copyright © 2018 Robert Xiao. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

@interface ViewController ()

@end

@implementation ViewController

extern int socks_main(int argc, const char** argv);

- (void)viewDidLoad {
    [super viewDidLoad];

    int port = 4884;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        char portbuf[32];
        sprintf(portbuf, "%d", port);
        const char *argv[] = {"microsocks", "-p", portbuf, NULL};

        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary* addresses = [AppDelegate deviceIPAddress];
            NSString* address = @"";
            for (id key in [addresses keyEnumerator]) {
                address = [NSString stringWithFormat:@"%@\n%@: %@:%d",address,key,[addresses objectForKey:key],port];
            }
            [self.statusLabel setText:[NSString stringWithFormat:@"Running at%@", address]];
        });

        int status = socks_main(3, argv);

        dispatch_async(dispatch_get_main_queue(), ^{
            [self.statusLabel setText:[NSString stringWithFormat:@"Failed to start: %d", status]];
        });
    });

    /* Extremely hacky way to keep app running in the background.
     This WILL get the app rejected from the App Store! */
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"blank" ofType:@"wav"]];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self.audioPlayer setVolume:0.01];
    [self.audioPlayer setNumberOfLoops:-1];
    [self.audioPlayer prepareToPlay];
    [self.audioPlayer play];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
