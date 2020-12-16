//
//  AppDelegate.swift
//  TwitchKitTester
//
//  Created by Tyler Prevost on 11/4/20.
//

import AppKit
import UserNotifications

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
}
