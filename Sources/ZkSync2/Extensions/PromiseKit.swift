//
//  PromiseKit.swift
//  ZkSync2
//
//  Created by Maxim Makhun on 9/30/22.
//

import Foundation
import PromiseKit

public extension Swift.Result {
    
    var promiseResult: PromiseKit.Result<Success> {
        switch self {
        case .success(let success):
            return .fulfilled(success)
        case .failure(let error):
            return .rejected(error)
        }
    }
}

public extension PromiseKit.Resolver {
    
    func resolve(_ result: Swift.Result<T, Error>) {
        self.resolve(result.promiseResult)
    }
}

public extension PromiseKit.Result {
    
    var result: Swift.Result<T, Error> {
        switch self {
        case .fulfilled(let value):
            return .success(value)
        case .rejected(let error):
            return .failure(error)
        }
    }
}
