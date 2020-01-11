//
//  AudioPlayer+RemoteControl.swift
//  AudioPlayer
//
//  Created by Daniel Dam Freiling on 15/05/2017.
//  Copyright © 2017 Kevin Delannoy. All rights reserved.
//

import Foundation
import MediaPlayer

// RemoteControls TODO:
// - delegate callbacks for like/dislike/rate/bookmark commands
// - test shuffle/repeat mode commands

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
    
    //TODO: delegate callbacks for these commands
    case rate = 10
    case like = 11
    case dislike = 12
    case bookmark = 13
    
    /// Available from iOS 10 tvOS 10
    case changeRepeatMode = 14
    /// Available from iOS 10 and tvOS 10
    case changeShuffleMode = 15
}

@available(OSX 10.12.2, *)
extension AudioPlayer {
    
    /// Get or set the preferred intervals for skip forward and backward remote control commands.
    /// Currently does not support a different interval for forward or backward.
    public var remoteControlSkipIntervals: [NSNumber] {
        get {
            return MPRemoteCommandCenter.shared().skipForwardCommand.preferredIntervals
        }
        set {
            let remote = MPRemoteCommandCenter.shared()
            remote.skipForwardCommand.preferredIntervals = newValue
            remote.skipBackwardCommand.preferredIntervals = newValue
        }
    }
    
    /// Get or set the supported playback rates for the changePlaybackRate command
    public var remoteControlSupportedPlaybackRates: [NSNumber] {
        get {
            return MPRemoteCommandCenter.shared().changePlaybackRateCommand.supportedPlaybackRates
        }
        set {
            MPRemoteCommandCenter.shared().changePlaybackRateCommand.supportedPlaybackRates = newValue
        }
    }
    
    func unregisterRemoteControlCommands(_ cmds: [AudioPlayerRemoteCommand]) {
        for remoteCmd in cmds.flatMap({ cmd in getMPRemoteCommands(cmd) }) {
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
    
    @objc func handleRemoteControlCommandEvent(_ event: MPRemoteCommandEvent) -> MPRemoteCommandHandlerStatus {
        guard (player?.currentItem) != nil else {
            if #available(iOS 9.1, tvOS 9.1, *) {
                return .noActionableNowPlayingItem
            } else {
                return .commandFailed
            }
        }
        let remote = MPRemoteCommandCenter.shared()
        
        // Assume success, must set to .failed inside case if necessary
        var handlerStatus = MPRemoteCommandHandlerStatus.success
        
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
            handlerStatus = .commandFailed
        }
        return handlerStatus
    }
    
    private var remoteCommandsToRegister: [MPRemoteCommand] {
        get {
            return remoteCommandsEnabled.flatMap({ cmd in getMPRemoteCommands(cmd) })
        }
    }
    
    private func handleChangePlaybackPositionEvent(_ event: MPRemoteCommandEvent) {
        guard let event = event as? MPChangePlaybackPositionCommandEvent else {
            return
        }
        self.seek(to: event.positionTime)
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
        case .one:
            newRepeatMode = .repeat
        case .all:
            newRepeatMode = .repeatAll
        case .off:
            newRepeatMode = .normal
        default:
            newRepeatMode = .normal
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
    
    private func getMPRemoteCommands(_ command: AudioPlayerRemoteCommand) -> [MPRemoteCommand] {
        let remote = MPRemoteCommandCenter.shared()
        switch command {
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
            if #available(iOS 9.1, tvOS 9.1, *) {
                return [remote.changePlaybackPositionCommand]
            } else {
                return []
            }
        case .changeRepeatMode:
            if #available(iOS 10, tvOS 10, *) {
                return [remote.changeRepeatModeCommand]
            } else {
                return []
            }
        case .changeShuffleMode:
            if #available(iOS 10, tvOS 10, *) {
                return [remote.changeShuffleModeCommand]
            } else {
                return []
            }
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
