//
//  DependencyContainer.swift
//  DependencyContainer
//
//  Created by bumslap on 15/03/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

import Foundation
import NetworkServiceProtocols
import NetworkService

public class DependencyContainer {
    
    private let dependencyPool = DependencyPool()
    
    public static let shared: DependencyContainer = DependencyContainer()
    
    private init() {
        
        let firebaseAuthService = NetworkDependencyContainer().buildServerAuth
        register(key: .firebaseAuth, value: firebaseAuthService)
        
        let firebaseDatabaseService = NetworkDependencyContainer().buildServerDatabase
        register(key: .firebaseDatabase, value: firebaseDatabaseService)
        
        let firebaseStorageService = NetworkDependencyContainer().buildServerStorage
        register(key: .firebaseStorage, value: firebaseStorageService)
        
        let firebaseServerManager = ServerManager()//ServiceFactory.createFoodOptionService(network: mockServer)
        register(key: .firebaseServer, value: firebaseServerManager)
        
    }
    
    
    private func register<T>(key: DependencyKey, dependency: T) {
        do {
            try dependencyPool.register(key: key, dependency: dependency)
        } catch DependencyError.keyAlreadyExistsError {
            fatalError("keyIsAlreadyRegistered \(key)")
        } catch DependencyError.downcastingFailureError {
            fatalError("castingError \(dependency)")
        } catch {
            fatalError("unknown Error\(dependency)")
        }
    }
    
    public func getDependency<T>(key: DependencyKey) -> T {
        do {
            return try dependencyPool.pullOutDependency(key: key)
        } catch DependencyError.unregisteredKeyError {
            fatalError("unregisteredKeyError \(key)")
        } catch DependencyError.downcastingFailureError {
            fatalError("downcastingFailureError \(key)")
        } catch {
            fatalError("failed getDependencyr \(key)")
        }
    }
    
}
public enum DependencyKey {
    case firebaseAuth
    case firebaseDatabase
    case firebaseStorage
    case firebaseServer
}
