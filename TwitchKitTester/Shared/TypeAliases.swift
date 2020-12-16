//
//  TypeAliases.swift
//  TwitchKitTester
//
//  Created by Tyler Prevost on 12/8/20.
//

#if os(macOS)
import AppKit

typealias PlatformIndependentLabel = NSTextField
typealias PlatformIndependentButton = NSButton
typealias PlatformIndependentTextField = NSTextField
typealias PlatformIndependentTableCell = NSTableCellView
typealias PlatformIndependentTableView = NSTableView
typealias PlatformIndependentTableViewDelegate = NSTableViewDelegate
typealias PlatformIndependentTableViewDataSource = NSTableViewDataSource
typealias PlatformIndependentTableViewController = MacOSTableViewController
typealias PlatformIndependentStoryboardSegue = NSStoryboardSegue

class MacOSTableViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    @IBOutlet var tableView: NSTableView!
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        0
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        nil
    }
}

extension NSStoryboardSegue {
    var destination: Any { destinationController }
}

extension NSTextField {
    var text: String? {
        get { stringValue }
        set { stringValue = newValue ?? "" }
    }
    
    var placeholder: String? {
        get { placeholderString }
        set { placeholderString = newValue }
    }
}

#else
import UIKit

typealias PlatformIndependentLabel = UILabel
typealias PlatformIndependentButton = UIButton
typealias PlatformIndependentTextField = UITextField
typealias PlatformIndependentTableCell = UITableViewCell
typealias PlatformIndependentTableView = UITableView
typealias PlatformIndependentTableViewDelegate = UITableViewDelegate
typealias PlatformIndependentTableViewDataSource = UITableViewDataSource
typealias PlatformIndependentTableViewController = UITableViewController
typealias PlatformIndependentStoryboardSegue = UIStoryboardSegue
#endif
