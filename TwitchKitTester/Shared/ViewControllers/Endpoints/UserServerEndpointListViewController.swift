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
            
            apiSession?.perform(GetPredictionsRequest()) {
                switch $0 {
                case .success((let responseBody, _)):
                    print("Get Predictions result:", responseBody.predictions)
                case .failure(let error):
                    print("Error:", error)
                }
            }
            
            let req = CreatePredictionRequest(title: "Will this work?", blueOutcome: "Yes", pinkOutcome: "No")
            apiSession?.perform(req) {
                switch $0 {
                case .success((let responseBody, _)):
                    print("Create Prediction result:", responseBody.prediction)
                case .failure(let error):
                    print("Error:", error)
                }
            }
        }
    }
    
    private var apiSession: ServerUserAPISession?
}
