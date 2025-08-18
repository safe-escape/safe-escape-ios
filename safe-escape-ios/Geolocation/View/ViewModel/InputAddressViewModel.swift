//
//  InputAddressViewModel.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/23/25.
//

import Foundation

enum InputFocusState {
    case none
    case focusIn
    case focusOut
}

// 주소 검색 뷰 타입
enum InputAddressViewType {
    case shadow // background + shadow
    case border // background + border
}

// 주소 검색 에러
enum InputAddressError {
    case validateFailed // validation 실패한 경우
    case noData // 주소 리스트 없는 경우
}

// 주소 검색 뷰모델
class InputAddressViewModel: ObservableObject {
    // input
    @Published var textInputAddress: String = ""
    
    // 포커스 요청
    @Published var focusRequest: InputFocusState = .none
    
    // 주소 리스트 및 노출 여부
    @Published var showOverlay: Bool = false
    @Published var addressList: [Address] = []
    
    // 무한 스크롤 관련
    @Published var isLoadingMore: Bool = false
    @Published var hasMoreData: Bool = true
    private var currentPage: Int = 1
    
    // 검색 에러
    @Published var errorState: InputAddressError? = nil
    
    // 주소 검색 loading 여부
    @Published var loading: Bool = false
    // 선택한 주소
    @Published var selectedAddress: Address? = nil
    
    // 마지막으로 검색한 주소
    private var lastFindAddress: String = ""
    
    // 주소 검색
    func findAddress() {
        // 에러 상태 초기화
        errorState = nil
        
        // 마지막 검색한 주소와 input이 동일하고 해당 주소 리스트가 있는 경우, 주소 리스트 다시 노출
        guard textInputAddress != lastFindAddress || addressList.isEmpty else {
            self.showOverlay = true
            return
        }
        
        // 주소 리스트
        addressList = []
        
        // input 한자리 이하면 다시 입력하도록 변경
        if textInputAddress.count < 2 {
            self.errorState = .validateFailed
            self.showOverlay = true
            return
        }
        
        // 입력한 주소 저장 및 조회
        lastFindAddress = textInputAddress
        currentPage = 1
        hasMoreData = true
        loading = true
        Task {
            let result = try? await FindUsecase.shared.findAddress(textInputAddress, page: currentPage)
            
            // 입력한 주소에 해당하는 주소 리스트가 없는 경우, No data 표시 및 다시 입력하도록 변경
            guard let result = result, !result.addresses.isEmpty else {
                await MainActor.run {
                    self.loading = false
                    self.errorState = .noData
                    self.showOverlay = true
                }
                return
            }
            
            // 주소 리스트 노출
            await MainActor.run {
                self.loading = false
                self.addressList = result.addresses
                self.hasMoreData = result.hasMoreData
                self.showOverlay = true
            }
        }
    }
    
    // 주소 리스트 > 선택
    func selectAddress(_ address: Address) {
        // 선택한 주소로 input 변경 및 주소 리스트 초기화
        textInputAddress = address.road
        lastFindAddress = address.road
        
        selectedAddress = address
        
        showOverlay = false
        addressList = [address]
    }
    
    // 더 많은 주소 로드 (무한 스크롤)
    func loadMoreAddress() {
        // 이미 로딩 중이거나 더 이상 데이터가 없으면 return
        guard !isLoadingMore && hasMoreData && !lastFindAddress.isEmpty else {
            return
        }
        
        isLoadingMore = true
        currentPage += 1
        
        Task {
            let result = try? await FindUsecase.shared.findAddress(lastFindAddress, page: currentPage)
            
            guard let result = result else {
                await MainActor.run {
                    self.isLoadingMore = false
                    self.currentPage -= 1 // 실패 시 페이지 롤백
                }
                return
            }
            
            await MainActor.run {
                self.addressList.append(contentsOf: result.addresses)
                self.hasMoreData = result.hasMoreData
                self.isLoadingMore = false
            }
        }
    }
    
    // 초기화
    func reset() {
        lastFindAddress = ""
        textInputAddress = ""
        
        errorState = nil
        selectedAddress = nil
        showOverlay = false
        addressList = []
        
        // 무한 스크롤 상태 초기화
        currentPage = 1
        hasMoreData = true
        isLoadingMore = false
    }
}
