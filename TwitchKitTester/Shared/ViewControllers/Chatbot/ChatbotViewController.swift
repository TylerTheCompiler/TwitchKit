//
//  ChatbotViewController.swift
//  TwitchKitTester
//
//  Created by Tyler Prevost on 12/1/20.
//

import TwitchKit

#if !os(macOS)
import UIKit
#endif

class EchoBot: Chatbot {
    override func didReceive(message: ChatMessage) {
        switch message {
        case .plainMessage(let plainMessage):
            send(message: plainMessage.message, to: plainMessage.channel)
            
        default:
            break
        }
    }
}

class ChatbotViewController: PlatformIndependentViewController {
    var authSession: ServerUserAuthSession?
    private var apiSession: ServerUserAPISession?
    
    private var chatbot: EchoBot?
    
    @IBOutlet private var chatView: TwitchChatView! {
        didSet { chatView?.uiDelegate = self }
    }
    
    @IBOutlet private var textField: PlatformIndependentTextField!
    
    @IBAction private func textFieldDidReturn(_ sender: Any) {
        guard let authSession = authSession, let channel = textField.text, !channel.isEmpty else {
            chatbot?.disconnect()
            chatbot = nil
            chatView.settings.channel = nil
            return
        }
        
        apiSession = ServerUserAPISession(authSession: authSession)
        apiSession?.perform(GetUsersRequest()) { response in
            switch response.result {
            case .success(let body):
                guard let displayName = body.users.first?.displayName else { return }
                self.chatbot = .init(username: displayName, authSession: .server(authSession))
                self.chatbot?.connect { response in
                    if response.error == nil {
                        self.chatbot?.join(channel: channel)
                    }
                }
                
            case .failure(let error):
                print("Chatbot get users request error:", error)
            }
        }
        
        chatView.settings.channel = channel
    }
}

extension ChatbotViewController: TwitchWebViewUIDelegate {
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
extension ChatbotViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldDidReturn(textField)
        return true
    }
}
#endif
