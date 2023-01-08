//
//  NetworkService.swift
//  
//
//  Created by zz129869523 on 2021/12/14.
//

import Foundation

enum NetworkServiceError: Error {
  case errorUrl
  case badResponse
}

protocol NetworkServiceContract: AnyObject {
  typealias Headers = [String: String]
  
  func requset<T: Decodable>(endpoint: Endpoint<T>) async throws -> [String: Any]?
}

final class NetworkService: NetworkServiceContract {
  func requset<T: Decodable>(endpoint: Endpoint<T>) async throws -> [String: Any]? {
    guard let url = endpoint.url else {
      throw NetworkServiceError.errorUrl
    }
    
    var urlRequest = URLRequest(url: url)
    urlRequest.httpMethod = endpoint.method.rawValue
    if let body = endpoint.body {
      if type(of: body) == Data.self {
        urlRequest.httpBody = body as? Data
      } else {
        urlRequest.httpBody = try? JSONEncoder().encode(body)
      }
    }
    
    endpoint.headers.forEach { (key, value) in
      urlRequest.setValue(value, forHTTPHeaderField: key)
    }
    do {
      let (data, _) = try await URLSession.shared.data(for: urlRequest)
      let dic = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
      
      return dic
    } catch {
      throw NetworkServiceError.badResponse
    }
  }
}
