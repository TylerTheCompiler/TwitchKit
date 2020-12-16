//
//  KrakenAPIRequestTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/14/20.
//

import XCTest
@testable import TwitchKit

private let userId = "SomeUserId"
private let channelId = "SomeChannelId"
private let gameName = "SomeGameName"
private let limit = 10
private let offset = 100
private let cursor = "SomeCursor"
private let direction = LegacySortDirection.descending
private let language = "SomeLanguage"
private let videoId = "SomeVideoId"

class KrakenAPIBitRequestTests: XCTestCase {
    func test_LegacyGetCheermotesRequest() {
        let req = LegacyGetCheermotesRequest(channelId: channelId)
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/bits/actions")
        XCTAssertEqual(req.equatableQueryParams, [.init(.channelId, channelId)])
        XCTAssertEqual(req.body, nil)
    }
}

class KrakenAPIChannelRequestTests: XCTestCase {
    func test_LegacyGetCurrentChannelRequest() {
        let req = LegacyGetCurrentChannelRequest()
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/channel")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, nil)
    }
        
    func test_LegacyGetChannelByIdRequest() {
        let req = LegacyGetChannelByIdRequest(channelId: channelId)
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/channels/\(channelId)")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, nil)
    }
        
    func test_LegacyUpdateChannelRequest() {
        let status = "Some status"
        let delay = 123
        let channelFeedEnabled = true
        
        let req = LegacyUpdateChannelRequest(channelId: channelId,
                                             status: status,
                                             game: gameName,
                                             delay: delay,
                                             channelFeedEnabled: channelFeedEnabled)
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .put)
        XCTAssertEqual(req.path, "/channels/\(channelId)")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, .init(channel: .init(
            status: status,
            game: gameName,
            delay: delay.description,
            channelFeedEnabled: channelFeedEnabled
        )))
    }
        
    func test_LegacyGetChannelEditorsRequest() {
        let req = LegacyGetChannelEditorsRequest(channelId: channelId)
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/channels/\(channelId)/editors")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyGetChannelFollowersRequest() {
        let req = LegacyGetChannelFollowersRequest(
            channelId: channelId,
            limit: limit,
            offset: offset,
            cursor: cursor,
            direction: direction
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/channels/\(channelId)/follows")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.limit, limit.description),
            .init(.offset, offset.description),
            .init(.cursor, cursor),
            .init(.direction, direction.rawValue)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyGetChannelTeamsRequest() {
        let req = LegacyGetChannelTeamsRequest(channelId: channelId)
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/channels/\(channelId)/teams")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyGetChannelSubscribersRequest() {
        let req = LegacyGetChannelSubscribersRequest(
            channelId: channelId,
            limit: limit,
            offset: offset,
            direction: direction
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/channels/\(channelId)/subscriptions")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.limit, limit.description),
            .init(.offset, offset.description),
            .init(.direction, direction.rawValue)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyCheckChannelSubscriptionByUserRequest() {
        let req = LegacyCheckChannelSubscriptionByUserRequest(
            channelId: channelId,
            userId: userId
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/channels/\(channelId)/subscriptions/\(userId)")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyGetChannelVideosRequest() {
        let broadcastTypes = [LegacyVideo.BroadcastType.archive, .highlight, .upload]
        let languages = [language]
        let sort = LegacyGetChannelVideosRequest.Sort.time
        
        let req = LegacyGetChannelVideosRequest(
            channelId: channelId,
            limit: limit,
            offset: offset,
            broadcastTypes: broadcastTypes,
            languages: languages,
            sort: sort
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/channels/\(channelId)/videos")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.limit, limit.description),
            .init(.offset, offset.description),
            .init(.broadcastType, broadcastTypes.map(\.rawValue).joined(separator: ",")),
            .init(.language, languages.joined(separator: ",")),
            .init(.sort, sort.rawValue)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyStartChannelCommercialRequest() {
        let length = LegacyCommercial.Length.oneAndAHalfMinutes
        
        let req = LegacyStartChannelCommercialRequest(
            channelId: channelId,
            length: length
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .post)
        XCTAssertEqual(req.path, "/channels/\(channelId)/commercial")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, .init(length: length))
    }
    
    func test_LegacyResetChannelStreamKeyRequest() {
        let req = LegacyResetChannelStreamKeyRequest(channelId: channelId)
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .delete)
        XCTAssertEqual(req.path, "/channels/\(channelId)/stream_key")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, nil)
    }
}

class KrakenAPIChatRequestTests: XCTestCase {
    func test_LegacyGetChatBadgesByChannelRequest() {
        let req = LegacyGetChatBadgesByChannelRequest(channelId: channelId)
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/chat/\(channelId)/badges")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyGetChatEmoticonsBySetRequest() {
        let emoteSets = [123, 456, 789]
        
        let req = LegacyGetChatEmoticonsBySetRequest(emoteSets: emoteSets)
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/chat/emoticon_images")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.emoteSets, emoteSets.map(\.description).joined(separator: ","))
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyGetAllChatEmoticonSetsRequest() {
        let req = LegacyGetAllChatEmoticonSetsRequest()
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/chat/emoticon_images")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyGetAllChatEmoticonsRequest() {
        let req = LegacyGetAllChatEmoticonsRequest()
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/chat/emoticons")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, nil)
    }
}

class KrakenAPIClipRequestTests: XCTestCase {
    let clipSlug = "SomeClipSlug"
    
    func test_LegacyGetClipRequest() {
        let req = LegacyGetClipRequest(clipSlug: clipSlug)
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/clips/\(clipSlug)")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyGetTopClipsRequest_acrossAllChannelsAndGames() {
        let period = LegacyGetTopClipsRequest.Period.month
        let trending = true
        let languages = [language]
        
        let req = LegacyGetTopClipsRequest(
            period: period,
            trending: trending,
            languages: languages,
            limit: limit,
            cursor: cursor
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/clips/top")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.period, period.rawValue),
            .init(.trending, trending.description),
            .init(.language, languages.joined(separator: ",")),
            .init(.limit, limit.description),
            .init(.cursor, cursor)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyGetTopClipsRequest_forASpecificChannel() {
        let period = LegacyGetTopClipsRequest.Period.month
        let trending = true
        let languages = [language]
        
        let req = LegacyGetTopClipsRequest(
            channelId: channelId,
            period: period,
            trending: trending,
            languages: languages,
            limit: limit,
            cursor: cursor
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/clips/top")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.channel, channelId),
            .init(.period, period.rawValue),
            .init(.trending, trending.description),
            .init(.language, languages.joined(separator: ",")),
            .init(.limit, limit.description),
            .init(.cursor, cursor)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyGetTopClipsRequest_forASpecificGame() {
        let period = LegacyGetTopClipsRequest.Period.month
        let trending = true
        let languages = [language]
        
        let req = LegacyGetTopClipsRequest(
            game: gameName,
            period: period,
            trending: trending,
            languages: languages,
            limit: limit,
            cursor: cursor
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/clips/top")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.game, gameName),
            .init(.period, period.rawValue),
            .init(.trending, trending.description),
            .init(.language, languages.joined(separator: ",")),
            .init(.limit, limit.description),
            .init(.cursor, cursor)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyGetFollowedClipsRequest() {
        let trending = true
        
        let req = LegacyGetFollowedClipsRequest(
            trending: trending,
            limit: limit,
            cursor: cursor
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/clips/followed")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.trending, trending.description),
            .init(.limit, limit.description),
            .init(.cursor, cursor)
        ])
        XCTAssertEqual(req.body, nil)
    }
}

class KrakenAPICollectionRequestTests: XCTestCase {
    let collectionId = "SomeCollectionId"
    let itemId = "SomeItemId"
    let title = "SomeTitle"
    
    func test_LegacyGetCollectionMetadataRequest() {
        let req = LegacyGetCollectionMetadataRequest(collectionId: collectionId)
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/collections/\(collectionId)")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyGetCollectionRequest() {
        let includeAllItems = true
        
        let req = LegacyGetCollectionRequest(
            collectionId: collectionId,
            includeAllItems: includeAllItems
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/collections/\(collectionId)/items")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.includeAllItems, includeAllItems.description)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyGetCollectionsByChannelRequest() {
        let req = LegacyGetCollectionsByChannelRequest(
            channelId: channelId,
            containingVideoWithId: videoId,
            limit: limit,
            cursor: cursor
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/channels/\(channelId)/collections")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.containingItem, "video:\(videoId)"),
            .init(.limit, limit.description),
            .init(.cursor, cursor)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyCreateCollectionRequest() {
        let req = LegacyCreateCollectionRequest(
            channelId: channelId,
            title: title
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .post)
        XCTAssertEqual(req.path, "/channels/\(channelId)/collections")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, .init(title: title))
    }
    
    func test_LegacyUpdateCollectionRequest() {
        let req = LegacyUpdateCollectionRequest(
            collectionId: collectionId,
            title: title
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .put)
        XCTAssertEqual(req.path, "/collections/\(collectionId)")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, .init(title: title))
    }
    
    func test_LegacyCreateCollectionThumbnailRequest() {
        let req = LegacyCreateCollectionThumbnailRequest(
            collectionId: collectionId,
            itemId: itemId
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .put)
        XCTAssertEqual(req.path, "/collections/\(collectionId)/thumbnail")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, .init(itemId: itemId))
    }
    
    func test_LegacyDeleteCollectionRequest() {
        let req = LegacyDeleteCollectionRequest(collectionId: collectionId)
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .delete)
        XCTAssertEqual(req.path, "/collections/\(collectionId)")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyAddItemToCollectionRequest() {
        let req = LegacyAddItemToCollectionRequest(
            collectionId: collectionId,
            videoId: videoId
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .post)
        XCTAssertEqual(req.path, "/collections/\(collectionId)/items")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, .init(id: videoId))
    }
    
    func test_LegacyDeleteItemFromCollectionRequest() {
        let req = LegacyDeleteItemFromCollectionRequest(
            collectionId: collectionId,
            itemId: itemId
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .delete)
        XCTAssertEqual(req.path, "/collections/\(collectionId)/items/\(itemId)")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyMoveItemWithinCollectionRequest() {
        let position = 123
        
        let req = LegacyMoveItemWithinCollectionRequest(
            collectionId: collectionId,
            itemId: itemId,
            position: position
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .put)
        XCTAssertEqual(req.path, "/collections/\(collectionId)/items/\(itemId)")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, .init(position: position.description))
    }
}

class KrakenAPIGameRequestTests: XCTestCase {
    func test_LegacyGetTopGamesRequest() {
        let req = LegacyGetTopGamesRequest(
            limit: limit,
            offset: offset
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/games/top")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.limit, limit.description),
            .init(.offset, offset.description)
        ])
        XCTAssertEqual(req.body, nil)
    }
}

class KrakenAPIIngestRequestTests: XCTestCase {
    func test_LegacyGetIngestServersRequest() {
        let req = LegacyGetIngestServersRequest()
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/ingests")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, nil)
    }
}

class KrakenAPISearchRequestTests: XCTestCase {
    let query = "Some query"
    
    func test_LegacySearchChannelsRequest() {
        let req = LegacySearchChannelsRequest(
            query: query,
            limit: limit,
            offset: offset
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/search/channels")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.query, query),
            .init(.limit, limit.description),
            .init(.offset, offset.description)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacySearchGamesRequest() {
        let req = LegacySearchGamesRequest(query: query)
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/search/games")
        XCTAssertEqual(req.equatableQueryParams, [.init(.query, query)])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacySearchStreamsRequest() {
        let onlyHLS = true
        
        let req = LegacySearchStreamsRequest(
            query: query,
            onlyHLS: onlyHLS,
            limit: limit,
            offset: offset
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/search/streams")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.query, query),
            .init(.hls, onlyHLS.description),
            .init(.limit, limit.description),
            .init(.offset, offset.description)
        ])
        XCTAssertEqual(req.body, nil)
    }
}

class KrakenAPIStreamRequestTests: XCTestCase {
    func test_LegacyGetStreamByUserRequest() {
        let streamType = LegacyGetStreamByUserRequest.StreamType.playlist
        
        let req = LegacyGetStreamByUserRequest(
            channelId: channelId,
            streamType: streamType
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/streams/\(channelId)")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.streamType, streamType.rawValue)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyGetLiveStreamsRequest() {
        let channels = [channelId]
        let streamType = LegacyGetLiveStreamsRequest.StreamType.playlist
        
        let req = LegacyGetLiveStreamsRequest(
            channels: channels,
            game: gameName,
            language: language,
            streamType: streamType,
            limit: limit,
            offset: offset
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/streams")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.channel, channels.joined(separator: ",")),
            .init(.game, gameName),
            .init(.language, language),
            .init(.streamType, streamType.rawValue),
            .init(.limit, limit.description),
            .init(.offset, offset.description)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyGetStreamsSummaryRequest() {
        let req = LegacyGetStreamsSummaryRequest(game: gameName)
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/streams/summary")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.game, gameName)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyGetFeaturedStreamsRequest() {
        let req = LegacyGetFeaturedStreamsRequest(
            limit: limit,
            offset: offset
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/streams/featured")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.limit, limit.description),
            .init(.offset, offset.description)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyGetFollowedStreamsRequest() {
        let streamType = LegacyGetFollowedStreamsRequest.StreamType.playlist
        
        let req = LegacyGetFollowedStreamsRequest(
            streamType: streamType,
            limit: limit,
            offset: offset
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/streams/followed")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.streamType, streamType.rawValue),
            .init(.limit, limit.description),
            .init(.offset, offset.description)
        ])
        XCTAssertEqual(req.body, nil)
    }
}

class KrakenAPITeamRequestTests: XCTestCase {
    func test_LegacyGetAllTeamsRequest() {
        let req = LegacyGetAllTeamsRequest(
            limit: limit,
            offset: offset
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/teams")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.limit, limit.description),
            .init(.offset, offset.description)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyGetTeamRequest() {
        let teamName = "SomeTeam"
        
        let req = LegacyGetTeamRequest(teamName: teamName)
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/teams/\(teamName)")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, nil)
    }
}

class KrakenAPIUserRequestTests: XCTestCase {
    func test_LegacyGetCurrentUserRequest() {
        let req = LegacyGetCurrentUserRequest()
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/user")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyGetUserByIdRequest() {
        let req = LegacyGetUserByIdRequest(userId: userId)
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/users/\(userId)")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyGetUsersRequest() {
        let usernames = ["SomeUser1", "SomeUser2", "SomeUser3"]
        let req = LegacyGetUsersRequest(usernames: usernames)
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/users")
        XCTAssertEqual(req.equatableQueryParams, usernames.map { .init(.login, $0.lowercased()) })
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyGetUserEmotesRequest() {
        let req = LegacyGetUserEmotesRequest(userId: userId)
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/users/\(userId)/emotes")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyCheckUserSubscriptionByChannelRequest() {
        let req = LegacyCheckUserSubscriptionByChannelRequest(
            userId: userId,
            channelId: channelId
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/users/\(userId)/subscriptions/\(channelId)")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyGetUserFollowsRequest() {
        let sort = LegacyGetUserFollowsRequest.Sort.lastBroadcast
        
        let req = LegacyGetUserFollowsRequest(
            userId: userId,
            direction: direction,
            sortBy: sort,
            limit: limit,
            offset: offset
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/users/\(userId)/follows/channels")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.direction, direction.rawValue),
            .init(.sortBy, sort.rawValue),
            .init(.limit, limit.description),
            .init(.offset, offset.description)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyCheckUserFollowsByChannelRequest() {
        let req = LegacyCheckUserFollowsByChannelRequest(
            userId: userId,
            channelId: channelId
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/users/\(userId)/follows/channels/\(channelId)")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyFollowChannelRequest() {
        let turnOnNotifications = true
        
        let req = LegacyFollowChannelRequest(
            userId: userId,
            channelId: channelId,
            turnOnNotifications: turnOnNotifications
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .put)
        XCTAssertEqual(req.path, "/users/\(userId)/follows/channels/\(channelId)")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.notifications, turnOnNotifications.description)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyUnfollowChannelRequest() {
        let req = LegacyUnfollowChannelRequest(
            userId: userId,
            channelId: channelId
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .delete)
        XCTAssertEqual(req.path, "/users/\(userId)/follows/channels/\(channelId)")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyGetUserBlockListRequest() {
        let req = LegacyGetUserBlockListRequest(
            userId: userId,
            limit: limit,
            offset: offset
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/users/\(userId)/blocks")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.limit, limit.description),
            .init(.offset, offset.description)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyBlockUserRequest() {
        let sourceUserId = "SourceUserId"
        let targetUserId = "TargetUserId"
        
        let req = LegacyBlockUserRequest(
            sourceUserId: sourceUserId,
            targetUserId: targetUserId
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .put)
        XCTAssertEqual(req.path, "/users/\(sourceUserId)/blocks/\(targetUserId)")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyUnblockUserRequest() {
        let sourceUserId = "SourceUserId"
        let targetUserId = "TargetUserId"
        
        let req = LegacyUnblockUserRequest(
            sourceUserId: sourceUserId,
            targetUserId: targetUserId
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .delete)
        XCTAssertEqual(req.path, "/users/\(sourceUserId)/blocks/\(targetUserId)")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyCreateUserConnectionToViewerHeartbeatServiceRequest() {
        let identifier = "SomeIdentifier"
        
        let req = LegacyCreateUserConnectionToViewerHeartbeatServiceRequest(identifier: identifier)
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .put)
        XCTAssertEqual(req.path, "/user/vhs")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, .init(identifier: identifier))
    }
    
    func test_LegacyCheckUserConnectionToViewerHeartbeatServiceRequest() {
        let req = LegacyCheckUserConnectionToViewerHeartbeatServiceRequest()
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/user/vhs")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyDeleteUserConnectionToViewerHeartbeatServiceRequest() {
        let req = LegacyDeleteUserConnectionToViewerHeartbeatServiceRequest()
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .delete)
        XCTAssertEqual(req.path, "/user/vhs")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, nil)
    }
}

class KrakenAPIVideoRequestTests: XCTestCase {
    func test_LegacyGetVideoRequest() {
        let req = LegacyGetVideoRequest(videoId: videoId)
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/videos/\(videoId)")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyGetTopVideosRequest() {
        let broadcastTypes = [LegacyVideo.BroadcastType.archive, .highlight, .upload]
        let languages = [language]
        let period = LegacyGetTopVideosRequest.Period.month
        let sort = LegacyGetTopVideosRequest.Sort.views
        
        let req = LegacyGetTopVideosRequest(
            game: gameName,
            broadcastTypes: broadcastTypes,
            languages: languages,
            period: period,
            sort: sort,
            limit: limit,
            offset: offset
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/videos/top")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.game, gameName),
            .init(.broadcastType, broadcastTypes.map(\.rawValue).joined(separator: ",")),
            .init(.language, languages.joined(separator: ",")),
            .init(.period, period.rawValue),
            .init(.sort, sort.rawValue),
            .init(.limit, limit.description),
            .init(.offset, offset.description)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyGetFollowedVideosRequest() {
        let broadcastTypes = [LegacyVideo.BroadcastType.archive, .highlight, .upload]
        let languages = [language]
        let sort = LegacyGetFollowedVideosRequest.Sort.views
        
        let req = LegacyGetFollowedVideosRequest(
            broadcastTypes: broadcastTypes,
            languages: languages,
            sort: sort,
            limit: limit,
            offset: offset
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/videos/followed")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.broadcastType, broadcastTypes.map(\.rawValue).joined(separator: ",")),
            .init(.language, languages.joined(separator: ",")),
            .init(.sort, sort.rawValue),
            .init(.limit, limit.description),
            .init(.offset, offset.description)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyUpdateVideoRequest() {
        let title = "SomeTitle"
        let description = "SomeDescription"
        let tags = ["Tag1", "Tag2", "Tag3"]
        
        let req = LegacyUpdateVideoRequest(
            videoId: videoId,
            title: title,
            description: description,
            game: gameName,
            language: language,
            tags: tags
        )
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .put)
        XCTAssertEqual(req.path, "/videos/\(videoId)")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.title, title),
            .init(.description, description),
            .init(.game, gameName),
            .init(.language, language),
            .init(.tagList, tags.joined(separator: ","))
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_LegacyDeleteVideoRequest() {
        let req = LegacyDeleteVideoRequest(videoId: videoId)
        
        XCTAssertEqual(req.apiVersion, .kraken)
        XCTAssertEqual(req.method, .delete)
        XCTAssertEqual(req.path, "/videos/\(videoId)")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, nil)
    }
}
