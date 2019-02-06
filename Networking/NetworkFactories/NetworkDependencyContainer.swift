//
//  NetworkDependencyContainer.swift
//  BeBrav
//
//  Created by bumslap on 03/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

/// NetworkDependencyContainer는 을 각 Factory 프로토콜을 구현한 구조체로서 각각의 네트워크
/// 구성요소를 자동으로 만들어주는 역할을 하는 container 입니다.


import Foundation

struct NetworkDependencyContainer {}

extension NetworkDependencyContainer: NetworkFactory {
    func buildServerDatabase() -> ServerDatabase {
        let jsonParser = buildJsonParser()
        let serverDatabaseSeperator = buildDatabaseNetworkSeperator()
        let serverDatabase = ServerDatabase(seperator: serverDatabaseSeperator,
                                            parser: jsonParser)
        return serverDatabase
    }
    
    func buildServerAuth() -> ServerAuth {
        let jsonParser = buildJsonParser()
        let serverAuthSeperator = buildNetworAuthkSeperator()
        let serverAuth = ServerAuth(seperator: serverAuthSeperator,
                                    parser: jsonParser)
        return serverAuth
    }
    
    func buildServerStorage() -> ServerStorage {
        let jsonParser = buildJsonParser()
        let serverStorageSeperator = buildNetworStoragekSeperator()
        let serverStorage = ServerStorage(seperator: serverStorageSeperator,
                                          parser: jsonParser)
        return serverStorage
    }
}

extension NetworkDependencyContainer: NetworkSeperatorFactory {
    func buildNetworStoragekSeperator() -> NetworkSeparator {
        let dispatcher = buildStorageDispatcher()
        let requestMaker = buildRequestMaker()
        let networkSeparator = NetworkSeparator(dispatcher: dispatcher,
                                                requestMaker: requestMaker)
        return networkSeparator
    }
    
    func buildNetworAuthkSeperator() -> NetworkSeparator {
        let dispatcher = buildAuthDispatcher()
        let requestMaker = buildRequestMaker()
        let networkSeparator = NetworkSeparator(dispatcher: dispatcher,
                                                requestMaker: requestMaker)
        return networkSeparator
    }
    
    func buildDatabaseNetworkSeperator() -> NetworkSeparator {
        let dispatcher = buildDatabaseDispatcher()
        let requestMaker = buildRequestMaker()
        let networkSeparator = NetworkSeparator(dispatcher: dispatcher,
                                                requestMaker: requestMaker)
        return networkSeparator
    }
}

extension NetworkDependencyContainer: DispatcherFactory {
    
    func buildDatabaseDispatcher() -> Dispatcher {
        return Dispatcher(baseUrl: FirebaseDatabase.reference.urlComponents?.url,
                          session: URLSession.shared)
    }
    
    func buildAuthDispatcher() -> Dispatcher {
            return Dispatcher(baseUrl: FirebaseAuth.auth.urlComponents?.url,
                              session: URLSession.shared)
    }
    
    func buildStorageDispatcher() -> Dispatcher {
            return Dispatcher(baseUrl: FirebaseStorage.storage.urlComponents?.url,
                              session: URLSession.shared)
    }
}

extension NetworkDependencyContainer: ParserFactory {
    func buildJsonParser() -> JsonParser {
        return JsonParser()
    }
}

extension NetworkDependencyContainer: RequestMakerFactory {
    func buildRequestMaker() -> RequestMaker {
        return RequestMaker()
    }
}

