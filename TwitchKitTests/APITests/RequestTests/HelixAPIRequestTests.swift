//
//  HelixAPIRequestTests.swift
//  TwitchKitTests
//
//  Created by Tyler Prevost on 12/14/20.
//

import XCTest
@testable import TwitchKit

private let userId = "SomeUserId"
private let userIds = ["UserId1", "UserId2", "UserId3"]
private let gameId = "SomeGameId"
private let dateInterval = DateInterval(start: Date(), duration: 3600)
private let first = 100
private let cursor = Pagination.Cursor(rawValue: "SomeCursor")
private let forwardCursor = Pagination.DirectedCursor.forward(.init(rawValue: "SomeForwardCursor"))
private let backwardCursor = Pagination.DirectedCursor.backward(.init(rawValue: "SomeBackwardCursor"))

class HelixAPIAdsRequestTests: XCTestCase {
    func test_StartCommercialRequest() {
        let length = Commercial.Length.oneMinuteThirtySeconds
        
        let req = StartCommercialRequest(length: length)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .post)
        XCTAssertEqual(req.path, "/channels/commercial")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, .init(broadcasterId: "", length: length))
    }
    
    func test_StartCommercialRequest_updateWithUserId() {
        let length = Commercial.Length.oneMinuteThirtySeconds
        
        var req = StartCommercialRequest(length: length)
        req.update(with: userId)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .post)
        XCTAssertEqual(req.path, "/channels/commercial")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, .init(broadcasterId: userId, length: length))
    }
}

class HelixAPIAnalyticsRequestTests: XCTestCase {
    func test_GetExtensionAnalyticsRequest_forASpecificExtension() {
        let extensionId = "SomeExtensionId"
        
        let req = GetExtensionAnalyticsRequest(
            extensionId: extensionId,
            dateInterval: dateInterval
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/analytics/extensions")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.extensionId, extensionId),
            .init(.startedAt, DateFormatter.zeroedOutTimeInternetDateFormatter.string(from: dateInterval.start)),
            .init(.endedAt, DateFormatter.zeroedOutTimeInternetDateFormatter.string(from: dateInterval.end))
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetExtensionAnalyticsRequest_forSeparateAnalyticsReports() {
        let reportType = ExtensionReport.ReportType.overviewV2
        
        let req = GetExtensionAnalyticsRequest(
            reportType: reportType,
            dateInterval: dateInterval,
            first: first,
            after: cursor
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/analytics/extensions")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.type, reportType.rawValue),
            .init(.startedAt, DateFormatter.zeroedOutTimeInternetDateFormatter.string(from: dateInterval.start)),
            .init(.endedAt, DateFormatter.zeroedOutTimeInternetDateFormatter.string(from: dateInterval.end)),
            .init(.first, first.description),
            .init(.after, cursor.rawValue)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetGameAnalyticsRequest_forASpecificGame() {
        let req = GetGameAnalyticsRequest(
            gameId: gameId,
            dateInterval: dateInterval
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/analytics/games")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.gameId, gameId),
            .init(.startedAt, DateFormatter.zeroedOutTimeInternetDateFormatter.string(from: dateInterval.start)),
            .init(.endedAt, DateFormatter.zeroedOutTimeInternetDateFormatter.string(from: dateInterval.end))
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetGameAnalyticsRequest_forSeparateAnalyticsReports() {
        let reportType = GameReport.ReportType.overviewV2
        
        let req = GetGameAnalyticsRequest(
            reportType: reportType,
            dateInterval: dateInterval,
            first: first,
            after: cursor
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/analytics/games")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.type, reportType.rawValue),
            .init(.startedAt, DateFormatter.zeroedOutTimeInternetDateFormatter.string(from: dateInterval.start)),
            .init(.endedAt, DateFormatter.zeroedOutTimeInternetDateFormatter.string(from: dateInterval.end)),
            .init(.first, first.description),
            .init(.after, cursor.rawValue)
        ])
        XCTAssertEqual(req.body, nil)
    }
}

class HelixAPIBitsRequestTests: XCTestCase {
    func test_GetBitsLeaderboardRequest() {
        let count = 123
        let period = GetBitsLeaderboardRequest.Period.month(of: Date())
        
        let req = GetBitsLeaderboardRequest(
            count: count,
            period: period,
            userId: userId
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/bits/leaderboard")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.count, count.description),
            .init(.period, period.periodRawValue),
            .init(.startedAt, period.startedAtRawValue!),
            .init(.userId, userId)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetBitsLeaderboardRequest_period_periodRawValues() {
        let now = Date()
        XCTAssertEqual(GetBitsLeaderboardRequest.Period.all.periodRawValue, "all")
        XCTAssertEqual(GetBitsLeaderboardRequest.Period.day(of: now).periodRawValue, "day")
        XCTAssertEqual(GetBitsLeaderboardRequest.Period.week(of: now).periodRawValue, "week")
        XCTAssertEqual(GetBitsLeaderboardRequest.Period.month(of: now).periodRawValue, "month")
        XCTAssertEqual(GetBitsLeaderboardRequest.Period.year(of: now).periodRawValue, "year")
    }
    
    func test_GetBitsLeaderboardRequest_period_startedAtRawValues() {
        let now = Date()
        let startedAtString = ISO8601DateFormatter.internetDateFormatter.string(from: now)
        XCTAssertEqual(GetBitsLeaderboardRequest.Period.all.startedAtRawValue, nil)
        XCTAssertEqual(GetBitsLeaderboardRequest.Period.day(of: now).startedAtRawValue, startedAtString)
        XCTAssertEqual(GetBitsLeaderboardRequest.Period.week(of: now).startedAtRawValue, startedAtString)
        XCTAssertEqual(GetBitsLeaderboardRequest.Period.month(of: now).startedAtRawValue, startedAtString)
        XCTAssertEqual(GetBitsLeaderboardRequest.Period.year(of: now).startedAtRawValue, startedAtString)
    }
    
    func test_GetCheermotesRequest() {
        let req = GetCheermotesRequest(broadcasterId: userId)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/bits/cheermotes")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.broadcasterId, userId)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetExtensionTransactionsRequest_forASpecificSetOfTransactions() {
        let extensionId = "SomeExtensionId"
        let transactionIds = ["SomeTransactionId1", "SomeTransactionId2", "SomeTransactionId3"]
        
        let req = GetExtensionTransactionsRequest(
            extensionId: extensionId,
            transactionIds: transactionIds,
            first: first
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/extensions/transactions")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.extensionId, extensionId),
            .init(.first, first.description),
            .init(.id, transactionIds[0]),
            .init(.id, transactionIds[1]),
            .init(.id, transactionIds[2])
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetExtensionTransactionsRequest_withAPaginationCursor() {
        let extensionId = "SomeExtensionId"
        
        let req = GetExtensionTransactionsRequest(
            extensionId: extensionId,
            after: cursor,
            first: first
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/extensions/transactions")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.extensionId, extensionId),
            .init(.first, first.description),
            .init(.after, cursor.rawValue)
        ])
        XCTAssertEqual(req.body, nil)
    }
}

class HelixAPIChannelPointRequestTests: XCTestCase {
    let customRewardId = "SomeRewardId"
    
    func test_CreateCustomRewardRequest() {
        let title = "SomeTitle"
        let cost = 1000
        let prompt = "SomePrompt"
        let isEnabled = true
        let backgroundColor = "SomeHexColor"
        let isUserInputRequired = true
        let isMaxPerStreamEnabled = true
        let maxPerStream = 100
        let isMaxPerUserPerStreamEnabled = true
        let maxPerUserPerStream = 10
        let isGlobalCooldownEnabled = true
        let globalCooldownSeconds = 30
        let shouldRedemptionsSkipRequestQueue = true
        
        var req = CreateCustomRewardRequest(
            title: title,
            cost: cost,
            prompt: prompt,
            isEnabled: isEnabled,
            backgroundColor: backgroundColor,
            isUserInputRequired: isUserInputRequired,
            isMaxPerStreamEnabled: isMaxPerStreamEnabled,
            maxPerStream: maxPerStream,
            isMaxPerUserPerStreamEnabled: isMaxPerUserPerStreamEnabled,
            maxPerUserPerStream: maxPerUserPerStream,
            isGlobalCooldownEnabled: isGlobalCooldownEnabled,
            globalCooldownSeconds: globalCooldownSeconds,
            shouldRedemptionsSkipRequestQueue: shouldRedemptionsSkipRequestQueue
        )
        
        req.update(with: userId)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .post)
        XCTAssertEqual(req.path, "/channel_points/custom_rewards")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.broadcasterId, userId)
        ])
        XCTAssertEqual(req.body, .init(
            title: title,
            cost: cost,
            prompt: prompt,
            isEnabled: isEnabled,
            backgroundColor: backgroundColor,
            isUserInputRequired: isUserInputRequired,
            isMaxPerStreamEnabled: isMaxPerStreamEnabled,
            maxPerStream: maxPerStream,
            isMaxPerUserPerStreamEnabled: isMaxPerUserPerStreamEnabled,
            maxPerUserPerStream: maxPerUserPerStream,
            isGlobalCooldownEnabled: isGlobalCooldownEnabled,
            globalCooldownSeconds: globalCooldownSeconds,
            shouldRedemptionsSkipRequestQueue: shouldRedemptionsSkipRequestQueue
        ))
    }
    
    func test_DeleteCustomRewardRequest() {
        var req = DeleteCustomRewardRequest(customRewardId: customRewardId)
        
        req.update(with: userId)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .delete)
        XCTAssertEqual(req.path, "/channel_points/custom_rewards")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.id, customRewardId),
            .init(.broadcasterId, userId)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetCustomRewardRedemptionsRequest_forASpecificSetOfRedemptions() {
        let redemptionIds = ["SomeRedemptionId1", "SomeRedemptionId2", "SomeRedemptionId3"]
        
        var req = GetCustomRewardRedemptionsRequest(
            rewardId: customRewardId,
            redemptionIds: redemptionIds
        )
        
        req.update(with: userId)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/channel_points/custom_rewards/redemptions")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.rewardId, customRewardId),
            .init(.id, redemptionIds[0]),
            .init(.id, redemptionIds[1]),
            .init(.id, redemptionIds[2]),
            .init(.broadcasterId, userId)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetCustomRewardRedemptionsRequest() {
        let status = CustomChannelPointsReward.Redemption.Status.fulfilled
        let sortOrder = GetCustomRewardRedemptionsRequest.SortOrder.oldest
        
        var req = GetCustomRewardRedemptionsRequest(
            rewardId: customRewardId,
            status: status,
            sortBy: sortOrder,
            first: first
        )
        
        req.update(with: userId)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/channel_points/custom_rewards/redemptions")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.rewardId, customRewardId),
            .init(.status, status.rawValue),
            .init(.sort, sortOrder.rawValue),
            .init(.first, first.description),
            .init(.broadcasterId, userId)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetCustomRewardRedemptionsRequest_withAPaginationCursor() {
        var req = GetCustomRewardRedemptionsRequest(
            after: cursor,
            first: first
        )
        
        req.update(with: userId)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/channel_points/custom_rewards/redemptions")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.after, cursor.rawValue),
            .init(.first, first.description),
            .init(.broadcasterId, userId)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetCustomRewardsRequest() {
        let customRewardIds = ["SomeRewardId1", "SomeRewardId2", "SomeRewardId3"]
        let onlyManageableRewards = true
        
        var req = GetCustomRewardsRequest(
            customRewardIds: customRewardIds,
            onlyManageableRewards: onlyManageableRewards
        )
        
        req.update(with: userId)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/channel_points/custom_rewards")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.onlyManageableRewards, onlyManageableRewards.description),
            .init(.id, customRewardIds[0]),
            .init(.id, customRewardIds[1]),
            .init(.id, customRewardIds[2]),
            .init(.broadcasterId, userId)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_UpdateCustomRewardRedemptionStatusRequest() {
        let redemptionIds = ["SomeRedemptionId1", "SomeRedemptionId2", "SomeRedemptionId3"]
        let status = CustomChannelPointsReward.Redemption.Status.fulfilled
        
        var req = UpdateCustomRewardRedemptionStatusRequest(
            redemptionIds: redemptionIds,
            rewardId: customRewardId,
            status: status
        )
        
        req.update(with: userId)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .patch)
        XCTAssertEqual(req.path, "/channel_points/custom_rewards/redemptions")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.rewardId, customRewardId),
            .init(.id, redemptionIds[0]),
            .init(.id, redemptionIds[1]),
            .init(.id, redemptionIds[2]),
            .init(.broadcasterId, userId)
        ])
        XCTAssertEqual(req.body, .init(status: status))
    }
    
    func test_UpdateCustomRewardRequest() {
        let title = "SomeTitle"
        let cost = 1000
        let prompt = "SomePrompt"
        let isEnabled = true
        let backgroundColor = "SomeHexColor"
        let isUserInputRequired = true
        let isMaxPerStreamEnabled = true
        let maxPerStream = 100
        let isMaxPerUserPerStreamEnabled = true
        let maxPerUserPerStream = 10
        let isGlobalCooldownEnabled = true
        let globalCooldownSeconds = 30
        let shouldRedemptionsSkipRequestQueue = true
        let isPaused = true
        
        var req = UpdateCustomRewardRequest(
            customRewardId: customRewardId,
            title: title,
            prompt: prompt,
            cost: cost,
            backgroundColor: backgroundColor,
            isEnabled: isEnabled,
            isUserInputRequired: isUserInputRequired,
            isMaxPerStreamEnabled: isMaxPerStreamEnabled,
            maxPerStream: maxPerStream,
            isMaxPerUserPerStreamEnabled: isMaxPerUserPerStreamEnabled,
            maxPerUserPerStream: maxPerUserPerStream,
            isGlobalCooldownEnabled: isGlobalCooldownEnabled,
            globalCooldownSeconds: globalCooldownSeconds,
            isPaused: isPaused,
            shouldRedemptionsSkipRequestQueue: shouldRedemptionsSkipRequestQueue
        )
        
        req.update(with: userId)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .patch)
        XCTAssertEqual(req.path, "/channel_points/custom_rewards")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.id, customRewardId),
            .init(.broadcasterId, userId)
        ])
        XCTAssertEqual(req.body, .init(
            title: title,
            prompt: prompt,
            cost: cost,
            backgroundColor: backgroundColor,
            isEnabled: isEnabled,
            isUserInputRequired: isUserInputRequired,
            isMaxPerStreamEnabled: isMaxPerStreamEnabled,
            maxPerStream: maxPerStream,
            isMaxPerUserPerStreamEnabled: isMaxPerUserPerStreamEnabled,
            maxPerUserPerStream: maxPerUserPerStream,
            isGlobalCooldownEnabled: isGlobalCooldownEnabled,
            globalCooldownSeconds: globalCooldownSeconds,
            isPaused: isPaused,
            shouldRedemptionsSkipRequestQueue: shouldRedemptionsSkipRequestQueue
        ))
    }
}

class HelixAPIClipRequestTests: XCTestCase {
    func test_CreateClipRequest() {
        let hasDelay = true
        
        let req = CreateClipRequest(
            broadcasterId: userId,
            hasDelay: hasDelay
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .post)
        XCTAssertEqual(req.path, "/clips")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.broadcasterId, userId),
            .init(.hasDelay, hasDelay.description)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetClipsRequest_forASpecificSetOfClips() {
        let clipIds = ["ClipId1", "ClipId2", "ClipId3"]
        
        let req = GetClipsRequest(
            clipIds: clipIds,
            dateInterval: dateInterval
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/clips")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.id, clipIds[0]),
            .init(.id, clipIds[1]),
            .init(.id, clipIds[2]),
            .init(.startedAt, ISO8601DateFormatter.internetDateFormatter.string(from: dateInterval.start)),
            .init(.endedAt, ISO8601DateFormatter.internetDateFormatter.string(from: dateInterval.end))
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetClipsRequest_forASpecificBroadcaster() {
        let req = GetClipsRequest(
            broadcasterId: userId,
            cursor: forwardCursor,
            first: first,
            dateInterval: dateInterval
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/clips")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.broadcasterId, userId),
            .init(.after, forwardCursor.forwardRawValue!),
            .init(.first, first.description),
            .init(.startedAt, ISO8601DateFormatter.internetDateFormatter.string(from: dateInterval.start)),
            .init(.endedAt, ISO8601DateFormatter.internetDateFormatter.string(from: dateInterval.end))
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetClipsRequest_forASpecificGame() {
        let req = GetClipsRequest(
            gameId: gameId,
            cursor: backwardCursor,
            first: first,
            dateInterval: dateInterval
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/clips")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.gameId, gameId),
            .init(.before, backwardCursor.backwardRawValue!),
            .init(.first, first.description),
            .init(.startedAt, ISO8601DateFormatter.internetDateFormatter.string(from: dateInterval.start)),
            .init(.endedAt, ISO8601DateFormatter.internetDateFormatter.string(from: dateInterval.end))
        ])
        XCTAssertEqual(req.body, nil)
    }
}

class HelixAPIEntitlementRequestTests: XCTestCase {
    func test_GetCodeStatusRequest() {
        let codes = ["Code1", "Code2", "Code3"]
        
        let req = GetCodeStatusRequest(
            userId: userId,
            codes: codes
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/entitlements/codes")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.userId, userId),
            .init(.code, codes[0]),
            .init(.code, codes[1]),
            .init(.code, codes[2])
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetDropsEntitlementsRequest_forASpecificSetOfEntitlements() {
        let entitlementIds = ["EntitlementId1", "EntitlementId2", "EntitlementId3"]
        
        let req = GetDropsEntitlementsRequest(entitlementIds: entitlementIds)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/entitlements/drops")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.id, entitlementIds[0]),
            .init(.id, entitlementIds[1]),
            .init(.id, entitlementIds[2])
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetDropsEntitlementsRequest() {
        let req = GetDropsEntitlementsRequest(
            userId: userId,
            gameId: gameId,
            after: cursor,
            first: first
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/entitlements/drops")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.userId, userId),
            .init(.gameId, gameId),
            .init(.after, cursor.rawValue),
            .init(.first, first.description)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetUserDropsEntitlementsRequest_forASpecificSetOfEntitlements() {
        let entitlementIds = ["EntitlementId1", "EntitlementId2", "EntitlementId3"]
        
        let req = GetUserDropsEntitlementsRequest(entitlementIds: entitlementIds)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/entitlements/drops")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.id, entitlementIds[0]),
            .init(.id, entitlementIds[1]),
            .init(.id, entitlementIds[2])
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetUserDropsEntitlementsRequest() {
        let req = GetUserDropsEntitlementsRequest(
            gameId: gameId,
            after: cursor,
            first: first
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/entitlements/drops")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.gameId, gameId),
            .init(.after, cursor.rawValue),
            .init(.first, first.description)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_RedeemCodeRequest() {
        let codes = ["SomeCode1", "SomeCode2", "SomeCode3"]
        
        let req = RedeemCodeRequest(
            userId: userId,
            codes: codes
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .post)
        XCTAssertEqual(req.path, "/entitlements/codes")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.userId, userId),
            .init(.code, codes[0]),
            .init(.code, codes[1]),
            .init(.code, codes[2])
        ])
        XCTAssertEqual(req.body, nil)
    }
}

class HelixAPIEventSubRequestTests: XCTestCase {
    func test_GetEventSubSubscriptionsRequest() {
        let status = EventSub.Subscription.Status.authorizationRevoked
        
        let req = GetEventSubSubscriptionsRequest(status: status)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/eventsub/subscriptions")
        XCTAssertEqual(req.equatableQueryParams, [.init(.status, status.rawValue)])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetEventSubSubscriptionsRequest_withPaginationCursor() {
        let req = GetEventSubSubscriptionsRequest(after: cursor)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/eventsub/subscriptions")
        XCTAssertEqual(req.equatableQueryParams, [.init(.after, cursor.rawValue)])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_CreateEventSubSubscriptionRequest() {
        let callback = URL(string: "callback://callback")!
        let secret = "SomeSecret"
        
        let condition = EventSub.SubscriptionCondition.channelBan(broadcasterUserId: userId)
        let transport = CreateEventSubSubscriptionRequest.Transport(method: .webhook,
                                                                    callback: callback,
                                                                    secret: secret)
        let version = "SomeVersion"
        
        let req = CreateEventSubSubscriptionRequest(
            condition: condition,
            transport: transport,
            version: version
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .post)
        XCTAssertEqual(req.path, "/eventsub/subscriptions")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, .init(
            type: condition.subscriptionType,
            version: version,
            condition: condition,
            transport: transport,
            isBatchingEnabled: false
        ))
    }
    
    func test_CreateEventSubSubscriptionRequest_convenienceInitializer() {
        let callback = URL(string: "callback://callback")!
        let secret = "SomeSecret"
        
        let condition = EventSub.SubscriptionCondition.channelBan(broadcasterUserId: userId)
        let transport = CreateEventSubSubscriptionRequest.Transport(method: .webhook,
                                                                    callback: callback,
                                                                    secret: secret)
        let version = "1"
        
        let req = CreateEventSubSubscriptionRequest(
            condition: condition,
            callbackURL: callback,
            secret: secret
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .post)
        XCTAssertEqual(req.path, "/eventsub/subscriptions")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, .init(
            type: condition.subscriptionType,
            version: version,
            condition: condition,
            transport: transport,
            isBatchingEnabled: false
        ))
    }
    
    func test_DeleteEventSubSubscriptionRequest() {
        let subscriptionId = "SomeSubscriptionId"
        
        let req = DeleteEventSubSubscriptionRequest(subscriptionId: subscriptionId)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .delete)
        XCTAssertEqual(req.path, "/eventsub/subscriptions")
        XCTAssertEqual(req.equatableQueryParams, [.init(.id, subscriptionId)])
        XCTAssertEqual(req.body, nil)
    }
}

class HelixAPIGameRequestTests: XCTestCase {
    func test_GetTopGamesRequest() {
        let req = GetTopGamesRequest(
            cursor: forwardCursor,
            first: first
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/games/top")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.after, forwardCursor.forwardRawValue!),
            .init(.first, first.description)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetGamesRequest() {
        let gameIds = ["GameId1", "GameId2", "GameId3"]
        let gameNames = ["GameName1", "GameName2", "GameName3"]
        
        let req = GetGamesRequest(
            gameIds: gameIds,
            gameNames: gameNames,
            cursor: backwardCursor,
            first: first
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/games")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.before, backwardCursor.backwardRawValue!),
            .init(.first, first.description),
            .init(.id, gameIds[0]),
            .init(.id, gameIds[1]),
            .init(.id, gameIds[2]),
            .init(.name, gameNames[0]),
            .init(.name, gameNames[1]),
            .init(.name, gameNames[2])
        ])
        XCTAssertEqual(req.body, nil)
    }
}

class HelixAPIHypeTrainRequestTests: XCTestCase {
    func test_GetHypeTrainEventsRequest_forASpecificHypeTrainEvent() {
        let eventId = "SomeHypeTrainEventId"
        
        var req = GetHypeTrainEventsRequest(eventId: eventId)
        
        req.update(with: userId)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/hypetrain/events")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.id, eventId),
            .init(.broadcasterId, userId)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetHypeTrainEventsRequest() {
        var req = GetHypeTrainEventsRequest(
            broadcasterId: nil,
            after: cursor,
            first: first
        )
        
        req.update(with: userId)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/hypetrain/events")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.cursor, cursor.rawValue),
            .init(.first, first.description),
            .init(.broadcasterId, userId)
        ])
        XCTAssertEqual(req.body, nil)
    }
}

class HelixAPIModerationRequestTests: XCTestCase {
    
    func test_CheckAutoModStatusRequest() {
        let messages = [AutoModMessage(id: "Id1", text: "Text1", userId: "UserId1"),
                        AutoModMessage(id: "Id2", text: "Text2", userId: "UserId2"),
                        AutoModMessage(id: "Id3", text: "Text3", userId: "UserId3")]
        
        var req = CheckAutoModStatusRequest(messages: messages)
        
        req.update(with: userId)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .post)
        XCTAssertEqual(req.path, "/moderation/enforcements/status")
        XCTAssertEqual(req.equatableQueryParams, [.init(.broadcasterId, userId)])
        XCTAssertEqual(req.body, .init(messages: messages))
    }
    
    func test_GetBannedUsersRequest() {
        var req = GetBannedUsersRequest(userIds: userIds)
        
        req.update(with: userId)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/moderation/banned")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.userId, userIds[0]),
            .init(.userId, userIds[1]),
            .init(.userId, userIds[2]),
            .init(.broadcasterId, userId)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetBannedUsersRequest_withPaginationCursor() {
        var req = GetBannedUsersRequest(cursor: backwardCursor)
        
        req.update(with: userId)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/moderation/banned")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.before, backwardCursor.backwardRawValue!),
            .init(.broadcasterId, userId)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetBanEventsRequest() {
        var req = GetBanEventsRequest(userIds: userIds)
        
        req.update(with: userId)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/moderation/banned/events")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.userId, userIds[0]),
            .init(.userId, userIds[1]),
            .init(.userId, userIds[2]),
            .init(.broadcasterId, userId)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetBanEventsRequest_withPaginationCursor() {
        var req = GetBanEventsRequest(
            after: cursor,
            first: first
        )
        
        req.update(with: userId)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/moderation/banned/events")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.after, cursor.rawValue),
            .init(.broadcasterId, userId)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetModeratorsRequest() {
        var req = GetModeratorsRequest(userIds: userIds)
        
        req.update(with: userId)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/moderation/moderators")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.userId, userIds[0]),
            .init(.userId, userIds[1]),
            .init(.userId, userIds[2]),
            .init(.broadcasterId, userId)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetModeratorsRequest_withPaginationCursor() {
        var req = GetModeratorsRequest(after: cursor)
        
        req.update(with: userId)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/moderation/moderators")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.after, cursor.rawValue),
            .init(.broadcasterId, userId)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetModeratorEventsRequest() {
        var req = GetModeratorEventsRequest(userIds: userIds)
        
        req.update(with: userId)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/moderation/moderators/events")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.userId, userIds[0]),
            .init(.userId, userIds[1]),
            .init(.userId, userIds[2]),
            .init(.broadcasterId, userId)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetModeratorEventsRequest_withPaginationCursor() {
        var req = GetModeratorEventsRequest(after: cursor)
        
        req.update(with: userId)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/moderation/moderators/events")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.after, cursor.rawValue),
            .init(.broadcasterId, userId)
        ])
        XCTAssertEqual(req.body, nil)
    }
}

class HelixAPISearchRequestTests: XCTestCase {
    func test_SearchCategoriesRequest() {
        let query = "Some query"
        
        let req = SearchCategoriesRequest(
            query: query,
            after: cursor,
            first: first
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/search/categories")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.query, query),
            .init(.after, cursor.rawValue),
            .init(.first, first.description)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_SearchChannelsRequest() {
        let query = "Some query"
        let liveOnly = true
        
        let req = SearchChannelsRequest(
            query: query,
            liveOnly: liveOnly,
            after: cursor,
            first: first
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/search/channels")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.query, query),
            .init(.liveOnly, liveOnly.description),
            .init(.after, cursor.rawValue),
            .init(.first, first.description)
        ])
        XCTAssertEqual(req.body, nil)
    }
}

class HelixAPIStreamRequestTests: XCTestCase {
    func test_GetStreamKeyRequest() {
        var req = GetStreamKeyRequest()
        
        req.update(with: userId)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/streams/key")
        XCTAssertEqual(req.equatableQueryParams, [.init(.broadcasterId, userId)])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetStreamsRequest() {
        let gameIds = ["GameId1", "GameId2", "GameId3"]
        let userLogins = ["UserLogin1", "UserLogin1", "UserLogin1"]
        let languages = ["SomeLanguage1", "SomeLanguage2", "SomeLanguage3"]
        
        let req = GetStreamsRequest(
            gameIds: gameIds,
            userIds: userIds,
            userLogins: userLogins,
            languages: languages,
            first: first
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/streams")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.first, first.description),
            .init(.gameId, gameIds[0]),
            .init(.gameId, gameIds[1]),
            .init(.gameId, gameIds[2]),
            .init(.userId, userIds[0]),
            .init(.userId, userIds[1]),
            .init(.userId, userIds[2]),
            .init(.userLogin, userLogins[0]),
            .init(.userLogin, userLogins[1]),
            .init(.userLogin, userLogins[2]),
            .init(.language, languages[0]),
            .init(.language, languages[1]),
            .init(.language, languages[2])
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetStreamsRequest_withPaginationCursor() {
        let req = GetStreamsRequest(
            cursor: backwardCursor,
            first: first
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/streams")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.before, backwardCursor.backwardRawValue!),
            .init(.first, first.description)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_CreateStreamMarkerRequest() {
        let description = "SomeDescription"
        
        let req = CreateStreamMarkerRequest(
            userId: userId,
            description: description
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .post)
        XCTAssertEqual(req.path, "/streams/markers")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, .init(
            userId: userId,
            description: description
        ))
    }
    
    func test_GetStreamMarkersRequest_forASpecificUser() {
        let req = GetStreamMarkersRequest(
            userId: userId,
            first: first
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/streams/markers")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.userId, userId),
            .init(.first, first.description)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetStreamMarkersRequest_forASpecificVideo() {
        let videoId = "SomeVideoId"
        
        let req = GetStreamMarkersRequest(
            videoId: videoId,
            first: first
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/streams/markers")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.videoId, videoId),
            .init(.first, first.description)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetStreamMarkersRequest_withAPaginationCursor() {
        let req = GetStreamMarkersRequest(
            cursor: backwardCursor,
            first: first
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/streams/markers")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.before, backwardCursor.backwardRawValue!),
            .init(.first, first.description)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetChannelInformationRequest() {
        let req = GetChannelInformationRequest(broadcasterId: userId)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/channels")
        XCTAssertEqual(req.equatableQueryParams, [.init(.broadcasterId, userId)])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_ModifyChannelInformationRequest() {
        let broadcasterLanguage = "SomeLanguage"
        let title = "SomeTitle"
        
        let req = ModifyChannelInformationRequest(
            broadcasterId: userId,
            gameId: gameId,
            broadcasterLanguage: broadcasterLanguage,
            title: title
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .patch)
        XCTAssertEqual(req.path, "/channels")
        XCTAssertEqual(req.equatableQueryParams, [.init(.broadcasterId, userId)])
        XCTAssertEqual(req.body, .init(
            gameId: gameId,
            broadcasterLanguage: broadcasterLanguage,
            title: title
        ))
    }
}

class HelixAPISubscriptionRequestTests: XCTestCase {
    func test_GetBroadcasterSubscriptionsRequest() {
        var req = GetBroadcasterSubscriptionsRequest(userIds: userIds)
        
        req.update(with: userId)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/subscriptions")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.userId, userIds[0]),
            .init(.userId, userIds[1]),
            .init(.userId, userIds[2]),
            .init(.broadcasterId, userId)
        ])
        XCTAssertEqual(req.body, nil)
    }
}

class HelixAPITagRequestTests: XCTestCase {
    let tagIds = ["SomeTagId1", "SomeTagId2", "SomeTagId3"]
    
    func test_GetAllStreamTagsRequest() {
        let req = GetAllStreamTagsRequest(
            tagIds: tagIds,
            first: first
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/tags/streams")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.first, first.description),
            .init(.tagId, tagIds[0]),
            .init(.tagId, tagIds[1]),
            .init(.tagId, tagIds[2])
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetAllStreamTagsRequest_withPaginationCursor() {
        let req = GetAllStreamTagsRequest(
            after: cursor,
            first: first
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/tags/streams")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.after, cursor.rawValue),
            .init(.first, first.description)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetStreamTagsRequest() {
        let req = GetStreamTagsRequest(broadcasterId: userId)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/streams/tags")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.broadcasterId, userId)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_ReplaceStreamTagsRequest() {
        let req = ReplaceStreamTagsRequest(
            broadcasterId: userId,
            tagIds: tagIds
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .put)
        XCTAssertEqual(req.path, "/streams/tags")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.broadcasterId, userId)
        ])
        XCTAssertEqual(req.body, .init(tagIds: tagIds))
    }
}

class HelixAPIUserRequestTests: XCTestCase {
    let fromId = "FromUserId"
    let toId = "ToUserId"
    
    func test_GetUserActiveExtensionsRequest() {
        let req = GetUserActiveExtensionsRequest(userId: userId)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/users/extensions/list")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.userId, userId)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetUserActiveExtensionsRequest_responseBody_decodesFromJSON() throws {
        let data = Data("""
        {
            "data": {
                "overlay": {
                    "1": {
                        "active": true,
                        "id": "overlay1",
                        "version": "1.0",
                        "name": "Overlay One"
                    },
                    "2": {
                        "active": true,
                        "id": "overlay2",
                        "version": "2.0",
                        "name": "Overlay Two"
                    }
                },
                "component": {
                    "1": {
                        "active": true,
                        "id": "component1",
                        "version": "3.0",
                        "name": "Component One",
                        "x": 100,
                        "y": 200
                    }
                },
                "mobile": {
                    "1": {
                        "active": false
                    }
                }
            }
        }
        """.utf8)
        
        let expectedResponse: GetUserActiveExtensionsRequest.ResponseBody = .init(extensions: [
            .overlay: [
                .init(
                    isActive: true,
                    information: .init(
                        id: "overlay1",
                        version: "1.0",
                        name: "Overlay One",
                        coordinates: nil
                    )
                ),
                .init(
                    isActive: true,
                    information: .init(
                        id: "overlay2",
                        version: "2.0",
                        name: "Overlay Two",
                        coordinates: nil
                    )
                ),
            ],
            .component: [
                .init(
                    isActive: true,
                    information: .init(
                        id: "component1",
                        version: "3.0",
                        name: "Component One",
                        coordinates: (x: 100, y: 200)
                    )
                )
            ],
            .mobile: [
                .init(isActive: false, information: nil)
            ]
        ])
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let response = try decoder.decode(GetUserActiveExtensionsRequest.ResponseBody.self, from: data)
        
        XCTAssertEqual(response, expectedResponse, "Incorrect response value")
    }
    
    func test_GetUserExtensionsRequest() {
        let req = GetUserExtensionsRequest()
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/users/extensions/list")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetUserFollowsRequest_withFromUser() {
        let req = GetUserFollowsRequest(
            fromId: fromId,
            toId: toId,
            first: first
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/users/follows")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.fromId, fromId),
            .init(.toId, toId),
            .init(.first, first.description)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetUserFollowsRequest_withToUser() {
        let req = GetUserFollowsRequest(
            toId: toId,
            fromId: fromId,
            first: first
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/users/follows")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.fromId, fromId),
            .init(.toId, toId),
            .init(.first, first.description)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetUserFollowsRequest_withPaginationCursor() {
        let req = GetUserFollowsRequest(
            after: cursor,
            first: first
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/users/follows")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.after, cursor.rawValue),
            .init(.first, first.description)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetUsersRequest() {
        let userLogins = ["Login1", "Login2", "Login3"]
        
        let req = GetUsersRequest(
            userIds: userIds,
            logins: userLogins
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/users")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.id, userIds[0]),
            .init(.id, userIds[1]),
            .init(.id, userIds[2]),
            .init(.login, userLogins[0]),
            .init(.login, userLogins[1]),
            .init(.login, userLogins[2])
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_UpdateUserExtensionsRequest() {
        let extensionUpdates: [ExtensionType: [ExtensionUpdate]] = [
            .component: [
                .init(isActive: true, id: "SomeId1", version: "SomeVersion1"),
                .init(isActive: true, id: "SomeId2", version: "SomeVersion2"),
                .init(isActive: true, id: "SomeId3", version: "SomeVersion3")
            ],
            .overlay: [
                .init(isActive: false, id: "SomeId4", version: "SomeVersion1"),
                .init(isActive: false, id: "SomeId5", version: "SomeVersion2"),
                .init(isActive: false, id: "SomeId6", version: "SomeVersion3")
            ],
            .panel: [
                .init(isActive: true, id: "SomeId7", version: "SomeVersion1"),
                .init(isActive: false, id: "SomeId8", version: "SomeVersion2"),
                .init(isActive: true, id: "SomeId9", version: "SomeVersion3")
            ],
            .mobile: [
                .init(isActive: false, id: "SomeId10", version: "SomeVersion1"),
                .init(isActive: true, id: "SomeId11", version: "SomeVersion2"),
                .init(isActive: false, id: "SomeId12", version: "SomeVersion3")
            ]
        ]
        
        let req = UpdateUserExtensionsRequest(extensionUpdates: extensionUpdates)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .put)
        XCTAssertEqual(req.path, "/users/extensions")
        XCTAssertEqual(req.equatableQueryParams, [])
        XCTAssertEqual(req.body, .init(extensionUpdates: extensionUpdates))
    }
    
    func test_UpdateUserExtensionsRequest_requestBody_encodesToJSON() throws {
        let extensionUpdates: [ExtensionType: [ExtensionUpdate]] = [
            .component: [
                .init(isActive: true, id: "SomeId1", version: "SomeVersion1"),
                .init(isActive: true, id: "SomeId2", version: "SomeVersion2"),
                .init(isActive: true, id: "SomeId3", version: "SomeVersion3")
            ],
            .overlay: [
                .init(isActive: false, id: "SomeId4", version: "SomeVersion1"),
                .init(isActive: false, id: "SomeId5", version: "SomeVersion2"),
                .init(isActive: false, id: "SomeId6", version: "SomeVersion3")
            ],
            .panel: [
                .init(isActive: true, id: "SomeId7", version: "SomeVersion1"),
                .init(isActive: false, id: "SomeId8", version: "SomeVersion2"),
                .init(isActive: true, id: "SomeId9", version: "SomeVersion3")
            ],
            .mobile: [
                .init(isActive: false, id: "SomeId10", version: "SomeVersion1"),
                .init(isActive: true, id: "SomeId11", version: "SomeVersion2"),
                .init(isActive: false, id: "SomeId12", version: "SomeVersion3")
            ]
        ]
        
        let requestBody = UpdateUserExtensionsRequest.RequestBody(extensionUpdates: extensionUpdates)
        
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        encoder.outputFormatting = .sortedKeys
        let data = try encoder.encode(requestBody)
        
        let expectedString = """
        {"data":{"component":{"0":{"active":true,"id":"SomeId1","version":"SomeVersion1"},"1":{"active":true,"id":"SomeId2","version":"SomeVersion2"},"2":{"active":true,"id":"SomeId3","version":"SomeVersion3"}},"mobile":{"0":{"active":false,"id":"SomeId10","version":"SomeVersion1"},"1":{"active":true,"id":"SomeId11","version":"SomeVersion2"},"2":{"active":false,"id":"SomeId12","version":"SomeVersion3"}},"overlay":{"0":{"active":false,"id":"SomeId4","version":"SomeVersion1"},"1":{"active":false,"id":"SomeId5","version":"SomeVersion2"},"2":{"active":false,"id":"SomeId6","version":"SomeVersion3"}},"panel":{"0":{"active":true,"id":"SomeId7","version":"SomeVersion1"},"1":{"active":false,"id":"SomeId8","version":"SomeVersion2"},"2":{"active":true,"id":"SomeId9","version":"SomeVersion3"}}}}
        """
        
        XCTAssertEqual(String(data: data, encoding: .utf8), expectedString)
    }
    
    func test_UpdateUserRequest() {
        let description = "SomeDescription"
        
        let req = UpdateUserRequest(description: description)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .put)
        XCTAssertEqual(req.path, "/users")
        XCTAssertEqual(req.equatableQueryParams, [.init(.description, description)])
        XCTAssertEqual(req.body, nil)
    }
}

class HelixAPIVideoRequestTests: XCTestCase {
    func test_GetVideosRequest_forASpecificSetOfVideos() {
        let videoIds = ["SomeVideoId1", "SomeVideoId2", "SomeVideoId3"]
        
        let req = GetVideosRequest(videoIds: videoIds)
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/videos")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.id, videoIds[0]),
            .init(.id, videoIds[1]),
            .init(.id, videoIds[2])
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetVideosRequest_forASpecificUser() {
        let language = "SomeLanguage"
        let period = GetVideosRequest.Period.month
        let sort = GetVideosRequest.Sort.trending
        let type = GetVideosRequest.VideoType.highlight
        
        let req = GetVideosRequest(
            userId: userId,
            language: language,
            period: period,
            sort: sort,
            type: type,
            first: first
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/videos")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.first, first.description),
            .init(.language, language),
            .init(.period, period.rawValue),
            .init(.sort, sort.rawValue),
            .init(.type, type.rawValue),
            .init(.userId, userId)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetVideosRequest_forASpecificGame() {
        let language = "SomeLanguage"
        let period = GetVideosRequest.Period.month
        let sort = GetVideosRequest.Sort.trending
        let type = GetVideosRequest.VideoType.highlight
        
        let req = GetVideosRequest(
            gameId: gameId,
            language: language,
            period: period,
            sort: sort,
            type: type,
            first: first
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/videos")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.first, first.description),
            .init(.gameId, gameId),
            .init(.language, language),
            .init(.period, period.rawValue),
            .init(.sort, sort.rawValue),
            .init(.type, type.rawValue)
        ])
        XCTAssertEqual(req.body, nil)
    }
    
    func test_GetVideosRequest_withAPaginationCursor() {
        let req = GetVideosRequest(
            cursor: backwardCursor,
            first: first
        )
        
        XCTAssertEqual(req.apiVersion, .helix)
        XCTAssertEqual(req.method, .get)
        XCTAssertEqual(req.path, "/videos")
        XCTAssertEqual(req.equatableQueryParams, [
            .init(.before, backwardCursor.backwardRawValue!),
            .init(.first, first.description)
        ])
        XCTAssertEqual(req.body, nil)
    }
}
