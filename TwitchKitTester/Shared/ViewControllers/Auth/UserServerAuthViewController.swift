//
//  UserServerAuthViewController.swift
//  TwitchKitTester
//
//  Created by Tyler Prevost on 12/1/20.
//

import TwitchKit

protocol UserServerAuthViewControllerDelegate: AnyObject {
    func userServerAuthViewControllerCanConsumeAuthCode(_ viewController: UserServerAuthViewController) -> Bool
    func userServerAuthViewControllerConsumeAuthCode(_ viewController: UserServerAuthViewController) -> AuthCode?
    func userServerAuthViewControllerConsumeAuthCodeAndExpectedNonce(_ viewController: UserServerAuthViewController) -> (AuthCode, String?)?
    // swiftlint:disable:previous line_length
}

struct UserServerAuthSettings {
    var authSession: ServerUserAuthSession
    var accessTokenStore: KeychainUserAccessTokenStore
    var refreshTokenStore: KeychainRefreshTokenStore
    weak var delegate: UserServerAuthViewControllerDelegate?
}

class UserServerAuthViewController: PlatformIndependentViewController {
    @IBOutlet private var accessTokenLabel: PlatformIndependentLabel!
    @IBOutlet private var refreshTokenLabel: PlatformIndependentLabel!
    @IBOutlet private var continueSignInButton: PlatformIndependentButton!
    
    var settings: UserServerAuthSettings? {
        didSet {
            if let accessTokenObserver = accessTokenObserver {
                NotificationCenter.default.removeObserver(accessTokenObserver)
            }
            
            if let refreshTokenObserver = refreshTokenObserver {
                NotificationCenter.default.removeObserver(refreshTokenObserver)
            }
            
            if let accessTokenStore = settings?.accessTokenStore {
                accessTokenObserver = NotificationCenter.default.addObserver(
                    forName: .keychainAuthTokenStoreDidStoreAuthToken,
                    object: accessTokenStore,
                    queue: .main
                ) { [weak self] notif in
                    let accessToken =
                        notif.userInfo?[keychainAuthTokenStoreAuthTokenUserInfoKey] as? ValidatedUserAccessToken
                    self?.updateAccessTokenLabel(with: accessToken)
                }
            }
            
            if let refreshTokenStore = settings?.accessTokenStore {
                refreshTokenObserver = NotificationCenter.default.addObserver(
                    forName: .keychainAuthTokenStoreDidStoreAuthToken,
                    object: refreshTokenStore,
                    queue: .main
                ) { [weak self] notif in
                    let refreshToken = notif.userInfo?[keychainAuthTokenStoreAuthTokenUserInfoKey] as? RefreshToken
                    self?.updateRefreshTokenLabel(with: refreshToken)
                }
            }
        }
    }
    
    private var accessTokenObserver: NSObjectProtocol?
    private var refreshTokenObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        settings?.accessTokenStore.fetchAuthToken(forUserId: settings?.authSession.userId) { [weak self] result in
            try? self?.updateAccessTokenLabel(with: result.get())
        }
        
        settings?.refreshTokenStore.fetchAuthToken(forUserId: settings?.authSession.userId) { [weak self] result in
            try? self?.updateRefreshTokenLabel(with: result.get())
        }
        
        continueSignInButton.isEnabled = settings?.delegate?
            .userServerAuthViewControllerCanConsumeAuthCode(self) ?? false
    }
    
    deinit {
        if let accessTokenObserver = accessTokenObserver {
            NotificationCenter.default.removeObserver(accessTokenObserver)
        }
        
        if let refreshTokenObserver = refreshTokenObserver {
            NotificationCenter.default.removeObserver(refreshTokenObserver)
        }
    }
    
    private func updateAccessTokenLabel(with validatedAccessToken: ValidatedUserAccessToken?) {
        if TesterAppData.shared.hideAccessTokens {
            accessTokenLabel.text = "<Hidden>"
        } else {
            accessTokenLabel.text = validatedAccessToken?.stringValue ?? "nil"
        }
    }
    
    private func updateRefreshTokenLabel(with refreshToken: RefreshToken?) {
        if TesterAppData.shared.hideAccessTokens {
            refreshTokenLabel.text = "<Hidden>"
        } else {
            refreshTokenLabel.text = refreshToken?.rawValue ?? "nil"
        }
    }
    
    @IBAction private func continueSignInWithAuthCode(_ sender: Any) {
        if let authCode = settings?.delegate?.userServerAuthViewControllerConsumeAuthCode(self) {
            continueSignInButton.isEnabled = false
            settings?.authSession.getNewAccessToken(withAuthCode: authCode) { response in
                switch response.result {
                case .success(let validatedAccessToken):
                    print("(Server) User access token:", validatedAccessToken.stringValue)
                    
                case .failure(let error):
                    print("(Server) Error:", error)
                }
            }
        } else if let authCodeAndNonce = settings?.delegate?.userServerAuthViewControllerConsumeAuthCodeAndExpectedNonce(self) {
            // swiftlint:disable:previous line_length
            continueSignInButton.isEnabled = false
            settings?.authSession.getNewAccessAndIdTokens(withAuthCode: authCodeAndNonce.0,
                                                          expectedNonce: authCodeAndNonce.1) { response in
                switch response.result {
                case .success((let validatedAccessToken, let idToken)):
                    print("(Server) User access token:", validatedAccessToken.stringValue)
                    print("(Server) ID token:", idToken)
                    
                case .failure(let error):
                    print("(Server) Error:", error)
                }
            }
        }
    }
    
    @IBAction private func refreshAccessToken(_ sender: Any) {
        settings?.authSession.getRefreshedAccessToken { response in
            switch response.result {
            case .success(let validatedAccessToken):
                print("(Server) User access token:", validatedAccessToken.stringValue)
                
            case .failure(let error):
                print("(Server) Error:", error)
            }
        }
    }
    
    @IBAction private func revokeAccessToken(_ sender: Any) {
        settings?.authSession.revokeCurrentAccessToken { response in
            if let error = response.error {
                print("(Server) Error:", error)
            } else {
                print("(Server) User access token revoked!", response.httpURLResponse?.statusCode ?? -1)
            }
        }
    }
    
    @IBAction private func clearAccessToken(_ sender: Any) {
        guard let userId = settings?.authSession.userId else {
            print("(Server) Error: No userId!")
            return
        }
        
        settings?.accessTokenStore.removeAuthToken(forUserId: userId) { error in
            if let error = error {
                print("(Server) Error:", error)
            } else {
                print("(Server) User access token cleared!")
            }
        }
    }
    
    @IBAction private func clearRefreshToken(_ sender: Any) {
        guard let userId = settings?.authSession.userId else {
            print("(Server) Error: No userId!")
            return
        }
        
        settings?.refreshTokenStore.removeAuthToken(forUserId: userId) { error in
            if let error = error {
                print("(Server) Error:", error)
            } else {
                print("(Server) Refresh token cleared!")
            }
        }
    }
}
