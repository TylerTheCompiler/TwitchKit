//
//  ClientAuthViewController.swift
//  TwitchKitTester
//
//  Created by Tyler Prevost on 12/1/20.
//

import TwitchKit

protocol ClientAuthViewControllerDelegate: AnyObject {
    func clientAuthViewController(_ viewController: ClientAuthViewController,
                                  didReceive authCode: AuthCode)
    
    func clientAuthViewController(_ viewController: ClientAuthViewController,
                                  didReceive authCode: AuthCode,
                                  expectedNonce: String?)
}

struct ClientAuthSettings {
    var authSession: ClientAuthSession
    var accessTokenStore: KeychainUserAccessTokenStore
    weak var delegate: ClientAuthViewControllerDelegate?
}

class ClientAuthViewController: PlatformIndependentViewController {
    @IBOutlet private var accessTokenLabel: PlatformIndependentLabel!
    
    var settings: ClientAuthSettings? {
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
                        notif.userInfo?[keychainAuthTokenStoreAuthTokenUserInfoKey] as? ValidatedUserAccessToken
                    self?.updateAccessTokenLabel(with: accessToken)
                }
            }
        }
    }
    
    private var tokenObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settings?.authSession.presentationContextProvider = self
        
        settings?.accessTokenStore.fetchAuthToken(forUserId: settings?.authSession.userId) { [weak self] result in
            try? self?.updateAccessTokenLabel(with: result.get())
        }
    }
    
    deinit {
        if let tokenObserver = tokenObserver {
            NotificationCenter.default.removeObserver(tokenObserver)
        }
    }
    
    private func updateAccessTokenLabel(with validatedAccessToken: ValidatedUserAccessToken?) {
        if TesterAppData.shared.hideAccessTokens {
            accessTokenLabel.text = "<Hidden>"
        } else {
            accessTokenLabel.text = validatedAccessToken?.stringValue ?? "nil"
        }
    }
    
    @IBAction private func getAccessToken(_ sender: Any) {
        settings?.authSession.defaultAuthFlow = .oAuth(forceVerify: false)
        settings?.authSession.getNewAccessToken { result in
            switch result {
            case .success((let validatedAccessToken, _, _)):
                print("(Client) User access token:", validatedAccessToken.stringValue)
                
            case .failure(let error):
                print("(Client) Error:", error)
            }
        }
    }
    
    @IBAction private func getIdTokenAndAccessToken(_ sender: Any) {
        settings?.authSession.defaultAuthFlow = .openId(claims: TesterAppData.shared.claims)
        settings?.authSession.getNewAccessToken { result in
            switch result {
            case .success((let validatedAccessToken, let idToken, _)):
                if let idToken = idToken {
                    print("(Client) ID token:", idToken)
                }
                
                print("(Client) User access token:", validatedAccessToken.stringValue)
                
            case .failure(let error):
                print("(Client) Error:", error)
            }
        }
    }
    
    @IBAction private func getIdToken(_ sender: Any) {
        settings?.authSession.getIdToken(claims: TesterAppData.shared.claims) { result in
            switch result {
            case .success(let idToken):
                print("(Client) ID token:", idToken)
                
            case .failure(let error):
                print("(Client) Error:", error)
            }
        }
    }
    
    @IBAction private func getAuthCodeUsingOAuth(_ sender: Any) {
        settings?.authSession.getAuthCode(using: .oAuth()) { result in
            switch result {
            case .success((let code, _)):
                print("(Client) Auth code (send to server):", code)
                self.settings?.delegate?.clientAuthViewController(self, didReceive: code)
                
            case .failure(let error):
                print("(Client) Error:", error)
            }
        }
    }
    
    @IBAction private func getAuthCodeUsingOIDC(_ sender: Any) {
        settings?.authSession.getAuthCode(using: .openId(claims: TesterAppData.shared.claims)) { result in
            switch result {
            case .success((let code, let nonce)):
                print("(Client) Auth code (send to server):", code)
                print("(Client) Nonce (send to server):", nonce ?? "nil")
                self.settings?.delegate?.clientAuthViewController(self, didReceive: code, expectedNonce: nonce)
                
            case .failure(let error):
                print("(Client) Error:", error)
            }
        }
    }
    
    @IBAction private func revokeAccessToken(_ sender: Any) {
        settings?.authSession.revokeCurrentAccessToken { result in
            switch result {
            case .success:
                print("(Client) User access token revoked!")
                
            case .failure(let error):
                print("(Client) Error:", error)
            }
        }
    }
    
    @IBAction private func clearAccessToken(_ sender: Any) {
        guard let userId = settings?.authSession.userId else {
            print("(Client) Error: No userId!")
            return
        }
        
        settings?.accessTokenStore.removeAuthToken(forUserId: userId) { error in
            if let error = error {
                print("(Client) Error:", error)
            } else {
                print("(Client) User access token cleared!")
            }
        }
    }
}
