//
//  CrowdedViewModel.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/28/25.
//

import Foundation
import Combine
import SwiftUI

class CrowdedViewModel: ObservableObject {
    var inputAddressViewModel = InputAddressViewModel()
    
    @Published var defaultExpectedText: [String]?
    
    @Published var expectedDate: String = "날짜"
    @Published var selectedExpectedDate = Calendar.current.date(byAdding: .day, value: -1, to: Date())! {
        didSet {
            guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date()), selectedExpectedDate > yesterday else {
                return
            }
                
            expectedDate = selectedExpectedDate.format()
            showDatePicker = false
            
            enableExpectButton = (inputAddressViewModel.selectedAddress != nil)
        }
    }
    @Published var showDatePicker: Bool = false
    
    @Published var expectedCrowded: Crowded?
    
    @Published var enableExpectButton: Bool = false
    @Published var expectLoading: Bool = false
    
    @Published var nearByLoading: Bool = false
    @Published var nearByList: [CrowdedNearBy] = []
    
    private var cancellables = Set<AnyCancellable>()
    init() {
        inputAddressViewModel.$textInputAddress
            .sink { input in
                guard input != self.inputAddressViewModel.selectedAddress?.road else {
                    return
                }
                
                self.inputAddressViewModel.selectedAddress = nil
            }
            .store(in: &cancellables)
        
        inputAddressViewModel.$selectedAddress
            .sink { address in
                self.enableExpectButton = (address != nil) && (self.selectedExpectedDate >= Date())
            }
            .store(in: &cancellables)
    }
    
    func requestData() {
        // TODO: API 연동
        defaultExpectedText = ["💬 일요일엔 ", "홍대입구", "가 가장 혼잡해요 !"]
    }
    
    func expectCrowded() {
        // TODO: API 연동
    }
    
    func getCrowdedLevelText(_ data: Crowded) -> String {
        switch data.level {
        case .free:
            return "여유"
        case .normal:
            return "보통"
        case .crowded:
            return "혼잡"
        case .veryCrowded:
            return "굉장히 혼잡"
        }
    }
    
    func getCrowdedLevelColor(_ data: Crowded) -> Color {
        switch data.level {
        case .free:
            return .free
        case .normal:
            return .normal
        case .crowded:
            return .crowded
        case .veryCrowded:
            return .veryCrowded
        }
    }
    
    func getCrowdedLevelTextMarker(_ data: Crowded) -> String {
        switch data.level {
        case .free:
            return "로울"
        case .normal:
            return "일"
        case .crowded, .veryCrowded:
            return "할"
        }
    }
    
    func getCrowdedLevelText(_ data: CrowdedNearBy?) -> String {
        guard let data else {
            return ""
        }
        
        switch data.crowded.level {
        case .free:
            return "여유"
        case .normal:
            return "보통"
        case .crowded:
            return "혼잡"
        case .veryCrowded:
            return "굉장히 혼잡"
        }
    }
    
}
