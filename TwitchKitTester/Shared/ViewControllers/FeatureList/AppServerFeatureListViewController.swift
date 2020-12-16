//
//  AppServerFeatureListViewController.swift
//  TwitchKitTester
//
//  Created by Tyler Prevost on 12/1/20.
//

import TwitchKit

class AppServerFeatureListViewController: FeatureListViewController {
    var authSettings: AppServerAuthSettings?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        features = [
            .embedding,
            .deepLinks,
            .auth,
            .endpoints,
            .eventSub
        ]
        
        title = "App Server API Session"
    }
    
    override func showAuth(in viewController: PlatformIndependentViewController) {
        guard let viewController = viewController as? AppServerAuthViewController else { return }
        viewController.settings = authSettings
    }
    
    override func showEndpoints(in viewController: PlatformIndependentViewController) {
        guard let viewController = viewController as? AppServerEndpointListViewController else { return }
        viewController.authSession = authSettings?.authSession
    }
    
    override func showEventSub(in viewController: EventSubViewController) {
        viewController.authSession = authSettings?.authSession
    }
}
