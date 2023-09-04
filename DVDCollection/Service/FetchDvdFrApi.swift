//
//  FetchDvdFrApi.swift
//  DVDCollection
//
//  Created by Sam on 29/08/2023.
//

import Foundation

class FetchDvdFrApi {
    
    func getDvdFrInfo(barcode: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let sessionConfig = URLSessionConfiguration.default
        
        /* Create session, and optionally set a URLSessionDelegate. */
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        
        /* Create the Request: */
        
        guard var URL = URL(string: "https://www.dvdfr.com/api/search.php") else {return}
        let URLParams = [
            "gencode": "\(barcode)",
            "withActors": "null",
            "produit": "ALL",
        ]
        URL = URL.appendingQueryParameters(URLParams)
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"
        
        /* Start a new Task */
        //        let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
        //            if (error == nil) {
        //                // Success
        //                let statusCode = (response as! HTTPURLResponse).statusCode
        //                print("URL Session Task Succeeded: HTTP \(statusCode)")
        //                guard let xmlData = data else {return}
        //                //                do {
        //                print("xmlData: \(xmlData)")
        //                xmlParserDvdFr(xml: xmlData)
        //                //                } catch {
        //                //                    print (error)
        //                //                }
        //            }
        //            else {
        //                // Failure
        //                print("URL Session Task Failed: %@", error!.localizedDescription);
        //            }
        //        })
        //        task.resume()
        //        session.finishTasksAndInvalidate()
        //    }
        //}
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if let error = error {
                // Failure
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(error!))
                return
            }
            completion(.success(data))
            // Process the data and parse it into DVD objects
         //   ScannerDispatcher.self().parseDvdFrAPIResponse(xml: data)
            
//            if dvds.isEmpty {
//                completion(.failure(error))
//            } else {
//                completion(.success(dvds))
//            }
        }
        task.resume()
        session.finishTasksAndInvalidate()
    }
}


protocol URLQueryParameterStringConvertible {
    var queryParameters: String {get}
}

extension Dictionary : URLQueryParameterStringConvertible {
    /**
     This computed property returns a query parameters string from the given NSDictionary. For
     example, if the input is @{@"day":@"Tuesday", @"month":@"January"}, the output
     string will be @"day=Tuesday&month=January".
     @return The computed parameters string.
     */
    var queryParameters: String {
        var parts: [String] = []
        for (key, value) in self {
            let part = String(format: "%@=%@",
                              String(describing: key).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!,
                              String(describing: value).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
            parts.append(part as String)
        }
        return parts.joined(separator: "&")
    }
    
}

extension URL {
    /**
     Creates a new URL by adding the given query parameters.
     @param parametersDictionary The query parameter dictionary to add.
     @return A new URL.
     */
    func appendingQueryParameters(_ parametersDictionary : Dictionary<String, String>) -> URL {
        let URLString : String = String(format: "%@?%@", self.absoluteString, parametersDictionary.queryParameters)
        return URL(string: URLString)!
    }
}
