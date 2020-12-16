//
//  ClientFeatureListViewController.swift
//  TwitchKitTester
//
//  Created by Tyler Prevost on 12/1/20.
//

import TwitchKit

class ClientFeatureListViewController: FeatureListViewController {
    var authSettings: ClientAuthSettings?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        features = [
            .embedding,
            .deepLinks,
            .auth,
            .endpoints
        ]
        
        if let userId = authSettings?.authSession.userId {
            title = "Client API Session (\(userId))"
        } else {
            title = "Client API Session"
        }
    }
    
    override func showAuth(in viewController: PlatformIndependentViewController) {
        guard let viewController = viewController as? ClientAuthViewController else { return }
        viewController.settings = authSettings
    }
    
    override func showEndpoints(in viewController: PlatformIndependentViewController) {
        guard let viewController = viewController as? ClientEndpointListViewController else { return }
        viewController.authSession = authSettings?.authSession
    }
}
