//
//  TwitchClipView.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/30/20.
//

import WebKit

/// A view that can display a clip from Twitch.
open class TwitchClipView: TwitchWebView {
    
    /// A hint to the view about what the developer thinks will lead to the best user experience.
    public enum PreloadHint: String {
        
        /// Only video metadata (e.g., length) is fetched. This is the recommended value.
        case metadata
        
        /// The whole video file could be downloaded, even if the user is not expected to use it.
        case auto
        
        /// The video should not be preloaded
        case none
    }
    
    /// A structure that contains all of the settings to configure a Twitch clip view.
    public struct Settings {
        
        /// A globally unique string called a slug, by which clips are referenced.
        public var clipSlug: String?
        
        /// If true, the player can go full screen.
        public var allowFullscreen: Bool
        
        /// If true, the video starts playing automatically, without the user clicking play.
        /// The exception is mobile devices, on which video cannot be played without user interaction.
        public var autoplay: Bool
        
        /// Specifies whether the initial state of the video is muted.
        public var startsMuted: Bool
        
        /// Indicates when the browser should provide a scroll bar (or other scrolling device) for the frame.
        /// Recommended: false.
        public var isScrollingEnabled: Bool
        
        /// Whether the internal webview uses the Twitch dark mode or light mode.
        public var theme: Theme
        
        /// The size of the internal webview.
        public var size: (width: Dimension, height: Dimension)
        
        /// A hint to the view about what the developer thinks will lead to the best user experience.
        public var preloadHint: PreloadHint
        
        /// Width of the border.
        public var frameBorder: Int
        
        /// Domain(s) that will be embedding Twitch. You must have one parent for each domain your site uses.
        public var parents: [String]
        
        /// The base URL from which to load the internal webview.
        ///
        /// If not set, the webview uses "https://twitch.tv" as its base URL.
        public var baseURL: URL?
        
        /// The internal webview's configuration.
        public var webViewConfiguration: WKWebViewConfiguration
        
        /// A closure that is called when the internal webview is created. The created webview is passed to the closure
        /// as the only parameter.
        ///
        /// Use this to configure the webview itself.
        public var didCreateWebViewHandler: ((WKWebView) -> Void)?
        
        /// Creates a new settings instance.
        ///
        /// - Parameters:
        ///   - clipSlug: A globally unique string called a slug, by which clips are referenced. Default: nil.
        ///   - allowFullscreen: If true, the player can go full screen. Default: false.
        ///   - autoplay: If true, the video starts playing automatically, without the user clicking play.
        ///               The exception is mobile devices, on which video cannot be played without user interaction.
        ///               Default: true.
        ///   - startsMuted: Specifies whether the initial state of the video is muted. Default: false.
        ///   - isScrollingEnabled: Indicates when the browser should provide a scroll bar (or other scrolling device)
        ///                         for the frame. Recommended: false. Default: false.
        ///   - theme: Whether the clip should use dark mode or light mode. Default: `.dark`.
        ///   - size: The size of the internal webview. Default: `(.percentage(100), .percentage(100))`.
        ///   - preloadHint: A hint to the view about what the developer thinks will lead to the best user experience.
        ///                  Default: `.metadata`.
        ///   - frameBorder: Width of the border. Default: 0.
        ///   - parents: Domain(s) that will be embedding Twitch. You must have one parent for each domain your site
        ///              uses. Default: an empty array.
        ///   - baseURL: The base URL from which to load the internal webview. If nil, the webview uses
        ///              "https://twitch.tv" as its base URL.
        ///   - webViewConfiguration: The internal webview's configuration.
        ///                           Default: The default configuration with `allowsInlineMediaPlayback` set to true.
        ///   - didCreateWebViewHandler: A closure that is called when the internal webview is created.
        ///                              The created webview is passed to the closure as the only parameter.
        ///                              Use this to configure the webview itself. Default: nil.
        public init(clipSlug: String? = nil,
                    allowFullscreen: Bool = false,
                    autoplay: Bool = true,
                    startsMuted: Bool = false,
                    isScrollingEnabled: Bool = false,
                    theme: Theme = .dark,
                    size: (width: Dimension, height: Dimension) = (.percentage(100), .percentage(100)),
                    preloadHint: PreloadHint = .metadata,
                    frameBorder: Int = 0,
                    parents: [String] = [],
                    baseURL: URL? = nil,
                    webViewConfiguration: WKWebViewConfiguration = {
                        let config = WKWebViewConfiguration()
                        #if !os(macOS)
                        config.allowsInlineMediaPlayback = true
                        #endif
                        return config
                    }(),
                    didCreateWebViewHandler: ((WKWebView) -> Void)? = nil) {
            self.clipSlug = clipSlug
            self.allowFullscreen = allowFullscreen
            self.autoplay = autoplay
            self.startsMuted = startsMuted
            self.isScrollingEnabled = isScrollingEnabled
            self.theme = theme
            self.size = size
            self.preloadHint = preloadHint
            self.frameBorder = frameBorder
            self.parents = parents
            self.baseURL = baseURL
            self.webViewConfiguration = webViewConfiguration
            self.didCreateWebViewHandler = didCreateWebViewHandler
        }
    }
    
    /// The clip view's settings. Setting this will recreate the internal webview and apply the new settings.
    open var settings = Settings() {
        didSet { recreateWebView(baseURL: settings.baseURL) }
    }
    
    /// Creates a new clip view with the given initial settings.
    ///
    /// - Parameters:
    ///   - frame: The frame of the clip view.
    ///   - settings: The initial settings to apply to the clip view.
    ///   - uiDelegate: The object that will receive web view UI events from the clip view. Default: nil.
    public convenience init(frame: CGRect, settings: Settings, uiDelegate: TwitchWebViewUIDelegate? = nil) {
        self.init(frame: frame)
        self.uiDelegate = uiDelegate
        self.settings = settings
        recreateWebView(baseURL: settings.baseURL)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override internal func didRecreate(webView: WKWebView) {
        super.didRecreate(webView: webView)
        settings.didCreateWebViewHandler?(webView)
    }
    
    override internal var webViewConfiguration: WKWebViewConfiguration {
        settings.webViewConfiguration
    }
    
    override var htmlStringForWebView: String? {
        guard let slug = settings.clipSlug else { return nil }
        
        let parentString: String
        if settings.parents.isEmpty {
            parentString = "&parent=twitch.tv"
        } else {
            parentString = "&" + settings.parents
                .map { "parent=\($0)" }
                .joined(separator: "&")
        }
        
        let autoplayString = "&autoplay=\(settings.autoplay)"
        let mutedString = "&muted=\(settings.startsMuted)"
        
        let darkModeString: String
        switch settings.theme {
        case .dark: darkModeString = "&darkpopout"
        case .light: darkModeString = ""
        }
        
        let htmlString = """
        <html>
            <head>
                <meta name="viewport" content="width=device-width, shrink-to-fit=YES, initial-scale=1.0, \
                    maximum-scale=1.0, user-scalable=no">
            </head>
            <body style="margin:0;">
                <iframe style="margin:0;"
                    src="https://clips.twitch.tv/embed?clip=\(slug)\(autoplayString)\(mutedString)\(parentString)\(darkModeString)"
                    width="\(settings.size.width.stringValue(includeQuotesForPercentages: false))"
                    height="\(settings.size.height.stringValue(includeQuotesForPercentages: false))"
                    preload="\(settings.preloadHint.rawValue)"
                    frameborder="\(settings.frameBorder)"
                    scrolling="\(settings.isScrollingEnabled ? "yes" : "no")"
                    allowfullscreen="\(settings.allowFullscreen)">
                </iframe>
            </body>
        </html>
        """
        
        return htmlString
    }
}
