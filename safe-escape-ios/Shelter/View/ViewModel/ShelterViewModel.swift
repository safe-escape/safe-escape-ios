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
    
    @Published var nearByList: [CrowdedNearBy] = []
  
    func requestData() {
        loading = true
        
        Task {
            let shelters = try await ShelterUsecase.shared.getNearByShelterList()
            
            await MainActor.run {
                self.shelters = shelters
                loading = false
            }
        }
    }
}
