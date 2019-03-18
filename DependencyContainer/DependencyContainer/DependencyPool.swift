//
//  DependencyPool.swift
//  DependencyContainer
//
//  Created by bumslap on 15/03/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation

class DependencyPool {
    
    private var dependencyPool = [DependencyKey: Any]()
    
    func register<T>(key: DependencyKey, dependency: T) throws {
        
        guard dependencyPool[key] == nil else {
            throw DependencyError.keyAlreadyExistsError(key: key)
        }
        
        dependencyPool[key] = dependency
    }
    
    func pullOutDependency<T>(key: DependencyKey) throws -> T {
        
        guard let rawDependency = dependencyPool[key] else {
            throw DependencyError.unregisteredKeyError(key: key)
        }
        guard let dependency = rawDependency as? T else {
            throw DependencyError.downcastingFailureError(key: key)
        }
        return dependency
    }
    
   
}



enum DependencyError: Error {
    case keyAlreadyExistsError(key: DependencyKey)
    case unregisteredKeyError(key: DependencyKey)
    case downcastingFailureError(key: DependencyKey)
}
