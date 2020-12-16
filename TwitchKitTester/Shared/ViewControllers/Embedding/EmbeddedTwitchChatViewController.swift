//
//  EmbeddedTwitchChatViewController.swift
//  TwitchKitTester
//
//  Created by Tyler Prevost on 12/1/20.
//

import TwitchKit

#if os(macOS)
import AppKit
#else
import UIKit
#endif

class EmbeddedTwitchChatViewController: PlatformIndependentViewController {
    @IBOutlet private var chatView: TwitchChatView! {
        didSet { chatView?.uiDelegate = self }
    }
    
    @IBAction private func textFieldDidReturn(_ textField: PlatformIndependentTextField) {
        guard let channelName = textField.text, !channelName.isEmpty else { return }
        chatView.settings.channel = channelName
    }
}

extension EmbeddedTwitchChatViewController: TwitchWebViewUIDelegate {
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
extension EmbeddedTwitchChatViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldDidReturn(textField)
        textField.resignFirstResponder()
        return true
    }
}
#endif
