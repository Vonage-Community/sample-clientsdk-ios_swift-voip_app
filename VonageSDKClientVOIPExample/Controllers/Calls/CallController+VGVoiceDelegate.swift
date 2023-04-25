//
//  CallController+VGVoiceDelegate.swift
//  VonageSDKClientVOIPExample
//
//  Created by Ashley Arthur on 12/02/2023.
//

import Foundation
import VonageClientSDKVoice
import CallKit

typealias CallUpdate = (call:UUID, leg:UUID, status:String)

// Consts
let VonageLegStatusRinging = "ringing"
let VonageLegStatusAnswered = "answered"
let VonageLegStatusCompleted = "completed"
let LocalComplete = "LocalComplete"

extension VonageCallController: VGVoiceClientDelegate {
    
    // MARK: VGVoiceClientDelegate Sessions

    func clientWillReconnect(_ client: VGBaseClient) {
        vonageWillReconnect.send(())
    }
    
    func clientDidReconnect(_ client: VGBaseClient) {
        vonageDidReconnect.send(())
    }
    
    func client(_ client: VGBaseClient, didReceiveSessionErrorWith reason: VGSessionErrorReason) {
        vonageSessionError.send(reason)
    }
    
    // MARK: VGVoiceClientDelegate Invites
    
    func voiceClient(_ client: VGVoiceClient, didReceiveInviteForCall callId: String, from caller: String, with type: VGVoiceChannelType) {
        let uuid = UUID(uuidString: callId)!
        self.vonageCalls.send(Call.inbound(id: uuid, from: caller, status: .ringing))
    }
    
    func voiceClient(_ client: VGVoiceClient, didReceiveInviteCancelForCall callId: VGCallId, with reason: VGVoiceInviteCancelReasonType) {
        let uuid = UUID(uuidString: callId)!
        var cxreason: CXCallEndedReason = .failed

        switch (reason){
        case .remoteTimeout: cxreason = .unanswered
        case .rejectedElsewhere: cxreason = .rejectedElsewhere
        case .answeredElsewhere: cxreason = .answeredElsewhere
        case .remoteCancel: cxreason = .remoteEnded
        @unknown default:
            fatalError()
        }
        self.vonageCallUpdates.send((uuid, CallStatus.completed(remote: true, reason: cxreason)))
    }
    
    
    // MARK: VGVoiceClientDelegate LegStatus
    
    func voiceClient(_ client: VGVoiceClient, didReceiveLegStatusUpdateForCall callId: String, withLegId legId: String, andStatus status: VGLegStatus) {
        if (status == .answered ) {
            let uuid = UUID(uuidString: callId)!
            vonageCallUpdates.send((uuid, CallStatus.answered))
        }
    }
    
    func voiceClient(_ client: VGVoiceClient, didReceiveHangupForCall callId: String, withQuality callQuality: VGRTCQuality, isRemote:Bool) {
        let uuid = UUID(uuidString: callId)!
        if (isRemote == true) {
            vonageCallUpdates.send((uuid, CallStatus.completed(remote: true, reason: .remoteEnded))) 
        }
        else {
            vonageCallUpdates.send((uuid, CallStatus.completed(remote: false, reason: nil)))
        }
    }
}
