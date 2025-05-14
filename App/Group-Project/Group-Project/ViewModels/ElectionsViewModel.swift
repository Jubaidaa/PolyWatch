import Foundation
import SwiftUI

@MainActor
class ElectionsViewModel: ObservableObject {
    @Published var elections: [Election] = []
    @Published var isLoading = false
    @Published var error: ElectionError?
    @Published var retryCount = 0
    
    private let service: ElectionService
    
    init() {
        self.service = ElectionService(apiKey: "AIzaSyA81H369Zveytnca05k2Mtkr4RfjmGyi9U")
    }
    
    func fetchElections() {
        isLoading = true
        error = nil
        
        Task {
            do {
                elections = try await service.fetchElections()
                isLoading = false
                // Reset retry count on success
                retryCount = 0
            } catch let error as ElectionError {
                self.error = error
                isLoading = false
                
                // If we have a network error, try to auto-retry once
                if error == .networkError && retryCount < 1 {
                    retryCount += 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.fetchElections()
                    }
                }
            } catch {
                self.error = .networkError
                isLoading = false
            }
        }
    }
    
    func formatDate(_ dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateStyle = .long
        
        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        }
        return dateString
    }
} 