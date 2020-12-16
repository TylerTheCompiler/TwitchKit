//
//  TesterAppData.swift
//  TwitchKitTester
//
//  Created by Tyler Prevost on 11/28/20.
//

import TwitchKit

// swiftlint:disable force_unwrapping

struct TesterAppData {
    static let shared = Self()
    
    // Change these values to match the values of your Twitch app.
    let clientId = "YOUR_CLIENT_ID"
    let clientSecret = "YOUR_APP_SECRET"
    let redirectURL = URL(string: "YOUR_REDIRECT_URL")!
    
    /// Set whatever scopes you want to request when authorizing.
    let scopes = Set<Scope>.all
    
    /// Set whatever claims you want to request if using OIDC to authenticate/authorize.
    let claims = Set<Claim>.all
    
    /// If you're going to be using EventSub, this is the callback URL that Twitch will attempt to call.
    /// You can use [ngrok](https://ngrok.com/download) to test this out for free.
    let eventSubCallbackURL = URL(string: "YOUR_EVENTSUB_CALLBACK_URL")!
    
    /// Set this to `false` to see your access tokens in the example app.
    ///
    /// This is set to `true` by default in case you are sharing your screen for whatever reason.
    let hideAccessTokens = true
}
