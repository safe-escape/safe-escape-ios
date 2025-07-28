//
//  CrowdedViewModel.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/28/25.
//

import Foundation
import Combine
import SwiftUI

// 혼잡도 뷰모델
class CrowdedViewModel: ObservableObject {
    // 주소 검색 뷰모델
    var inputAddressViewModel = InputAddressViewModel()

    // 혼잡도 예상 default 표시 텍스트
    @Published var defaultExpectedText: [String]?
    
    // 날짜 선택 가능한 최소/최대 날짜(오늘 ~ 오늘 + 2일)
    let minDate = Date()
    let maxDate = Calendar.current.date(byAdding: .day, value: 2, to: Date())!
    // 선택한 날짜 표시 텍스트
    @Published var expectedDate: String = "날짜"
    // 선택한 날짜(Date)
    @Published var selectedExpectedDate = Date()
    // Date Picker show/hide
    @Published var showDatePicker: Bool = false
    
    // 혼잡도 예상 날짜/위치 / 예상 혼잡도
    var expectedCrowded: (address: String, date: Date)?
    @Published var expectedCrowdedLevel: CrowdedLevel?
    // 혼잡도 예상 결과 존재 여부
    var hasExpectedCrowded: Bool {
        expectedCrowded != nil && expectedCrowdedLevel != nil
    }
    
    // 혼잡도 예상 버튼 enable/disable
    @Published var enableExpectButton: Bool = false
    // 혼잡도 예상 loading 여부
    @Published var expectLoading: Bool = false
    
    // 내 주변 혼잡한 지역 loading 여부
    @Published var nearByLoading: Bool = false
    // 내 주변 혼잡한 지역 리스트
    @Published var nearByList: [CrowdedNearBy] = []
    
    private var cancellables = Set<AnyCancellable>()
    init() {
        // 주소 검색 input 변경 시, 선택한 주소 초기화
        inputAddressViewModel.$textInputAddress
            .sink { [weak self] input in
                guard input != self?.inputAddressViewModel.selectedAddress?.road else {
                    return
                }
                
                self?.inputAddressViewModel.selectedAddress = nil
            }
            .store(in: &cancellables)
        
        // 주소 검색 선택한 주소 변경 시, 혼잡도 예상 버튼 enable 여부 체크
        inputAddressViewModel.$selectedAddress
            .sink { [weak self] address in
                self?.enableExpectButton = (address != nil) && (!(self?.expectedDate.contains("날짜") ?? true))
            }
            .store(in: &cancellables)
    }
    
    // 뷰 데이터 초기화
    func reset() {
        nearByList = []
        
        expectedCrowded = nil
        expectedCrowdedLevel = nil
        
        inputAddressViewModel.reset()
        
        expectedDate = "날짜"
        selectedExpectedDate = Date()
    }
    
    // 혼잡도 에상 default text 및 내 주변 혼잡한 지역 조회
    func requestData() {
        reset()
        
        nearByLoading = true
        Task {
            let nearByList = try await CrowdedUsecase.shared.getCrowdedNearByList()
            
            await MainActor.run {
                // TODO: 혼잡도 예상 Default Text API에서 가져오는 것으로 변경 필요
                defaultExpectedText = ["💬 일요일엔 ", "홍대입구", "가 가장 혼잡해요 !"]
                self.nearByList = nearByList
                nearByLoading = false
            }
        }
    }
    
    // 혼잡도 예상 날짜 선택 시, 선택한 날짜 텍스트 포맷팅 및 혼잡도 예상 버튼 enable 여부 체크
    func changeDate() {
        expectedDate = selectedExpectedDate.format()
        showDatePicker = false
        
        enableExpectButton = (inputAddressViewModel.selectedAddress != nil)
    }
    
    // 혼잡도 예상 조회
    func expectCrowded() {
        // TODO: 에러 처리
        // 주소 validation 실패 시 return
        guard let address = inputAddressViewModel.selectedAddress, let coordinate = address.coordinate else {
            return
        }
        
        // 혼잡도 예상 조회
        expectedCrowdedLevel = nil
        expectLoading = true
        Task {
            let crowdedLevel = try await CrowdedUsecase.shared.expectCrowded(coordinate, selectedExpectedDate)
            
            await MainActor.run {
                expectedCrowded = (address.road, selectedExpectedDate)
                expectedCrowdedLevel = crowdedLevel
                expectLoading = false
            }
        }
    }
    
    // 혼잡도 예상 -> 혼잡도 텍스트
    func getCrowdedLevelText(_ level: CrowdedLevel) -> String {
        switch level {
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
    
    // 혼잡도 예상 -> 혼잡도 텍스트 컬러
    func getCrowdedLevelColor(_ level: CrowdedLevel) -> Color {
        switch level {
        case .free:
            return Color(hex: "#2BBE37")!
        case .normal:
            return Color(hex: "#FBB828")!
        case .crowded:
            return Color(hex: "#ff7139")!
        case .veryCrowded:
            return .red
        }
    }
    
    // 혼잡도 예상 -> 혼잡도 뒤 텍스트
    func getCrowdedLevelTextMarker(_ level: CrowdedLevel) -> String {
        switch level {
        case .free:
            return "로울"
        case .normal:
            return "일"
        case .crowded, .veryCrowded:
            return "할"
        }
    }
    
    // 내 주변 혼잡한 지역 -> 혼잡도 텍스트
    func getCrowdedLevelText(_ data: CrowdedNearBy?) -> String {
        guard let data else {
            return ""
        }
        
        switch data.crowded.level {
        case .free:
            return "여유로워요"
        case .normal:
            return "보통이에요"
        case .crowded:
            return "혼잡해요"
        case .veryCrowded:
            return "굉장히 혼잡해요"
        }
    }
    
}
