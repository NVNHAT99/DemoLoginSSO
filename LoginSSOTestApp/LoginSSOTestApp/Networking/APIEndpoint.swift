//
//  APIEndpoint.swift
//  LoginSSOTestApp
//
//  Created by Nhat Nguyen on 8/24/25.
//

import Foundation

public protocol APIEndpoint {
    var url: String { get }
    var method: HTTPMethod { get }
    var headerParameters: [String: String]? { get }
    var bodyParameters: [String: Any]? { get }
    var timeout: TimeInterval? { get }
}
