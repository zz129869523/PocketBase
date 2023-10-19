//
//  File.swift
//  
//
//  Created by sergeypdev on 19.10.23.
//

import Foundation

public extension DateFormatter {
  /// Default date formatting used by PocketBase server.
  static let defaultPocketBase: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSSZ"
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.calendar = Calendar(identifier: .iso8601)
    return formatter
  }()
}
