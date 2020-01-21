//
//  Logger.swift
//  Repeatit
//
//  Created by nelson on 2017. 8. 10..
//  Copyright © 2017년 yongseongkim. All rights reserved.
//

import Foundation
import Firebase

class Logger {
    class Counter {
        // Bookmark
        static var numberOfPreviousBookmarkButtonTap = 0
        static var numberOfLatestBookmarkButtonTap = 0
        static var numberOfNextBookmarkButtonTap = 0
        static var numberOfAddBookmarkButtonTap = 0
        
        // Time
        static var numberOfMoveStartButtonTap = 0
        static var numberOfBeforeOneSecondButtonTap = 0
        static var numberOfBeforeTwoSecondsButtonTap = 0
        static var numberOfBeforeFiveSecondsButtonTap = 0
        static var numberOfAfterFiveSecondsButtonTap = 0
    }
    
//    class func loadPlayer(item: PlayerItem?, duraton: Double) {
//        guard let playerItem = item else { return }
//        let title = playerItem.title ?? (playerItem.url?.lastPathComponent ?? "unknown error")
//        let artist = playerItem.artist ?? "Unkown Artist"
//        Analytics.logEvent("load_player", parameters: [
//            "name": title as NSObject,
//            "artist": artist as NSObject,
//            "duration": duraton as NSObject
//            ])
//    }
    
    class func loggingPlayerControlTap() {
        Analytics.logEvent("player_control_tap", parameters: [
            "previous_bookmark": Logger.Counter.numberOfPreviousBookmarkButtonTap as NSObject,
            "latest_bookmark": Logger.Counter.numberOfLatestBookmarkButtonTap as NSObject,
            "next_bookmark": Logger.Counter.numberOfNextBookmarkButtonTap as NSObject,
            "add_bookmark": Logger.Counter.numberOfAddBookmarkButtonTap as NSObject,
            "move_start": Logger.Counter.numberOfMoveStartButtonTap as NSObject,
            "before_5_seconds": Logger.Counter.numberOfBeforeFiveSecondsButtonTap as NSObject,
            "before_2_seconds": Logger.Counter.numberOfBeforeTwoSecondsButtonTap as NSObject,
            "before_1_seconds": Logger.Counter.numberOfBeforeOneSecondButtonTap as NSObject,
            "after_5_seconds": Logger.Counter.numberOfAfterFiveSecondsButtonTap as NSObject
            ])
        Logger.Counter.numberOfPreviousBookmarkButtonTap = 0
        Logger.Counter.numberOfLatestBookmarkButtonTap = 0
        Logger.Counter.numberOfNextBookmarkButtonTap = 0
        Logger.Counter.numberOfAddBookmarkButtonTap = 0
        
        Logger.Counter.numberOfMoveStartButtonTap = 0
        Logger.Counter.numberOfBeforeOneSecondButtonTap = 0
        Logger.Counter.numberOfBeforeTwoSecondsButtonTap = 0
        Logger.Counter.numberOfBeforeFiveSecondsButtonTap = 0
        Logger.Counter.numberOfAfterFiveSecondsButtonTap = 0
    }
    
    class func previousBookmarkButtonTapped() {
        Logger.Counter.numberOfPreviousBookmarkButtonTap = Logger.Counter.numberOfPreviousBookmarkButtonTap + 1
    }
    
    class func nextBookmarkButtonTapped() {
        Logger.Counter.numberOfNextBookmarkButtonTap = Logger.Counter.numberOfNextBookmarkButtonTap + 1
    }
    
    class func latestBookmarkButtonTapped() {
        Logger.Counter.numberOfLatestBookmarkButtonTap = Logger.Counter.numberOfLatestBookmarkButtonTap + 1
    }
    
    class func addBookmarkButtonTapped() {
        Logger.Counter.numberOfAddBookmarkButtonTap = Logger.Counter.numberOfAddBookmarkButtonTap + 1
    }
    
    class func moveStartButtonTapped() {
        Logger.Counter.numberOfMoveStartButtonTap = Logger.Counter.numberOfMoveStartButtonTap + 1
    }
    
    class func before5SecondsButtonTapped() {
        Logger.Counter.numberOfBeforeFiveSecondsButtonTap = Logger.Counter.numberOfBeforeFiveSecondsButtonTap + 1
    }
    
    class func before2SecondsButtonTapped() {
        Logger.Counter.numberOfBeforeTwoSecondsButtonTap = Logger.Counter.numberOfBeforeTwoSecondsButtonTap + 1
    }
    
    class func before1SecondButtonTapped() {
        Logger.Counter.numberOfBeforeOneSecondButtonTap = Logger.Counter.numberOfBeforeOneSecondButtonTap + 1
    }
    
    class func After5SecondsButtonTapped() {
        Logger.Counter.numberOfAfterFiveSecondsButtonTap = Logger.Counter.numberOfAfterFiveSecondsButtonTap + 1
    }
}
