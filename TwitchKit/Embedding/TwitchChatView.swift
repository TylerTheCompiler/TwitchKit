//
//  TwitchChatView.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/30/20.
//

import WebKit

/// A view that can display a Twitch chatroom.
open class TwitchChatView: TwitchWebView {
    
    /// A structure that contains all of the settings to configure a Twitch chat view.
    public struct Settings {
        
        /// Name of the channel of the chatroom to load (live content only).
        public var channel: String?
        
        /// Whether the internal webview uses the Twitch dark mode or light mode.
        public var theme: Theme
        
        /// Indicates when the browser should provide a scroll bar (or other scrolling device) for the frame.
        /// Recommended: false.
        public var isScrollingEnabled: Bool
        
        /// The size of the internal webview.
        public var size: (width: Dimension, height: Dimension)
        
        /// The width of the border.
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
        ///   - channel: Name of the channel of the chatroom to load (live content only). Default: nil.
        ///   - theme: Whether the internal webview uses the Twitch dark mode or light mode. Default: `.dark`.
        ///   - isScrollingEnabled: Indicates when the browser should provide a scroll bar (or other scrolling device)
        ///                         for the frame. Recommended: false. Default: false.
        ///   - size: The size of the internal webview. Default: `(.percentage(100), .percentage(100))`.
        ///   - frameBorder: The width of the border. Default: 0.
        ///   - parents: Domain(s) that will be embedding Twitch. You must have one parent for each domain your site
        ///              uses. Default: an empty array.
        ///   - baseURL: The base URL from which to load the internal webview. If nil, the webview uses
        ///              "https://twitch.tv" as its base URL.
        ///   - webViewConfiguration: The internal webview's configuration. Default: the default configuration.
        ///   - didCreateWebViewHandler: A closure that is called when the internal webview is created.
        ///                              The created webview is passed to the closure as the only parameter.
        ///                              Use this to configure the webview itself. Default: nil.
        public init(channel: String? = nil,
                    theme: Theme = .dark,
                    isScrollingEnabled: Bool = false,
                    size: (width: Dimension, height: Dimension) = (.percentage(100), .percentage(100)),
                    frameBorder: Int = 0,
                    parents: [String] = [],
                    baseURL: URL? = nil,
                    webViewConfiguration: WKWebViewConfiguration = .init(),
                    didCreateWebViewHandler: ((WKWebView) -> Void)? = nil) {
            self.channel = channel
            self.theme = theme
            self.isScrollingEnabled = isScrollingEnabled
            self.frameBorder = frameBorder
            self.parents = parents
            self.baseURL = baseURL
            self.webViewConfiguration = webViewConfiguration
            self.didCreateWebViewHandler = didCreateWebViewHandler
            self.size = size
        }
    }
    
    /// The chat view's settings. Setting this will recreate the internal webview and apply the new settings.
    open var settings = Settings() {
        didSet { recreateWebView(baseURL: settings.baseURL) }
    }
    
    /// Creates a new chat view with the given initial settings.
    ///
    /// - Parameters:
    ///   - frame: The frame of the chat view.
    ///   - settings: The initial settings to apply to the chat view.
    ///   - uiDelegate: The object that will receive web view UI events from the chat view. Default: nil.
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
        guard let channel = settings.channel else { return nil }
        
        let parentString: String
        if settings.parents.isEmpty {
            parentString = "parent=twitch.tv"
        } else {
            parentString = settings.parents
                .map { "parent=\($0)" }
                .joined(separator: "&")
        }
        
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
                    frameborder="\(settings.frameBorder)"
                    scrolling="\(settings.isScrollingEnabled ? "yes" : "no")"
                    src="https://www.twitch.tv/embed/\(channel)/chat?\(parentString)\(darkModeString)"
                    width="\(settings.size.width.stringValue(includeQuotesForPercentages: false))"
                    height="\(settings.size.height.stringValue(includeQuotesForPercentages: false))">
                </iframe>
            </body>
        </html>
        """
        
        return htmlString
    }
}
