//
//  AudioPlayer+RemoteControl.swift
//  AudioPlayer
//
//  Created by Daniel Dam Freiling on 15/05/2017.
//  Copyright © 2017 Kevin Delannoy. All rights reserved.
//

import Foundation
import MediaPlayer

/// Enum for AudioPlayer remote commands. Saves clients from having to provide MPRemoteCommand references.
/// Some commands may not occupy one of the command slots or can collapse with others into the menu button.
/// Unless stated otherwise these commands can be assumed to be available from iOS 7.1, tvOS 9 and OSX 10.12.1
@objc public enum AudioPlayerRemoteCommand: Int {
    /// This command encompasses play, pause and playPause commands
    case playPause = 0
    case stop = 1
    case nextTrack = 2
    case previousTrack = 3
    case skipForward = 4
    case skipBackward = 5
    case seekForward = 6
    case seekBackward = 7
    case changePlaybackRate = 8
    /// Available from iOS 9.1 and tvOS 9.1
    case changePlaybackPosition = 9
    
    // These commands must be handled by the delegate.
    case rate = 10
    case like = 11
    case dislike = 12
    case bookmark = 13
    
    /// Available from iOS 10 and tvOS 10
    case changeRepeatMode = 14
    case changeShuffleMode = 15
    
    func getMPRemoteCommands() -> [MPRemoteCommand] {
        let remote = MPRemoteCommandCenter.shared()
        switch self {
        case .playPause:
            return [remote.togglePlayPauseCommand, remote.playCommand, remote.pauseCommand]
        case .stop:
            return [remote.stopCommand]
        case .nextTrack:
            return [remote.nextTrackCommand]
        case .previousTrack:
            return [remote.previousTrackCommand]
        case .skipForward:
            return [remote.skipForwardCommand]
        case .skipBackward:
            return [remote.skipBackwardCommand]
        case .seekForward:
            return [remote.seekForwardCommand]
        case .seekBackward:
            return [remote.seekBackwardCommand]
        case .changePlaybackRate:
            return [remote.changePlaybackRateCommand]
        case .changePlaybackPosition:
            if #available(iOS 9.1, tvOS 9.1, OSX 10.12.1, *) {
                return [remote.changePlaybackPositionCommand]
            } else {
                return []
            }
        case .changeRepeatMode:
            return [remote.changeRepeatModeCommand]
        case .changeShuffleMode:
            return [remote.changeShuffleModeCommand]
        case .rate:
            return [remote.ratingCommand]
        case .like:
            return [remote.likeCommand]
        case .dislike:
            return [remote.dislikeCommand]
        case .bookmark:
            return [remote.bookmarkCommand]
        }
    }
}

extension AudioPlayer {
    
    /// Get or set the preferred intervals for skip forward and backward remote control commands.
    /// Currently does not support a different interval for forward or backward.
    public var remoteControlSkipIntervals: [TimeInterval] {
        get {
            return MPRemoteCommandCenter.shared().skipForwardCommand.preferredIntervals as! [TimeInterval]
        }
        set {
            let remote = MPRemoteCommandCenter.shared()
            remote.skipForwardCommand.preferredIntervals = newValue as [NSNumber]
            remote.skipBackwardCommand.preferredIntervals = newValue as [NSNumber]
        }
    }
    
    func unregisterRemoteControlCommands(_ cmds: [AudioPlayerRemoteCommand]) {
        for remoteCmd in cmds.flatMap({ cmd in cmd.getMPRemoteCommands() }) {
            remoteCmd.isEnabled = false
            remoteCmd.removeTarget(self)
        }
    }
    
    func registerRemoteControlCommands() {
        // MPRemoteCommandCenter on iOS can have a max of 3 commands enabled at a time. Any others won't be shown.
        for command in remoteCommandsToRegister {
            command.removeTarget(self)
            command.addTarget(self, action: #selector(handleRemoteControlCommandEvent(_:)))
            command.isEnabled = true
        }
    }
    
    func setRemoteControlCommandsEnabled(_ enabled: Bool) {
        for remoteCmd in remoteCommandsToRegister {
            remoteCmd.isEnabled = enabled
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
        var commandStatus = MPRemoteCommandHandlerStatus.success
        
        if event.command == remote.stopCommand {
            self.stop()
        } else if event.command == remote.nextTrackCommand {
            self.next()
        } else if event.command == remote.previousTrackCommand {
            self.previous()
        } else if event.command == remote.pauseCommand ||
            (event.command == remote.togglePlayPauseCommand && state.isPlaying) {
            self.pause()
        } else if event.command == remote.playCommand ||
            (event.command == remote.togglePlayPauseCommand && state.isPaused) {
            self.resume()
        } else if event.command == remote.seekBackwardCommand {
            handleRemoteControlSeekEvent(event, isForward: false)
        } else if event.command == remote.seekForwardCommand {
            handleRemoteControlSeekEvent(event, isForward: true)
        } else if event.command == remote.skipBackwardCommand {
            if let event = event as? MPSkipIntervalCommandEvent {
                self.seekToRelativeTime(-event.interval)
            }
        } else if event.command == remote.skipForwardCommand {
            if let event = event as? MPSkipIntervalCommandEvent {
                self.seekToRelativeTime(event.interval)
            }
        } else if event.command == remote.changePlaybackRateCommand {
            if let event = event as? MPChangePlaybackRateCommandEvent {
                self.rate = event.playbackRate
            }
        } else if #available(iOS 9.1, tvOS 9.1, *), event.command == remote.changePlaybackPositionCommand {
            handleChangePlaybackPositionEvent(event)
        } else if event.command == remote.changeRepeatModeCommand {
            handleChangeRepeatModeEvent(event)
        } else if event.command == remote.changeShuffleModeCommand {
            handleChangeShuffleModeEvent(event)
        } else {
            if delegate?.audioPlayer(self, didReceiveRemoteControlEvent: event) == false {
                commandStatus = .commandFailed
            }
        }
        return commandStatus
    }
    
    private var remoteCommandsToRegister: [MPRemoteCommand] {
        get {
            return remoteCommandsEnabled.flatMap({ cmd in cmd.getMPRemoteCommands() })
        }
    }
    
    private func handleChangePlaybackPositionEvent(_ event: MPRemoteCommandEvent) {
        guard let event = event as? MPChangePlaybackPositionCommandEvent else {
            return
        }
        guard self.player?.currentItem?.status == .readyToPlay else {
            self.seek(to: event.positionTime)
            return
        }
        self.seek(to: event.positionTime, byAdaptingTimeToFitSeekableRanges: false,
                  toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero) { [weak self] finished in
            // TODO: This is implicitly updated when there is a completionHandler anyway..
            self?.updateNowPlayingInfoCenter()
        }
    }
    
    private func handleRemoteControlSeekEvent(_ event: MPRemoteCommandEvent, isForward: Bool) {
        guard let event = event as? MPSeekCommandEvent else {
            return
        }
        if (event.type == .beginSeeking) {
            seekingBehavior.handleSeekingStart(player: self, forward: isForward)
        } else {
            seekingBehavior.handleSeekingEnd(player: self, forward: isForward)
        }
    }
    
    private func handleChangeRepeatModeEvent(_ event: MPRemoteCommandEvent) {
        guard let event = event as? MPChangeRepeatModeCommandEvent else {
            return
        }
        let newRepeatMode: AudioPlayerMode
        switch event.repeatType {
        case .off:
            newRepeatMode = .normal
        case .one:
            newRepeatMode = .repeat
        case .all:
            newRepeatMode = .repeatAll
        }
        self.mode = self.mode.contains(.shuffle) ? [.shuffle, newRepeatMode] : newRepeatMode
    }
    
    private func handleChangeShuffleModeEvent(_ event: MPRemoteCommandEvent) {
        guard let event = event as? MPChangeShuffleModeCommandEvent else {
            return
        }
        if event.shuffleType == .off {
            self.mode.remove(.shuffle)
        } else {
            self.mode.insert(.shuffle)
        }
    }
}
