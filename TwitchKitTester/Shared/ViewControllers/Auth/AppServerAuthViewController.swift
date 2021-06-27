//
//  AppServerAuthViewController.swift
//  TwitchKitTester
//
//  Created by Tyler Prevost on 12/1/20.
//

import TwitchKit

struct AppServerAuthSettings {
    var authSession: ServerAppAuthSession
    var accessTokenStore: KeychainAppAccessTokenStore
}

class AppServerAuthViewController: PlatformIndependentViewController {
    @IBOutlet private var accessTokenLabel: PlatformIndependentLabel!
    
    var settings: AppServerAuthSettings? {
        didSet {
            if let tokenObserver = tokenObserver {
                NotificationCenter.default.removeObserver(tokenObserver)
            }
            
            if let accessTokenStore = settings?.accessTokenStore {
                tokenObserver = NotificationCenter.default.addObserver(
                    forName: .keychainAuthTokenStoreDidStoreAuthToken,
                    object: accessTokenStore,
                    queue: .main
                ) { [weak self] notif in
                    let accessToken =
                        notif.userInfo?[keychainAuthTokenStoreAuthTokenUserInfoKey] as? ValidatedAppAccessToken
                    self?.updateAccessTokenLabel(with: accessToken)
                }
            }
        }
    }
    
    private var tokenObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settings?.accessTokenStore.fetchAuthToken { [weak self] result in
            try? self?.updateAccessTokenLabel(with: result.get())
        }
    }
    
    deinit {
        if let tokenObserver = tokenObserver {
            NotificationCenter.default.removeObserver(tokenObserver)
        }
    }
    
    private func updateAccessTokenLabel(with validatedAccessToken: ValidatedAppAccessToken?) {
        if TesterAppData.shared.hideAccessTokens {
            accessTokenLabel.text = "<Hidden>"
        } else {
            accessTokenLabel.text = validatedAccessToken?.stringValue ?? "nil"
        }
    }
    
    @IBAction private func getAccessToken(_ sender: Any) {
        settings?.authSession.getNewAccessToken { result in
            switch result {
            case .success((let validatedAccessToken, _)):
                print("(Server) App access token:", validatedAccessToken.stringValue)
                
            case .failure(let error):
                print("(Server) Error:", error)
            }
        }
    }
    
    @IBAction private func revokeAccessToken(_ sender: Any) {
        settings?.authSession.revokeCurrentAccessToken { result in
            switch result {
            case .success(let response):
                print("(Server) App access token revoked!", response.statusCode)
                
            case .failure(let error):
                print("(Server) Error:", error)
            }
        }
    }
    
    @IBAction private func clearAccessToken(_ sender: Any) {
        settings?.accessTokenStore.removeAuthToken(forUserId: nil) { error in
            if let error = error {
                print("(Server) Error:", error)
            } else {
                print("(Server) App access token cleared!")
            }
        }
    }
}
