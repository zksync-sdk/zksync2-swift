//
//  HTTPTransport.swift
//  ZKSync2
//
//  Created by Maxim Makhun on 7/24/22.
//

import Foundation
import Alamofire

import Foundation

protocol Transport {
    
    func send<Parameters: Encodable, Response: Decodable>(method: String,
                                                          params: Parameters?,
                                                          completion: @escaping (Result<Response>) -> Void)
    
    func send<Parameters: Encodable, Response: Decodable>(method: String,
                                                          params: Parameters?,
                                                          queue: DispatchQueue,
                                                          completion: @escaping (Result<Response>) -> Void)
}

class HTTPTransport: Transport {
    
    private let url: URL
    private var session: Session
    
    init(_ url: URL) {
        self.url = url
        let configuration = URLSessionConfiguration.default
        var headers = configuration.httpAdditionalHeaders ?? [:]
        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        configuration.httpAdditionalHeaders = headers
        self.session = Session(configuration: configuration)
    }
    
    func send<P, R>(method: String,
                    params: P?,
                    completion: @escaping (Result<R>) -> Void) where P: Encodable, R: Decodable {
        send(method: method,
             params: params,
             queue: .main,
             completion: completion)
    }
    
    func send<P, R>(method: String,
                    params: P?,
                    queue: DispatchQueue,
                    completion: @escaping (Result<R>) -> Void) where P: Encodable, R: Decodable {
        session.request(url,
                        method: .post,
                        parameters: JRPC.Request(method: method, params: params),
                        encoder: JSONParameterEncoder.default)
        .validate()
        .responseDecodable(queue: queue, decoder: JRPCDecoder()) { [weak self] (response: DataResponse<R, AFError>) in
            guard let self = self else { return }
            
#if DEBUG
            switch response.result {
            case .success(let result):
                completion(.success(result))
            case .failure(let error):
                let error = self.processAFError(error)
                completion(.failure(error))
                break
            }
#else
            completion(response.result.mapError({ self.processAFError($0) }))
#endif
        }
    }
    
    private func processAFError(_ afError: AFError) -> Error {
        if case let AFError.responseSerializationFailed(reason) = afError {
            switch reason {
            case .customSerializationFailed(let error),
                    .decodingFailed(let error),
                    .jsonSerializationFailed(let error):
                return error
            default:
                return afError
            }
        } else if case let AFError.responseValidationFailed(reason) = afError,
                  case let .unacceptableStatusCode(code) = reason {
            return ZKSyncError.invalidStatusCode(code: code)
        } else if case let AFError.sessionTaskFailed(error: taskError) = afError {
            return taskError
        }
        
        return afError
    }
}

class JRPCDecoder: DataDecoder {
    
    func decode<D>(_ type: D.Type, from data: Data) throws -> D where D: Decodable {
        NSLog("Response data: \(D.Type.self) \(String(decoding: data, as: UTF8.self)) ")
        
        let response = try JSONDecoder().decode(JRPC.Response<D>.self, from: data)
        
        guard let result = response.result else {
            guard let error = response.error else {
                throw ZKSyncError.emptyResponse
            }
            throw ZKSyncError.rpcError(code: error.code, message: error.message)
        }
        return result
    }
}

enum ZKSyncError: LocalizedError {
    
    case emptyResponse
    case invalidStatusCode(code: Int)
    case rpcError(code: Int, message: String)
    
    var errorDescription: String? {
        switch self {
        case .rpcError(let code, let message):
            return "\(message) (\(code))"
        case .emptyResponse:
            return "Response is empty"
        case .invalidStatusCode(let code):
            return "Invalid status code: \(code)"
        }
    }
}
