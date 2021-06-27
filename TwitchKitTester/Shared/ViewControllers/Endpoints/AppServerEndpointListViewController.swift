//
//  AppServerEndpointListViewController.swift
//  TwitchKitTester
//
//  Created by Tyler Prevost on 12/1/20.
//

import TwitchKit

class AppServerEndpointListViewController: PlatformIndependentTableViewController {
    var authSession: ServerAppAuthSession? {
        didSet {
            guard let authSession = authSession else {
                apiSession = nil
                return
            }
            
            apiSession = .init(authSession: authSession)
            
            apiSession?.perform(LegacyGetChatBadgesByChannelRequest(channelId: twitchChannelId)) { result in
                switch result {
                case .success((let badges, _)):
                    print("Response:", badges)
                    
                case .failure(let error):
                    print("Error:", error)
                }
            }
        }
    }
    
    private var apiSession: ServerAppAPISession?
}
