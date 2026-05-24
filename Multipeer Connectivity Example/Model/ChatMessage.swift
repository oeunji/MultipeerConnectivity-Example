//
//  ChatMessage.swift
//  Multipeer Connectivity Example
//
//  Created by 이은지 on 5/24/26.
//

import Foundation

struct ChatMessage: Identifiable {
    let id = UUID()
    let text: String
    let isMine: Bool
    let senderPeerID: String
}
