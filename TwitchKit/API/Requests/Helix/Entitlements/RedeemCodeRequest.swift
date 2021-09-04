//
//  RedeemCodeRequest.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/4/20.
//

/// Redeems one or more provided codes to the authenticated Twitch user.
///
/// This API requires that the caller is an authenticated Twitch user. The API is throttled to one request per second
/// per authenticated user. Codes are redeemable alphanumeric strings tied only to the bits product. This third-party
/// API allows other parties to redeem codes on behalf of users. Third-party app and extension developers can use the
/// API to provide rewards of bits from within their games. Twitch provide sets of codes to the third party as part of
/// a contract agreement. The third-party program then calls this API to credit the Twitch user by submitting any
/// specific codes. This means that a bits reward can be applied without the user having to follow any manual steps.
///
/// All codes are single-use. Once a code has been redeemed, via either this API or the site page, the code is no
/// longer valid for any further use.
public struct RedeemCodeRequest: APIRequest {
    public typealias UserToken = IncompatibleAccessToken
    public typealias ResponseBody = GetCodeStatusRequest.ResponseBody
    
    public enum QueryParamKey: String {
        case code
        case userId = "user_id"
    }
    
    public let method: HTTPMethod = .post
    public let path = "/entitlements/codes"
    public let queryParams: [(key: QueryParamKey, value: String?)]
    
    /// Creates a new Redeem Code request.
    ///
    /// - Parameters:
    ///   - userId: Represents a numeric Twitch user ID. The user account which is going to receive the entitlement
    ///             associated with the code.
    ///   - codes: The codes to redeem to the authenticated user's account. Codes are fifteen character (plus optional
    ///            hyphen separators) alphanumeric strings, e.g. ABCDE-12345-FGHIJ. 1-20 codes are allowed.
    public init(userId: String, codes: [String]) {
        queryParams = [
            (.userId, userId)
        ] + codes.map {
            (.code, $0)
        }
    }
}
