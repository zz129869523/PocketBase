//
//  Realtime.swift
//  
//
//  Created by 陳勇辰 on 2022/12/29.
//

import Foundation
import EventSource

class Realtime {
  static let shared = Realtime()
  private let networkService: NetworkServiceContract = NetworkService()
  
  var eventSource: EventSource? = nil
  var currentId: String? = nil
  var clientId: String? = nil
  var subscriptions: [String] = []
  
  private func setupEventSource() {
    guard eventSource == nil else { return }
    
    let serverURL = URL(string: PocketBase<User>.host + "/api/realtime")!
    
    eventSource = EventSource(url: serverURL)
    
    eventSource?.connect()
    
    eventSource?.onOpen {
//      print("Realtime opened!")
    }
    
    eventSource?.onComplete({ (statusCode, reconnect, error) in
      self.eventSource?.connect(lastEventId: self.currentId)
    })
    
    eventSource?.addEventListener("PB_CONNECT", handler: { id, event, data in
      guard let data, let dict = Utils.stringToDictionary(text: data) else { return }
      self.clientId = dict["clientId"] as? String
      self.currentId = id
      
      if !self.subscriptions.isEmpty {
        Task {
          guard let clientId = self.clientId else { return }
          
          let dict = try? await self.networkService.requset(endpoint: Endpoint<RealtimeRequset>.setSubscriptions(clientId: clientId, subscriptions: self.subscriptions))
          let err = try? ErrorResponse(dictionary: dict ?? [:])
          if let err {
            print(err)
          }
        }
      }
    })
  }
  
  func subscribe(_ event: String) async -> [String: Any]? {
    setupEventSource()

    if self.subscriptions.contains(where: { $0 == event }) {
      print("event(\(event)) in the subscriptions")
      return nil
    }
    
    self.subscriptions.append(event)
    
    guard let clientId else { return nil }

    return try? await self.networkService.requset(endpoint: Endpoint<RealtimeRequset>.setSubscriptions(clientId: clientId, subscriptions: self.subscriptions))
  }
  
  func unsubscribe(_ event: String = "") async -> [String: Any]? {
    guard let clientId else {
      print("clientId is nil")
      return nil
    }
    if event == "" {
      self.subscriptions = []
    } else if self.subscriptions.contains(where: { $0 == event }) {
      // remove event from subscriptions
      self.subscriptions = self.subscriptions.filter { $0 != event }
    } else {
      print("Not found from subscriptions")
      return nil
    }
    
    return try? await self.networkService.requset(endpoint: Endpoint<RealtimeRequset>.setSubscriptions(clientId: clientId, subscriptions: self.subscriptions))
  }
}

struct RealtimeRequset: Codable {
  var clientId: String
  var subscriptions: [String]
}

public struct Event<U: Codable & Identifiable>: Codable {
  public var action: Action
  public var record: U
}

public enum Action: String, Codable {
  case create
  case update
  case delete
}
