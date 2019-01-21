//
//  SeekOperation.swift
//  AudioPlayer
//
//  Created by Daniel Dam Freiling on 13/06/2017.
//  Copyright © 2017 Kevin Delannoy. All rights reserved.
//

import CoreMedia

@objc public class SeekOperation: NSObject {
    
    init(time: TimeInterval,
         adaptToFitSeekableRanges: Bool = false,
         toleranceBefore: CMTime = kCMTimePositiveInfinity,
         toleranceAfter: CMTime = kCMTimePositiveInfinity,
         completionHandler: ((Bool) -> Void)? = nil) {
        self.time = time
        self.adaptToFitSeekableRanges = adaptToFitSeekableRanges
        self.toleranceBefore = toleranceBefore
        self.toleranceAfter = toleranceAfter
        self.completionHandler = completionHandler
    }
    
    public var time: TimeInterval
    public var adaptToFitSeekableRanges: Bool
    public var toleranceBefore: CMTime
    public var toleranceAfter: CMTime
    public var completionHandler: ((Bool) -> Void)?
}
