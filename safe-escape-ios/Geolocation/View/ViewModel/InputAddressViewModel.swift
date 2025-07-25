//
//  InputAddressViewModel.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/23/25.
//

import Foundation

// 주소 검색 에러
enum InputAddressError {
    case validateFailed // validation 실패한 경우
    case noData // 주소 리스트 없는 경우
}

// 주소 검색 뷰모델
class InputAddressViewModel: ObservableObject {
    // input
    @Published var textInputAddress: String = ""
    
    // 주소 리스트 및 노출 여부
    @Published var showAddressList: Bool = false
    @Published var addressList: [Address] = []
    
    // 검색 에러
    @Published var errorState: InputAddressError? = nil
    
    //
    @Published var loading: Bool = false
    
    @Published var selectedAddress: Address? = nil
    
    // 마지막으로 검색한 주소
    private var lastFindAddress: String = ""
    
    // 주소 검색
    func findAddress() {
        // 에러 상태 초기화
        errorState = nil
        
        // 마지막 검색한 주소와 input이 동일하고 해당 주소 리스트가 있는 경우, 주소 리스트 다시 노출
        guard textInputAddress != lastFindAddress || addressList.isEmpty else {
            self.showAddressList = true
            return
        }
        
        // 주소 리스트
        addressList = []
        
        // input 한자리 이하면 다시 입력하도록 변경
        if textInputAddress.count < 2 {
            self.errorState = .validateFailed
            return
        }
        
        // 입력한 주소 저장 및 조회
        lastFindAddress = textInputAddress
        loading = true
        Task {
            let addressList = try? await FindUsecase.shared.findAddress(textInputAddress)
            
            // 입력한 주소에 해당하는 주소 리스트가 없는 경우, No data 표시 및 다시 입력하도록 변경
            guard let addressList = addressList, !addressList.isEmpty else {
                await MainActor.run {
                    self.loading = false
                    self.errorState = .noData
                }
                return
            }
            
            // 주소 리스트 노출
            await MainActor.run {
                self.loading = false
                self.addressList = addressList
                self.showAddressList = true
            }
        }
    }
    
    // 주소 리스트 > 선택
    func selectAddress(_ address: Address) {
        // 선택한 주소로 input 변경 및 주소 리스트 초기화
        textInputAddress = address.road
        
        selectedAddress = address
        
        showAddressList = false
        addressList = []
    }
}
