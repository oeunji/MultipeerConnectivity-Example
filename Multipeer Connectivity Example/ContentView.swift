//
//  ContentView.swift
//  Multipeer Connectivity Example
//
//  Created by 이은지 on 5/18/26.
//

import SwiftUI
import MultipeerConnectivity

struct ContentView: View {
    @StateObject private var multipeerConnectivityManager = MultipeerConnectivityManager()
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("주변 기기")
                .font(.title3)
                .fontWeight(.bold)
            
            List(multipeerConnectivityManager.foundPeers, id: \.self) { peer in
                Button {
                    multipeerConnectivityManager.invite(peer)
                } label: {
                    HStack {
                        Image(systemName: "iphone")
                        Text(peer.displayName)
                    }
                }
            }
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
