//
//  ViewController.swift
//  AudioPlayerSwiftDemo
//
//  Created by Daniel Dam Freiling on 14/05/2017.
//  Copyright © 2017 Nota. All rights reserved.
//

import UIKit
import AVFoundation
import AVFoundation
import AudioPlayer


class ViewController: UIViewController, AudioPlayerDelegate {
    
    var player: AudioPlayer = AudioPlayer()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        player.delegate = self
//        player.sessionCategory = AVAudioSessionCategoryPlayback
//        player.sessionMode = AVAudioSessionModeSpokenAudio
//        player.timePitchAlgorithm = AVAudioTimePitchAlgorithmTimeDomain
        player.remoteCommandsEnabled = [.changePlaybackPosition, .like, .dislike, .bookmark, .changePlaybackRate, .changeRepeatMode, .changeShuffleMode, .playPause, .skipBackward]
        player.remoteControlSkipIntervals = [60]
        player.bufferingStrategy = .playWhenPreferredBufferDurationFull;
        player.preferredBufferDurationBeforePlayback = 10.0;
        player.preferredForwardBufferDuration = 300.0;
        
//        let delegate = UIApplication.shared.delegate as? AppDelegate
//        delegate?.player = player
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getAudioItemForURL(_ urlStr: String, withTitle title: String, withAlbum album: String? = "", withArtist artist: String? = "") -> AudioItem? {
        let item = AudioItem(highQualitySoundURL: URL(string: urlStr))
        item?.title = title
        item?.album = album
        item?.artist = artist
        return item
    }

    @IBAction func doPlay(_ sender: Any) {
        print(#function)
        
        let fileUrl: URL = Bundle.main.url(forResource: "13_kapitel_9", withExtension: "mp3")!
        let fileUrl2: URL = Bundle.main.url(forResource: "1984-01-org", withExtension: "mp3")!
        
        var items = [AudioItem]()
//        items.append(getAudioItemForURL("https://lbs.nota.dk/api/v1.0/files/6115fbee-a21b-4d19-9bd9-c4670e8e5ca3/37027/0/03_kolofon_og_bibliogra.mp3", withTitle: "idx 2", withArtist: "Michael Kamp")!)
//        items.append(getAudioItemForURL(fileUrl.absoluteString, withTitle: "1984-01", withArtist: "George Orwell")!)
//        items.append(getAudioItemForURL(fileUrl2.absoluteString, withTitle: "1984-02", withArtist: "George Orwell")!)
//        items.append(getAudioItemForURL("https://beta.lbs.nota.dk/api/v1.0/files/3b3d22e4-dfc8-451f-af37-31d169db893a/37027/0/13_kapitel_9.mp3", withTitle: "1984", withArtist: "George Orwell")!)
//        items.append(getAudioItemForURL("https://archive.org/download/George-Orwell-1984-Audio-book/1984-02_64kb.mp3", withTitle: "1984", withArtist: "George Orwell")!)
//        items.append(getAudioItemForURL("https://archive.org/download/George-Orwell-1984-Audio-book/1984-03_64kb.mp3", withTitle: "1984", withArtist: "George Orwell")!)
//        items.append(getAudioItemForURL("https://archive.org/download/George-Orwell-1984-Audio-book/1984-04_64kb.mp3", withTitle: "1984", withArtist: "George Orwell")!)
        
//        items.append(getAudioItemForURL("http://www.moviesoundclips.net/download.php?id=3706&ft=mp3", withTitle: "Mustachio!", withArtist: "Mustascio!")!)
//        items.append(getAudioItemForURL("https://lbs.nota.dk/api/v1.0/files/6115fbee-a21b-4d19-9bd9-c4670e8e5ca3/37027/0/01_michael_kamp_bunker_.mp3", withTitle: "idx 0", withArtist: "Michael Kamp")!)
//        items.append(getAudioItemForURL("https://lbs.nota.dk/api/v1.0/files/6115fbee-a21b-4d19-9bd9-c4670e8e5ca3/37027/0/02_om_denne_udgave.mp3", withTitle: "idx 1", withArtist: "Michael Kamp")!)
        items.append(getAudioItemForURL("https://lbs.nota.dk/api/v1.0/files/6115fbee-a21b-4d19-9bd9-c4670e8e5ca3/37027/0/03_kolofon_og_bibliogra.mp3", withTitle: "idx 2", withArtist: "Michael Kamp")!)
        items.append(getAudioItemForURL("https://lbs.nota.dk/api/v1.0/files/6115fbee-a21b-4d19-9bd9-c4670e8e5ca3/37027/0/04_citat.mp3", withTitle: "idx 3", withArtist: "Michael Kamp")!)
        items.append(getAudioItemForURL("https://lbs.nota.dk/api/v1.0/files/6115fbee-a21b-4d19-9bd9-c4670e8e5ca3/37027/0/05_kapitel_1.mp3", withTitle: "idx 4", withArtist: "Michael Kamp")!)
        items.append(getAudioItemForURL("https://lbs.nota.dk/api/v1.0/files/6115fbee-a21b-4d19-9bd9-c4670e8e5ca3/37027/0/06_kapitel_2.mp3", withTitle: "idx 5", withArtist: "Michael Kamp")!)
        items.append(getAudioItemForURL("https://lbs.nota.dk/api/v1.0/files/6115fbee-a21b-4d19-9bd9-c4670e8e5ca3/37027/0/08_kapitel_4.mp3", withTitle: "Kapitel 4", withAlbum: "Bunker 137", withArtist: "Michael Kamp")!)
        items.append(getAudioItemForURL("https://lbs.nota.dk/api/v1.0/files/6115fbee-a21b-4d19-9bd9-c4670e8e5ca3/37027/0/09_kapitel_5.mp3", withTitle: "Kapitel 5", withAlbum: "Bunker 137", withArtist: "Michael Kamp")!)
        items.append(getAudioItemForURL("https://lbs.nota.dk/api/v1.0/files/6115fbee-a21b-4d19-9bd9-c4670e8e5ca3/37027/0/10_kapitel_6.mp3", withTitle: "Kapitel 6", withAlbum: "Bunker 137", withArtist: "Michael Kamp")!)
        items.append(getAudioItemForURL("https://lbs.nota.dk/api/v1.0/files/6115fbee-a21b-4d19-9bd9-c4670e8e5ca3/37027/0/01_michael_kamp_bunker_.mp3", withTitle: "idx 0", withArtist: "Michael Kamp")!)
//        items.append(getAudioItemForURL("https://archive.org/download/George-Orwell-1984-Audio-book/1984-01.mp3", withTitle: "Kapitel 1", withAlbum: "1986", withArtist: "George Orwell")!)
//        items.append(getAudioItemForURL("https://archive.org/download/George-Orwell-1984-Audio-book/1984-02.mp3", withTitle: "Kapitel 2", withAlbum: "1986", withArtist: "George Orwell")!)
//        items.append(getAudioItemForURL("https://archive.org/download/George-Orwell-1984-Audio-book/1984-03.mp3", withTitle: "Kapitel 3", withAlbum: "1986", withArtist: "George Orwell")!)
        
        player.play(items: items, startAtIndex: 2)
//        player.play(items: items)
        player.seek(to: TimeInterval(50)) { completed in
            print("Seek completed? \(completed)")
        }
    }
    
    @IBAction func doToggle(_ sender: Any) {
        if (player.state == .paused) {
            player.resume()
        } else if player.rate != 0.0 {
            player.pause()
        }
    }

    @IBAction func doBack(_ sender: Any) {
        print(#function)
        player.previous()
    }
    
    @IBAction func doForward(_ sender: Any) {
        print(#function)
        player.nextOrStop()
    }
    
    @IBAction func doStop(_ sender: Any) {
        print(#function)
        player.stop()
    }
    
    @IBAction func doChangeRemoteCommands(_ sender: Any) {
//        player.remoteCommandsEnabled = [.skipBackward, .playPause, .skipForward, .changeRepeatMode, .changeShuffleMode, .changePlaybackPosition]
    }
    
    @IBAction func doChangeSkipInterval(_ sender: Any) {
        // Skip to almost end
        if let duration = player.currentItemDuration {
            player.seek(to: duration - 10, byAdaptingTimeToFitSeekableRanges: false, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero) { success in
                print("seek result: \(success)")
            }
        }
//        player.seekUnsafe(to: 192, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
//        print("AudioPlayer index/time: \(self.player.currentItemIndexInQueue)@\(self.player.currentItemProgression) / \(self.player.currentItemDuration)")
    }
    
    @IBAction func rateChanged(_ sender: UISlider) {
        let newValue = sender.value
        print("rate changed: \(newValue)")
        player.rate = newValue
    }
    
    func audioPlayer(_ audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState, to state: AudioPlayerState) {
        print("AudioPlayer state \(from) -> \(state)")
    }
    
    func audioPlayer(_ audioPlayer: AudioPlayer, willStartPlaying item: AudioItem) {
        print("AudioPlayer will start playing")
    }
    
    func audioPlayer(_ audioPlayer: AudioPlayer, didUpdateProgressionTo time: TimeInterval, percentageRead: Float) {
        print("AudioPlayer didUpdateProgression \(time) -- \(percentageRead)%")
    }
    
    func audioPlayer(_ audioPlayer: AudioPlayer, didFindDuration duration: TimeInterval, for item: AudioItem) {
        print("AudioPlayer didFindDuration \(duration)")
    }
    
    
    func audioPlayer(_ audioPlayer: AudioPlayer, didUpdateEmptyMetadataOn item: AudioItem, withData data: [AVMetadataItem]) {
        
    }
    
    func audioPlayer(_ audioPlayer: AudioPlayer, didLoadEarliest earliest: TimeInterval, latest: TimeInterval, for item: AudioItem) {
        print("AudioPlayer didLoad \(earliest) <-> \(latest) for item \(item.title ?? "")")
    }
    func audioPlayer(_ audioPlayer: AudioPlayer, didLoad range: TimeRange, for item: AudioItem) {
        print("AudioPlayer didLoad \(range.earliest) <-> \(range.latest) for item \(item.title ?? "")")
    }
    
    func audioPlayer(_ audioPlayer: AudioPlayer, isReadyToSeek item: AudioItem) {
        print("AudioPlayer isReadyToSeek for item \(item.title ?? "")")
    }
    
    func audioPlayer(_ audioPlayer: AudioPlayer, finishedPlaying item: AudioItem) {
        print("AudioPlayer finished playing item \(item.title ?? "")")
    }
}

