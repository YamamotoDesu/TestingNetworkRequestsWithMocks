# TestingNetworkRequestsWithMocks
iOS Unit Testing by Example - Chapter 12

![image](https://user-images.githubusercontent.com/47273077/178744829-44543765-d038-4d50-938d-7fb790badb98.png)

```swift
class ViewController: UIViewController {
    
    @IBOutlet private(set) var button: UIButton!
    private var dataTask: URLSessionDataTask?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    
    @IBAction private func butoonTapped() {
        searchForBook(terms: "out from boneville")
    }
    
    private func searchForBook(terms: String) {
        guard let encodedTerms = terms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://itunes.apple.com/search?" +
                            "media=ebook&term=\(encodedTerms)") else { return }
        
        let request = URLRequest(url: url)
        dataTask = URLSession.shared.dataTask(with: request) { [weak self] (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            guard let self = self else { return }
            
            let decoded = String(data: data ?? Data(), encoding: .utf8)
            print("response: \(String(describing: response))")
            print("data: \(String(describing: decoded))")
            print("error: \(String(describing: error))")
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.dataTask = nil
                self.button.isEnabled = true
            }
        }
        button.isEnabled = false
        dataTask?.resume()
    }

}
```
---------

##  Isolate URLSession with Dependency Injection

```swift
import UIKit

// Extract a URLSession Protocol For Test Doubles
protocol URLSesionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: URLSesionProtocol { }

class ViewController: UIViewController {
    
    @IBOutlet private(set) var button: UIButton!
    private var dataTask: URLSessionDataTask?
    var session: URLSesionProtocol = URLSession.shared // Isolate URLSession with Dependency Injection
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
    }
    
    @IBAction private func butoonTapped() {
        searchForBook(terms: "out from boneville")
    }
    
    private func searchForBook(terms: String) {
        guard let encodedTerms = terms.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://itunes.apple.com/search?" +
                            "media=ebook&term=\(encodedTerms)") else { return }
        
        let request = URLRequest(url: url)
        dataTask = session.dataTask(with: request) { [weak self] (data: Data?, response: URLResponse?, error: Error?) -> Void in
            
            guard let self = self else { return }
            
            let decoded = String(data: data ?? Data(), encoding: .utf8)
            print("response: \(String(describing: response))")
            print("data: \(String(describing: decoded))")
            print("error: \(String(describing: error))")
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.dataTask = nil
                self.button.isEnabled = true
            }
        }
        button.isEnabled = false
        dataTask?.resume()
    }

}
```

## Make a Test Spy
```swift
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
```

## Design the Test Case

```swift
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
```
