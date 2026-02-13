//
//  FilmDetailView.swift
//  Ghibli Archive
//
//  Created by Guilherme Gonçalves de Oliveira Junior on 11/02/26.
//

import SwiftUI


// MARK: - FilmDetailView

struct FilmDetailView: View {
    @Environment(AppCoordinator.self) private var coordinator
    @State private var viewModel: FilmDetailViewModel
    
    init(apiID: String) {
        self._viewModel = State(initialValue: FilmDetailViewModel(apiID: apiID))
    }
    
    var body: some View {
        ZStack {
            Color(red: 0.98, green: 0.97, blue: 0.95)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    ZStack(alignment: .topLeading) {
                        
                        // MARK: - FilmBannerImage
                        
                        if let bannerURL = viewModel.film?.bannerImageURL {
                            AsyncImage(url: URL(string: bannerURL)) { phase in
                                switch phase {
                                case .empty:
                                    defaltGradient
                                case .success(let image):
                                    getBackgroundImage(image: image)
                                case .failure:
                                   defaltGradient
                                @unknown default:
                                    defaltGradient
                                }
                            }
                        } else {
                            defaltGradient
                        }
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.6),
                                Color.black.opacity(0.3),
                                Color.clear
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 500)
                        
                        
                        // MARK: - HeaderView
                        
                        VStack(alignment: .leading, spacing: 0) {
                            backButton
                            Spacer()
                    
                            HStack {
                                CardView(imageURL: viewModel.film?.imageName,
                                         title: viewModel.film?.title ?? "Unknown")
                                .frame(width: 180)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                            
                            TitleAndTranslationLabels(title: viewModel.film?.title ?? "Unknow",
                                                      japaneseTitle: viewModel.film?.japaneseTitle ?? "Unkwown")
                            .padding(.bottom, 20)
                        }
                    }
                    
                    VStack(spacing: 20) {
                        
                        // MARK: - LoadingState
                        
                        if viewModel.isLoading {
                           isLoadingView
                        }
                        
                        // MARK: - ErrorState
                        
                        if let errorMessage = viewModel.errorMessage {
                            getErrorView(errorMessage: errorMessage)
                        }
                        
                        
                        // MARK: - InfoCards
                        
                        HStack(spacing: 16) {
                            InfoCard(styleScheme: InfoCardStyleScheme.year,
                                     label: "Ano",
                                     value: "\(viewModel.film?.year ?? 0000)")
                            InfoCard(styleScheme: InfoCardStyleScheme.duration,
                                     label: "Duraação",
                                     value: "\(viewModel.film?.duration ?? 00)\nmin")
                            InfoCard(styleScheme: InfoCardStyleScheme.rating,
                                     label: "Nota",
                                     value: viewModel.formattedRating)
                        }
                        .padding(.top, 30)
                        
                        
                        // MARK: - ProductionInfoCard
                        
                        SectionCard(styleScheme: SectionCardStyleScheme.synopsis,
                                    title: "SINOPSE",
                                    content: viewModel.film?.synopsis ?? ""
                        )
                        
                        SectionCard(styleScheme: SectionCardStyleScheme.director,
                                    title: "Diretor",
                                    content: viewModel.film?.director ?? ""
                        )
                        
                        SectionCard(styleScheme: SectionCardStyleScheme.producer,
                                    title: "Produtor",
                                    content: viewModel.film?.producer ?? ""
                        )
                        .padding(.bottom, 40)
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.loadFilmDetails()
        }
    }
}


// MARK: - Components

extension FilmDetailView {
    var backButton: some View {
        HStack {
            // Back button
            Button(action: {
                coordinator.pop()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .bold))
                    Text("Voltar")
                        .font(.system(size: 22, weight: .bold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Color(red: 0.6, green: 0.15, blue: 0.25)
                )
                .cornerRadius(25)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 50)
        .padding(.bottom, 30)
    }
    
    var isLoadingView: some View {
        HStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
                .padding()
            Spacer()
        }
    }
    
    func getErrorView(errorMessage: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 32))
                .foregroundColor(Color(red: 0.6, green: 0.15, blue: 0.25))
            
            Text(errorMessage)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black.opacity(0.7))
                .multilineTextAlignment(.center)
            
            Button("Tentar Novamente") {
                Task {
                    await viewModel.refresh()
                }
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(red: 0.6, green: 0.15, blue: 0.25))
            .cornerRadius(10)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }
    
    func getBackgroundImage(image: Image) -> some View {
        GeometryReader { geometry in
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: geometry.size.width)
                .clipped()
        }
    }
    
    var defaltGradient: some View {
        LinearGradient(
            colors: [
                Color(red: 0.4, green: 0.5, blue: 0.6),
                Color(red: 0.3, green: 0.4, blue: 0.5)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}
