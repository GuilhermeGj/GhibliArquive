//
//  FilmCatalogView.swift
//  Ghibli Archive
//
//  Created by Guilherme Gonçalves de Oliveira Junior on 11/02/26.
//

import SwiftUI


// MARK: - FilmCatalogView

struct FilmCatalogView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var viewModel = FilmCatalogViewModel()
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.97, blue: 0.95)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 8) {
                        
                        // MARK: - BackButton
                        backButton
                        
                        // MARK: - Header
                        headerTitleLabel
                        
                        // MARK: - Count
                        filmCountLabel
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    
                    // MARK: - FilmList
                    filmCatalog
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    
                    // MARK: - LoadingState
                    if viewModel.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                                .scaleEffect(1.5)
                                .padding()
                            Spacer()
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
            
            // MARK: - ErrorState
            if let errorMessage = viewModel.errorMessage {
                getErrorMessage(message: errorMessage)
            }
        }
        .navigationBarBackButtonHidden(true)
        
        // MARK: - Service
        .task {
            await viewModel.loadFilms()
        }
    }
}


// MARK: - Components

extension FilmCatalogView {
    var backButton: some View {
        Button(action: {
            coordinator.pop()
        }) {
            HStack(spacing: 8) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .semibold))
                Text("Voltar")
                    .font(.system(size: 20, weight: .semibold))
            }
            .foregroundColor(Color(red: 0.6, green: 0.15, blue: 0.25))
        }
        .padding(.top, 8)
    }
    
    var headerTitleLabel: some View {
        HStack(alignment: .center, spacing: 12) {
            Circle()
                .fill(Color(red: 0.6, green: 0.15, blue: 0.25))
                .frame(width: 12, height: 12)
            
            Text("Filmes")
                .font(.system(size: 56, weight: .bold))
                .foregroundColor(.black)
            
            Circle()
                .fill(Color(red: 0.85, green: 0.65, blue: 0.25))
                .frame(width: 12, height: 12)
        }
    }
    
    var filmCountLabel: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
                .font(.system(size: 16))
                .foregroundColor(Color(red: 0.65, green: 0.45, blue: 0.25))
            
            Text("\(viewModel.totalFilmsCount) filmes disponíveis")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(Color(red: 0.65, green: 0.45, blue: 0.25))
        }
        .padding(.top, 4)
    }
    
    var filmCatalog: some View {
        LazyVGrid(columns: columns, spacing: 24) {
            ForEach(viewModel.films) { film in
                FilmCardView(film: film)
                    .onTapGesture {
                        coordinator.navigateToFilmDetail(film.apiId)
                    }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
    
    func getErrorMessage(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(Color(red: 0.6, green: 0.15, blue: 0.25))
            
            Text(message)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Button("Tentar Novamente") {
                Task {
                    await viewModel.refresh()
                }
            }
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(red: 0.6, green: 0.15, blue: 0.25))
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 30)
    }
}
