//
//  DeepLinkListViewController.swift
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

class DeepLinkListViewController: PlatformIndependentTableViewController {
    private var deepLinks: [TwitchAppDeepLink] = [
        .channel(name: ""),
        .game(name: ""),
        .vod(videoId: ""),
        .categoryTag(id: ""),
        .liveStreamTag(id: ""),
        .following,
        .login
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
    }
    
    @IBAction private func showDeepLink(_ sender: Any) {
        performSegue(withIdentifier: "ShowDeepLink", sender: nil)
    }
    
    override func prepare(for segue: PlatformIndependentStoryboardSegue, sender: Any?) {
        #if os(macOS)
        let optionalSelectedRow = tableView.selectedRow >= 0 ? tableView.selectedRow : nil
        #else
        let optionalSelectedRow = tableView.indexPathForSelectedRow?.row
        #endif
        guard let selectedRow = optionalSelectedRow,
              let deepLinkViewController = segue.destination as? DeepLinkViewController else {
            return
        }
        
        deepLinkViewController.deepLink = deepLinks[selectedRow]
    }
    
    #if os(macOS)
    override func numberOfRows(in tableView: NSTableView) -> Int {
        deepLinks.count
    }
    
    override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: .init("Cell"), owner: self) as? SessionCell
        
        switch deepLinks[row] {
        case .channel: cell?.textField?.text = "Open Channel"
        case .game: cell?.textField?.text = "Open Game Directory"
        case .vod: cell?.textField?.text = "Open Video"
        case .categoryTag: cell?.textField?.text = "Open Category Tag"
        case .liveStreamTag: cell?.textField?.text = "Open Live Stream Tag"
        case .following: cell?.textField?.text = "Open Following"
        case .login: cell?.textField?.text = "Open Login"
        }
        
        return cell
    }
    #else
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        deepLinks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        switch deepLinks[indexPath.row] {
        case .channel: cell.textLabel?.text = "Open Channel"
        case .game: cell.textLabel?.text = "Open Game Directory"
        case .vod: cell.textLabel?.text = "Open Video"
        case .categoryTag: cell.textLabel?.text = "Open Category Tag"
        case .liveStreamTag: cell.textLabel?.text = "Open Live Stream Tag"
        case .following: cell.textLabel?.text = "Open Following"
        case .login: cell.textLabel?.text = "Open Login"
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showDeepLink(tableView)
    }
    #endif
}
