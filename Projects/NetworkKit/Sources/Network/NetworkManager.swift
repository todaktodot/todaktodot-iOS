//
//  NetworkManager.swift
//  NetworkKit
//
//  Created by 임대진 on 11/25/24.
//

import Foundation
import RxSwift
public import Alamofire

public final class NetworkManager: Network {
    
    public var session: Session
    private static var _shared: NetworkManager?
    
    public static var shared: NetworkManager {
        guard let instance = _shared else {
            fatalError("NetworkManager.setup()이 호출 된 곳이 없습니다.")
        }
        return instance
    }
    
    public static func setup(tokenProvider: TokenProvider) {
        self._shared = NetworkManager(tokenProvider: tokenProvider)
    }
    
    private init(tokenProvider: TokenProvider? = nil) {
        let interceptor = TokenInterceptor(tokenProvider: tokenProvider)
        
        self.session = Session(
            interceptor: interceptor,
            eventMonitors: [APIEventMonitor()]
        )
    }
    
    public func request<E: Requestable>(with endpoint: E) -> Observable<E.Response> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NSError(domain: "Network Error", code: -1, userInfo: nil))
                return Disposables.create()
            }
            
            let request = self.session.request(endpoint.makeURL(),
                                               method: endpoint.method,
                                               parameters: endpoint.parameters,
                                               encoding: endpoint.encoding,
                                               headers: endpoint.headers)
                .validate()
                .responseDecodable(of: E.Response.self) { response in
                    switch response.result {
                    case .success(let data):
                        observer.onNext(data)
                        observer.onCompleted()
                    case .failure(let error):
                        if let data = response.data {
                            do {
                                let errorResponse = try JSONDecoder().decode(APIErrorResponse.self, from: data)
                                let customError = CustomAFError(underlyingError: error, message: errorResponse.message)
                                observer.onError(customError)
                            } catch {
                                observer.onError(error)
                            }
                        }
                    }
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    public func requestOptional<E: Requestable>(with endpoint: E) -> Observable<E.Response?> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NSError(domain: "Network Error", code: -1, userInfo: nil))
                return Disposables.create()
            }
            
            let request = self.session.request(endpoint.makeURL(),
                                               method: endpoint.method,
                                               parameters: endpoint.parameters,
                                               encoding: endpoint.encoding,
                                               headers: endpoint.headers)
                .validate()
                .responseDecodable(of: E.Response.self, emptyResponseCodes: Set(200..<300)) { response in
                    switch response.result {
                    case .success(let data):
                        observer.onNext(data)
                        observer.onCompleted()
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    public func upload<E: MultipartRequestable>(with endpoint: E) -> Observable<Bool> {
        return Observable.create { [weak self] observer in
            guard let self = self else {
                observer.onError(NSError(domain: "Network Error", code: -1, userInfo: nil))
                return Disposables.create()
            }
            
            let request = self.session.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(endpoint.jsonData, withName: endpoint.isCreate ? "createInsightCommand" : "updateInsightCommand", mimeType: "application/json")
                
                for (index, image) in endpoint.images.enumerated() {
                    if let imageData = image.jpegData(compressionQuality: 0.8) {
                        multipartFormData.append(imageData, withName: "mainImage", fileName: "image_\(index).jpeg", mimeType: "image/jpeg")
                    }
                }
            }, to: endpoint.makeURL(), method: endpoint.method, headers: endpoint.headers)
            .validate()
            .responseDecodable(of: E.Response.self) { response in
                switch response.result {
                case .success(let data):
                    observer.onNext(true)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
}
