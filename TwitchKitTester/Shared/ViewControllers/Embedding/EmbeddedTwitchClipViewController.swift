//
//  EmbeddedTwitchClipViewController.swift
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

class EmbeddedTwitchClipViewController: PlatformIndependentViewController {
    @IBOutlet private var clipView: TwitchClipView!
    
    @IBAction private func textFieldDidReturn(_ textField: PlatformIndependentTextField) {
        guard let clipSlug = textField.text, !clipSlug.isEmpty else { return }
        clipView.settings.clipSlug = clipSlug
    }
}

#if !os(macOS)
extension EmbeddedTwitchClipViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textFieldDidReturn(textField)
        textField.resignFirstResponder()
        return true
    }
}
#endif
