//
//  ChatView.swift
//  Multipeer Connectivity Example
//
//  Created by 이은지 on 5/21/26.
//

import SwiftUI
import MultipeerConnectivity

struct ChatView: View {
    let connectedPeers: [MCPeerID]

    var body: some View {
        List(connectedPeers, id: \.self) { peer in
            HStack {
                Image(systemName: "message.fill")
                    .foregroundStyle(.blue)
                Text("\(peer.displayName) 과의 대화")
            }
        }
        .navigationTitle("채팅")
    }
}
