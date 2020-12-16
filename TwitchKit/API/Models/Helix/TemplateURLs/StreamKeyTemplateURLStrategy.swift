//
//  StreamKeyTemplateURLStrategy.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/11/20.
//

/// A template URL strategy where the URL contains the string `{stream_key}` which is to be replaced
/// by a user's stream key to create an `rtmp://` URL pointing to an ingest server that can be streamed to.
public enum StreamKeyTemplateURLStrategy: TemplateURLStrategy {
    public static let templateStrings = ["stream_key"]
}

extension TemplateURL where Strategy == StreamKeyTemplateURLStrategy {
    
    /// Returns a URL created from the template string with the `{stream_key}` token replaced with the
    /// given stream key string value.
    ///
    /// - Parameter streamKey: The raw stream key value to replace the token with.
    /// - Returns: An `rtmp://` URL pointing to an ingest server that can be streamed to.
    public func with(streamKey: String) -> URL? {
        Strategy.urlByReplacingTemplateStrings(in: template, with: [streamKey])
    }
    
    /// Returns a URL created from the template string with the `{stream_key}` token replaced with the
    /// given `StreamKey`'s `streamKey` string value.
    ///
    /// - Parameter streamKey: The stream key to replace the token with.
    /// - Returns: An `rtmp://` URL pointing to an ingest server that can be streamed to.
    public func with(streamKey: StreamKey) -> URL? {
        Strategy.urlByReplacingTemplateStrings(in: template, with: [streamKey.streamKey])
    }
}
