//
//  FilmService.swift
//  Ghibli Archive
//
//  Created by Guilherme Gonçalves de Oliveira Junior on 11/02/26.
//

import Foundation

protocol FilmCatalogWorkerProtocol {
    func fetchAllFilms() async throws -> [FilmListItem]
    func getTotalFilmsCount() -> Int
}

final class FilmCatalogWorker: FilmCatalogWorkerProtocol {
    
    // MARK: - Dependencies
    private let networkManager: NetworkManager
    
    // MARK: - Cache
    private var cachedFilms: [FilmListItem]?
    private var cacheTimestamp: Date?
    private let cacheValidityDuration: TimeInterval = 300
    
    // MARK: - Initialization
    init(networkManager: NetworkManager) {
        self.networkManager = networkManager
    }
    
    // MARK: - Public Methods

    func fetchAllFilms() async throws -> [FilmListItem] {
        if let cached = cachedFilms,
           let timestamp = cacheTimestamp,
           Date().timeIntervalSince(timestamp) < cacheValidityDuration {
            print("📦 Usando filmes do cache")
            return cached
        }
        
        print("🌐 Buscando filmes da API...")
        
        do {
            let filmListDTOs = try await networkManager.request(
                endpoint: "/films",
                type: [FilmListDTO].self
            )
            let films = filmListDTOs.enumerated().map { index, dto in
                FilmListItem(from: dto, position: index + 1)
            }
            
            let sortedFilms = films.sorted { $0.year < $1.year }

            cachedFilms = sortedFilms
            cacheTimestamp = Date()
            
            print("✅ \(films.count) filmes carregados com sucesso")
            return sortedFilms
            
        } catch let error as NetworkError {
            print("❌ Erro de rede: \(error.localizedDescription)")
            throw FilmServiceError.networkError(error)
            
        } catch {
            print("❌ Erro desconhecido: \(error)")
            throw FilmServiceError.unknown(error)
        }
    }
    
    func getTotalFilmsCount() -> Int {
        if let cached = cachedFilms {
            return cached.count
        }
        return 0
    }
    
    func clearCache() {
        cachedFilms = nil
        cacheTimestamp = nil
        print("🗑️ Cache limpo")
    }
    
    func forceRefresh() async throws -> [FilmListItem] {
        clearCache()
        return try await fetchAllFilms()
    }
}
