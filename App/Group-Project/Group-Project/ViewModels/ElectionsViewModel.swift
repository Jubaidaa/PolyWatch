import Foundation
import SwiftUI

@MainActor
class ElectionsViewModel: ObservableObject {
    @Published var elections: [Election] = []
    @Published var isLoading = false
    @Published var error: ElectionError?
    
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
            } catch let error as ElectionError {
                self.error = error
                isLoading = false
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