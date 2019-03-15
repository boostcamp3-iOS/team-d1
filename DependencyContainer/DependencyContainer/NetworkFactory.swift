//
//  NetworkFactory.swift
//  BeBrav
//
//  Created by bumslap on 03/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//
/// Factory를 생성할 때 사용할 프로토콜을 모아놓은 파일입니다.
///

import Foundation
import NetworkServiceProtocols

protocol NetworkFactory {
    
    func buildServerDatabase() -> ServerDatabase
    
    func buildServerAuth() -> ServerAuth
    
    func buildServerStorage() -> ServerStorage
    
}

protocol NetworkSeperatorFactory {
    
    func buildDatabaseNetworkSeperator() -> NetworkSeparator
    
    func buildNetworStoragekSeperator() -> NetworkSeparator
    
    func buildNetworAuthkSeperator() -> NetworkSeparator
    
}

protocol ParserFactory {
    
    func buildJsonParser() -> JsonParser

}

protocol RequestMakerFactory {
    
    func buildRequestMaker() -> RequestMaker
    
}

protocol DispatcherFactory {
    
    func buildDatabaseDispatcher() -> Dispatcher
    
    func buildAuthDispatcher() -> Dispatcher
    
    func buildStorageDispatcher() -> Dispatcher
    
}
