# Multipeer Connectivity Example

`MultipeerConnectivity` 프레임워크를 사용해 주변 iOS 기기를 탐색하고, 초대 후 연결해 간단한 텍스트 채팅을 주고받는 SwiftUI 예제 앱입니다.

## 개요

- 주변 기기 검색
- 기기 초대 및 수락/거절 처리
- 연결된 기기 목록 표시
- 연결된 피어들과 1:1 또는 다대다 텍스트 메시지 전송

앱은 `MCNearbyServiceAdvertiser`, `MCNearbyServiceBrowser`, `MCSession`을 직접 사용해 멀티피어 연결 흐름을 구현합니다.

## 기술 스택

- SwiftUI
- MultipeerConnectivity
- Combine

## 동작 방식

1. 앱 실행 시 현재 기기는 주변에 자신을 광고하고, 동시에 다른 기기를 탐색합니다.
2. 발견된 기기 목록에서 상대를 선택하면 초대 알림이 표시됩니다.
3. 상대 기기가 초대를 수락하면 연결된 기기 목록으로 이동합니다.
4. 연결이 성립된 뒤 채팅 화면에서 메시지를 전송하면 연결된 모든 피어에게 브로드캐스트됩니다.

## 프로젝트 구조

```text
Multipeer Connectivity Example
├── Application
│   ├── Multipeer_Connectivity_ExampleApp.swift
│   └── Multipeer-Connectivity-Example-Info.plist
├── Global
│   ├── Extension
│   │   └── View+Extension.swift
│   └── Modifier
│       └── PeerInvitationAlertModifier.swift
├── Manager
│   └── MultipeerConnectivityManager.swift
├── Model
│   └── ChatMessage.swift
├── Resource
│   └── Assets.xcassets
└── View
    ├── ChatView.swift
    └── MultipeerConnectivityView.swift
```

## 주요 구현 포인트

### `MultipeerConnectivityManager`

- 내 기기를 `MCPeerID(displayName: UIDevice.current.name)`으로 식별
- 서비스 타입은 `c3-start`
- 세션 암호화는 `.required`
- 검색된 기기(`foundPeers`), 연결된 기기(`connectedPeers`), 수신 메시지(`receivedMessages`)를 `@Published`로 관리

### 화면 구성

- `MultipeerConnectivityView`
  - 주변 기기 목록
  - 연결된 기기 목록
  - 채팅 화면 이동
- `ChatView`
  - 송수신 메시지 표시
  - 연결된 모든 피어에게 메시지 전송
- `PeerInvitationAlertModifier`
  - 초대 확인 알림
  - 수신 초대 수락/거절 알림

## 권한 및 설정

현재 프로젝트에는 로컬 네트워크 사용을 위한 설정이 포함되어 있습니다.

- `NSLocalNetworkUsageDescription`
- `NSBonjourServices`: `_c3-start._tcp`

처음 실행 시 로컬 네트워크 권한을 허용해야 주변 기기 검색과 연결이 정상 동작합니다.

## 실행 방법

### 요구 사항

- Xcode
- iOS 기기 2대 이상 권장
- 같은 네트워크 환경 또는 근거리 무선 통신이 가능한 상태

### 실행 절차

1. Xcode에서 `Multipeer Connectivity Example.xcodeproj`를 엽니다.
2. 두 대 이상의 실제 iPhone에서 앱을 실행합니다.
3. 각 기기에서 로컬 네트워크 권한을 허용합니다.
4. 한 기기에서 주변 기기를 선택해 초대합니다.
5. 상대 기기에서 초대를 수락합니다.
6. 연결 후 `채팅하러 가기` 버튼으로 이동해 메시지를 주고받습니다.

## 확인할 점

- 시뮬레이터보다 실제 기기 테스트가 적합합니다.
- 메시지는 현재 문자열 텍스트만 전송합니다.
- 파일 전송, 스트림 수신 관련 delegate 메서드는 비어 있으며 확장 포인트로 남아 있습니다.
- 테스트 타깃은 생성되어 있지만 현재 저장소에는 테스트 코드가 포함되어 있지 않습니다.

## 개선 아이디어

- 연결 상태 배지 및 오류 표시 강화
- 메시지 자동 스크롤
- 파일 전송 및 이미지 공유
- 연결 끊김 재시도 처리
- 닉네임 사용자 지정

