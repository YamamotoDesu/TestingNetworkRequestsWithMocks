//
//  ViewController.swift
//  NetworkRequest
//
//  Created by 山本響 on 2022/09/04.
//

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

