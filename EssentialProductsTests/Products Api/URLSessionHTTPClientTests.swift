//
//  URLSessionHTTPClientTests.swift
//  EssentialProductsTests
//
//  Created by Matteo Casu on 07/11/24.
//

import XCTest
import EssentialProducts

class URLSessionHTTPClient {
    
    let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        
        session.dataTask(with: url) { _, _, error in
            
            if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
}

final class URLSessionHTTPClientTests: XCTestCase {
    
    func test_getFromURL_failsOnRequestError() {
        
        URLProtocol.registerClass(URLProtocolStub.self)
        
        let url = URL(string: "https://example.com")!
        let anyError = NSError(domain: "test", code: 0)
        URLProtocolStub.stub(url: url, error: anyError)
        let sut = URLSessionHTTPClient()

        let exp = expectation(description: "Wait for completion")
        
        sut.get(from: url) { result in
            
            switch result {
            case .failure(let error):
                XCTAssertNotNil(error)
            default:
                XCTFail("Expected error: \(anyError) but got nil")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        URLProtocol.unregisterClass(URLProtocolStub.self)
    }
    
    
    private class URLProtocolStub: URLProtocol {
        private static var stubs = [URL: Stub]()
        
        private struct Stub {
            let error: Error?
        }
        
        static func stub(url: URL, error: Error? = nil) {
            stubs[url] = Stub(error: error)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            
            return URLProtocolStub.stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url, let stub = URLProtocolStub.stubs[url] else { return }
            
            if let error = stub.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
        }
        
        override func stopLoading() {}
    }

}
