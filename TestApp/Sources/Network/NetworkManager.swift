//
//  NetworkManager.swift
//  TestApp
//
//  Created by Sergey Kononov on 27.02.2021.
//  Copyright © 2021 . All rights reserved.
//

import Foundation


final class NetworkManager {
    let backendURL = URL(string: "https://api.fda.gov/")
    
    static var shared: NetworkManager = {
        let instance = NetworkManager()
        
        return instance
    }()
    
    // MARK: - Private
    private init() {}
    
    private func sendRequest(_ request: URLRequest, completionHandler: @escaping (Error?, Any?, TimeInterval) -> Void) {
        print("*** Request start:")
        print("request.URL = \(String(describing: request.url))")
        print("Request header = \(request.allHTTPHeaderFields ?? [:])")
        print("Request body = \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "")")
        
        let startDate = Date()
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            let requestTime = Date().timeIntervalSince(startDate)
            let httpResponse = response as? HTTPURLResponse
            let responseString = String(data: data!, encoding: .utf8)!
            
            print("*** Response:")
            print("HTTP status code = \(httpResponse!.statusCode)")
            print("response header = \(httpResponse!.allHeaderFields)")
            print("responseString = \(responseString)")
            print("error: \(String(describing: error))")
            
            var jsonData: Any?
            if let jsonObject = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments) as Any {
                jsonData = jsonObject
            }
            
            completionHandler(error, jsonData, requestTime)
            
        }).resume()
    }
    
    private func sendRequest(_ request: URLRequest, completionHandler: @escaping (Result<Data, Error>, TimeInterval) -> Void) {
        print("*** Request start:")
        print("request.URL = \(String(describing: request.url))")
        print("Request header = \(request.allHTTPHeaderFields ?? [:])")
        print("Request body = \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "")")
        
        let startDate = Date()
        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
            let requestTime = Date().timeIntervalSince(startDate)
            let httpResponse = response as? HTTPURLResponse
            let responseString = String(data: data!, encoding: .utf8)!
            
            print("*** Response:")
            print("HTTP status code = \(httpResponse!.statusCode)")
            print("response header = \(httpResponse!.allHeaderFields)")
            print("responseString = \(responseString)")
            print("error: \(String(describing: error))")
            
            guard let data = data, error == nil else {
                if let error = error {
                        completionHandler(.failure(error), requestTime)
                }
                return
            }
            
            completionHandler(.success(data), requestTime)
            
        }).resume()
    }
    
    // MARK: Requests
    
    private func requestForUrl(_ url: URL, httpMethod method: String, contentType: String = "application/json") -> URLRequest {
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 60.0)
        request.httpMethod = method
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        
        return request
    }
    
    private func requestForEndpointPath(_ endpointPath: String, httpMethod method: String, contentType: String = "application/json", queryItems: [URLQueryItem]? = nil) -> URLRequest? {
        guard var url = backendURL?.appendingPathComponent(endpointPath) else { return nil }
        
        if queryItems != nil {
            var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: true)
            urlComponents?.queryItems = queryItems
            
            if urlComponents?.url == nil {
                NSLog("Creating URL from urlComponents failed")
                return nil
            } else {
                url = (urlComponents?.url)!
            }
        }
        
        return requestForUrl(url, httpMethod: "GET")
    }

    
    // MARK: Test request
    
    private func testRequestForLoadingItems(itemsPerPage: Int) -> URLRequest? {
        let path = "food/enforcement.json"
        
        let queryItems = [
            URLQueryItem(name: "limit", value: "\(itemsPerPage)")
        ]
        
        var request = requestForEndpointPath(path, httpMethod: "GET", queryItems: queryItems)
        
        request?.setValue("application/json", forHTTPHeaderField: "Accept")
        
        return request
    }
    
    // MARK: - Public
    
    func loadTestItems(itemsPerPage: Int = 1, completion: @escaping (Result<[Item], Error>) -> Void) {
        guard let request = testRequestForLoadingItems(itemsPerPage: itemsPerPage) else {
            completion(.failure(NSError(domain: "request", code: 0, userInfo: [NSLocalizedDescriptionKey: "Something went wrong"])))
            return
        }
        
        sendRequest(request, completionHandler: { error, data, requestTime in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            } else {
                do {
                    guard let networkData = data as? Dictionary<String, Any> else {
                        completion(.failure(NSError(domain: "mapping", code: 0, userInfo: [NSLocalizedDescriptionKey: "Something went wrong"])))
                        return
                    }
                    
                    let items = try NetworkMapping.mappedObjects(from: networkData["results"], type: Item.self)
                    
                    DispatchQueue.main.async {
                        completion(.success(items))
                    }
                } catch let error as NSError {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        })
    }
    
    
}

extension NetworkManager: NSCopying {

    func copy(with zone: NSZone? = nil) -> Any {
        return self
    }
}
