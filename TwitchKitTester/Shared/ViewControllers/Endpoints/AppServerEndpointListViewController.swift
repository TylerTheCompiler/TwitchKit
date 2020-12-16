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
            
            apiSession?.perform(LegacyGetChatBadgesByChannelRequest(channelId: twitchChannelId)) { response in
                switch response.result {
                case .success(let badges):
                    print("Response:", badges)
                    
                case .failure(let error):
                    print("Error:", error)
                }
            }
        }
    }
    
    private var apiSession: ServerAppAPISession?
}
