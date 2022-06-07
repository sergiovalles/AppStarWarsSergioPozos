//
//  NetworkManager.swift
//  starwars
//
//

import Foundation

enum GenericError: Error {
    case runtimeError(String)
}

final class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func doLogin(for name: String, password: String, success: @escaping (User) -> Void, failure: @escaping (_ error: String) -> Void) {
        let params = name.replacingOccurrences(of: " ", with: "+")
        let endpoint = Constants.kBaseUrl + "/people/?search=\(params)"
        
        guard let url = URL(string: endpoint) else {
            failure("Invalid request")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let _ = error {
                failure("Unable to complete your request")
                return
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                failure("Invalid response from the server")
                return
            }
            
            guard let data = data else {
                failure("Data received from the server was invalid")
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let result = try decoder.decode(UserSearchResponse.self, from: data)
                guard let user = result.results.first, let user = user else {
                    throw GenericError.runtimeError("User not found")
                }
                
                if user.hairColor != password {
                    throw GenericError.runtimeError("Wrong email or password")
                }
                success(user)
            } catch {
                failure("Data received from the server was invalid")
            }
        }
        
        task.resume()
    }
    
    func getFilms(urls filmsUrl: [String], completion: @escaping (Result<[Film], GenericError>) -> Void) {
        var filmsCollection: [Film] = []
        let urlDownloadQueue = DispatchQueue(label: "com.urlDownloader.urlqueue")
        let urlDownloadGroup = DispatchGroup()
        
        for urlString in filmsUrl {
            urlDownloadGroup.enter()
            guard let url = URL(string: urlString) else {
                urlDownloadQueue.async {
                    urlDownloadGroup.leave()
                    completion(.failure(GenericError.runtimeError("Invalid request")))
                }
                return
            }
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else {
                    // handle error
                    urlDownloadQueue.async {
                        urlDownloadGroup.leave()
                        completion(.failure(GenericError.runtimeError("Unable to get films")))
                    }
                    return
                }
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                guard var film = try? decoder.decode(Film.self, from: data) else {
                    // handle error
                    urlDownloadQueue.async {
                        urlDownloadGroup.leave()
                        completion(.failure(GenericError.runtimeError("Unable to get films")))
                    }
                    return
                }
                urlDownloadQueue.async {
                    film.openingCrawl = film.openingCrawl.replacingOccurrences(of: "\r\n", with: " ")
                    filmsCollection.append(film)
                    urlDownloadGroup.leave()
                }
            }
            task.resume()
        }
        
        urlDownloadGroup.notify(queue: DispatchQueue.global()) {
            completion(.success(filmsCollection))
        }
    }
    
    func getMovieCharacters(urls charactersUrl: [String], completion: @escaping (Result<[MovieCharacter], GenericError>) -> Void) {
        var charactersCollection: [MovieCharacter] = []
        let urlDownloadQueue = DispatchQueue(label: "com.urlDownloader.urlqueue")
        let urlDownloadGroup = DispatchGroup()
        
        for urlString in charactersUrl {
            urlDownloadGroup.enter()
            guard let url = URL(string: urlString) else {
                urlDownloadQueue.async {
                    urlDownloadGroup.leave()
                    completion(.failure(GenericError.runtimeError("Invalid request")))
                }
                return
            }
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data else {
                    // handle error
                    urlDownloadQueue.async {
                        urlDownloadGroup.leave()
                        completion(.failure(GenericError.runtimeError("Unable to get films")))
                    }
                    return
                }
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                guard var mCharacter = try? decoder.decode(MovieCharacter.self, from: data) else {
                    // handle error
                    urlDownloadQueue.async {
                        urlDownloadGroup.leave()
                        completion(.failure(GenericError.runtimeError("Unable to get films")))
                    }
                    return
                }
                urlDownloadQueue.async {
                    self.getHomeworld(for: mCharacter.homeworld, completion: { result in
                        switch result {
                        case .success(let planet):
                            mCharacter.homeworldName = planet.name
                        case .failure(let error):
                            urlDownloadQueue.async {
                                urlDownloadGroup.leave()
                                completion(.failure(GenericError.runtimeError(error.localizedDescription)))
                            }
                            return
                        }
                    })
                }
                
                urlDownloadQueue.async {
                    charactersCollection.append(mCharacter)
                    urlDownloadGroup.leave()
                }
            }
            task.resume()
        }
        
        urlDownloadGroup.notify(queue: DispatchQueue.global()) {
            completion(.success(charactersCollection))
        }
    }
    
    func getHomeworld(for url: String, completion: @escaping(Result<Planet, GenericError>) -> Void) {
        guard let url = URL(string: url) else {
            completion(.failure(GenericError.runtimeError("Invalid request")))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let _ = error {
                completion(.failure(GenericError.runtimeError("Unable to complete your request")))
                return
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                completion(.failure(GenericError.runtimeError("Invalid response from the server")))
                return
            }
            
            guard let data = data else {
                completion(.failure(GenericError.runtimeError("Data received from the server was invalid")))
                return
            }
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let result = try decoder.decode(Planet.self, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(GenericError.runtimeError("Data received from the server was invalid")))
            }
        }
        
        task.resume()
    }
    
}

