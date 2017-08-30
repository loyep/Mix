//
//  Provider+Internal.swift
//  SwiftyWeibo
//
//  Created by Maxwell on 16/08/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import Foundation
import Result

// MARK: - Provider

/// Internal extension to keep the inner-workings outside the main SwiftyWeibo.swift file.
internal extension Provider {
    // Yup, we're disabling these. The function is complicated, but breaking it apart requires a large effort.
    // swiftlint:disable cyclomatic_complexity
    // swiftlint:disable function_body_length
    /// Performs normal requests.
    func requestNormal(_ target: TargetType, callbackQueue: DispatchQueue?, progress: Provider.ProgressBlock?, completion: @escaping Provider.Completion) -> Cancellable {
        let endpoint = self.endpoint(target)
        let stubBehavior = self.stubClosure(target)
        let cancellableToken = CancellableWrapper()
        
        // Allow plugins to modify response
        let pluginsWithCompletion: Provider.Completion = { result in
            let processedResult = self.plugins.reduce(result) { $1.value.process($0, target: target) }
            completion(processedResult)
        }
        
        if trackInflights {
            objc_sync_enter(self)
            var inflightCompletionBlocks = self.inflightRequests[endpoint]
            inflightCompletionBlocks?.append(completion)
            self.inflightRequests[endpoint] = inflightCompletionBlocks
            objc_sync_exit(self)
            
            if inflightCompletionBlocks != nil {
                return cancellableToken
            } else {
                objc_sync_enter(self)
                self.inflightRequests[endpoint] = [completion]
                objc_sync_exit(self)
            }
        }
        
        let performNetworking = { (requestResult: Result<URLRequest, SwiftyWeiboError>) in
            if cancellableToken.isCancelled {
                self.cancelCompletion(pluginsWithCompletion, target: target)
                return
            }
            
            var request: URLRequest!
            
            switch requestResult {
            case .success(let urlRequest):
                request = urlRequest
            case .failure(let error):
                pluginsWithCompletion(.failure(error))
                return
            }
            
            // Allow plugins to modify request
            request = self.plugins.reduce(request) { $1.value.prepare($0, target: target) }
            let networkCompletion: Provider.Completion = { result in
                if self.trackInflights {
                    self.inflightRequests[endpoint]?.forEach { $0(result) }
                    
                    objc_sync_enter(self)
                    self.inflightRequests.removeValue(forKey: endpoint)
                    objc_sync_exit(self)
                } else {
                    pluginsWithCompletion(result)
                }
            }
            
            cancellableToken.innerCancellable = self.performRequest(target, request: request, callbackQueue: callbackQueue, progress: progress, completion: networkCompletion, endpoint: endpoint, stubBehavior: stubBehavior)
        }
        
        requestClosure(endpoint, performNetworking)
        
        return cancellableToken
    }
    
    // swiftlint:enable cyclomatic_complexity
    // swiftlint:enable function_body_length
    
    private func performRequest(_ target: TargetType, request: URLRequest, callbackQueue: DispatchQueue?, progress: Provider.ProgressBlock?, completion: @escaping Provider.Completion, endpoint: Endpoint<TargetType>, stubBehavior: SwiftyWeibo.StubBehavior) -> Cancellable {
        
        switch stubBehavior {
        case .never:
            switch target.task {
            case .requestPlain, .requestData, .requestParameters, .requestCompositeData, .requestCompositeParameters:
                return self.sendRequest(target, request: request, callbackQueue: callbackQueue, progress: progress, completion: completion)
                
            case .uploadFile(let file):
                return self.sendUploadFile(target, request: request, callbackQueue: callbackQueue, file: file, progress: progress, completion: completion)
                
            case .uploadMultipart(let multipartBody), .uploadCompositeMultipart(let multipartBody, _):
                guard !multipartBody.isEmpty && target.method.supportsMultipart else {
                    fatalError("\(target) is not a multipart upload target.")
                }
                return self.sendUploadMultipart(target, request: request, callbackQueue: callbackQueue, multipartBody: multipartBody, progress: progress, completion: completion)
                
            case .downloadDestination(let destination), .downloadParameters(_, _, let destination):
                return self.sendDownloadRequest(target, request: request, callbackQueue: callbackQueue, destination: destination, progress: progress, completion: completion)
            }
            
        default:
            return self.stubRequest(target, request: request, callbackQueue: callbackQueue, completion: completion, endpoint: endpoint, stubBehavior: stubBehavior)
        }
    }
    
    func cancelCompletion(_ completion: Provider.Completion, target: TargetType) {
        let error = SwiftyWeiboError.underlying(NSError(domain: NSURLErrorDomain, code: NSURLErrorCancelled, userInfo: nil), nil)
        plugins.forEach { $0.value.didReceive(.failure(error), target: target) }
        completion(.failure(error))
    }
    
    /// Creates a function which, when called, executes the appropriate stubbing behavior for the given parameters.
    internal final func createStubFunction(_ token: CancellableToken, forTargetType target: TargetType, withCompletion completion: @escaping Provider.Completion, endpoint: Endpoint<TargetType>, plugins: [String: PluginType], request: URLRequest) -> (() -> Void) {
        // swiftlint:disable:this function_parameter_count
        return {
            if token.isCancelled {
                self.cancelCompletion(completion, target: target)
                return
            }
            
            switch endpoint.sampleResponseClosure() {
            case .networkResponse(let statusCode, let data):
                let response = SwiftyWeibo.Response(statusCode: statusCode, data: data, request: request, response: nil)
                plugins.forEach { $0.value.didReceive(.success(response), target: target) }
                completion(.success(response))
            case .response(let customResponse, let data):
                let response = SwiftyWeibo.Response(statusCode: customResponse.statusCode, data: data, request: request, response: customResponse)
                plugins.forEach { $0.value.didReceive(.success(response), target: target) }
                completion(.success(response))
            case .networkError(let error):
                let error = SwiftyWeiboError.underlying(error, nil)
                plugins.forEach { $0.value.didReceive(.failure(error), target: target) }
                completion(.failure(error))
            }
        }
    }
    
    /// Notify all plugins that a stub is about to be performed. You must call this if overriding `stubRequest`.
    final func notifyPluginsOfImpendingStub(for request: URLRequest, target: TargetType) {
        let alamoRequest = manager.request(request as URLRequestConvertible)
        plugins.forEach { $0.value.willSend(alamoRequest, target: target) }
        alamoRequest.cancel()
    }
}

internal extension Provider {
    func sendUploadMultipart(_ target: TargetType, request: URLRequest, callbackQueue: DispatchQueue?, multipartBody: [MultipartFormData], progress: Provider.ProgressBlock? = nil, completion: @escaping Provider.Completion) -> CancellableWrapper {
        let cancellable = CancellableWrapper()
        
        let multipartFormData: (RequestMultipartFormData) -> Void = { form in
            for bodyPart in multipartBody {
                switch bodyPart.provider {
                case .data(let data):
                    self.append(data: data, bodyPart: bodyPart, to: form)
                case .file(let url):
                    self.append(fileURL: url, bodyPart: bodyPart, to: form)
                case .stream(let stream, let length):
                    self.append(stream: stream, length: length, bodyPart: bodyPart, to: form)
                }
            }
        }
        
        manager.upload(multipartFormData: multipartFormData, with: request) { result in
            switch result {
            case .success(let alamoRequest, _, _):
                if cancellable.isCancelled {
                    self.cancelCompletion(completion, target: target)
                    return
                }
                cancellable.innerCancellable = self.sendAlamofireRequest(alamoRequest, target: target, callbackQueue: callbackQueue, progress: progress, completion: completion)
            case .failure(let error):
                completion(.failure(SwiftyWeiboError.underlying(error as NSError, nil)))
            }
        }
        
        return cancellable
    }
    
    func sendUploadFile(_ target: TargetType, request: URLRequest, callbackQueue: DispatchQueue?, file: URL, progress: ProgressBlock? = nil, completion: @escaping Completion) -> CancellableToken {
        let uploadRequest = manager.upload(file, with: request)
        let alamoRequest = target.validate ? uploadRequest.validate() : uploadRequest
        return self.sendAlamofireRequest(alamoRequest, target: target, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    func sendDownloadRequest(_ target: TargetType, request: URLRequest, callbackQueue: DispatchQueue?, destination: @escaping DownloadDestination, progress: ProgressBlock? = nil, completion: @escaping Completion) -> CancellableToken {
        let downloadRequest = manager.download(request, to: destination)
        let alamoRequest = target.validate ? downloadRequest.validate() : downloadRequest
        return self.sendAlamofireRequest(alamoRequest, target: target, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    func sendRequest(_ target: TargetType, request: URLRequest, callbackQueue: DispatchQueue?, progress: Provider.ProgressBlock?, completion: @escaping Provider.Completion) -> CancellableToken {
        let initialRequest = manager.request(request as URLRequestConvertible)
        let alamoRequest = target.validate ? initialRequest.validate() : initialRequest
        return sendAlamofireRequest(alamoRequest, target: target, callbackQueue: callbackQueue, progress: progress, completion: completion)
    }
    
    func sendAlamofireRequest<T>(_ alamoRequest: T, target: TargetType, callbackQueue: DispatchQueue?, progress progressCompletion: Provider.ProgressBlock?, completion: @escaping Provider.Completion) -> CancellableToken where T: Requestable, T: Request {
        // Give plugins the chance to alter the outgoing request
        let plugins = self.plugins
        plugins.forEach { $0.value.willSend(alamoRequest, target: target) }
        
        var progressAlamoRequest = alamoRequest
        let progressClosure: (Progress) -> Void = { progress in
            let sendProgress: () -> Void = {
                progressCompletion?(ProgressResponse(progress: progress))
            }
            
            if let callbackQueue = callbackQueue {
                callbackQueue.async(execute: sendProgress)
            } else {
                sendProgress()
            }
        }
        
        // Perform the actual request
        if progressCompletion != nil {
            switch progressAlamoRequest {
            case let downloadRequest as DownloadRequest:
                if let downloadRequest = downloadRequest.downloadProgress(closure: progressClosure) as? T {
                    progressAlamoRequest = downloadRequest
                }
            case let uploadRequest as UploadRequest:
                if let uploadRequest = uploadRequest.uploadProgress(closure: progressClosure) as? T {
                    progressAlamoRequest = uploadRequest
                }
            default: break
            }
        }
        
        let completionHandler: RequestableCompletion = { response, request, data, error in
            let result = convertResponseToResult(response, request: request, data: data, error: error)
            // Inform all plugins about the response
            plugins.forEach { $0.value.didReceive(result, target: target) }
            progressCompletion?(ProgressResponse(response: result.value))
            completion(result)
        }
        
        progressAlamoRequest = progressAlamoRequest.response(callbackQueue: callbackQueue, completionHandler: completionHandler)
        
        progressAlamoRequest.resume()
        
        return CancellableToken(request: progressAlamoRequest)
    }
}

// MARK: RequestMultipartFormData appending

internal extension Provider {
    func append(data: Data, bodyPart: MultipartFormData, to form: RequestMultipartFormData) {
        if let mimeType = bodyPart.mimeType {
            if let fileName = bodyPart.fileName {
                form.append(data, withName: bodyPart.name, fileName: fileName, mimeType: mimeType)
            } else {
                form.append(data, withName: bodyPart.name, mimeType: mimeType)
            }
        } else {
            form.append(data, withName: bodyPart.name)
        }
    }
    func append(fileURL url: URL, bodyPart: MultipartFormData, to form: RequestMultipartFormData) {
        if let fileName = bodyPart.fileName, let mimeType = bodyPart.mimeType {
            form.append(url, withName: bodyPart.name, fileName: fileName, mimeType: mimeType)
        } else {
            form.append(url, withName: bodyPart.name)
        }
    }
    func append(stream: InputStream, length: UInt64, bodyPart: MultipartFormData, to form: RequestMultipartFormData) {
        form.append(stream, withLength: length, name: bodyPart.name, fileName: bodyPart.fileName ?? "", mimeType: bodyPart.mimeType ?? "")
    }
}

/// Encode parameters for multipart/form-data
internal func multipartQueryComponents(_ key: String, _ value: Any) -> [(String, String)] {
    var components: [(String, String)] = []
    
    if let dictionary = value as? [String: Any] {
        for (nestedKey, value) in dictionary {
            components += multipartQueryComponents("\(key)[\(nestedKey)]", value)
        }
    } else if let array = value as? [Any] {
        for value in array {
            components += multipartQueryComponents("\(key)[]", value)
        }
    } else {
        components.append((key, "\(value)"))
    }
    
    return components
}

public func convertResponseToResult(_ response: HTTPURLResponse?, request: URLRequest?, data: Data?, error: Swift.Error?) ->
    Result<SwiftyWeibo.Response, SwiftyWeiboError> {
        switch (response, data, error) {
        case let (.some(response), data, .none):
            let response = SwiftyWeibo.Response(statusCode: response.statusCode, data: data ?? Data(), request: request, response: response)
            return .success(response)
        case let (.some(response), _, .some(error)):
            let response = SwiftyWeibo.Response(statusCode: response.statusCode, data: data ?? Data(), request: request, response: response)
            let error = SwiftyWeiboError.underlying(error, response)
            return .failure(error)
        case let (_, _, .some(error)):
            let error = SwiftyWeiboError.underlying(error, nil)
            return .failure(error)
        default:
            let error = SwiftyWeiboError.underlying(NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: nil), nil)
            return .failure(error)
        }
}

public extension Provider {
    
    /// Closure that defines the endpoints for the provider.
    public typealias EndpointClosure = (TargetType) -> Endpoint<TargetType>
    
    /// Closure that decides if and what request should be performed
    public typealias RequestResultClosure = (Result<URLRequest, SwiftyWeiboError>) -> Void
    
    /// Closure that resolves an `Endpoint` into a `RequestResult`.
    public typealias RequestClosure = (Endpoint<TargetType>, @escaping RequestResultClosure) -> Void
    
    /// Closure that decides if/how a request should be stubbed.
    public typealias StubClosure = (TargetType) -> SwiftyWeibo.StubBehavior
    
    /// Closure to be executed when a request has completed.
    public typealias Completion = (_ result: Result<SwiftyWeibo.Response, SwiftyWeiboError>) -> Void
    
    /// Closure to be executed when progress changes.
    public typealias ProgressBlock = (_ progress: ProgressResponse) -> Void
    
}
