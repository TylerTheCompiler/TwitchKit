//
//  KeychainAuthTokenStore.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/5/20.
//

/// An error that occurs when fetching or storing tokens to/from the keychain.
public enum KeychainAuthTokenStoreError: Error {
    
    /// The keychain did not contain an auth token.
    case missingToken
    
    /// The current app somehow does not have a bundle ID or the bundle ID is empty.
    case missingBundleId
    
    /// The keychain contained unexpected data for the auth token.
    case unexpectedItemData
    
    /// The keychain contained data for the auth token, but it was empty.
    case emptyItemData
    
    /// An unhandled keychain error occurred, where `status` indicates the keychain error.
    case unhandledError(status: OSStatus)
}

extension Notification.Name {
    
    /// A notification that is posted when a `KeychainTokenStore` successfully stores/removes an auth token
    /// to/from the keychain.
    public static let keychainAuthTokenStoreDidStoreAuthToken =
        Self("TwitchKit.KeychainAuthTokenStoreDidStoreAuthToken")
}

/// The `userInfo` key for the token that was stored (or removed) in a
/// `keychainAuthTokenStoreDidStoreAuthToken` notification.
public let keychainAuthTokenStoreAuthTokenUserInfoKey = "token"

/// The `userInfo` key for the user ID used to store (or remove) a token in a
/// `keychainAuthTokenStoreDidStoreAuthToken` notification.
public let keychainAuthTokenStoreUserIdUserInfoKey = "userId"

/// Stores and fetches an auth token to/from the default keychain.
open class KeychainAuthTokenStore<Token>: AuthTokenStoring where Token: AuthToken {
    
    /// Whether the auth token should be synchronized over iCloud or not.
    public let synchronizesOveriCloud: Bool
    
    /// Retrieves a auth token from the keychain for an optional user ID.
    ///
    /// - Parameters:
    ///   - userId: The user ID of the auth token to fetch, or nil if the auth token type does not apply to a user.
    ///   - completion: A closure to be called when fetching of the auth token is complete.
    ///   - result: The result of the fetch containing either the auth token or an error.
    open func fetchAuthToken(forUserId userId: String? = nil,
                             completion: @escaping (_ result: Result<Token, Error>) -> Void) {
        do {
            var query = [String: AnyObject]()
            query[kSecClass as String] = kSecClassGenericPassword
            query[kSecAttrAccount as String] = userId as CFString?
            query[kSecAttrService as String] = try serviceString() as CFString?
            query[kSecAttrSynchronizable as String] = synchronizesOveriCloud as CFBoolean?
            query[kSecUseDataProtectionKeychain as String] = kCFBooleanTrue
            query[kSecMatchLimit as String] = kSecMatchLimitOne
            query[kSecReturnData as String] = kCFBooleanTrue
            
            var result: AnyObject?
            let status = keychainInteracting.getItem(query as CFDictionary, &result)
            
            completion(.init {
                guard status != errSecItemNotFound else { throw KeychainAuthTokenStoreError.missingToken }
                guard status == noErr else { throw KeychainAuthTokenStoreError.unhandledError(status: status) }
                
                guard let data = result as? Data else {
                    throw KeychainAuthTokenStoreError.unexpectedItemData
                }
                
                let tokens = try JSONDecoder.snakeCaseToCamelCase.decode([Token].self, from: data)
                guard let token = tokens.first else {
                    throw KeychainAuthTokenStoreError.emptyItemData
                }
                
                return token
            })
        } catch {
            completion(.failure(error))
        }
    }
    
    /// Stores or removes an auth token to/from the keychain for an optional user ID.
    ///
    /// If an auth token is stored or removed successfully, a notification is posted with the name
    /// `Notification.Name.keychainAuthTokenStoreDidStoreToken` to the default `NotificationCenter`. The `object` of
    /// the notification is the `KeychainAuthTokenStore`. The `userInfo` dictionary of the notification contains the
    /// new auth token (or nil) with the key `keychainTokenStoreTokenUserInfoKey` and the user ID (if any) that was
    /// used to store it with the key `keychainAuthTokenStoreUserIdUserInfoKey`.
    ///
    /// - Parameters:
    ///   - token: The token to store, or nil to remove the token from storage.
    ///   - userId: The user ID of the token to store or remove, or nil if the token type does not apply to a user.
    ///   - completion: A closure to be called when storing of the token is complete. The `error` parameter contains
    ///                 any error that prevented the storage of the token.
    open func store(authToken: Token?,
                    forUserId userId: String? = nil,
                    completion: ((_ error: Error?) -> Void)?) {
        do {
            var query = [String: AnyObject]()
            query[kSecClass as String] = kSecClassGenericPassword
            query[kSecAttrAccount as String] = userId as CFString?
            query[kSecAttrService as String] = try serviceString() as CFString?
            query[kSecAttrSynchronizable as String] = kSecAttrSynchronizableAny
            query[kSecUseDataProtectionKeychain as String] = kCFBooleanTrue
            
            if let authToken = authToken {
                let readStatus = keychainInteracting.getItem(query as CFDictionary, nil)
                
                if readStatus == noErr {
                    // Update
                    var attributesToUpdate = [String: AnyObject]()
                    let data = try JSONEncoder.camelCaseToSnakeCase.encode([authToken])
                    attributesToUpdate[kSecValueData as String] = data as CFData?
                    attributesToUpdate[kSecAttrLabel as String] = keychainItemLabel(withUserId: userId) as CFString?
                    attributesToUpdate[kSecAttrSynchronizable as String] = synchronizesOveriCloud as CFBoolean?
                    
                    let updateStatus = keychainInteracting.updateItem(query as CFDictionary,
                                                                      attributesToUpdate as CFDictionary)
                    
                    guard updateStatus == noErr else {
                        throw KeychainAuthTokenStoreError.unhandledError(status: updateStatus)
                    }
                } else if readStatus == errSecItemNotFound {
                    // Add
                    let data = try JSONEncoder.camelCaseToSnakeCase.encode([authToken])
                    query[kSecValueData as String] = data as CFData?
                    query[kSecAttrLabel as String] = keychainItemLabel(withUserId: userId) as CFString?
                    query[kSecAttrSynchronizable as String] = synchronizesOveriCloud as CFBoolean?
                    
                    let addStatus = keychainInteracting.addItem(query as CFDictionary, nil)
                    
                    guard addStatus == noErr else {
                        throw KeychainAuthTokenStoreError.unhandledError(status: addStatus)
                    }
                } else {
                    throw KeychainAuthTokenStoreError.unhandledError(status: readStatus)
                }
            } else {
                // Delete
                let deleteStatus = keychainInteracting.deleteItem(query as CFDictionary)
                
                guard deleteStatus == noErr else {
                    throw KeychainAuthTokenStoreError.unhandledError(status: deleteStatus)
                }
            }
            
            var userInfo = [AnyHashable: Any]()
            userInfo[keychainAuthTokenStoreAuthTokenUserInfoKey] = authToken
            userInfo[keychainAuthTokenStoreUserIdUserInfoKey] = userId
            NotificationCenter.default.post(name: .keychainAuthTokenStoreDidStoreAuthToken,
                                            object: self,
                                            userInfo: userInfo)
            completion?(nil)
        } catch {
            completion?(error)
        }
    }
    
    // MARK: - Internal
    
    internal let keyKind: String
    internal let identifier: String
    
    internal func serviceString() throws -> String {
        guard let bundleId = getBundleIdHandler(),
              !bundleId.isEmpty else {
            throw KeychainAuthTokenStoreError.missingBundleId
        }
        
        return [bundleId, "twitch-kit", identifier, keyKind]
            .filter { !$0.isEmpty }
            .joined(separator: ".")
    }
    
    internal init(synchronizesOveriCloud: Bool = false, keyKind: String, identifier: String) {
        self.synchronizesOveriCloud = synchronizesOveriCloud
        self.keyKind = keyKind
        self.identifier = identifier
    }
    
    internal func keychainItemLabel(withUserId userId: String?) -> String? {
        nil
    }
    
    // For unit testing
    internal var keychainInteracting: KeychainInteracting = KeychainWrapper()
    internal var getBundleIdHandler = { Bundle.main.bundleIdentifier }
}

// For unit testing

internal protocol KeychainInteracting: AnyObject {
    var getItem: (_ query: CFDictionary, _ result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus { get }
    var updateItem: (_ query: CFDictionary, _ attributesToUpdate: CFDictionary) -> OSStatus { get }
    var addItem: (_ query: CFDictionary, _ result: UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus { get }
    var deleteItem: (_ query: CFDictionary) -> OSStatus { get }
}

internal class KeychainWrapper: KeychainInteracting {
    var getItem: (CFDictionary, UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus = SecItemCopyMatching
    var updateItem: (CFDictionary, CFDictionary) -> OSStatus = SecItemUpdate
    var addItem: (CFDictionary, UnsafeMutablePointer<CFTypeRef?>?) -> OSStatus = SecItemAdd
    var deleteItem: (CFDictionary) -> OSStatus = SecItemDelete
}
