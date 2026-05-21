//
//  ContentView.swift
//  Multipeer Connectivity Example
//
//  Created by 이은지 on 5/18/26.
//

import SwiftUI
import MultipeerConnectivity

struct ContentView: View {
    @State private var selectedPeer: MCPeerID?
    @StateObject private var multipeerConnectivityManager = MultipeerConnectivityManager()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("주변 기기")
                .font(.title3)
                .fontWeight(.bold)
                .padding(16)
            
            if multipeerConnectivityManager.foundPeers.isEmpty {
                ContentUnavailableView(
                    "주변 기기가 없습니다.",
                    systemImage: "wifi.slash",
                    description: Text("같은 네트워크 또는 근처에서 이 앱을 실행 중인 기기를 찾지 못했습니다.")
                )
            } else {
                List(multipeerConnectivityManager.foundPeers, id: \.self) { peer in
                    
                    Button {
                        selectedPeer = peer
                    } label: {
                        HStack {
                            Image(systemName: "iphone")
                            Text(peer.displayName)
                        }
                    }
                }
            }
            
            Text("초대 완료된 기기")
                .font(.title3)
                .fontWeight(.bold)
                .padding(16)

            if multipeerConnectivityManager.connectedPeers.isEmpty {
                ContentUnavailableView(
                    "연결된 기기가 없습니다.",
                    systemImage: "person.crop.circle.badge.questionmark",
                    description: Text("초대를 수락한 기기가 여기 표시됩니다.")
                )
            } else {
                List(multipeerConnectivityManager.connectedPeers, id: \.self) { peer in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                        Text(peer.displayName)
                    }
                }
            }
        }
        .peerInvitationAlerts(
            selectedPeer: $selectedPeer,
            manager: multipeerConnectivityManager
        )
        .onAppear {
            multipeerConnectivityManager.startHosting()
            multipeerConnectivityManager.startBrowsing()
        }
        .onDisappear {
            multipeerConnectivityManager.stopHosting()
            multipeerConnectivityManager.stopBrowsing()
        }
    }
}
