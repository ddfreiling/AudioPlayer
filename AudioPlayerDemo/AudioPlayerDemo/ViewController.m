//
//  ViewController.m
//  AudioPlayerDemo
//
//  Created by Daniel Dam Freiling on 09/05/2017.
//  Copyright © 2017 Nota. All rights reserved.
//

#import "ViewController.h"

#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioPlayer/AudioPlayer-swift.h>

@interface ViewController () <AudioPlayerDelegate>

@property (strong, nonatomic) AudioPlayer *player;
@property (strong, nonatomic) NSArray *items;

- (AudioItem *)audioItemFromURLString:(NSString *)urlStr withTitle:(NSString*)title andArtist:(NSString*)artist;
- (NSNumber *) getIndexForAudioItem:(AudioItem *)item;

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setupPlayer];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (AudioItem *)audioItemFromURLString:(NSString *)urlStr withTitle:(NSString*)title andArtist:(NSString*)artist {
    AudioItem *item = [[AudioItem alloc] initWithHighQualitySoundURL:[NSURL URLWithString:urlStr]
                                    mediumQualitySoundURL:nil
                                       lowQualitySoundURL:nil];
    item.title = title;
    item.artist = artist;
    return item;
}

- (void)setupPlayer {
    self.player = [[AudioPlayer alloc] init];
    self.player.delegate = self;
    
    // Buffering strategy
    self.player.bufferingStrategy = AudioPlayerBufferingStrategyPlayWhenPreferredBufferDurationFull;
    self.player.preferredBufferDurationBeforePlayback = 2.0;
    self.player.preferredForwardBufferDuration = 600.0;
    self.player.timePitchAlgorithm = AVAudioTimePitchAlgorithmTimeDomain;
    self.player.remoteControlSkipIntervals = [NSArray arrayWithObjects:[NSNumber numberWithInt:10], nil];
    self.player.remoteControlSupportedPlaybackRates = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.5], [NSNumber numberWithFloat:1.0], [NSNumber numberWithFloat:1.5], nil];
    self.player.remoteCommandsEnabled = [NSArray arrayWithObjects:
                                         [NSNumber numberWithInt:AudioPlayerRemoteCommandChangePlaybackPosition],
                                         [NSNumber numberWithInt:AudioPlayerRemoteCommandSkipBackward],
                                         [NSNumber numberWithInt:AudioPlayerRemoteCommandPlayPause],
                                         [NSNumber numberWithInt:AudioPlayerRemoteCommandSkipForward],
                                         nil];
    
    // Default values, but setting explicitly
    self.player.resumeAfterInterruption = true;
    self.player.resumeAfterConnectionLoss = true;
    self.items = [[NSArray alloc] initWithObjects:
                  //                  [self audioItemFromURLString:@"https://lbs.nota.dk/api/v1.0/files/6115fbee-a21b-4d19-9bd9-c4670e8e5ca3/37027/0/01_michael_kamp_bunker_.mp3" withTitle:@"Intro" andArtist:@"Michael Kamp"],
                  //                  [self audioItemFromURLString:@"https://lbs.nota.dk/api/v1.0/files/6115fbee-a21b-4d19-9bd9-c4670e8e5ca3/37027/0/02_om_denne_udgave.mp3" withTitle:@"Om denne udgave" andArtist:@"Michael Kamp"],
                  //                  [self audioItemFromURLString:@"https://lbs.nota.dk/api/v1.0/files/6115fbee-a21b-4d19-9bd9-c4670e8e5ca3/37027/0/03_kolofon_og_bibliogra.mp3" withTitle:@"Kolofon og bib" andArtist:@"Michael Kamp"],
                  //                  [self audioItemFromURLString:@"https://lbs.nota.dk/api/v1.0/files/6115fbee-a21b-4d19-9bd9-c4670e8e5ca3/37027/0/04_citat.mp3" withTitle:@"Citat" andArtist:@"Michael Kamp"],
                  //                  [self audioItemFromURLString:@"https://lbs.nota.dk/api/v1.0/files/6115fbee-a21b-4d19-9bd9-c4670e8e5ca3/37027/0/05_kapitel_1.mp3" withTitle:@"Kapitel 1" andArtist:@"Michael Kamp"],
                  //                  [self audioItemFromURLString:@"https://lbs.nota.dk/api/v1.0/files/6115fbee-a21b-4d19-9bd9-c4670e8e5ca3/37027/0/06_kapitel_2.mp3" withTitle:@"Kapitel 2" andArtist:@"Michael Kamp"],
                  //                  nil];
                  [self audioItemFromURLString:@"https://archive.org/download/George-Orwell-1984-Audio-book/1984-01.mp3" withTitle:@"1984 - 1" andArtist:@"George Orwell"],
                  [self audioItemFromURLString:@"https://archive.org/download/George-Orwell-1984-Audio-book/1984-02.mp3" withTitle:@"1984 - 2" andArtist:@"George Orwell"],
                  [self audioItemFromURLString:@"https://archive.org/download/George-Orwell-1984-Audio-book/1984-03.mp3" withTitle:@"1984 - 3" andArtist:@"George Orwell"],
                  nil];
}


- (IBAction)play:(id)sender {
    if (self.player == nil) {        
        [self setupPlayer];
    }
    self.player.rate = 1.5;
    [self.player playWithItems:self.items startAtIndex:0];
}
- (IBAction)playPause:(id)sender {
    if (self.player.state == AudioPlayerStatePlaying) {
        [self.player pause];
    } else {
        [self.player resume];
    }
}

- (IBAction)back:(id)sender {
//    [self.player previous];
    NSLog(@"time & duration is: %@ / %@", self.player.currentItemProgression, self.player.currentItemDuration);
    self.player.currentItem.artworkImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:@"https://bookcover.nota.dk/711233_w140_h200.jpg"]]];
}

- (IBAction)forward:(id)sender {
    [self.player nextOrStop];
}

- (IBAction)seekSpecific:(id)sender {
    [self.player playWithItems:self.items startAtIndex:1];
    
    [self.player seekTo:50.5 byAdaptingTimeToFitSeekableRanges:false toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler: ^(BOOL success){
        NSLog(@"seek completed: %d", success);
    }];
}

- (IBAction)stop:(id)sender {
    [self.player stop];
}

- (NSNumber *) getIndexForAudioItem:(AudioItem *)item {
    return [NSNumber numberWithUnsignedInteger:[self.items indexOfObject:item]];
}

- (void)audioPlayer:(AudioPlayer *)audioPlayer didChangeStateFrom:(enum AudioPlayerState)from to:(enum AudioPlayerState)state {
    NSLog(@"changed from state %d to %d", (int)from, (int)state);
    if (state == AudioPlayerStateFailed) {
        NSLog(@"failed with error: %@", self.player.failedError);
    }
}
- (void)audioPlayer:(AudioPlayer *)audioPlayer willStartPlaying:(AudioItem *)item {
    NSLog(@"will start playing: %@", [self getIndexForAudioItem:item]);
}
- (void)audioPlayer:(AudioPlayer *)audioPlayer didUpdateProgressionTo:(NSTimeInterval)time percentageRead:(float)percentageRead {
    NSLog(@"updated progression to: time %.1f, percent %.1f", (float)time, percentageRead);
}
- (void)audioPlayer:(AudioPlayer *)audioPlayer didFindDuration:(NSTimeInterval)duration for:(AudioItem *)item {
    NSLog(@"found duration for %@: %f", [self getIndexForAudioItem:item], (float)duration);
}
- (void)audioPlayer:(AudioPlayer *)audioPlayer didLoadEarliest:(NSTimeInterval)earliest latest:(NSTimeInterval)latest for:(AudioItem *)item {
    float loaded = (float)latest - (float)earliest;
    NSLog(@"did load %@ - %f", [self getIndexForAudioItem:item], loaded);
}

@end
