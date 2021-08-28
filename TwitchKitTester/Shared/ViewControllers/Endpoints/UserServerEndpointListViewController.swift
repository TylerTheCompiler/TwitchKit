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
            
            apiSession = ServerUserAPISession(authSession: authSession)
            
            apiSession?.perform(GetPollsRequest()) {
                switch $0.result {
                case .success(let responseBody):
                    print("Get Polls result:", responseBody.polls)
                case .failure(let error):
                    print("Error:", error)
                }
            }
            
            let req = CreatePollRequest(title: "Will this work?")
            apiSession?.perform(req) {
                switch $0.result {
                case .success(let responseBody):
                    print("Create Poll result:", responseBody.poll)
                case .failure(let error):
                    print("Error:", error)
                }
            }
        }
    }
    
    private var apiSession: ServerUserAPISession?
}
