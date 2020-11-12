//
//  NetworkLayer.swift
//  GIFfit
//
//  Created by kishore Kumar on 27/10/20.
//

import Foundation

/// FetchType used to fetch the GIF with respective parameters
enum FetchType {
    case trend(offset:Int, limit:Int)
    case search(qurey:String, offset:Int, limit:Int)
    case favourite(gifIds:[String])

    var fetchURL:URL {
        var requestURL:URL
        switch self {
        case .favourite(let gifIds):
            requestURL = URL(string:"https://api.giphy.com/v1/gifs?api_key=\(AppConstants.shared.api_key)&ids=\(gifIds.joined(separator: ","))")!


        case .search(let qurey, let offset, let limit):
            let q = qurey.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""

            requestURL = URL(string:"https://api.giphy.com/v1/gifs/search?api_key=\(AppConstants.shared.api_key)&limit=\(limit)&offset=\(offset)&q=\(q)")!

            
        case .trend(let offset, let limit):
            requestURL = URL(string:"https://api.giphy.com/v1/gifs/trending?api_key=\(AppConstants.shared.api_key)&limit=\(limit)&offset=\(offset)")!
            
        }
        return requestURL
    }
}

func newJSONDecoder() -> JSONDecoder {
    let decoder = JSONDecoder()
    if #available(iOS 10.0, *) {
        decoder.dateDecodingStrategy = .iso8601
    }
    return decoder
}

func newJSONEncoder() -> JSONEncoder {
    let encoder = JSONEncoder()
    if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
        encoder.dateEncodingStrategy = .iso8601
    }
    return encoder
}

// MARK: - URLSession response handlers

typealias GiphyAPICompletion = (GiphyModel?, URLResponse?, Error?) -> Void

extension URLSession {
    /// Common request handling
    /// - Parameters:
    ///   - url: url
    ///   - completionHandler: compleion with Datamodel, response, error
    /// - Returns: DataTask
    fileprivate func codableTask<T: Codable>(with url: URL, completionHandler: @escaping (T?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        
        return self.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completionHandler(nil, response, error)
                return
            }
            completionHandler(try? newJSONDecoder().decode(T.self, from: data), response, nil)
        }
    }
    
    /// Fetch Giphymodel
    /// - Parameters:
    ///   - fetchType: Fetch type
    ///   - completionHandler: Completion with Giphy model
    /// - Returns: Data task
    @discardableResult
    func giphyModel(with fetchType: FetchType, completionHandler: @escaping GiphyAPICompletion) -> URLSessionDataTask {
        print(fetchType.fetchURL)
        return self.codableTask(with: fetchType.fetchURL, completionHandler: completionHandler)
    }
    
    /// Download single file
    /// - Parameters:
    ///   - model: GifCellViewModel
    ///   - completion: Completion with stored location url
    /// - Returns: Data task
    func download(model:GifCellViewModel, completion:@escaping (URL?)->()) -> URLSessionDataTask? {
        func createFile(for model:GifCellViewModel, data:Data?){
                        
            guard let fileData = data else {
                completion(nil)
                return
            }
            
            guard let url = FileManager.documentDirURL?.appendingPathComponent("\(model.id).gif") else {
                completion(nil)
                return
            }
            
            do {
                if FileManager.default.fileExists(atPath: url.absoluteString) {
                    try fileData.write(to: url, options: .atomic)
                }
                else {
                    try fileData.write(to: url, options: .atomic)
                }
                
                DispatchQueue.main.async {
                    completion(url)
                }
            }
            catch {
                completion(nil)
            }
        }
        guard let url = FileManager.documentDirURL?.appendingPathComponent("\(model.id).gif") else {
            completion(nil)
            return nil
        }
        
        if FileManager.default.fileExists(atPath: url.absoluteString) {
            completion(url)
            return nil
        }
        
        return URLSession.shared.dataTask(with: model.url!) { (data, resp, error) in
            DispatchQueue.global(qos: .background).async {
                createFile(for: model, data: data)
            }
        }

    }
}


