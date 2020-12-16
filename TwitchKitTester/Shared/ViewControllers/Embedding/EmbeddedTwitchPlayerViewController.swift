//
//  EmbeddedTwitchPlayerViewController.swift
//  TwitchKitTester
//
//  Created by Tyler Prevost on 12/1/20.
//

import TwitchKit
import WebKit

#if os(macOS)
import AppKit
#else
import UIKit
#endif

class EmbeddedTwitchPlayerViewController: PlatformIndependentViewController {
    @IBOutlet private var playerView: TwitchPlayerView! {
        didSet { playerView?.uiDelegate = self }
    }
    
    @IBAction private func textFieldDidReturn(_ textField: PlatformIndependentTextField) {
        guard let channelName = textField.text, !channelName.isEmpty else { return }
        var settings = TwitchPlayerView.Settings()
        settings.content = .channel(name: channelName)
        
        if playerView.frame.height > playerView.frame.width {
            settings.layout = .playerWithChat
        } else {
            settings.layout = .playerOnly
        }
        
        playerView.settings = settings
    }
}

extension EmbeddedTwitchPlayerViewController: TwitchWebViewUIDelegate {
    func twitchWebView(_ twitchWebView: TwitchWebView,
                       didReceive chatConfirmationDialog: TwitchWebView.ChatConfirmationDialog) {
        #if os(macOS)
        guard let window = view.window else {
            chatConfirmationDialog.completionHandler(false)
            return
        }
        
        chatConfirmationDialog.show(in: window)
        #else
        chatConfirmationDialog.show(from: self)
        #endif
    }
}

#if !os(macOS)
extension EmbeddedTwitchPlayerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldDidReturn(textField)
        textField.resignFirstResponder()
        return true
    }
}
#endif
