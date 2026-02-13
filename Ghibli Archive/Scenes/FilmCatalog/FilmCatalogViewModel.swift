//
//  FilmCatalogViewModel.swift
//  Ghibli Archive
//
//  Created by Guilherme Gonçalves de Oliveira Junior on 11/02/26.
//

import Foundation

@Observable
final class FilmCatalogViewModel {
    
    // MARK: - Published Properties
    
    private(set) var films: [FilmListItem] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    
    var totalFilmsCount: Int {
        filmService.getTotalFilmsCount()
    }
    
    // MARK: - Dependencies
    
    private let filmService: FilmCatalogWorkerProtocol
    
    // MARK: - Initialization
    
    init(filmService: FilmCatalogWorkerProtocol? = nil) {
        self.filmService = filmService ?? FilmCatalogWorker(networkManager: NetworkManager.shared)
    }
    
    // MARK: - Public Methods

    @MainActor
    func loadFilms() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            films = try await filmService.fetchAllFilms()
        } catch {
            errorMessage = error.localizedDescription
            films = []
        }
        
        isLoading = false
    }
    
    @MainActor
    func refresh() async {
        await loadFilms()
    }
    
    func clearError() {
        errorMessage = nil
    }
}
