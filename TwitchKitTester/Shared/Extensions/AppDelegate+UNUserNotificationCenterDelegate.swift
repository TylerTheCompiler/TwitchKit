//
//  AppDelegate+UNUserNotificationCenterDelegate.swift
//  TwitchKitTester
//
//  Created by Tyler Prevost on 11/19/20.
//

import Foundation
import UserNotifications

#if os(macOS)
import AppKit
#else
import UIKit
#endif

enum UserNotificationCategory: String {
    case userMention
}

enum UserNotificationUserInfoKey: String {
    case channel
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        defer { completionHandler() }
        let userInfo = response.notification.request.content.userInfo
        let categoryIdentifier = response.notification.request.content.categoryIdentifier
        switch UserNotificationCategory(rawValue: categoryIdentifier) {
        case .userMention:
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                guard let channel = userInfo[UserNotificationUserInfoKey.channel.rawValue] as? String,
                      let channelURL = URL(string: "https://twitch.tv/\(channel)") else {
                    return
                }
                
                #if os(macOS)
                NSWorkspace.shared.open(channelURL)
                #else
                UIApplication.shared.open(channelURL)
                #endif
                
            default:
                break
            }
            
        default:
            break
        }
    }
}
