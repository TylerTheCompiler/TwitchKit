//
//  TwitchPlayerView.swift
//  TwitchKit
//
//  Created by Tyler Prevost on 11/30/20.
//

import WebKit

/// A view that can display a Twitch video player and optionally Twitch chat along with it.
open class TwitchPlayerView: TwitchWebView {
    
    /// The type of content to display in a Twitch player view.
    public enum Content {
        
        /// The content to display is a live stream with the given channel name.
        case channel(name: String)
        
        /// The content to display is a VOD with the given video ID.
        case video(id: String)
        
        /// The content to display is VOD collection. If you use this, you may also specify an initial video in the
        /// VOD collection, otherwise playback will begin with the first video in the collection. All VODs are
        /// auto-played. Chat replay is not supported.
        case collection(id: String, initialVideoId: String? = nil)
    }
    
    /// Describes what elements a Twitch player view should display.
    public enum Layout: String {
        
        /// Shows both video and chat side-by-side. At narrow sizes, chat renders under the video player.
        /// Only supported for live content.
        case playerWithChat = "video-with-chat"
        
        /// Shows only the video player (omits chat).
        case playerOnly = "video"
    }
    
    /// A structure that contains all of the settings to configure a Twitch player view.
    public struct Settings {
        
        /// The type of content to display in a Twitch player view.
        public var content: Content?
        
        /// The size of the internal webview.
        public var size: (width: Dimension, height: Dimension)
        
        /// The layout of the player view.
        public var layout: Layout
        
        /// Whether the internal webview uses the Twitch dark mode or light mode.
        public var theme: Theme
        
        /// If true, the player can go full screen.
        public var allowFullscreen: Bool
        
        /// If true, the video starts playing automatically, without the user clicking play. The exception is mobile
        /// devices, on which video cannot be played without user interaction.
        public var autoplay: Bool
        
        /// Specifies whether the initial state of the video is muted.
        public var startsMuted: Bool
        
        /// Time in the video where playback starts, in seconds.
        public var startTime: TimeInterval
        
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
        ///   - content: The content to display in the player view. Default: nil.
        ///   - size: The size of the internal webview. Default: `(.percentage(100), .percentage(100))`.
        ///   - layout: The layout of the player view. Default: `.playerOnly`.
        ///   - theme: Whether the internal webview uses the Twitch dark mode or light mode. Default: `.dark`.
        ///   - allowFullscreen: If true, the player can go full screen. Default: true.
        ///   - autoplay: If true, the video starts playing automatically, without the user clicking play.
        ///               The exception is mobile devices, on which video cannot be played without user interaction.
        ///               Default: true.
        ///   - startsMuted: Specifies whether the initial state of the video is muted. Default: false.
        ///   - startTime: Time in the video where playback starts, in seconds. Default: 0.0.
        ///   - parents: Domain(s) that will be embedding Twitch. You must have one parent for each domain your site
        ///              uses. Default: an empty array.
        ///   - baseURL: The base URL from which to load the internal webview. If nil, the webview uses
        ///              "https://twitch.tv" as its base URL.
        ///   - webViewConfiguration: The internal webview's configuration.
        ///                           Default: The default configuration with `allowsInlineMediaPlayback` set to true.
        ///   - didCreateWebViewHandler: A closure that is called when the internal webview is created.
        ///                              The created webview is passed to the closure as the only parameter.
        ///                              Use this to configure the webview itself. Default: nil.
        public init(content: Content? = nil,
                    size: (width: Dimension, height: Dimension) = (.percentage(100), .percentage(100)),
                    layout: Layout = .playerOnly,
                    theme: Theme = .dark,
                    allowFullscreen: Bool = true,
                    autoplay: Bool = true,
                    startsMuted: Bool = false,
                    startTime: TimeInterval = 0.0,
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
            self.content = content
            self.size = size
            self.layout = layout
            self.theme = theme
            self.allowFullscreen = allowFullscreen
            self.autoplay = autoplay
            self.startsMuted = startsMuted
            self.startTime = startTime
            self.parents = parents
            self.baseURL = baseURL
            self.webViewConfiguration = webViewConfiguration
            self.didCreateWebViewHandler = didCreateWebViewHandler
        }
    }
    
    /// The player view's settings. Setting this will recreate the internal webview and apply the new settings.
    open var settings = Settings() {
        didSet { recreateWebView(baseURL: settings.baseURL) }
    }
    
    /// Creates a new player view with the given initial settings.
    ///
    /// - Parameters:
    ///   - frame: The frame of the player view.
    ///   - settings: The initial settings to apply to the player view.
    ///   - uiDelegate: The object that will receive web view UI events from the player view. Default: nil.
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
    
    override internal var htmlStringForWebView: String? {
        var embedKeyValuePairs = [(key: String, value: String)]()
        
        switch settings.content {
        case .channel(let name):
            embedKeyValuePairs.append(("channel", "\"\(name)\""))
            
        case .video(let id):
            embedKeyValuePairs.append(("video", "\"\(id)\""))
            
        case .collection(let id, let initialVideoId):
            embedKeyValuePairs.append(("collection", "\"\(id)\""))
            if let initialVideoId = initialVideoId {
                embedKeyValuePairs.append(("video", "\"\(initialVideoId)\""))
            }
            
        default:
            return nil
        }
        
        embedKeyValuePairs.append(("width", settings.size.width.stringValue(includeQuotesForPercentages: true)))
        embedKeyValuePairs.append(("height", settings.size.height.stringValue(includeQuotesForPercentages: true)))
        embedKeyValuePairs.append(("allowfullscreen", "\(settings.allowFullscreen)"))
        embedKeyValuePairs.append(("autoplay", "\(settings.autoplay)"))
        embedKeyValuePairs.append(("layout", "\"\(settings.layout.rawValue)\""))
        embedKeyValuePairs.append(("muted", "\(settings.startsMuted)"))
        embedKeyValuePairs.append(("theme", "\"\(settings.theme.rawValue)\""))
        
        let startTimeInSeconds = Int(settings.startTime)
        let hours = startTimeInSeconds / 3600
        let minutes = (startTimeInSeconds % 3600) / 60
        let seconds = (startTimeInSeconds % 3600) % 60
        embedKeyValuePairs.append(("time", "\"\(hours)h\(minutes)m\(seconds)\""))
        
        let parents: [String]
        if settings.parents.isEmpty {
            parents = ["\"twitch.tv\""]
        } else {
            parents = settings.parents.map { "\"\($0)\"" }
        }
        
        embedKeyValuePairs.append(("parent", "[\(parents.joined(separator: ", "))]"))
        
        let embedKeyValueStrings = embedKeyValuePairs.map { $0.key + ": " + $0.value }
        let htmlString = """
        <html>
            <head>
                <meta name="viewport" content="width=device-width, shrink-to-fit=YES, initial-scale=1.0, \
                    maximum-scale=1.0, user-scalable=no">
            </head>
            <body style="margin:0;">
                <div style="margin:0;" id="twitch-embed"></div>
                <script src="https://embed.twitch.tv/embed/v1.js"></script>
                <script type="text/javascript">
                    new Twitch.Embed("twitch-embed", {
                        \(embedKeyValueStrings.joined(separator: ", "))
                    });
                </script>
            </body>
        </html>
        """
        
        return htmlString
    }
}
