//
//  EventSubViewController.swift
//  TwitchKitTester
//
//  Created by Tyler Prevost on 12/1/20.
//

import TwitchKit

class EventSubViewController: PlatformIndependentViewController {
    var authSession: ServerAppAuthSession? {
        didSet { if isViewLoaded { update() } }
    }
    
    private var apiSession: ServerAppAPISession?
    private var server: EventSub.Server?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        update()
    }
    
    private func update() {
        guard let authSession = authSession else {
            apiSession = nil
            return
        }
        
        do {
            try server = .init(authSession: authSession, port: .http)
            try server?.start()
        } catch {
            print("(Server) Error creating and starting EventSub server:", error)
        }
        
        apiSession = .init(authSession: authSession)
        
        deleteAllSubscriptions { [weak self] errors in
            if errors.isEmpty {
                self?.createSubscription(.channelBan(broadcasterUserId: twitchChannelId))
                self?.createSubscription(.channelUnban(broadcasterUserId: twitchChannelId))
            } else {
                print("(Server) Errors deleting subscriptions:", errors)
            }
        }
    }
    
    private func createSubscription(_ condition: EventSub.SubscriptionCondition) {
        let request = CreateEventSubSubscriptionRequest(
            condition: condition,
            callbackURL: TesterAppData.shared.eventSubCallbackURL,
            secret: UUID().uuidString
        )
        
        apiSession?.perform(request) { result in
            switch result {
            case .success((let responseBody, _)):
                print("(Server) Created EventSub subscription:", responseBody.subscriptions.first as Any)
                
            case .failure(let error):
                print("(Server) Error creating EventSub subscription:", error)
            }
        }
    }
    
    private func getSubscriptions(
        completion: @escaping (Result<(GetEventSubSubscriptionsRequest.ResponseBody, HTTPURLResponse), Error>) -> Void
    ) {
        apiSession?.perform(GetEventSubSubscriptionsRequest(), completion: completion)
    }
    
    private func deleteAllSubscriptions(completion: @escaping ([Error]) -> Void) {
        getSubscriptions { result in
            switch result {
            case .success((let responseBody, _)):
                let group = DispatchGroup()
                var errors = [Swift.Error]()
                for subscription in responseBody.subscriptions {
                    group.enter()
                    self.deleteSubscription(withId: subscription.id) { result in
                        switch result {
                        case .success:
                            break
                        case .failure(let error):
                            errors.append(error)
                        }
                        group.leave()
                    }
                }
                
                group.notify(queue: .main) {
                    completion(errors)
                }
                
            case .failure(let error):
                completion([error])
            }
        }
    }
    
    private func deleteSubscription(
        withId subscriptionId: String,
        completion: @escaping (Result<HTTPURLResponse, Error>) -> Void
    ) {
        apiSession?.perform(DeleteEventSubSubscriptionRequest(subscriptionId: subscriptionId), completion: completion)
    }
}
