//
//  ViewControllerTests.swift
//  NetworkRequestTests
//
//  Created by 山本響 on 2022/09/04.
//

import XCTest
@testable import NetworkRequest

class ViewControllerTests: XCTestCase {

    func test_tappingButton_shouldMakeDataTaskToSearchForEBookOutFromBonevile() {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let sut: ViewController = sb.instantiateViewController(identifier: String(describing: ViewController.self))
        
        let mockURLSession = MockURLSession()
        sut.session = mockURLSession
        sut.loadViewIfNeeded()
        
        tap(sut.button)

        XCTAssertEqual(mockURLSession.dataTaskCallCount, 1, "call count")
        XCTAssertEqual(mockURLSession.dataTaskArgsRequest.first, URLRequest(url: URL(string: "https://itunes.apple.com/search?media=ebook&term=out%20from%20boneville")!), "request")
    }
    
}
