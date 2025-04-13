import Foundation

class ElectionService {
    private let baseURL = "https://civicinfo.googleapis.com/civicinfo/v2"
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
        
        print("Fetching elections from URL: \(url)")
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw ElectionError.invalidResponse
        }
        
        print("Response status code: \(httpResponse.statusCode)")
        
        if !(200...299).contains(httpResponse.statusCode) {
            if let errorString = String(data: data, encoding: .utf8) {
                print("Error response: \(errorString)")
            }
            throw ElectionError.invalidResponse
        }
        
        do {
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Received JSON: \(jsonString)")
            }
            
            let decoder = JSONDecoder()
            let result = try decoder.decode(ElectionsResponse.self, from: data)
            return result.elections
        } catch {
            print("Decoding error: \(error)")
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