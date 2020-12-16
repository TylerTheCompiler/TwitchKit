//
//  SessionCell.swift
//  TwitchKitTester
//
//  Created by Tyler Prevost on 11/29/20.
//

import Foundation

class SessionCell: PlatformIndependentTableCell {
    var uuid: UUID?
    
    override func prepareForReuse() {
        uuid = nil
        #if os(macOS)
        textField?.text = " "
        #else
        textLabel?.text = " "
        detailTextLabel?.text = " "
        #endif
        super.prepareForReuse()
    }
}
