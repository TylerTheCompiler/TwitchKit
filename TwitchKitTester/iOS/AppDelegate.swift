//
//  AppDelegate.swift
//  TwitchKitTester
//
//  Created by Tyler Prevost on 11/2/20.
//

import UIKit
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
}
