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
        
        // Create a custom URLSession with a timeout
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15 // 15 seconds timeout
        config.waitsForConnectivity = true
        let session = URLSession(configuration: config)
        
        do {
            let (data, response) = try await session.data(from: url)
            
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
        } catch let urlError as URLError {
            print("URL Session error: \(urlError)")
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                // Use mock data when offline
                return mockElections()
            default:
                throw ElectionError.networkError
            }
        } catch {
            print("Unknown error: \(error)")
            throw ElectionError.networkError
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
    
    // Mock data to use when offline
    private func mockElections() -> [Election] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return [
            Election(
                id: "mock-election-1",
                name: "US Presidential Election",
                electionDay: "\(currentYear)-11-05",
                ocdDivisionId: "ocd-division/country:us"
            ),
            Election(
                id: "mock-election-2",
                name: "California Primary Election",
                electionDay: "\(currentYear)-03-05",
                ocdDivisionId: "ocd-division/country:us/state:ca"
            ),
            Election(
                id: "mock-election-3",
                name: "New York Primary Election",
                electionDay: "\(currentYear)-04-28",
                ocdDivisionId: "ocd-division/country:us/state:ny"
            )
        ]
    }
} 