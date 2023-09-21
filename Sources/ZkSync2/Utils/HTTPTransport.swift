//
//  HTTPTransport.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 7/24/22.
//

import Foundation
import Alamofire

protocol Transport {
    
    func send<Response: Decodable>(method: String,
                                   parameters: [JRPC.Parameter]?) async throws -> Response
    
    func send<Response: Decodable>(method: String,
                                   parameters: [JRPC.Parameter]?,
                                   queue: DispatchQueue) async throws -> Response
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
    
    func send<R>(method: String, parameters: [JRPC.Parameter]?) async throws -> R where R : Decodable {
        try await send(method: method,
             parameters: parameters,
             queue: .main)
    }
    
    func send<R>(method: String, parameters: [JRPC.Parameter]?, queue: DispatchQueue) async throws -> R where R : Decodable {
        let requestParameters = JRPC.Request(method: method, parameters: parameters)
        
#if DEBUG
        do {
            let encodedParameters = try JSONEncoder().encode(requestParameters)
            print("Encoded parameters: \(String(data: encodedParameters, encoding: .utf8)!)")
        } catch {
            print("Unable to encode parameters with error: \(error.localizedDescription)")
        }
#endif
        
        return try await withCheckedThrowingContinuation({ continuation in
            session.request(url,
                            method: .post,
                            parameters: requestParameters,
                            encoder: JSONParameterEncoder.default)
            .validate()
            .responseDecodable(queue: queue, decoder: JRPCDecoder()) { [weak self] (response: DataResponse<R, AFError>) in
                guard let self = self else { return }
                
#if DEBUG
                switch response.result {
                case .success(let result):
                    continuation.resume(with: .success(result))
                case .failure(let error):
                    let error = self.processAFError(error)
                    continuation.resume(throwing: error)
                    break
                }
#else
                completion(response.result.mapError({ self.processAFError($0) }))
#endif
            }
        })
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
            return ZkSyncError.invalidStatusCode(code: code)
        } else if case let AFError.sessionTaskFailed(error: taskError) = afError {
            return taskError
        }
        
        return afError
    }
}

class JRPCDecoder: DataDecoder {
    
    func decode<D>(_ type: D.Type, from data: Data) throws -> D where D: Decodable {
#if DEBUG
        if let json = try? JSONSerialization.jsonObject(with: data,
                                                        options: .mutableContainers),
           let jsonData = try? JSONSerialization.data(withJSONObject: json,
                                                      options: .prettyPrinted) {
            let responseString = String(decoding: jsonData, as: UTF8.self)
            print("Response data: \(D.Type.self) \(responseString)")
        }
#endif
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(DateFormatter.default)
        
        let response = try decoder.decode(JRPC.Response<D>.self, from: data)
        
        guard let result = response.result else {
            guard let error = response.error else {
                throw ZkSyncError.emptyResponse
            }
            throw ZkSyncError.rpcError(code: error.code, message: error.message)
        }
        return result
    }
}

enum ZkSyncError: LocalizedError {
    
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
