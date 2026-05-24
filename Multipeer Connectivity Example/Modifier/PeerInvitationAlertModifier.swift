//
//  PeerInvitationAlertModifier.swift
//  Multipeer Connectivity Example
//
//  Created by 이은지 on 5/21/26.
//

import SwiftUI
import MultipeerConnectivity

struct PeerInvitationAlertModifier: ViewModifier {
    @Binding var selectedPeer: MCPeerID?
    @ObservedObject var manager: MultipeerConnectivityManager

    func body(content: Content) -> some View {
        content
            .alert(
                "초대하시겠습니까?",
                isPresented: Binding(
                    get: { selectedPeer != nil },
                    set: { if !$0 { selectedPeer = nil } }
                )
            ) {
                Button("예") {
                    if let peer = selectedPeer {
                        manager.invite(peer)
                    }
                    selectedPeer = nil
                }

                Button("아니오", role: .cancel) {
                    selectedPeer = nil
                }
            } message: {
                Text("\(selectedPeer?.displayName ?? "") 기기를 초대합니다.")
            }
            .alert(
                "초대를 수락하시겠습니까?",
                isPresented: Binding(
                    get: { manager.incomingInvitationPeer != nil },
                    set: {
                        if !$0, manager.incomingInvitationPeer != nil {
                            manager.respondToInvitation(accept: false)
                        }
                    }
                )
            ) {
                Button("수락") {
                    manager.respondToInvitation(accept: true)
                }

                Button("거절", role: .cancel) {
                    manager.respondToInvitation(accept: false)
                }
            } message: {
                Text("\(manager.incomingInvitationPeer?.displayName ?? "") 기기가 연결을 요청했습니다.")
            }
    }
}

extension View {
    func peerInvitationAlerts(
        selectedPeer: Binding<MCPeerID?>,
        manager: MultipeerConnectivityManager
    ) -> some View {
        self.modifier(
            PeerInvitationAlertModifier(
                selectedPeer: selectedPeer,
                manager: manager
            )
        )
    }
}
