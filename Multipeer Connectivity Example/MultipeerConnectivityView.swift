//
//  MultipeerConnectivityView.swift
//  Multipeer Connectivity Example
//
//  Created by 이은지 on 5/18/26.
//

import SwiftUI
import MultipeerConnectivity

struct MultipeerConnectivityView: View {
    @State private var selectedPeer: MCPeerID?
    @State private var isShowingChatView = false
    @StateObject private var multipeerConnectivityManager = MultipeerConnectivityManager()
    
    var body: some View {
        NavigationStack {
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

                HStack {
                    Spacer()

                    Button {
                        isShowingChatView = true
                    } label: {
                        Text("채팅하러 가기")
                            .fontWeight(.semibold)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                multipeerConnectivityManager.connectedPeers.isEmpty
                                ? Color.gray.opacity(0.3)
                                : Color.blue
                            )
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                    .disabled(multipeerConnectivityManager.connectedPeers.isEmpty)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
                }
            }
            .navigationDestination(isPresented: $isShowingChatView) {
                ChatView(connectedPeers: multipeerConnectivityManager.connectedPeers)
            }
            .peerInvitationAlerts(
                selectedPeer: $selectedPeer,
                manager: multipeerConnectivityManager
            )
            .onAppear {
                multipeerConnectivityManager.startAdvertising()
                multipeerConnectivityManager.startBrowsing()
            }
            .onDisappear {
                multipeerConnectivityManager.stopAdvertising()
                multipeerConnectivityManager.stopBrowsing()
            }
        }
    }
}
