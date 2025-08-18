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

    // 혼잡도 예상 default 표시 텍스트 (롤링 배너용 여러개)
    @Published var defaultExpectedTexts: [[String]] = []
    @Published var currentDefaultTextIndex: Int = 0
    
    // 날짜 선택 가능한 최소/최대 날짜(오늘 ~ 오늘 + 2일)
    let minDate = Date()
    let maxDate = Calendar.current.date(byAdding: .day, value: 2, to: Date())!
    // 선택한 날짜 표시 텍스트
    @Published var expectedDate: String = "날짜"
    // 선택한 날짜(Date)
    @Published var selectedExpectedDate = Date()
    // Date Picker show/hide
    @Published var showDatePicker: Bool = false
    
    // 선택한 시간
    @Published var selectedHour: Int = Calendar.current.component(.hour, from: Date())
    
    // 선택 가능한 시간 리스트
    var availableHours: [Int] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selectedDay = calendar.startOfDay(for: selectedExpectedDate)
        
        if calendar.isDate(selectedDay, inSameDayAs: today) {
            // 오늘인 경우: 현재 시간 이후만 선택 가능
            let currentHour = calendar.component(.hour, from: Date())
            return Array(currentHour...23)
        } else {
            // 내일 이후인 경우: 모든 시간 선택 가능
            return Array(0...23)
        }
    }
    
    // 혼잡도 예상 날짜/위치 / 예상 혼잡도 / 예상 지역
    var expectedCrowded: (address: String, date: Date)?
    @Published var expectedCrowdedLevel: CrowdedLevel?
    var expectedPredictionLocation: PredictionLocation?
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
        
        // 선택된 날짜가 변경될 때 선택된 시간이 유효한지 체크하고 조정
        $selectedExpectedDate
            .sink { [weak self] newDate in
                guard let self = self else { return }
                
                let calendar = Calendar.current
                let now = Date()
                
                // 선택한 날짜가 오늘이고, 날짜 + 선택한 시간이 현재 시간보다 전이면 현재 시간으로 변경
                if calendar.isDateInToday(newDate) {
                    let selectedDateTime = calendar.date(bySettingHour: self.selectedHour, minute: 0, second: 0, of: newDate) ?? newDate
                    
                    if selectedDateTime < now {
                        self.selectedHour = calendar.component(.hour, from: now)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    // 뷰 데이터 초기화
    func reset() {
        nearByList = []
        
        expectedCrowded = nil
        expectedCrowdedLevel = nil
        expectedPredictionLocation = nil
        
        inputAddressViewModel.reset()
        
        expectedDate = "날짜"
        selectedExpectedDate = Date()
        selectedHour = Calendar.current.component(.hour, from: Date())
    }
    
    // 혼잡도 에상 default text 및 내 주변 혼잡한 지역 조회
    func requestData() {
        reset()
        
        if defaultExpectedTexts.isEmpty {
            getDefaultExpectedText()
        }
        
        nearByLoading = true
        Task {
            async let nearByTask = CrowdedUsecase.shared.getCrowdedNearByList()
            
            let nearByList = try await nearByTask
            
            await MainActor.run {
                self.nearByList = nearByList
                nearByLoading = false
            }
        }
    }
    
    private func getDefaultExpectedText() {
        Task {
            let predictions = try await CrowdedUsecase.shared.getDefaultExpectedText()
            
            await MainActor.run {
                // API에서 받은 데이터들로 여러 개의 Default Text 생성
                let dayText = getTomorrowDayText()
                
                defaultExpectedTexts = predictions.map { (crowdedLevel, predictionLocation) in
                    let locationText = predictionLocation.name
                    let crowdedText = getCrowdedLevelText(crowdedLevel)
                    return ["💬 \(dayText)엔 ", locationText, "\(SubjectFormatter.getSubjectMarker(locationText)) \(crowdedText) !"]
                }
                
                // 롤링 배너 시작
                if !defaultExpectedTexts.isEmpty {
                    startRollingBanner()
                }
            }
        }
    }
    
    // 롤링 배너 타이머 시작
    private func startRollingBanner() {
        Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            guard let self = self, !self.defaultExpectedTexts.isEmpty else { return }
            
            DispatchQueue.main.async {
                self.currentDefaultTextIndex = (self.currentDefaultTextIndex + 1) % self.defaultExpectedTexts.count
            }
        }
    }
    
    // 내일 요일 텍스트 반환
    private func getTomorrowDayText() -> String {
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: Date()) ?? Date()
        let weekday = calendar.component(.weekday, from: tomorrow)
        
        let weekdays = ["일요일", "월요일", "화요일", "수요일", "목요일", "금요일", "토요일"]
        return weekdays[weekday - 1]
    }
    
    // 혼잡도 예상 날짜 선택 시, 선택한 날짜 텍스트 포맷팅 및 혼잡도 예상 버튼 enable 여부 체크
    func changeDate() {
        expectedDate = "\(selectedExpectedDate.format())일 \(formatHourToAMPM(selectedHour))"
        showDatePicker = false
        
        enableExpectButton = (inputAddressViewModel.selectedAddress != nil)
    }
    
    // 시간을 오전/오후 형식으로 변환
    func formatHourToAMPM(_ hour: Int) -> String {
        if hour < 12 {
            return "오전 \(hour)시"
        } else if hour == 12 {
            return "오후 12시"
        } else {
            return "오후 \(hour - 12)시"
        }
    }
    
    // 혼잡도 예상 조회
    func expectCrowded() {
        // TODO: 에러 처리
        // 주소 validation 실패 시 return
        guard let address = inputAddressViewModel.selectedAddress, let coordinate = address.coordinate else {
            return
        }
        
        // 선택한 날짜와 시간을 결합한 Date 생성
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedExpectedDate)
        let combinedDate = calendar.date(bySettingHour: selectedHour, minute: 0, second: 0, of: calendar.date(from: dateComponents)!) ?? selectedExpectedDate
        
        // 혼잡도 예상 조회
        expectedCrowdedLevel = nil
        expectedPredictionLocation = nil
        expectLoading = true
        Task {
            let (crowdedLevel, predictionLocation) = try await CrowdedUsecase.shared.expectCrowded(coordinate, combinedDate)
            
            await MainActor.run {
                expectedCrowded = (address.road, combinedDate)
                expectedCrowdedLevel = crowdedLevel
                expectedPredictionLocation = predictionLocation
                expectLoading = false
            }
        }
    }
    
    // 혼잡도 예상 -> 혼잡도 텍스트
    func getPredictionCrowdedLevelText(_ level: CrowdedLevel) -> String {
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
    func getCrowdedLevelText(_ level: CrowdedLevel?) -> String {
        guard let level else {
            return ""
        }
        
        switch level {
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
