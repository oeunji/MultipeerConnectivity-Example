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
    
    @State private var message = ""

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(connectedPeers, id: \.self) { peer in
                        HStack {
                            Image(systemName: "message.fill")
                                .foregroundStyle(.blue)
                            
                            VStack(alignment: .leading) {
                                Text(peer.displayName)
                                    .font(.headline)
                                
                                Text("대화 내용")
                                    .padding(12)
                                    .background(Color.gray.opacity(0.15))
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            
            Divider()
            
            HStack(spacing: 12) {
                TextField("메시지 입력", text: $message)
                    .padding(12)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
                
                Button {
                    print(message)
                    message = ""
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .navigationTitle("채팅")
        .navigationBarTitleDisplayMode(.inline)
    }
}
