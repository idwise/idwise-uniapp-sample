//
//  IDWiseSDKBridge.swift
//  IDWiseUniPlugin
//
//  Bridge file to expose IDWiseSDK Swift framework to Objective-C
//

import Foundation
import IDWiseSDK

// Callback typealias to match Objective-C
public typealias CallbackType = ([String: Any], Bool) -> Void

// Swift wrapper class to bridge IDWiseSDK to Objective-C
@objc public class IDWiseSDKBridge: NSObject, IDWiseJourneyCallbacks {

    private var callback: CallbackType?

    @objc public init(callback: @escaping CallbackType) {
        self.callback = callback
        super.init()
    }

    // MARK: - IDWiseJourneyCallbacks

    public func onJourneyStarted(journeyStartedInfo: JourneyStartedInfo) {
        callback?([
            "event": "onJourneyStarted",
            "data": [
                "journeyId": journeyStartedInfo.journeyId
            ]
        ], true)
    }

    public func onJourneyResumed(journeyResumedInfo: JourneyResumedInfo) {
        callback?([
            "event": "onJourneyResumed",
            "data": [
                "journeyId": journeyResumedInfo.journeyId
            ]
        ], true)
    }

    public func onJourneyCompleted(journeyCompletedInfo: JourneyCompletedInfo) {
        callback?([
            "event": "onJourneyCompleted",
            "data": [
                "journeyId": journeyCompletedInfo.journeyId,
                "isSuccessful": journeyCompletedInfo.isSuccessful
            ]
        ], true)
    }

    public func onJourneyCancelled(journeyCancelledInfo: JourneyCancelledInfo) {
        var reason = "user_cancelled"
        if journeyCancelledInfo.cancellationReason == .tokenExpired {
            reason = "token_expired"
        }

        callback?([
            "event": "onJourneyCancelled",
            "data": [
                "journeyId": journeyCancelledInfo.journeyId,
                "cancellationReason": reason
            ]
        ], true)
    }

    public func onJourneyBlocked(journeyBlockedInfo: JourneyBlockedInfo) {
        var data: [String: Any] = [
            "journeyId": journeyBlockedInfo.journeyId
        ]

        if let blockedTransaction = journeyBlockedInfo.blockedTransaction {
            var blockedTxn: [String: Any] = [:]

            if let canRetry = blockedTransaction.canRetry {
                blockedTxn["canRetry"] = canRetry
            }

            if let blockReasonMessage = blockedTransaction.blockReasonMessage {
                blockedTxn["blockReasonMessage"] = blockReasonMessage
            }

            if let allBlockReasons = blockedTransaction.allBlockReasons {
                let reasons = allBlockReasons.compactMap { reason -> [String: String]? in
                    guard let code = reason.blockReasonCode else { return nil }
                    return ["blockReasonCode": code]
                }
                blockedTxn["allBlockReasons"] = reasons
            }

            data["blockedTransaction"] = blockedTxn
        }

        callback?([
            "event": "onJourneyBlocked",
            "data": data
        ], true)
    }

    public func onError(error: IDWiseError) {
        callback?([
            "event": "onError",
            "data": [
                "code": error.code,
                "message": error.message ,
                "requestId": error.requestId
            ]
        ], true)
    }
}

// Wrapper functions to expose IDWise SDK to Objective-C
@objc public class IDWiseWrapper: NSObject {

    @objc public static func initialize(clientKey: String,
                                       theme: String,
                                       completion: @escaping ([String: Any]) -> Void) {
        var idwiseTheme: IDWiseTheme = .systemDefault
        switch theme {
        case "light":
            idwiseTheme = .light
        case "dark":
            idwiseTheme = .dark
        default:
            idwiseTheme = .systemDefault
        }

        IDWise.initialize(clientKey: clientKey, theme: idwiseTheme, onSuccess: {
            completion(["success": true])
        }, onError: { err in
            if let error = err {
                completion([
                    "success": false,
                    "error": [
                        "code": error.code ,
                        "message": error.message,
                        "requestId": error.requestId
                    ]
                ])
            }
        })
    }

    @objc public static func startJourney(flowId: String,
                                         referenceNumber: String,
                                         locale: String,
                                         applicantDetails: [String: String]?,
                                         callbacks: IDWiseSDKBridge) {
        IDWise.startJourney(flowId: flowId,
                           referenceNumber: referenceNumber,
                           locale: locale,
                           applicantDetails: applicantDetails,
                           journeyCallbacks: callbacks)
    }

    @objc public static func resumeJourney(flowId: String,
                                          journeyId: String,
                                          locale: String,
                                          callbacks: IDWiseSDKBridge) {
        IDWise.resumeJourney(flowId: flowId,
                            journeyId: journeyId,
                            locale: locale,
                            journeyCallbacks: callbacks)
    }

    @objc public static func isDeviceBlocked() -> Bool {
        return IDWise.isDeviceBlocked()
    }
}
