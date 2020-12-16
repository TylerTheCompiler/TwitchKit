//
//  DeepLinkViewController.swift
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

class DeepLinkViewController: PlatformIndependentViewController {
    @IBOutlet private var textField: PlatformIndependentTextField!
    
    var deepLink: TwitchAppDeepLink? {
        didSet { if isViewLoaded { updateTextField() } }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTextField()
    }
    
    @IBAction private func openDeepLink(_ sender: Any) {
        guard textField.isHidden || textField.text?.isEmpty == false else { return }
        deepLink?.open { print("Did open deep link:", $0) }
    }
    
    @IBAction private func textFieldDidReturn(_ textField: PlatformIndependentTextField) {
        guard let deepLinkParam = textField.text,
              !deepLinkParam.isEmpty,
              let deepLink = deepLink else {
            return
        }
        
        switch deepLink {
        case .following, .login:
            return
            
        case .channel:
            self.deepLink = .channel(name: deepLinkParam)
            
        case .game:
            self.deepLink = .game(name: deepLinkParam)
            
        case .vod:
            self.deepLink = .vod(videoId: deepLinkParam)
            
        case .categoryTag:
            self.deepLink = .categoryTag(id: deepLinkParam)
            
        case .liveStreamTag:
            self.deepLink = .liveStreamTag(id: deepLinkParam)
        }
    }
    
    private func updateTextField() {
        guard let deepLink = deepLink else { return }
        switch deepLink {
        case .following, .login:
            textField.isHidden = true
            textField.placeholder = nil
            
        case .channel:
            textField.isHidden = false
            textField.placeholder = "Channel Name"
            
        case .game:
            textField.isHidden = false
            textField.placeholder = "Game Name"
            
        case .vod:
            textField.isHidden = false
            textField.placeholder = "Video ID"
            
        case .categoryTag:
            textField.isHidden = false
            textField.placeholder = "Category Tag ID"
            
        case .liveStreamTag:
            textField.isHidden = false
            textField.placeholder = "Live Stream Tag ID"
        }
    }
}

#if !os(macOS)
extension DeepLinkViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldDidReturn(textField)
        textField.resignFirstResponder()
        return true
    }
}
#endif
