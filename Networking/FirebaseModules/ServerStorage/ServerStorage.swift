//
//  StorageManager.swift
//  BeBrav
//
//  Created by bumslap on 02/02/2019.
//  Copyright © 2019 bumslap. All rights reserved.
//

/// ServerStorage는 initializer로 ResponseParser, NetworkSeparator를 받아서
/// 파이어베이스 Storage와 실제 통신하는 구조체입니다. 파이어베이스 실시간 데이터 베이스와는 다르게
/// 사진이나 동영상과 같은 데이터를 저장하는것을 위해 구현된 공간이기 때문에 HTTPMethod를 사용한다는
/// 것은 같으나 실시간 데이터 베이스와 상이한 방식으로 통신을 해야합니다. get 메서드 내부에서 먼저 원하는
/// 데이터를 GET 으로 요청하게 되면 HTTPHeader 안의 데이터로 ["x-goog-meta-firebasestoragedownloadtokens"]
/// 의 value인 download Token이 포함되어 오게 됩니다. 본래 URL에 위 토큰을 append하여 같이 요청해주면
/// 비로소 실제 이미지에 대한 download URL을 얻을 수 있게됩니다.
///
/// * NetworkSeperatable 는 공통적으로 사용하는  GET / POST / PATCH / PUT / DELETE 에 관한 메서드 방식을
/// 정의하는 프로토콜입니다. 초기화 시에는 이 프로토콜을 채택한 NetworkSeperator 구조체의 인스탠스를 인자로
/// 전달해야 합니다.
///
/// * ResponseParser 는 response의 유효성을 검증하고 JSON Parsing을 담당하는 프로토콜이며
/// 초기화 시에는 이 프로토콜을 채택한 JsonParser 구조체의 인스탠스를 인자로 전달해야 합니다.

import UIKit

struct ServerStorage: FirebaseService {
    
    let parser: ResponseParser
    let seperator: NetworkSeperatable
    
    init(seperator: NetworkSeperatable, parser: ResponseParser) {
        self.seperator = seperator
        self.parser = parser
    }
    
    
    /// GET 메서드를 통해서 파이어베이스 Storage에 접근하여 데이터를 가져옵니다.
    ///
    /// - Parameters:
    ///   - path: 디렉토리 형식으로 구현되어 있는 path에 접근하는 path입니다
    ///   - fileName: 가져오고 싶은 데이터의 이름을 입력합니다.
    ///   - completion: 메서드가 리턴된 이후에 호출되는 클로저입니다.
    /// - Returns: Result enum 타입으로 성공시 토큰이 포함된 주소값을 감싸서 연관 값으로 전달합니다.
    ///            실패시 Error를 전달합니다.
    func get(path: String,
             fileName: String,
             completion: @escaping (Result<String>) -> Void) {
        seperator.read(path: "\(path)%2F\(fileName)") { (result, response) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success:
                guard let extractedData =
                    self.parser.parseResponse(response: response,
                                              mimeType: MimeType.jpeg)
                        as? HTTPURLResponse else {
                    completion(.failure(APIError.responseUnsuccessful))
                    return
                }
                guard let token =
                    extractedData.allHeaderFields["x-goog-meta-firebasestoragedownloadtokens"]
                        as? String else {
                    completion(.failure(APIError.invalidData))
                    return
                }
                guard let urlString = extractedData.url?.absoluteString else {
                    completion(.failure(APIError.invalidData))
                    return
                }
                completion(.success("\(urlString)&token=\(token)"))
                return
            }
        }
    }
    
    
    /// POST 메서드를 통해서 파이어베이스 Storage에 접근하여 인자로 넘겨준 데이터를 업로드합니다.
    ///
    /// - Parameters:
    ///   - image: 전달할 이미지 데이터이며, UIImage를 인자로 전달하면 내부에서 바이너리 형식으로 바꿔주게 됩니다.
    ///   - scale: 전달할 이미지를 얼마나 스케일링 해줄지 결정하는 인자입니다.
    ///   - path: 디렉토리 형식으로 구현되어 있는 path에 접근하는 path입니다
    ///   - fileName: 저장하고 싶은 데이터의 이름을 입력합니다.
    ///   - completion: 메서드가 리턴된 이후에 호출되는 클로저입니다.
    /// - Returns: Result enum 타입으로 성공시 토큰이 포함된 주소값을 감싸서 연관 값으로 전달합니다.
    ///            실패시 Error를 전달합니다.
    func post(image: UIImage, scale: CGFloat, path: String, fileName: String,
              completion: @escaping (Result<URLResponse?>)->()) {
        guard let scaledImage = image.jpegData(compressionQuality: scale) else {
            completion(.failure(APIError.invalidData))
            return
        }
        seperator.write(path: "\(path)%2F\(fileName)",
                        data: scaledImage,
                        method: .post,
                        headers: ["Content-Type": MimeType.jpeg.rawValue])
        { (result, response) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success:
                completion(.success(response))
            }
        }
    }
    
    
    /// DELETE 메서드를 통해서 파이어베이스 Storage에 접근하여 해당 위치의 파일을 삭제합니다.
    ///
    /// - Parameters:
    ///   - path: 디렉토리 형식으로 구현되어 있는 path에 접근하는 path입니다
    ///   - fileName: 저장하고 싶은 데이터의 이름을 입력합니다.
    ///   - completion: 메서드가 리턴된 이후에 호출되는 클로저입니다.
    /// - Returns: Result enum 타입으로 성공시 response를 감싸서 연관 값으로 전달합니다.
    ///            실패시 Error를 전달합니다.
    /// - caution: 데이터를 삭제한 이후 비동기적인 상황에서 안전하지 않으므로 다른 작업시
    ///            completion을 이용해서 처리해야합니다.
    func delete(path: String,
                fileName: String,
                completion: @escaping (Result<URLResponse?>) -> Void) {
        self.seperator.delete(path: "\(path)%2F\(fileName)") { (result) in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let response):
                completion(.success(response))
                return
            }
        }
    }
}
