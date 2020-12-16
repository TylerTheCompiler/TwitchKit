//
//  CodeStatus.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// A code and its status.
public struct CodeStatus: Decodable {
    
    /// The status of a code.
    public enum Status: String, Decodable {
        
        /// Request successfully redeemed this code to the authenticated user's account.
        /// This status will only ever be encountered when calling the POST API to redeem a key.
        case successfullyRedeemed = "SUCCESSFULLY_REDEEMED"
        
        /// Code has already been claimed by a Twitch user.
        case alreadyClaimed = "ALREADY_CLAIMED"
        
        /// Code has expired and can no longer be claimed.
        case expired = "EXPIRED"
        
        /// User is not eligible to redeem this code.
        case userNotEligible = "USER_NOT_ELIGIBLE"
        
        /// Code is not valid and/or does not exist in Twitch's database.
        case notFound = "NOT_FOUND"
        
        /// Code is not currently active.
        case inactive = "INACTIVE"
        
        /// Code has not been claimed. This status will only ever be encountered when calling the
        /// GET API to get a key's status.
        case unused = "UNUSED"
        
        /// Code was not properly formatted.
        case incorrectFormat = "INCORRECT_FORMAT"
        
        /// Indicates some internal and/or unknown failure handling this code.
        case internalError = "INTERNAL_ERROR"
    }
    
    /// The code for which `status` applies.
    public let code: String
    
    /// Indicates the current status of each key when checking key status. Indicates the success or error
    /// state of each key when redeeming.
    public let status: Status
}
