//
//  AudioPlayer+RemoteControl.swift
//  AudioPlayer
//
//  Created by Daniel Dam Freiling on 15/05/2017.
//  Copyright © 2017 Kevin Delannoy. All rights reserved.
//

import Foundation
import MediaPlayer

/// TODO: Configurable which 3 remote commands to show. Use below enum
@objc public enum AudioPlayerRemoteCommand: Int {
    case playPause = 0
    case stop = 1
    case nextTrack = 2
    case previousTrack = 3
    case skipForward = 4
    case skipBackward = 5
    case seekForward = 6
    case seekBackward = 7
    case changePlaybackRate = 8
    case changeRepeatMode = 9
}

extension AudioPlayer {
    
    func registerRemoteControlHandlers() {
        // RemoteCommandCenter on iOS can have a max of 3 commands enabled at a time. Any others won't be shown.
        // TODO: Do other platforms have a 3 commands max as well?
        let remote = MPRemoteCommandCenter.shared()
        let commandsToRegister = [
            remote.previousTrackCommand,
            remote.playCommand,
            remote.pauseCommand,
            remote.nextTrackCommand,
            ]
        for command in commandsToRegister {
            command.removeTarget(self)
            command.addTarget(self, action: #selector(handleRemoteControlCommandEvent(_:)))
        }
        
        // Register togglePlayPause, which can be triggered by headset controls
        remote.togglePlayPauseCommand.removeTarget(self)
        remote.togglePlayPauseCommand.addTarget(self, action: #selector(handleRemoteControlCommandEvent(_:)))
        
        // Register remotePlaybackPostionChanged if supported by platform and enabled
        if #available(iOS 9.1, tvOS 9.1, OSX 10.12.1, *), self.remotePlaybackPositionChangeEnabled {
            remote.changePlaybackPositionCommand.removeTarget(self)
            remote.changePlaybackPositionCommand.addTarget(self, action: #selector(handleChangePlaybackPositionEvent(_:)))
        }
    }
    
    func setRemoteControlCommandsEnabled(_ enabled: Bool) {
        let remote = MPRemoteCommandCenter.shared()
        remote.previousTrackCommand.isEnabled = enabled
        remote.playCommand.isEnabled = enabled
        remote.pauseCommand.isEnabled = enabled
        remote.togglePlayPauseCommand.isEnabled = enabled
        remote.nextTrackCommand.isEnabled = enabled
        if #available(iOS 9.1, tvOS 9.1, OSX 10.12.1, *), self.remotePlaybackPositionChangeEnabled {
            remote.changePlaybackPositionCommand.isEnabled = enabled
        }
    }
    
    func handleRemoteControlCommandEvent(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        print(#function)
        guard (player?.currentItem) != nil else {
            if #available(iOS 9.1, tvOS 9.1, OSX 10.12.1, *) {
                return .noActionableNowPlayingItem
            } else {
                return .commandFailed
            }
        }
        let remote = MPRemoteCommandCenter.shared()
        
        // Assume success, must set to .failed inside case if necessary
        var handlerStatus = MPRemoteCommandHandlerStatus.success
        
        switch event.command {
            
        case (remote.stopCommand):
            self.stop()
        case (remote.nextTrackCommand):
            self.next()
        case (remote.previousTrackCommand):
            self.previous()
        case (remote.pauseCommand),
             (remote.togglePlayPauseCommand) where state.isPlaying:
            self.pause()
        case (remote.playCommand),
             (remote.togglePlayPauseCommand) where state.isPaused:
            self.resume()
        case (remote.seekBackwardCommand):
            handleRemoteControlSeekEvent(event, isForward: false)
        case (remote.seekForwardCommand):
            handleRemoteControlSeekEvent(event, isForward: true)
        case (remote.skipBackwardCommand):
            if let event = event as? MPSkipIntervalCommandEvent {
                self.seekToRelativeTime(-event.interval)
            }
        case (remote.skipForwardCommand):
            if let event = event as? MPSkipIntervalCommandEvent {
                self.seekToRelativeTime(event.interval)
            }
        case (remote.changePlaybackRateCommand):
            if let event = event as? MPChangePlaybackRateCommandEvent {
                self.rate = event.playbackRate
            }
        case (remote.changeRepeatModeCommand):
            handleChangeRepeatModeEvent(event)
        default:
            handlerStatus = .commandFailed
        }
        return handlerStatus
    }
    
    func handleChangePlaybackPositionEvent(_ event: MPChangePlaybackPositionCommandEvent) -> MPRemoteCommandHandlerStatus {
        self.seek(to: event.positionTime)
        return .success
    }
    
    func handleRemoteControlSeekEvent(_ event: MPRemoteCommandEvent, isForward: Bool) {
        guard let event = event as? MPSeekCommandEvent else {
            return
        }
        if (event.type == .beginSeeking) {
            seekingBehavior.handleSeekingStart(player: self, forward: isForward)
        } else {
            seekingBehavior.handleSeekingEnd(player: self, forward: isForward)
        }
    }
    
    func handleChangeRepeatModeEvent(_ event: MPRemoteCommandEvent) {
        guard let event = event as? MPChangeRepeatModeCommandEvent else {
            return
        }
        switch event.repeatType {
        case .off:
            self.mode = .normal
        case .one:
            self.mode = .repeat
        case .all:
            self.mode = .repeatAll
        }
    }
    
    func updateRemoteControlPreferredSkipIntervals(preferredIntervals: [NSNumber]) {
        let remote = MPRemoteCommandCenter.shared()
        remote.skipBackwardCommand.preferredIntervals = preferredIntervals
        remote.skipForwardCommand.preferredIntervals = preferredIntervals
    }
}
