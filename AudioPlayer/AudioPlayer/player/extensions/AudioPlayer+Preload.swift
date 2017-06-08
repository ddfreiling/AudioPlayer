//
//  AudioPlayer+Preload.swift
//  AudioPlayer
//
//  Created by Daniel Dam Freiling on 11/05/2017.
//  Copyright © 2017 Kevin Delannoy. All rights reserved.
//

import Foundation
import AVFoundation

extension AudioPlayer {
    
    public static let assetPreloadKeys = ["tracks", "playable"]
    
    public func clearAssetCache() {
        cachedAssets = [:]
    }
    
    func getAVURLAsset(forUrl: URL) -> AVURLAsset {
        if let asset = cachedAssets[forUrl],
               !assetHasFailed(asset) {
            KDEDebug("getAVURLAsset -- cached")
            return asset
        } else {
            ///See options: https://developer.apple.com/reference/avfoundation/avurlasset/initialization_options
            let asset = AVURLAsset(url: forUrl)
            cachedAssets[forUrl] = asset
            KDEDebug("getAVURLAsset -- new")
            return asset
        }
    }
    
    func getAVPlayerItem(forUrl: URL) -> AVPlayerItem {
        let asset = getAVURLAsset(forUrl: forUrl)
        let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: AudioPlayer.assetPreloadKeys)
        if #available(iOS 10.0, tvOS 10.0, OSX 10.12, *) {
            playerItem.preferredForwardBufferDuration = self.preferredForwardBufferDuration
        }
        
        return playerItem
    }
    
    func preloadItemAsset(asset: AVURLAsset, onComplete: @escaping (AVURLAsset?) -> Void) {
        asset.loadValuesAsynchronously(forKeys: AudioPlayer.assetPreloadKeys) {
            if (self.assetPreloadKeysAreLoaded(asset: asset) == false) {
                //loading failed, invalidate cached asset
                self.cachedAssets.removeValue(forKey: asset.url)
                onComplete(nil)
            } else {
                onComplete(asset)
            }
        }
    }
    
    func preloadNextItemAsset() {
        guard let queue = queue, hasNext else {
            return
        }
        let nextPosition = queue.nextPosition,
            item = queue.items[nextPosition],
            urlInfo = item.highestQualityURL
        if cachedAssets[urlInfo.url] != nil {
            // Next item has already been preloaded
            return
        }
        KDEDebug("preloading queue idx: \(nextPosition)")
        let asset = getAVURLAsset(forUrl: urlInfo.url)
        preloadItemAsset(asset: asset) { asset in
            if (asset == nil) {
                KDEDebug("error preloading queue idx: \(nextPosition)")
            } else {
                KDEDebug("preloaded queue idx: \(nextPosition)!")
            }
        }
    }
    
    private func assetHasFailed(_ asset: AVURLAsset) -> Bool {
        for key in AudioPlayer.assetPreloadKeys {
            var error: NSError?
            let result = asset.statusOfValue(forKey: key, error: &error)
            if (result == .failed || result == .cancelled || error != nil) {
                return true
            }
        }
        return false
    }
    
    private func assetPreloadKeysAreLoaded(asset: AVURLAsset) -> Bool {
        for key in AudioPlayer.assetPreloadKeys {
            var error: NSError?
            let result = asset.statusOfValue(forKey: key, error: &error)
            if (result != .loaded || error != nil) {
                KDEDebug("AVAsset failed to load key '\(key)': (\(String(describing: result))) \(error?.localizedDescription ?? "")")
                return false
            }
        }
        return true
    }
}
