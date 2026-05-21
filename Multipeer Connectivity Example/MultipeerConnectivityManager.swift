//
//  MultipeerConnectivity.swift
//  Multipeer Connectivity Example
//
//  Created by 이은지 on 5/19/26.
//

import Foundation
import MultipeerConnectivity
import UIKit
import Combine

class MultipeerConnectivityManager: NSObject, ObservableObject {
    
    @Published var foundPeers: [MCPeerID] = []

    private let serviceID = "c3-start"
    
    private var session: MCSession  // 세션 객체
    private var advertiser: MCAdvertiserAssistant?   // Advertiser 객체
    
    private(set) var myPeerID: MCPeerID
    
    private var browser: MCNearbyServiceBrowser?
    
    override init() {
        myPeerID = MCPeerID(displayName: UIDevice.current.name)
        
        // 세션 초기화
        self.session = MCSession(peer: myPeerID,
                                 securityIdentity: nil,
                                 encryptionPreference: .required)
        
        // Browser 초기화
        self.browser = MCNearbyServiceBrowser(
            peer: myPeerID,
            serviceType: serviceID
        )
        
        super.init()
        
        // 세션에서 일어나는 이벤트를 내가 처리하겠다고 delegate
        self.session.delegate = self
        self.browser?.delegate = self
    }
    
    // 초대 수락/거절 팝업창을 띄워주는 비서 객체 생성
    func startHosting() {
        advertiser = MCAdvertiserAssistant(serviceType: serviceID,
                                          discoveryInfo: nil,
                                          session: session)
        advertiser?.delegate = self
        advertiser?.start()  // 홍보 시작
    }
    
    func stopHosting() {
        advertiser?.stop()
        advertiser = nil
    }
    
    // 검색 시작/중지
    func startBrowsing() {
        browser?.startBrowsingForPeers()
    }
    
    func stopBrowsing() {
        browser?.stopBrowsingForPeers()
    }
    
    // 초대 함수 추가
    func invite(_ peerID: MCPeerID) {
        browser?.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    // 우리가 지정한 serviceID를 광고 중인 주변 기기들을 띄워주는 기본 화면 객체 생성
    func makeBrowser() -> MCBrowserViewController {
        let browser = MCBrowserViewController(serviceType: serviceID,
                                              session: session)
        browser.delegate = self // 화면 종료/취소 이벤트를 처리하기 위해 델리게이트 위임
        return browser
    }
}

// MARK: - MCSessionDelegate

extension MultipeerConnectivityManager: MCSessionDelegate {
    
    // 연결 상태 변경 감지
    func session(_ session: MCSession,
                peer peerID: MCPeerID,
                didChange state: MCSessionState) {

        switch state {
        case .connecting:
            print("\(peerID.displayName) 연결 중...")
        case .connected:
            print("\(peerID.displayName) 연결 성공!")
        case .notConnected:
            print("\(peerID.displayName) 연결 해제")
        @unknown default:
            break
        }
    }
    
    // 일반 데이터 수신
    /// 상대방이 보낸 일반 데이터가 도착됐을 때 호출
    /// 텍스트 메시지, Json, 게임 상태 좌표 등 거의 데부분의 통신 데이터는 이 메서드로 들어옴
    func session(_ session: MCSession,
                didReceive data: Data,
                fromPeer peerID: MCPeerID) {
                
        if let text = String(data: data, encoding: .utf8) {
            print("수신된 메시지: \(text)")
        }
    }
    
    // 실시간 스트림 수신
    /// 실시간 음성 채팅, 연속적인 비디오 스트림 등 지속적으로 흐르는 스트림 데이터가 들어올 때 호출
    /// 일반적인 채팅 앱에서는 사용하지 않음
    func session(_ session: MCSession,
                didReceive stream: InputStream,
                withName streamName: String,
                fromPeer peerID: MCPeerID) { }
    
    // 파일 수신 시작
    /// 상대방이 파일 전송을 시작했을 때 호출
    /// progress를 활용해 진행률 추적 가능
    func session(_ session: MCSession,
                didStartReceivingResourceWithName resourceName: String,
                fromPeer peerID: MCPeerID,
                with progress: Progress) { }

    // 완료 감지
    /// 파일 전송이 완료됐을 때 호출됨
    /// 성공 시 localURL에 임시 저장된 파일 위치가 들어오고, 실패 시 error 반환
    func session(_ session: MCSession,
                didFinishReceivingResourceWithName resourceName: String,
                fromPeer peerID: MCPeerID,
                at localURL: URL?,
                withError error: Error?) { }
}

// MARK: - MCBrowserViewControllerDelegate

extension MultipeerConnectivityManager: MCBrowserViewControllerDelegate {
    // 연결 완료 버튼을 눌렀을 때
    /// 기기 선택이 완료되었으므로 화면을 자연스럽게 닫아줌
    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
    }
    
    // 취소 버튼을 눌렀을 때
    /// 사용자가 기기 검색창을 나가고 싶어서 취소 버튼을 눌렀을 때 호출됨
    /// 연결을 하지 않고 화면을 종료
    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
        browserViewController.dismiss(animated: true)
    }
}

// MARK: - MCAdvertiserAssistantDelegate

extension MultipeerConnectivityManager: MCAdvertiserAssistantDelegate {
    
}

// MARK: - MCNearbyServiceBrowserDelegate

extension MultipeerConnectivityManager: MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        DispatchQueue.main.async {
            guard !self.foundPeers.contains(peerID) else { return }
            self.foundPeers.append(peerID)
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.foundPeers.removeAll { $0 == peerID }
        }
    }
}
