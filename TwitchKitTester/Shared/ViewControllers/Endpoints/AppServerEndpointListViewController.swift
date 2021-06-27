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
            
            let apiSession = ServerAppAPISession(authSession: authSession)
            self.apiSession = apiSession
            
            if #available(iOS 15, macOS 12, *) {
                async {
                    let request = LegacyGetChatBadgesByChannelRequest(channelId: twitchChannelId)
                    let (badges, _) = try await apiSession.perform(request)
                    print("Subscriber badge:", badges.subscriber?.image ?? "nil")
                    print("Admin badge:", badges.admin.image ?? "nil")
                    print("Broadcaster badge:", badges.broadcaster.image ?? "nil")
                    print("Global Mod badge:", badges.globalMod.image ?? "nil")
                    print("Mod badge:", badges.mod.image ?? "nil")
                    print("Staff badge:", badges.staff.image ?? "nil")
                    print("Turbo badge:", badges.turbo.image ?? "nil")
                }
            } else {
                apiSession.perform(LegacyGetChatBadgesByChannelRequest(channelId: twitchChannelId)) { result in
                    switch result {
                    case .success((let badges, _)):
                        print("Response:", badges)
                        
                    case .failure(let error):
                        print("Error:", error)
                    }
                }
            }
        }
    }
    
    private var apiSession: ServerAppAPISession?
}
