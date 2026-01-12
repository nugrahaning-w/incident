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

// MARK: - Service implements Repository
final class IncidentService: IncidentServiceProtocol, IncidentRepository {

    private let urlString = "https://gist.githubusercontent.com/xxfast/26856d7c1a06619d013d2e6a578b0426/raw/a6c5cbe23c1a740a1afe87f752b5df4dbfe1b624/mdc-challenge.json"

    private func makeRequest() throws -> URLRequest {
        guard let url = URL(string: urlString) else { throw NetworkError.invalidURL }
        var req = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 30)
        req.httpMethod = "GET"
        return req
    }

    private func decodeIncidents(from data: Data) throws -> [Incident] {
        let decoder = JSONDecoder()
        return try decoder.decode([Incident].self, from: data)
    }

    func fetchIncidents(completion: @escaping (Result<[Incident], NetworkError>) -> Void) {
        do {
            let request = try makeRequest()
            Onet.createURLSessionTask(for: request) { data, response, error in
                if let error = error { completion(.failure(.serverError(error.localizedDescription))); return }
                if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
                    completion(.failure(.serverError("HTTP \(http.statusCode)"))); return
                }
                guard let data = data else { completion(.failure(.noData)); return }
                do { completion(.success(try self.decodeIncidents(from: data))) }
                catch { completion(.failure(.decodingError)) }
            }
        } catch {
            completion(.failure(.invalidURL))
        }
    }

    func fetchIncidentsRx() -> Single<[Incident]> {
        fetchIncidents() // delegate to repository method to keep DRY
    }

    // MARK: - IncidentRepository
    func fetchIncidents() -> Single<[Incident]> {
        Single.create { observer in
            let request: URLRequest
            do {
                request = try self.makeRequest()
            } catch {
                observer(.failure(NetworkError.invalidURL))
                return Disposables.create()
            }
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
                    observer(.failure(NetworkError.noData))
                    return
                }
                do {
                    observer(.success(try self.decodeIncidents(from: data)))
                } catch {
                    observer(.failure(NetworkError.decodingError))
                }
            }
            return Disposables.create()
        }
    }
}
