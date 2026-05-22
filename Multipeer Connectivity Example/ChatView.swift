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
        .navigationTitle("채팅")
        .navigationBarTitleDisplayMode(.inline)
    }
}
