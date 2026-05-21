//
//  MultipeerConnectivity.swift
//  Multipeer Connectivity Example
//
//  Created by 이은지 on 5/19/26.
//

import Foundation
import MultipeerConnectivity
import Combine

class MultipeerConnectivityManager: NSObject, ObservableObject {
    
    @Published var foundPeers: [MCPeerID] = []          // 찾아낸 peer 목록
    @Published var connectedPeers: [MCPeerID] = []      // 연결된 peer 목록
    @Published var incomingInvitationPeer: MCPeerID?    // alert를 띄우기 위한 현재 초대 요청 대상

    private let serviceID = "c3-start"  // 앱 식별자
    
    private var session: MCSession  // 실제 데이터 통신 연결 통로
    private var advertiser: MCNearbyServiceAdvertiser?  // 주변에게 광고 객체
    private var browser: MCNearbyServiceBrowser?    // 주변 기기 탐색 객체

    private var invitationHandler: ((Bool, MCSession?) -> Void)?    // 초대 수락/거절 결과를 시스템에 전달하는 콜백
    
    private(set) var myPeerID: MCPeerID
    
    override init() {
        myPeerID = MCPeerID(displayName: UIDevice.current.name)
        
        // session 초기화
        self.session = MCSession(
            peer: myPeerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )
        
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
    
    deinit {
        stopBrowsing()
        stopHosting()
        session.disconnect()
    }
    
    // 주변 기기에게 내 기기를 광고(호스팅) 시작
    func startHosting() {
        advertiser = MCNearbyServiceAdvertiser(
            peer: myPeerID,
            discoveryInfo: nil,
            serviceType: serviceID
        )
        advertiser?.delegate = self
        advertiser?.startAdvertisingPeer()
    }
    
    // 주변 기기 광고(호스팅) 중지
    func stopHosting() {
        advertiser?.stopAdvertisingPeer()
        advertiser = nil
    }
    
    // 주변 기기 검색 시작
    func startBrowsing() {
        browser?.startBrowsingForPeers()
    }
    
    // 주변 기기 검색 중지
    func stopBrowsing() {
        browser?.stopBrowsingForPeers()
    }
    
    // 특정 peer에게 연결 초대 전송
    func invite(_ peerID: MCPeerID) {
        print("\(peerID.displayName)에게 초대 전송")
        browser?.invitePeer(peerID, to: session, withContext: nil, timeout: 10)
    }
    
    // 초대 요청에 대해 수락 또는 거절 응답 처리
    func respondToInvitation(accept: Bool) {
        invitationHandler?(accept, accept ? session : nil)
        invitationHandler = nil
        incomingInvitationPeer = nil
    }
}

// MARK: - MCSessionDelegate

extension MultipeerConnectivityManager: MCSessionDelegate {
    
    // 연결 상태 변경 감지
    func session(
        _ session: MCSession,
        peer peerID: MCPeerID,
        didChange state: MCSessionState
    ) {
        DispatchQueue.main.async {
            switch state {
            case .connecting:
                #if DEBUG
                print("\(peerID.displayName) 연결 중...")
                #endif
                
            case .connected:
                if !self.connectedPeers.contains(peerID) {
                    self.connectedPeers.append(peerID)
                }
                self.foundPeers.removeAll { $0 == peerID }
                
                #if DEBUG
                print("\(peerID.displayName) 연결 성공!")
                #endif
                
            case .notConnected:
                self.connectedPeers.removeAll { $0 == peerID }
                
                #if DEBUG
                print("\(peerID.displayName) 연결 해제")
                #endif
                
            @unknown default:
                break
            }
        }
    }
    
    // 일반 데이터 수신
    /// 상대방이 보낸 일반 데이터가 도착됐을 때 호출
    /// 텍스트 메시지, Json, 게임 상태 좌표 등 거의 데부분의 통신 데이터는 이 메서드로 들어옴
    func session(
        _ session: MCSession,
        didReceive data: Data,
        fromPeer peerID: MCPeerID
    ) {
        if let text = String(data: data, encoding: .utf8) {
            print("수신된 메시지: \(text)")
        }
    }
    
    // 실시간 스트림 수신
    /// 실시간 음성 채팅, 연속적인 비디오 스트림 등 지속적으로 흐르는 스트림 데이터가 들어올 때 호출
    /// 일반적인 채팅 앱에서는 사용하지 않음
    func session(
        _ session: MCSession,
        didReceive stream: InputStream,
        withName streamName: String,
        fromPeer peerID: MCPeerID
    ) { }
    
    // 파일 수신 시작
    /// 상대방이 파일 전송을 시작했을 때 호출
    /// progress를 활용해 진행률 추적 가능
    func session(
        _ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        with progress: Progress
    ) { }

    // 완료 감지
    /// 파일 전송이 완료됐을 때 호출됨
    /// 성공 시 localURL에 임시 저장된 파일 위치가 들어오고, 실패 시 error 반환
    func session(
        _ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL?,
        withError error: Error?
    ) { }
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

// MARK: - MCNearbyServiceAdvertiserDelegate

extension MultipeerConnectivityManager: MCNearbyServiceAdvertiserDelegate {
    
    // 근처에 있는 peer로부터 세션 참여 초대를 받았을 때
    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        DispatchQueue.main.async {
            self.incomingInvitationPeer = peerID
            self.invitationHandler = invitationHandler
        }
    }

    // 광고가 실패될 때
    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didNotStartAdvertisingPeer error: any Error
    ) {
        print("광고 시작 실패: \(error.localizedDescription)")
    }
}

// MARK: - MCNearbyServiceBrowserDelegate

extension MultipeerConnectivityManager: MCNearbyServiceBrowserDelegate {
    
    // 근처에 peer가 발견될 때
    func browser(
        _ browser: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String : String]?
    ) {
        DispatchQueue.main.async {
            guard !self.foundPeers.contains(peerID), !self.connectedPeers.contains(peerID) else { return }
            self.foundPeers.append(peerID)
        }
    }
    
    // 근처 peer와의 연결이 끊어졌을 때
    func browser(
        _ browser: MCNearbyServiceBrowser,
        lostPeer peerID: MCPeerID
    ) {
        DispatchQueue.main.async {
            self.foundPeers.removeAll { $0 == peerID }
        }
    }
}
