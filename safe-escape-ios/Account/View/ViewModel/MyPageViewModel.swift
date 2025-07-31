//
//  MyPageViewModel.swift
//  safe-escape-ios
//
//  Created by kaseul on 8/1/25.
//

import SwiftUI

class MyPageViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var favoriteShelters: [Shelter] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Lifecycle
    
    func onAppear() {
        Task {
            await loadFavoriteShelters()
        }
    }
    
    // MARK: - Data Loading
    
    @MainActor
    func loadFavoriteShelters() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let shelters = try await ShelterUsecase.shared.getFavoriteShelters()
            self.favoriteShelters = shelters
        } catch {
            self.errorMessage = "찜한 대피소를 불러오는데 실패했습니다."
            print("Error loading favorite shelters: \(error)")
        }
        
        isLoading = false
    }
    
    // MARK: - Actions
    func toggleShelterFavorite(_ shelter: Shelter) {
        Task {
            do {
                try await ShelterUsecase.shared.toggleShelterFavorite(shelter)
                
                // 찜 상태가 변경된 후 목록 새로고침
                await loadFavoriteShelters()
                
            } catch {
                self.errorMessage = "찜 상태 변경에 실패했습니다."
                print("Error toggling shelter favorite: \(error)")
            }
        }
    }
    
    @MainActor
    func refreshFavorites() async {
        await loadFavoriteShelters()
    }
}
