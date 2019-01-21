//
//  Logger.swift
//  AudioPlayer
//
//  Created by Daniel Dam Freiling on 08/06/2017.
//  Copyright © 2017 Kevin Delannoy. All rights reserved.
//

import Foundation

public func KDEDebug(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        
        var idx = items.startIndex
        let endIdx = items.endIndex
        
        repeat {
            Swift.print(items[idx], separator: separator, terminator: idx == (endIdx - 1) ? terminator : separator)
            idx += 1
        }
            while idx < endIdx
        
    #endif
}

public func KDEDebugDump(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
        
        var idx = items.startIndex
        let endIdx = items.endIndex
        
        repeat {
            Swift.debugPrint(items[idx], separator: separator, terminator: idx == (endIdx - 1) ? terminator : separator)
            idx += 1
        }
            while idx < endIdx
        
    #endif
}
