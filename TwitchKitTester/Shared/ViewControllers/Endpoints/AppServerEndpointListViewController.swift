//
//  AppServerEndpointListViewController.swift
//  TwitchKitTester
//
//  Created by Tyler Prevost on 12/1/20.
//

import TwitchKit
import UIKit

class AppServerEndpointListViewController: PlatformIndependentTableViewController {
    var authSession: ServerAppAuthSession? {
        didSet {
            guard let authSession = authSession else {
                apiSession = nil
                return
            }
            
            let apiSession = ServerAppAPISession(authSession: authSession)
            self.apiSession = apiSession
            
            guard #available(iOS 15, *) else { return }
            
            Task {
                do {
                    let req = GetChanneliCalendarRequest(broadcasterId: "29999098")
                    let data = try await apiSession.perform(req).body
                    print(String(decoding: data, as: UTF8.self))
                } catch {
                    print("Error:", error)
                }
            }
        }
    }
    
    private var apiSession: ServerAppAPISession?
}

import Combine

class ImageCell: UICollectionViewCell {
    let imageView = UIImageView()
    let titleLabel = UILabel()
    
    var emoteViewModel: EmoteCellViewModel? {
        didSet {
            cancellables.removeAll()
            emoteViewModel?.$image
                .assign(to: \.image, on: imageView)
                .store(in: &cancellables)
            
            emoteViewModel?.$title
                .map { Optional($0) }
                .assign(to: \.text, on: titleLabel)
                .store(in: &cancellables)
        }
    }
    
    var badgeViewModel: BadgeCellViewModel? {
        didSet {
            cancellables.removeAll()
            badgeViewModel?.$image
                .assign(to: \.image, on: imageView)
                .store(in: &cancellables)
            
            badgeViewModel?.$title
                .map { Optional($0) }
                .assign(to: \.text, on: titleLabel)
                .store(in: &cancellables)
        }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
        
        imageView.contentMode = .scaleAspectFit
        
        titleLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        
        titleLabel.textColor = .label
        titleLabel.font = .systemFont(ofSize: 20)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5
        titleLabel.textAlignment = .center
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}

class EmotesViewController: UIViewController {
    var emoteCellViewModels = [EmoteCellViewModel]() {
        didSet {
            if isViewLoaded {
                collectionView.reloadData()
            }
        }
    }
    
    var badgeCellViewModels = [BadgeCellViewModel]()
    
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    
    private let layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = .init(width: 100, height: 100)
        layout.sectionInset = .init(top: 20, left: 20, bottom: 20, right: 20)
        return layout
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        collectionView.register(ImageCell.self, forCellWithReuseIdentifier: "ImageCell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.prefetchDataSource = self
    }
}

extension EmotesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            emoteCellViewModels[indexPath.item].handleCellWillAppear(
                userInterfaceStyle: traitCollection.userInterfaceStyle,
                screenScale: view.window?.screen.scale ?? 1.0
            )
        } else {
            badgeCellViewModels[indexPath.item].handleCellWillAppear()
        }
    }
}

extension EmotesViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0 {
            return emoteCellViewModels.count
        } else {
            return badgeCellViewModels.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable:next force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ImageCell", for: indexPath) as! ImageCell
        if indexPath.section == 0 {
            cell.emoteViewModel = emoteCellViewModels[indexPath.item]
        } else {
            cell.badgeViewModel = badgeCellViewModels[indexPath.item]
        }
        
        return cell
    }
}

extension EmotesViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let userInterfaceStyle = traitCollection.userInterfaceStyle
        let screenScale = view.window?.screen.scale ?? 1.0
        
        indexPaths.forEach {
            if $0.section == 0 {
                emoteCellViewModels[$0.item].handleCellWillAppear(
                    userInterfaceStyle: userInterfaceStyle,
                    screenScale: screenScale
                )
            } else {
                badgeCellViewModels[$0.item].handleCellWillAppear()
            }
        }
    }
}

class EmoteCellViewModel {
    @Published private(set) var image: UIImage?
    @Published private(set) var title = ""
    @Published private(set) var isLoading = false
    
    let emote: Emote
    let templateURL: TemplateURL<EmoteImageTemplateURLStrategy>
    
    init(emote: Emote, templateURL: TemplateURL<EmoteImageTemplateURLStrategy>) {
        self.emote = emote
        self.templateURL = templateURL
        
        title = emote.name
    }
    
    func handleCellWillAppear(userInterfaceStyle: UIUserInterfaceStyle, screenScale: CGFloat) {
        let imageURL = self.imageURL(
            format: .default,
            themeMode: .init(userInterfaceStyle: userInterfaceStyle),
            scale: .init(floatValue: screenScale)
        )
        
        guard !isLoading, image == nil, let imageURL = imageURL else {
            return
        }
        
        isLoading = true
        
        URLSession.shared.dataTask(with: imageURL) { data, _, _ in
            if let data = data,
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.image = image
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }.resume()
    }
    
    private func imageURL(format: Emote.Format, themeMode: Emote.ThemeMode, scale: Emote.Scale) -> URL? {
        templateURL.with(emoteId: emote.identifier, format: format, themeMode: themeMode, scale: scale)
    }
}

class BadgeCellViewModel {
    @Published private(set) var image: UIImage?
    @Published private(set) var title = ""
    @Published private(set) var isLoading = false
    
    let badge: BadgeSet.Badge
    let setId: String
    
    init(badge: BadgeSet.Badge, setId: String) {
        self.badge = badge
        self.setId = setId
        title = setId + ":" + badge.identifier
    }
    
    func handleCellWillAppear() {
        guard !isLoading, image == nil else {
            return
        }
        
        isLoading = true
        
        URLSession.shared.dataTask(with: badge.imageURL4x) { data, _, _ in
            if let data = data,
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.image = image
                }
            } else {
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }.resume()
    }
}

extension Emote.ThemeMode {
    init(userInterfaceStyle: UIUserInterfaceStyle) {
        switch userInterfaceStyle {
        case .light, .unspecified:
            self = .light
        case .dark:
            self = .dark
        @unknown default:
            self = .light
        }
    }
}

extension Emote.Scale {
    init(floatValue: CGFloat) {
        switch floatValue {
        case ..<1.5: self = .small
        case 1.5..<2.5: self = .medium
        case 2.5...: self = .large
        default: self = .small
        }
    }
}
