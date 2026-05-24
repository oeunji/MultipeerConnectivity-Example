//
//  View+Extension.swift
//  Multipeer Connectivity Example
//
//  Created by 이은지 on 5/24/26.
//

import SwiftUI

extension View {
    // 현재 화면에서 키보드를 내립니다.
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
