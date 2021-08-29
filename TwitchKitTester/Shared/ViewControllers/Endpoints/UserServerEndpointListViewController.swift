//
//  UserServerEndpointListViewController.swift
//  TwitchKitTester
//
//  Created by Tyler Prevost on 12/1/20.
//

import TwitchKit

class UserServerEndpointListViewController: PlatformIndependentTableViewController {
    var authSession: ServerUserAuthSession? {
        didSet {
            guard let authSession = authSession else {
                apiSession = nil
                return
            }
            
            let apiSession = ServerUserAPISession(authSession: authSession)
            self.apiSession = apiSession
            
            guard #available(iOS 15, *) else { return }
            
            Task {
                do {
                    let req = GetChannelStreamScheduleRequest()
                    print(try await apiSession.perform(req).body.schedule)
                } catch {
                    print("Error:", error)
                }
            }
        }
    }
    
    private var apiSession: ServerUserAPISession?
}
