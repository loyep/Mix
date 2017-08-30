//
//  TargetType.swift
//  SwiftyWeibo
//
//  Created by Maxwell on 16/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import Foundation

/// The protocol used to define the specifications necessary for a `Provider`.
public protocol TargetType {
    
    /// The target's base `URL`.
    var baseURL: URL { get }
    
    /// The path to be appended to `baseURL` to form the full `URL`.
    var path: String { get }
    
    /// The HTTP method used in the request.
    var method: SwiftyWeibo.Method { get }
    
    /// Provides stub data for use in testing.
    var sampleData: Data { get }
    
    /// The type of HTTP task to be performed.
    var task: Task { get }
    
    /// Whether or not to perform Alamofire validation. Defaults to `false`.
    var validate: Bool { get }
    
    /// The headers to be used in the request.
    var headers: [String: String]? { get }
}

public extension TargetType {
    
    var validate: Bool { return true }
    
    var sampleData: Data { return Data() }
    
    var task: Task { return .requestPlain }
    
    var headers: [String: String]? { return nil }
}

/// Represents a type of upload task.
public enum UploadType {
    
    /// Upload a file.
    case file(URL)
    
    /// Upload "multipart/form-data"
    case multipart([MultipartFormData])
}

/// Represents a type of download task.
public enum DownloadType {
    
    /// Download a file to a destination.
    case request(DownloadDestination)
}

/// Represents "multipart/form-data" for an upload.
public struct MultipartFormData {
    
    /// Method to provide the form data.
    public enum FormDataProvider {
        case data(Foundation.Data)
        case file(URL)
        case stream(InputStream, UInt64)
    }
    
    /// Initialize a new `MultipartFormData`.
    public init(provider: FormDataProvider, name: String, fileName: String? = nil, mimeType: String? = nil) {
        self.provider = provider
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
    }
    
    /// The method being used for providing form data.
    public let provider: FormDataProvider
    
    /// The name.
    public let name: String
    
    /// The file name.
    public let fileName: String?
    
    /// The MIME type
    public let mimeType: String?
}

/// Represents an HTTP task.
public enum Task {
    
    /// A request with no additional data.
    case requestPlain
    
    /// A requests body set with data.
    case requestData(Data)
    
    /// A requests body set with encoded parameters.
    case requestParameters(parameters: [String: Any], encoding: ParameterEncoding)
    
    /// A requests body set with data, combined with url parameters.
    case requestCompositeData(bodyData: Data, urlParameters: [String: Any])
    
    /// A requests body set with encoded parameters combined with url parameters.
    case requestCompositeParameters(bodyParameters: [String: Any], bodyEncoding: ParameterEncoding, urlParameters: [String: Any])
    
    /// A file upload task.
    case uploadFile(URL)
    
    /// A "multipart/form-data" upload task.
    case uploadMultipart([MultipartFormData])
    
    /// A "multipart/form-data" upload task  combined with url parameters.
    case uploadCompositeMultipart([MultipartFormData], urlParameters: [String: Any])
    
    /// A file download task to a destination.
    case downloadDestination(DownloadDestination)
    
    /// A file download task to a destination with extra parameters using the given encoding.
    case downloadParameters(parameters: [String: Any], encoding: ParameterEncoding, destination: DownloadDestination)
}
