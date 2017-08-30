//
//  Endpoint.swift
//  SwiftyWeibo
//
//  Created by Maxwell on 16/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import Foundation

/// Used for stubbing responses.
public enum EndpointSampleResponse {
    
    /// The network returned a response, including status code and data.
    case networkResponse(Int, Data)
    
    /// The network returned response which can be fully customized.
    case response(HTTPURLResponse, Data)
    
    /// The network failed to send the request, or failed to retrieve a response (eg a timeout).
    case networkError(NSError)
}

/// Class for reifying a target of the `TargetType` enum unto a concrete `Endpoint`.
public struct Endpoint<TargetType> {
    public typealias SampleResponseClosure = () -> EndpointSampleResponse
    
    public let url: String
    public let method: SwiftyWeibo.Method
    public let sampleResponseClosure: SampleResponseClosure
    public let httpHeaderFields: [String: String]?
    public let task: Task
    
    /// Main initializer for `Endpoint`.
    public init(url: String,
                sampleResponseClosure: @escaping SampleResponseClosure,
                method: SwiftyWeibo.Method = SwiftyWeibo.Method.get,
                task: Task = .requestPlain,
                httpHeaderFields: [String: String]? = nil) {
        
        self.url = url
        self.sampleResponseClosure = sampleResponseClosure
        self.method = method
        self.task = task
        self.httpHeaderFields = httpHeaderFields
    }
    
    /// Convenience method for creating a new `Endpoint` with the same properties as the receiver, but with added HTTP header fields.
    public func adding(newHTTPHeaderFields: [String: String]) -> Endpoint<TargetType> {
        return adding(httpHeaderFields: newHTTPHeaderFields)
    }
    
    /// Convenience method for creating a new `Endpoint`, with changes only to the properties we specify as parameters
    public func adding(httpHeaderFields: [String: String]? = nil)  -> Endpoint<TargetType> {
        let newHTTPHeaderFields = add(httpHeaderFields: httpHeaderFields)
        return Endpoint(url: url, sampleResponseClosure: sampleResponseClosure, method: method, task: task, httpHeaderFields: newHTTPHeaderFields)
    }
    
    fileprivate func add(httpHeaderFields headers: [String: String]?) -> [String: String]? {
        guard let unwrappedHeaders = headers, unwrappedHeaders.isEmpty == false else {
            return self.httpHeaderFields
        }
        
        var newHTTPHeaderFields = self.httpHeaderFields ?? [:]
        unwrappedHeaders.forEach { key, value in
            newHTTPHeaderFields[key] = value
        }
        return newHTTPHeaderFields
    }
    
}

/// Extension for converting an `Endpoint` into an optional `URLRequest`.
extension Endpoint {
    /// Returns the `Endpoint` converted to a `URLRequest` if valid. Returns `nil` otherwise.
    public var urlRequest: URLRequest? {
        guard let requestURL = Foundation.URL(string: url) else { return nil }
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = httpHeaderFields
        
        switch task {
        case .requestPlain, .uploadFile, .uploadMultipart, .downloadDestination:
            return request
        case .requestData(let data):
            request.httpBody = data
            return request
        case let .requestParameters(parameters, parameterEncoding):
            return try? parameterEncoding.encode(request, with: parameters)
        case let .uploadCompositeMultipart(_, urlParameters):
            return try? URLEncoding(destination: .queryString).encode(request, with: urlParameters)
        case let .downloadParameters(parameters, parameterEncoding, _):
            return try? parameterEncoding.encode(request, with: parameters)
        case let .requestCompositeData(bodyData: bodyData, urlParameters: urlParameters):
            request.httpBody = bodyData
            return try? URLEncoding(destination: .queryString).encode(request, with: urlParameters)
        case let .requestCompositeParameters(bodyParameters: bodyParameters, bodyEncoding: bodyParameterEncoding, urlParameters: urlParameters):
            if bodyParameterEncoding is URLEncoding { fatalError("URLEncoding is disallowed as bodyEncoding.") }
            guard let bodyfulRequest = try? bodyParameterEncoding.encode(request, with: bodyParameters) else { return nil }
            return try? URLEncoding(destination: .queryString).encode(bodyfulRequest, with: urlParameters)
        }
    }
}

/// Required for using `Endpoint` as a key type in a `Dictionary`.
extension Endpoint: Equatable, Hashable {
    public var hashValue: Int {
        return urlRequest?.hashValue ?? url.hashValue
    }
    
    public static func == <T>(lhs: Endpoint<T>, rhs: Endpoint<T>) -> Bool {
        if lhs.urlRequest != nil, rhs.urlRequest == nil { return false }
        if lhs.urlRequest == nil, rhs.urlRequest != nil { return false }
        if lhs.urlRequest == nil, rhs.urlRequest == nil { return lhs.hashValue == rhs.hashValue }
        return (lhs.urlRequest == rhs.urlRequest)
    }
}
