//
//  SessionListViewController.swift
//  TwitchKitTester
//
//  Created by Tyler Prevost on 11/8/20.
//

import Foundation
import TwitchKit

#if os(macOS)
import AppKit
#else
import UIKit
#endif

let twitchChannelId = "12826"

class SessionListViewController: PlatformIndependentTableViewController {
    private var clientAuthSessions = [String: ClientAuthSession]()
    private var serverUserAuthSessions = [String: ServerUserAuthSession]()
    private var serverAppAuthSession: ServerAppAuthSession?
    
    private let clientSideUserAccessTokenStore = KeychainUserAccessTokenStore(synchronizesOveriCloud: true)
    private let serverSideUserAccessTokenStore = KeychainUserAccessTokenStore(synchronizesOveriCloud: true,
                                                                              identifier: "server")
    private let serverRefreshTokenStore = KeychainRefreshTokenStore(identifier: "server")
    private let appAccessTokenStore = KeychainAppAccessTokenStore(identifier: "server")
    
    private var pendingAuthCode: AuthCode?
    private var pendingAuthCodeAndExpectedNonce: (AuthCode, String?)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logAllGenericPasswords()
        
        clientAuthSessions = Dictionary(clientSideUserIds.map { ($0, ClientAuthSession(
            clientId: TesterAppData.shared.clientId,
            redirectURL: TesterAppData.shared.redirectURL,
            scopes: TesterAppData.shared.scopes,
            accessTokenStore: clientSideUserAccessTokenStore,
            userId: $0,
            defaultAuthFlow: .openId(claims: TesterAppData.shared.claims),
            presentationContextProvider: self
        )) }, uniquingKeysWith: { $1 })
        
        serverUserAuthSessions = Dictionary(serverSideUserIds.map { ($0, ServerUserAuthSession(
            clientId: TesterAppData.shared.clientId,
            clientSecret: TesterAppData.shared.clientSecret,
            redirectURL: TesterAppData.shared.redirectURL,
            scopes: TesterAppData.shared.scopes,
            accessTokenStore: serverSideUserAccessTokenStore,
            refreshTokenStore: serverRefreshTokenStore,
            userId: $0
        )) }, uniquingKeysWith: { $1 })
        
        appAccessTokenStore.fetchAuthToken { result in
            DispatchQueue.main.async {
                self.serverAppAuthSession = (try? result.get()) == nil ? nil : ServerAppAuthSession(
                    clientId: TesterAppData.shared.clientId,
                    clientSecret: TesterAppData.shared.clientSecret,
                    scopes: TesterAppData.shared.scopes,
                    accessTokenStore: self.appAccessTokenStore
                )
                
                self.tableView.reloadData()
            }
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didStoreToken(_:)),
                                               name: .keychainAuthTokenStoreDidStoreAuthToken,
                                               object: clientSideUserAccessTokenStore)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didStoreToken(_:)),
                                               name: .keychainAuthTokenStoreDidStoreAuthToken,
                                               object: serverSideUserAccessTokenStore)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didStoreToken(_:)),
                                               name: .keychainAuthTokenStoreDidStoreAuthToken,
                                               object: serverRefreshTokenStore)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(didStoreToken(_:)),
                                               name: .keychainAuthTokenStoreDidStoreAuthToken,
                                               object: appAccessTokenStore)
    }
    
    @objc private func didStoreToken(_ sender: Any) {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    #if os(macOS)
    override func viewWillAppear() {
        super.viewWillAppear()
        tableView.reloadData()
    }
    #else
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    #endif
    
    @IBAction private func createNewSession(_ sender: Any) {
        #if os(macOS)
        guard let window = view.window else { return }
        let alert = NSAlert()
        alert.alertStyle = .informational
        alert.messageText = "Choose Session Type"
        alert.informativeText = "Select a session type to authorize with."
        alert.addButton(withTitle: "Client")
        alert.addButton(withTitle: "Server (User)")
        alert.addButton(withTitle: "Server (App)")
        alert.addButton(withTitle: "Cancel")
        alert.beginSheetModal(for: window) { [weak self] response in
            switch response {
            case .alertFirstButtonReturn: self?.createNewClientAuthSession()
            case .alertSecondButtonReturn: self?.createNewUserServerAuthSession()
            case .alertThirdButtonReturn: self?.createNewAppServerAuthSession()
            default: break
            }
        }
        
        #else
        let sheet = UIAlertController(title: "Choose Session Type",
                                      message: "Select a session type to authorize with.",
                                      preferredStyle: .actionSheet)
        sheet.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
        
        sheet.addAction(.init(title: "Client", style: .default) { [weak self] _ in
            self?.createNewClientAuthSession()
        })
        
        sheet.addAction(.init(title: "Server (User)", style: .default) { [weak self] _ in
            self?.createNewUserServerAuthSession()
        })
        
        sheet.addAction(.init(title: "Server (App)", style: .default) { [weak self] _ in
            self?.createNewAppServerAuthSession()
        })
        
        sheet.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        
        present(sheet, animated: true)
        #endif
    }
    
    @IBAction private func showSessionForSelectedRow(_ sender: Any) {
        #if os(macOS)
        let section: Int
        let row = tableView.selectedRow
        if row >= 0, row < clientSideUserIds.count {
            section = 0
        } else if row >= clientSideUserIds.count, row < clientSideUserIds.count + serverSideUserIds.count {
            section = 1
        } else if row >= clientSideUserIds.count + serverSideUserIds.count {
            section = 2
        } else {
            return
        }
        #else
        let section = tableView.indexPathForSelectedRow?.section
        #endif
        
        switch section {
        case 0: performSegue(withIdentifier: "ShowClientSession", sender: nil)
        case 1: performSegue(withIdentifier: "ShowUserServerSession", sender: nil)
        case 2: performSegue(withIdentifier: "ShowAppServerSession", sender: nil)
        default: break
        }
    }
    
    override func prepare(for segue: PlatformIndependentStoryboardSegue, sender: Any?) {
        #if os(macOS)
        let row = tableView.selectedRow
        if row >= 0, row < clientSideUserIds.count,
           let session = clientAuthSessions[clientSideUserIds[row]] {
            guard let sessionVC = segue.destination as? ClientFeatureListViewController else { return }
            sessionVC.authSettings = .init(authSession: session,
                                           accessTokenStore: clientSideUserAccessTokenStore,
                                           delegate: self)
        } else if row >= clientSideUserIds.count, row < clientSideUserIds.count + serverSideUserIds.count,
                  let session = serverUserAuthSessions[serverSideUserIds[row - clientSideUserIds.count]] {
            guard let sessionVC = segue.destination as? UserServerFeatureListViewController else { return }
            sessionVC.authSettings = .init(authSession: session,
                                           accessTokenStore: serverSideUserAccessTokenStore,
                                           refreshTokenStore: serverRefreshTokenStore,
                                           delegate: self)
        } else if row >= clientSideUserIds.count + serverSideUserIds.count {
            guard let sessionVC = segue.destination as? AppServerFeatureListViewController,
                  let session = serverAppAuthSession else {
                return
            }
            
            sessionVC.authSettings = .init(authSession: session,
                                           accessTokenStore: appAccessTokenStore)
        }
        
        #else
        let selectedCellIndexPath = tableView.indexPathForSelectedRow
        switch (selectedCellIndexPath?.section, selectedCellIndexPath?.row) {
        case (0, let row?):
            guard let sessionVC = segue.destination as? ClientFeatureListViewController,
                  let session = clientAuthSessions[clientSideUserIds[row]] else {
                return
            }
            
            sessionVC.authSettings = .init(authSession: session,
                                           accessTokenStore: clientSideUserAccessTokenStore,
                                           delegate: self)
            
        case (1, let row?):
            guard let sessionVC = segue.destination as? UserServerFeatureListViewController,
                  let session = serverUserAuthSessions[serverSideUserIds[row]] else {
                return
            }
            
            sessionVC.authSettings = .init(authSession: session,
                                           accessTokenStore: serverSideUserAccessTokenStore,
                                           refreshTokenStore: serverRefreshTokenStore,
                                           delegate: self)
            
        case (2, _):
            guard let sessionVC = segue.destination as? AppServerFeatureListViewController,
                  let session = serverAppAuthSession else {
                return
            }
            
            sessionVC.authSettings = .init(authSession: session,
                                           accessTokenStore: appAccessTokenStore)
            
        default:
            break
        }
        #endif
    }
    
    #if os(macOS)
    override func numberOfRows(in tableView: NSTableView) -> Int {
        clientSideUserIds.count + serverSideUserIds.count + (serverAppAuthSession == nil ? 0 : 1)
    }
    
    override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        var userId = "N/A"
        var kind = 2
        var kindString = "App"
        
        if row >= 0, row < clientSideUserIds.count {
            userId = clientSideUserIds[row]
            kind = 0
            kindString = "User (Client)"
        } else if row >= clientSideUserIds.count, row < clientSideUserIds.count + serverSideUserIds.count {
            userId = serverSideUserIds[row - clientSideUserIds.count]
            kind = 1
            kindString = "User (Server)"
        }
        
        switch tableColumn?.identifier.rawValue {
        case "kindColumn":
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "kindCell")
            let cell = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? SessionCell
            cell?.textField?.text = kindString
            return cell
            
        case "userIdColumn":
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "userIdCell")
            let cell = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? SessionCell
            cell?.textField?.text = userId
            return cell
            
        default:
            let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "accessTokenCell")
            let cell = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? SessionCell
            let uuid = UUID()
            cell?.uuid = uuid
            
            weak var weakCell = cell
            func setText<T>(_ result: Result<T, Error>) where T: AccessToken {
                DispatchQueue.main.async {
                    guard weakCell?.uuid == uuid else { return }
                    weakCell?.textField?.text = (try? result.get())?.stringValue ?? "No Token"
                }
            }
            
            switch (kind, TesterAppData.shared.hideAccessTokens) {
            case (_, true): cell?.textField?.text = "Access tokens are hidden"
            case (0, false): clientSideUserAccessTokenStore.fetchAuthToken(forUserId: userId, completion: setText)
            case (1, false): serverSideUserAccessTokenStore.fetchAuthToken(forUserId: userId, completion: setText)
            case (2, false): appAccessTokenStore.fetchAuthToken(completion: setText)
            default: cell?.textField?.text = " "
            }
            
            return cell
        }
    }
    
    override func keyDown(with event: NSEvent) {
        let selectedRow = tableView.selectedRow
        guard selectedRow != -1,
              let characters = event.charactersIgnoringModifiers,
              characters.count == 1,
              (characters as NSString).character(at: 0) == NSDeleteCharacter else {
            super.keyDown(with: event)
            return
        }
        
        deleteRow(selectedRow)
    }
    
    #else
    override func numberOfSections(in tableView: UITableView) -> Int {
        3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return clientSideUserIds.count
        case 1: return serverSideUserIds.count
        case 2: return serverAppAuthSession == nil ? 0 : 1
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0: return "Client Sessions"
        case 1: return "Server User Sessions"
        case 2: return "Server App Sessions"
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let sessionCell = cell as? SessionCell
        let uuid = UUID()
        sessionCell?.uuid = uuid
        
        weak var weakCell = cell
        func setText<T>(_ result: Result<T, Error>) where T: AccessToken {
            DispatchQueue.main.async {
                guard sessionCell?.uuid == uuid else { return }
                weakCell?.detailTextLabel?.text = (try? result.get())?.stringValue ?? "No token"
            }
        }
        
        switch (indexPath.section, TesterAppData.shared.hideAccessTokens) {
        case (0, true):
            let userId = clientSideUserIds[indexPath.row]
            cell.textLabel?.text = userId
            cell.detailTextLabel?.text = "Access tokens are hidden"
            
        case (1, true):
            let userId = serverSideUserIds[indexPath.row]
            cell.textLabel?.text = userId
            cell.detailTextLabel?.text = "Access tokens are hidden"
            
        case (2, true):
            cell.textLabel?.text = "App Access Token"
            cell.detailTextLabel?.text = "Access tokens are hidden"
            
        case (0, false):
            let userId = clientSideUserIds[indexPath.row]
            cell.textLabel?.text = userId
            clientSideUserAccessTokenStore.fetchAuthToken(forUserId: userId, completion: setText)
            
        case (1, false):
            let userId = serverSideUserIds[indexPath.row]
            cell.textLabel?.text = userId
            serverSideUserAccessTokenStore.fetchAuthToken(forUserId: userId, completion: setText)
            
        case (2, false):
            cell.textLabel?.text = "App Access Token"
            appAccessTokenStore.fetchAuthToken(completion: setText)
            
        default:
            cell.textLabel?.text = " "
            cell.detailTextLabel?.text = " "
        }
        
        return cell
    }
    
    override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        switch indexPath.section {
        case 0: return swipeActionForClientSession(at: indexPath)
        case 1: return swipeActionForUserServerSession(at: indexPath)
        case 2: return swipeActionForAppSession(at: indexPath)
        default: return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showSessionForSelectedRow(tableView)
    }
    #endif
}

// MARK: - User IDs from User Defaults

extension SessionListViewController {
    private var clientSideUserIds: [String] {
        get { UserDefaults.standard.array(forKey: "com.tylerprevost.TwitchKitTester.ClientUserIds") as? [String] ?? [] }
        set {
            UserDefaults.standard.set(newValue, forKey: "com.tylerprevost.TwitchKitTester.ClientUserIds")
            UserDefaults.standard.synchronize()
        }
    }
    
    private var serverSideUserIds: [String] {
        get { UserDefaults.standard.array(forKey: "com.tylerprevost.TwitchKitTester.ServerUserIds") as? [String] ?? [] }
        set {
            UserDefaults.standard.set(newValue, forKey: "com.tylerprevost.TwitchKitTester.ServerUserIds")
            UserDefaults.standard.synchronize()
        }
    }
}

// MARK: - Keychain Manipulation

extension SessionListViewController {
    private func logAllGenericPasswords() {
        do {
            var query = [String: AnyObject]()
            query[kSecClass as String] = kSecClassGenericPassword
            query[kSecMatchLimit as String] = kSecMatchLimitAll
            query[kSecAttrSynchronizable as String] = kSecAttrSynchronizableAny
            query[kSecReturnAttributes as String] = kCFBooleanTrue
            
            var result: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &result)
            
            guard status != errSecItemNotFound else {
                print("Generic passwords:", [])
                return
            }
            
            guard status == noErr else { throw KeychainAuthTokenStoreError.unhandledError(status: status) }
            guard let array = result as? [Any] else { throw KeychainAuthTokenStoreError.unexpectedItemData }
            
            print("Generic passwords:", array)
        } catch {
            print("Log all generic passwords error:", error)
        }
    }
    
    private func deleteAllGenericPasswords() {
        do {
            var query = [String: AnyObject]()
            query[kSecClass as String] = kSecClassGenericPassword
            query[kSecAttrSynchronizable as String] = kSecAttrSynchronizableAny
            
            let status = SecItemDelete(query as CFDictionary)
            
            guard status == noErr else { throw KeychainAuthTokenStoreError.unhandledError(status: status) }
        } catch {
            print("Delete all keychain items error:", error)
        }
    }
}

// MARK: - Session Creation

extension SessionListViewController {
    private func createNewClientAuthSession() {
        let session = ClientAuthSession(
            clientId: TesterAppData.shared.clientId,
            redirectURL: TesterAppData.shared.redirectURL,
            scopes: TesterAppData.shared.scopes,
            accessTokenStore: clientSideUserAccessTokenStore,
            defaultAuthFlow: .openId(claims: TesterAppData.shared.claims),
            prefersEphemeralWebBrowserSession: true,
            presentationContextProvider: self
        )
        
        if #available(iOS 15, macOS 12, *) {
            #if os(iOS)
            async {
                let (validatedAccessToken, _, _) = try await session.newAccessToken()
                await MainActor.run {
                    self.addClientAuthSession(session, for: validatedAccessToken.validation.userId)
                }
            }
            #elseif os(macOS)
            Task.init {
                let (validatedAccessToken, _, _) = try await session.newAccessToken()
                await MainActor.run {
                    self.addClientAuthSession(session, for: validatedAccessToken.validation.userId)
                }
            }
            #endif
        } else {
            session.getNewAccessToken { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success((let validatedAccessToken, _, _)):
                        self.addClientAuthSession(session, for: validatedAccessToken.validation.userId)
                        
                    case .failure(let error):
                        print("Auth error:", error)
                    }
                }
            }
        }
    }
    
    private func createNewUserServerAuthSession() {
        let clientSession = ClientAuthSession(
            clientId: TesterAppData.shared.clientId,
            redirectURL: TesterAppData.shared.redirectURL,
            scopes: TesterAppData.shared.scopes,
            accessTokenStore: serverSideUserAccessTokenStore,
            defaultAuthFlow: .openId(claims: TesterAppData.shared.claims),
            prefersEphemeralWebBrowserSession: true,
            presentationContextProvider: self
        )
        
        clientSession.getAuthCode { result in
            switch result {
            case .success((let authCode, let nonce)):
                let session = ServerUserAuthSession(
                    clientId: TesterAppData.shared.clientId,
                    clientSecret: TesterAppData.shared.clientSecret,
                    redirectURL: TesterAppData.shared.redirectURL,
                    scopes: TesterAppData.shared.scopes,
                    accessTokenStore: self.serverSideUserAccessTokenStore,
                    refreshTokenStore: self.serverRefreshTokenStore
                )
                
                session.getNewAccessAndIdTokens(withAuthCode: authCode, expectedNonce: nonce) { result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success((let validatedAccessToken, _, _)):
                            self.addUserServerAuthSession(session, for: validatedAccessToken.validation.userId)
                            
                        case .failure(let error):
                            print("Server authorize error:", error)
                        }
                    }
                }
                
            case .failure(let error):
                print("Get auth code error:", error)
            }
        }
    }
    
    private func createNewAppServerAuthSession() {
        let session = ServerAppAuthSession(
            clientId: TesterAppData.shared.clientId,
            clientSecret: TesterAppData.shared.clientSecret,
            scopes: TesterAppData.shared.scopes,
            accessTokenStore: appAccessTokenStore
        )
        
        session.getNewAccessToken { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.setAppServerAuthSession(session)
                    
                case .failure(let error):
                    print("App auth error:", error)
                }
            }
        }
    }
    
    private func addClientAuthSession(_ session: ClientAuthSession, for userId: String) {
        clientAuthSessions[userId] = session
        if let index = clientSideUserIds.firstIndex(of: userId) {
            #if os(macOS)
            tableView.reloadData(forRowIndexes: .init(integer: index), columnIndexes: [0, 1, 2])
            #else
            tableView.reloadRows(at: [.init(row: index, section: 0)], with: .automatic)
            #endif
        } else {
            clientSideUserIds.append(userId)
            #if os(macOS)
            tableView.insertRows(at: .init(integer: clientSideUserIds.count - 1), withAnimation: .slideDown)
            #else
            tableView.insertRows(at: [.init(row: clientSideUserIds.count - 1, section: 0)], with: .automatic)
            #endif
        }
    }
    
    private func addUserServerAuthSession(_ session: ServerUserAuthSession, for userId: String) {
        serverUserAuthSessions[userId] = session
        if let index = serverSideUserIds.firstIndex(of: userId) {
            #if os(macOS)
            tableView.reloadData(forRowIndexes: .init(integer: index + clientSideUserIds.count),
                                 columnIndexes: [0, 1, 2])
            #else
            tableView.reloadRows(at: [.init(row: index, section: 1)],
                                 with: .automatic)
            #endif
        } else {
            serverSideUserIds.append(userId)
            #if os(macOS)
            tableView.insertRows(at: .init(integer: serverSideUserIds.count - 1 + clientSideUserIds.count),
                                 withAnimation: .slideDown)
            #else
            tableView.insertRows(at: [.init(row: serverSideUserIds.count - 1, section: 1)],
                                 with: .automatic)
            #endif
        }
    }
    
    private func setAppServerAuthSession(_ session: ServerAppAuthSession) {
        if serverAppAuthSession != nil {
            serverAppAuthSession = session
            #if os(macOS)
            tableView.reloadData(forRowIndexes: .init(integer: clientSideUserIds.count + serverSideUserIds.count),
                                 columnIndexes: [0, 1, 2])
            #else
            tableView.reloadRows(at: [.init(row: 0, section: 2)], with: .automatic)
            #endif
        } else {
            serverAppAuthSession = session
            #if os(macOS)
            tableView.insertRows(at: .init(integer: clientSideUserIds.count + serverSideUserIds.count),
                                 withAnimation: .slideDown)
            #else
            tableView.insertRows(at: [.init(row: 0, section: 2)], with: .automatic)
            #endif
        }
    }
}

// MARK: - Session Deletion

extension SessionListViewController {
    #if os(macOS)
    private func deleteRow(_ row: Int) {
        if row >= 0, row < clientSideUserIds.count {
            let index = row
            let userId = clientSideUserIds[index]
            clientSideUserAccessTokenStore.removeAuthToken(forUserId: userId) { [weak self] error in
                let removeUserId = {
                    self?.clientSideUserIds.remove(at: index)
                    self?.clientAuthSessions[userId] = nil
                    self?.tableView.removeRows(at: .init(integer: row), withAnimation: .slideUp)
                }
                
                if let error = error {
                    if case KeychainAuthTokenStoreError.unhandledError(status: errSecItemNotFound) = error {
                        removeUserId()
                    }
                } else {
                    removeUserId()
                }
            }
            
        } else if row >= clientSideUserIds.count, row < clientSideUserIds.count + serverSideUserIds.count {
            let index = row - clientSideUserIds.count
            let userId = serverSideUserIds[index]
            serverSideUserAccessTokenStore.removeAuthToken(forUserId: userId) { [weak self] error in
                let removeUserId = {
                    self?.serverSideUserIds.remove(at: index)
                    self?.serverUserAuthSessions[userId] = nil
                    self?.tableView.removeRows(at: .init(integer: row), withAnimation: .slideUp)
                }
                
                if let error = error {
                    if case KeychainAuthTokenStoreError.unhandledError(status: errSecItemNotFound) = error {
                        removeUserId()
                    }
                } else {
                    removeUserId()
                }
            }
        } else {
            appAccessTokenStore.removeAuthToken(forUserId: nil) { [weak self] error in
                let removeUserId = {
                    self?.serverAppAuthSession = nil
                    self?.tableView.removeRows(at: .init(integer: row), withAnimation: .slideUp)
                }
                
                if let error = error {
                    if case KeychainAuthTokenStoreError.unhandledError(status: errSecItemNotFound) = error {
                        removeUserId()
                    }
                } else {
                    removeUserId()
                }
            }
        }
    }
    #else
    private func swipeActionForClientSession(at indexPath: IndexPath) -> UISwipeActionsConfiguration {
        let userId = clientSideUserIds[indexPath.row]
        return .init(actions: [.init(style: .destructive, title: "Delete", handler: { [weak self] _, _, completion in
            self?.clientSideUserAccessTokenStore.removeAuthToken(forUserId: userId) { error in
                let removeUserId = {
                    self?.clientSideUserIds.remove(at: indexPath.row)
                    self?.clientAuthSessions[userId] = nil
                    self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                    completion(true)
                }
                
                if let error = error {
                    if case KeychainAuthTokenStoreError.unhandledError(status: errSecItemNotFound) = error {
                        removeUserId()
                    } else {
                        completion(false)
                    }
                } else {
                    removeUserId()
                }
            }
        })])
    }
    
    private func swipeActionForUserServerSession(at indexPath: IndexPath) -> UISwipeActionsConfiguration {
        let userId = serverSideUserIds[indexPath.row]
        return .init(actions: [.init(style: .destructive, title: "Delete", handler: { [weak self] _, _, completion in
            self?.serverSideUserAccessTokenStore.removeAuthToken(forUserId: userId) { error in
                let removeUserId = {
                    self?.serverSideUserIds.remove(at: indexPath.row)
                    self?.serverUserAuthSessions[userId] = nil
                    self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                    completion(true)
                }
                
                if let error = error {
                    if case KeychainAuthTokenStoreError.unhandledError(status: errSecItemNotFound) = error {
                        removeUserId()
                    } else {
                        completion(false)
                    }
                } else {
                    removeUserId()
                }
            }
        })])
    }
    
    private func swipeActionForAppSession(at indexPath: IndexPath) -> UISwipeActionsConfiguration {
        return .init(actions: [.init(style: .destructive, title: "Delete", handler: { [weak self] _, _, completion in
            self?.appAccessTokenStore.removeAuthToken(forUserId: nil) { error in
                let removeUserId = {
                    self?.serverAppAuthSession = nil
                    self?.tableView.deleteRows(at: [indexPath], with: .automatic)
                    completion(true)
                }
                
                if let error = error {
                    if case KeychainAuthTokenStoreError.unhandledError(status: errSecItemNotFound) = error {
                        removeUserId()
                    } else {
                        completion(false)
                    }
                } else {
                    removeUserId()
                }
            }
        })])
    }
    #endif
}

extension SessionListViewController: ClientAuthViewControllerDelegate {
    func clientAuthViewController(_ viewController: ClientAuthViewController, didReceive authCode: AuthCode) {
        pendingAuthCode = authCode
        pendingAuthCodeAndExpectedNonce = nil
    }
    
    func clientAuthViewController(_ viewController: ClientAuthViewController,
                                  didReceive authCode: AuthCode,
                                  expectedNonce: String?) {
        pendingAuthCode = nil
        pendingAuthCodeAndExpectedNonce = (authCode, expectedNonce)
    }
}

extension SessionListViewController: UserServerAuthViewControllerDelegate {
    func userServerAuthViewControllerCanConsumeAuthCode(_ viewController: UserServerAuthViewController) -> Bool {
        return pendingAuthCode != nil || pendingAuthCodeAndExpectedNonce != nil
    }
    
    func userServerAuthViewControllerConsumeAuthCode(_ viewController: UserServerAuthViewController) -> AuthCode? {
        defer { pendingAuthCode = nil }
        return pendingAuthCode
    }
    
    func userServerAuthViewControllerConsumeAuthCodeAndExpectedNonce(_ viewController: UserServerAuthViewController) -> (AuthCode, String?)? {
        // swiftlint:disable:previous line_length
        defer { pendingAuthCodeAndExpectedNonce = nil }
        return pendingAuthCodeAndExpectedNonce
    }
}
