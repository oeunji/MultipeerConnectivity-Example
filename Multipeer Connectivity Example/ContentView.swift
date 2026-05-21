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
        }
        .alert(
            "초대하시겠습니까?",
            isPresented: Binding(
                get: { selectedPeer != nil },
                set: { if !$0 { selectedPeer = nil } }
            )
        ) {
            Button("예") {
                if let peer = selectedPeer {
                    multipeerConnectivityManager.invite(peer)
                }
            }
            
            Button("아니오", role: .cancel) {
                selectedPeer = nil
            }
        } message: {
            Text("\(selectedPeer?.displayName ?? "") 기기를 초대합니다.")
        }
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
