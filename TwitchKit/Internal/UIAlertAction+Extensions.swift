//
//  UIAlertAction+Extensions.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 12/15/20.
//

import UIKit

extension UIAlertAction {
    // For unit testing
    @objc internal class func makeAction(withTitle title: String?,
                                         style: UIAlertAction.Style,
                                         handler: ((UIAlertAction) -> Void)?) -> UIAlertAction {
        UIAlertAction(title: title, style: style, handler: handler)
    }
}
