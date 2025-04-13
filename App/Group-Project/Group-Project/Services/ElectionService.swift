import Foundation

class ElectionService {
    private let baseURL = "https://www.googleapis.com/civicinfo/v2"
    private let apiKey: String
    
    init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    func fetchElections() async throws -> [Election] {
        guard var urlComponents = URLComponents(string: "\(baseURL)/elections") else {
            throw ElectionError.invalidURL
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        guard let url = urlComponents.url else {
            throw ElectionError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ElectionError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            let result = try decoder.decode(ElectionsResponse.self, from: data)
            return result.elections
        } catch {
            throw ElectionError.invalidData
        }
    }
    
    func fetchElectionDetails(electionId: String) async throws -> Election {
        guard var urlComponents = URLComponents(string: "\(baseURL)/elections/\(electionId)") else {
            throw ElectionError.invalidURL
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        guard let url = urlComponents.url else {
            throw ElectionError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw ElectionError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(Election.self, from: data)
        } catch {
            throw ElectionError.invalidData
        }
    }
} 