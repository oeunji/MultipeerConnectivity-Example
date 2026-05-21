//
//  ContentView.swift
//  Multipeer Connectivity Example
//
//  Created by 이은지 on 5/18/26.
//

import SwiftUI
import MultipeerConnectivity

struct ContentView: View {
    @ObservedObject var multipeerConnectivityManager = MultipeerConnectivityManager()
    
    @Binding var selectedPeer: MCPeerID?
    @Binding var receivedPeers: [String]
    
    var body: some View {
        Text("주변 기기")
            .font(.title3)
            .fontWeight(.bold)
        
    }
}
