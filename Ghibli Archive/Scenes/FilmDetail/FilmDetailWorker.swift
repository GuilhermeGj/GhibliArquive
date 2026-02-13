//
//  FilmService.swift
//  Ghibli Archive
//
//  Created by Guilherme Gonçalves de Oliveira Junior on 11/02/26.
//

import Foundation

protocol FilmDetailWorkerProtocol {
    func fetchFilmDetail(apiId: String) async throws -> FilmDetail
}

final class FilmDetailWorker: FilmDetailWorkerProtocol {
    
    private let networkManager: NetworkManager
    
    // MARK: - Initialization
    
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    // MARK: - Public Methods
    
    func fetchFilmDetail(apiId: String) async throws -> FilmDetail {
        print("🌐 Buscando detalhes do filme \(apiId)...")
        
        do {
            let filmDetailDTO = try await networkManager.request(
                endpoint: "/films/\(apiId)",
                type: FilmDetailDTO.self
            )
            
            let film = FilmDetail(from: filmDetailDTO)
            
            print("✅ Detalhes do filme carregados com sucesso")
            return film
            
        } catch let error as NetworkError {
            print("❌ Erro de rede: \(error.localizedDescription)")
            
            if case .httpError(let statusCode) = error, statusCode == 404 {
                throw FilmServiceError.filmNotFound
            }
            
            throw FilmServiceError.networkError(error)
            
        } catch {
            print("❌ Erro desconhecido: \(error)")
            throw FilmServiceError.unknown(error)
        }
    }
}

