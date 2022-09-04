//
//  MockURLSession.swift
//  NetworkRequestTests
//
//  Created by 山本響 on 2022/09/04.
//

import Foundation
@testable import NetworkRequest

class MockURLSession: URLSesionProtocol {
    var dataTaskCallCount = 0
    var dataTaskArgsRequest: [URLRequest] = []
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        dataTaskCallCount += 1
        dataTaskArgsRequest.append(request)
        return DummyURLSessionDataTask()
    }

}

private class DummyURLSessionDataTask: URLSessionDataTask {
    override func resume() {
         
    }
}


