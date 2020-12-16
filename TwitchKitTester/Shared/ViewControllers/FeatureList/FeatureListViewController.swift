//
//  FeatureListViewController.swift
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

class FeatureListViewController: PlatformIndependentViewController,
                                 PlatformIndependentTableViewDelegate,
                                 PlatformIndependentTableViewDataSource {
    enum Feature {
        case embedding
        case deepLinks
        case auth
        case endpoints
        case chatbot
        case pubSub
        case eventSub
        
        var title: String {
            switch self {
            case .embedding: return "Embedding Twitch"
            case .deepLinks: return "Deep Links"
            case .auth: return "Auth"
            case .endpoints: return "Endpoints"
            case .chatbot: return "Chatbot"
            case .pubSub: return "PubSub"
            case .eventSub: return "EventSub"
            }
        }
    }
    
    var features = [Feature]() {
        didSet { tableView.reloadData() }
    }
    
    @IBOutlet private(set) var tableView: PlatformIndependentTableView!
    
    @IBAction private func showFeature(_ sender: Any) {
        #if os(macOS)
        let selectedRow = tableView.selectedRow
        guard selectedRow != -1 else { return }
        #else
        guard let selectedRow = tableView.indexPathForSelectedRow?.row else { return }
        #endif
        
        let identifier: String
        let feature = features[selectedRow]
        switch feature {
        case .embedding: identifier = "ShowEmbedding"
        case .deepLinks: identifier = "ShowDeepLinks"
        case .auth: identifier = "ShowAuth"
        case .endpoints: identifier = "ShowEndpoints"
        case .chatbot: identifier = "ShowChatbot"
        case .pubSub: identifier = "ShowPubSub"
        case .eventSub: identifier = "ShowEventSub"
        }
        
        performSegue(withIdentifier: identifier, sender: feature)
    }
    
    #if os(macOS)
    func numberOfRows(in tableView: NSTableView) -> Int {
        features.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let feature = features[row]
        let cell = tableView.makeView(withIdentifier: .init("Cell"), owner: self) as? SessionCell
        cell?.textField?.text = feature.title
        return cell
    }
    #else
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        features.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let feature = features[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = feature.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showFeature(tableView)
    }
    #endif
    
    override func prepare(for segue: PlatformIndependentStoryboardSegue, sender: Any?) {
        guard let feature = sender as? Feature else { return }
        
        #if os(macOS)
        guard let destination = segue.destination as? NSViewController else { return }
        #else
        let destination = segue.destination
        #endif
        
        switch feature {
        case .embedding, .deepLinks: break
        case .auth:
            showAuth(in: destination)
            
        case .endpoints:
            showEndpoints(in: destination)
            
        case .chatbot:
            guard let viewController = destination as? ChatbotViewController else { return }
            showChatbot(in: viewController)
            
        case .pubSub:
            guard let viewController = destination as? PubSubViewController else { return }
            showPubSub(in: viewController)
            
        case .eventSub:
            guard let viewController = destination as? EventSubViewController else { return }
            showEventSub(in: viewController)
        }
    }
    
    func showAuth(in viewController: PlatformIndependentViewController) {
        // Overridden by subclasses
    }
    
    func showEndpoints(in viewController: PlatformIndependentViewController) {
        // Overridden by subclasses
    }
    
    func showChatbot(in viewController: ChatbotViewController) {
        // Overridden by subclasses
    }
    
    func showPubSub(in viewController: PubSubViewController) {
        // Overridden by subclasses
    }
    
    func showEventSub(in viewController: EventSubViewController) {
        // Overridden by subclasses
    }
}
