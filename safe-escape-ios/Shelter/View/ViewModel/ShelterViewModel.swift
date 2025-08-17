//
//  ShelterViewModel.swift
//  safe-escape-ios
//
//  Created by kaseul on 7/30/25.
//

import Foundation

class ShelterViewModel: ObservableObject {
    
    @Published var loading: Bool = false
    @Published var shelters: [Shelter] = []
  
    func requestData() {
        shelters = []
        loading = true
        
        Task {
            let shelters = try await ShelterUsecase.shared.getNearByShelterList()
            
            await MainActor.run {
                self.shelters = shelters
                loading = false
            }
        }
    }
    
    func toggleShelterFavorite(_ shelter: Shelter) {
        Task {
            do {
                try await ShelterUsecase.shared.toggleShelterFavorite(shelter)
                
                // 찜 상태가 변경된 후 목록 새로고침
                await MainActor.run {
                    shelters = shelters.map {
                        var s = $0
                        if s.id == shelter.id {
                            s.liked.toggle()
                        }
                        return s
                    }
                }
                
            } catch {
//                self.errorMessage = "찜 상태 변경에 실패했습니다."
                print("Error toggling shelter favorite: \(error)")
            }
        }
    }
}
