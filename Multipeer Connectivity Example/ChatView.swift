//
//  ChatView.swift
//  Multipeer Connectivity Example
//
//  Created by 이은지 on 5/21/26.
//

import SwiftUI
import MultipeerConnectivity

struct ChatView: View {
    @ObservedObject var multipeerConnectivityManager: MultipeerConnectivityManager
    @State private var message = ""

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(multipeerConnectivityManager.receivedMessages, id: \.self) { message in
                        Text(message)
                            .padding(12)
                            .background(Color.gray.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 16))
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
                    multipeerConnectivityManager.sendMessage(message)
                    message = ""
                } label: {
                    Image(systemName: "paperplane.fill")
                        .font(.title3)
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
                .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .navigationTitle(
            multipeerConnectivityManager.connectedPeers.count == 1
            ? multipeerConnectivityManager.connectedPeers.first?.displayName ?? "채팅"
            : "\(multipeerConnectivityManager.connectedPeers.count)명과 채팅"
        )
        .navigationBarTitleDisplayMode(.inline)

        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)

        .toolbarColorScheme(.light, for: .navigationBar)
    }
}

#Preview {
    NavigationStack {
        let manager = MultipeerConnectivityManager()
        manager.connectedPeers = [
            MCPeerID(displayName: "은지의 iPhone")
        ]
        manager.receivedMessages = [
            "나: 안녕하세요",
            "은지의 iPhone: 반갑습니다!",
            "나: 연결 잘 되나요?"
        ]
        
        return ChatView(multipeerConnectivityManager: manager)
    }
}
