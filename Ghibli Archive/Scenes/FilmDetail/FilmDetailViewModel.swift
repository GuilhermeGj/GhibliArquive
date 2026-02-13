//
//  FilmDetailViewModel.swift
//  Ghibli Archive
//
//  Created by Guilherme Gonçalves de Oliveira Junior on 11/02/26.
//

import Foundation

@Observable
final class FilmDetailViewModel {
    
    // MARK: - Published Properties
    
    private(set) var film: FilmDetail?
    private(set) var apiID: String
    private(set) var isLoading = false
    private(set) var errorMessage: String?
    private(set) var isDetailLoaded = false
    
    // MARK: - Dependencies
    
    private let filmService: FilmDetailWorkerProtocol
    
    // MARK: - Initialization
    
    init(apiID: String, filmService: FilmDetailWorkerProtocol? = nil) {
        self.apiID = apiID
        self.filmService = filmService ?? FilmDetailWorker(networkManager: NetworkManager.shared)
    }
    
    // MARK: - Public Methods
    
    @MainActor
    func loadFilmDetails() async {
        guard !isLoading, !isDetailLoaded else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let updatedFilm = try await filmService.fetchFilmDetail(apiId: apiID)
            film = updatedFilm
            isDetailLoaded = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func refresh() async {
        isDetailLoaded = false
        await loadFilmDetails()
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    var formattedDuration: String {
        let hours = (film?.duration ?? 0) / 60
        let minutes = film?.duration ?? 0 % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)min"
        } else {
            return "\(minutes)min"
        }
    }
    
    var formattedRating: String {
        "\(film?.rating ?? 0)/100"
    }
}
