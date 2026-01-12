//
//  NetrworkError.swift
//  incident
//
//  Created by Aji Nugrahaning Widhi on 07/01/26.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    case unknownError

    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "The URL is invalid."
        case .noData:
            return "No data was received from the server."
        case .decodingError:
            return "Failed to decode the response."
        case .serverError(let message):
            return "Server error: \(message)"
        case .unknownError:
            return "An unknown error occurred."
        }
    }
}
