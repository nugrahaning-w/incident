//
//  IncidentService.swift
//  incident
//
//  Created by Aji Nugrahaning Widhi on 07/01/26.
//

import Foundation
import RxSwift
import RxCocoa
import Onet

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

        guard let url = URL(string: urlString) else {
            completion(.failure(.invalidURL)); return
        }

        let request = URLRequest(url: url)

        // Onet-backed URLSession task
        Onet.createURLSessionTask(for: request) { data, response, error in
            // Network error
            if let error = error {
                completion(.failure(.serverError(error.localizedDescription)))
                return
            }

            // Optional: check HTTP status code
            if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                completion(.failure(.serverError("HTTP \(http.statusCode)")))
                return
            }

            guard let data = data else {
                completion(.failure(.noData)); return
            }

            do {
                // Incident handles its own date parsing; keep .iso8601 if you still rely on decoder strategy elsewhere
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
    }

    // RxSwift trait version (Single)
    func fetchIncidentsRx() -> Single<[Incident]> {
        guard let url = URL(string: urlString) else {
            return .error(NetworkError.invalidURL)
        }

        return Single.create { observer in
            let request = URLRequest(url: url)
            Onet.createURLSessionTask(for: request) { data, response, error in
                if let error = error {
                    observer(.failure(NetworkError.serverError(error.localizedDescription)))
                    return
                }
                if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                    observer(.failure(NetworkError.serverError("HTTP \(http.statusCode)")))
                    return
                }
                guard let data = data else {
                    observer(.failure(NetworkError.noData)); return
                }
                do {
                    let decoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .iso8601
                    let incidents = try decoder.decode([Incident].self, from: data)
                    observer(.success(incidents))
                } catch let decodingError as DecodingError {
                    #if DEBUG
                    print("Decoding error: \(decodingError)")
                    #endif
                    observer(.failure(NetworkError.decodingError))
                } catch {
                    observer(.failure(NetworkError.serverError(error.localizedDescription)))
                }
            }
            return Disposables.create()
        }
    }
}
