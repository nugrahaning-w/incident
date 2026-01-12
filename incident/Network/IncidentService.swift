//
//  IncidentService.swift
//  incident
//
//  Created by Aji Nugrahaning Widhi on 07/01/26.
//

import Foundation
import RxSwift
import RxCocoa

// MARK: - Protocol
protocol IncidentServiceProtocol {
    func fetchIncidents(completion: @escaping (Result<[Incident], NetworkError>) -> Void)
    func fetchIncidentsRx() -> Single<[Incident]>
}

// MARK: - Implementation
final class IncidentService: IncidentServiceProtocol {

    // API source
    private let urlString = "https://gist.githubusercontent.com/xxfast/26856d7c1a06619d013d2e6a578b0426/raw/a6c5cbe23c1a740a1afe87f752b5df4dbfe1b624/mdc-challenge.json"

    func fetchIncidents(completion: @escaping (Result<[Incident], NetworkError>) -> Void) {

        // Local bundle JSON (DISABLED, kept for reference)
        /*
        let fileURL =
            Bundle.main.url(forResource: "response", withExtension: "json")
            ?? Bundle.main.url(forResource: "response", withExtension: "json", subdirectory: "Mock")

        guard let fileURL else {
            completion(.failure(.invalidURL))
            return
        }
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            let incidents = try decoder.decode([Incident].self, from: data)
            completion(.success(incidents))
            return
        } catch let decodingError as DecodingError {
            completion(.failure(.decodingError))
            return
        } catch {
            completion(.failure(.serverError(error.localizedDescription)))
            return
        }
        */

        // Remote API request
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL)); return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            // Network error
            if let error = error {
                completion(.failure(.serverError(error.localizedDescription)))
                return
            }

            // Optional: check HTTP status code
            if let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) == false {
                completion(.failure(.serverError("HTTP \(http.statusCode)")))
                return
            }

            guard let data = data else {
                completion(.failure(.noData)); return
            }

            do {
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                let incidents = try decoder.decode([Incident].self, from: data)
                completion(.success(incidents))
            } catch let decodingError as DecodingError {
                #if DEBUG
                print("Decoding error: \(decodingError)")
                #endif
                completion(.failure(.decodingError))
            } catch {
                completion(.failure(.serverError(error.localizedDescription)))
            }
        }
        task.resume()
    }

    // RxSwift trait version (Single)
    func fetchIncidentsRx() -> Single<[Incident]> {
        Single.create { observer in
            self.fetchIncidents { result in
                switch result {
                case .success(let items): observer(.success(items))
                case .failure(let error): observer(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
