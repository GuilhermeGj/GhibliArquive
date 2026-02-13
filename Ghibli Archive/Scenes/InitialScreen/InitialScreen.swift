//
//  InitialScreen.swift
//  Ghibli Archive
//
//  Created by Guilherme Gonçalves de Oliveira Junior on 11/02/26.
//

import SwiftUI

struct InitialScreen: View {
    @Environment(AppCoordinator.self) private var coordinator
    
    var body: some View {
        NavigationStack(path: Binding(
            get: { coordinator.path },
            set: { coordinator.path = $0 }
        )) {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.55, green: 0.35, blue: 0.25),
                        Color(red: 0.45, green: 0.30, blue: 0.20)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                WavePatternView()
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(Color.yellow)
                            .frame(width: 40, height: 40)
                            .offset(x: 120, y: -80)
                        
                        Circle()
                            .fill(Color.pink.opacity(0.7))
                            .frame(width: 30, height: 30)
                            .offset(x: -120, y: 80)
                        
                        RoundedRectangle(cornerRadius: 30)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.7, green: 0.2, blue: 0.3),
                                        Color(red: 0.6, green: 0.15, blue: 0.25)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 200, height: 200)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.8, green: 0.5, blue: 0.3),
                                                Color(red: 0.7, green: 0.4, blue: 0.25)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 4
                                    )
                            )
                            .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                        
                        VStack(spacing: 0) {
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 50))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.green, Color(red: 0.4, green: 0.6, blue: 0.3)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .rotationEffect(.degrees(20))
                                .offset(x: 10, y: 10)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.5, green: 0.6, blue: 0.3),
                                            Color(red: 0.4, green: 0.5, blue: 0.2)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: 20, height: 80)
                                .offset(x: -15)
                        }
                    }
                    .padding(.top, 60)
                    
                    HStack(spacing: 8) {
                        Rectangle()
                            .fill(Color.yellow.opacity(0.8))
                            .frame(width: 40, height: 1)
                        
                        Text("STUDIO GHIBLI")
                            .font(.system(size: 16, weight: .medium, design: .default))
                            .tracking(3)
                            .foregroundColor(Color.yellow.opacity(0.9))
                        
                        Rectangle()
                            .fill(Color.yellow.opacity(0.8))
                            .frame(width: 40, height: 1)
                    }
                    .padding(.top, 20)
                    
                    Text("Bem-vindo")
                        .font(.system(size: 70, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Explore a coleção mágica\nque encantou gerações ao\nredor do mundo")
                        .font(.system(size: 18, weight: .regular))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 40)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    
                    Button(action: {
                        coordinator.navigateToFilmCatalog()
                    }) {
                        HStack(spacing: 12) {
                            Text("Começar")
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 65)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.7, green: 0.2, blue: 0.3),
                                    Color(red: 0.6, green: 0.15, blue: 0.25)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(35)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 30)
                    .padding(.bottom, 50)
                }
            }
            .navigationDestination(for: AppCoordinator.Destination.self) { destination in
                switch destination {
                case .filmCatalog:
                    FilmCatalogView()
                case .filmDetail(let apiId):
                    FilmDetailView(apiID: apiId)
                }
            }
        }
    }
}

struct WavePatternView: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<5) { index in
                    Wave(offset: Double(index) * 0.2)
                        .stroke(
                            Color.black.opacity(0.08),
                            lineWidth: 2
                        )
                        .offset(y: CGFloat(index) * geometry.size.height / 5)
                }
            }
        }
    }
}

struct Wave: Shape {
    var offset: Double
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let wavelength = rect.width / 2
        let amplitude: CGFloat = 30
        
        path.move(to: CGPoint(x: 0, y: rect.midY))
        
        for x in stride(from: 0, through: rect.width, by: 5) {
            let relativeX = x / wavelength
            let sine = sin((relativeX + offset) * .pi)
            let y = amplitude * sine + rect.midY
            
            path.addLine(to: CGPoint(x: x, y: y))
        }
        
        return path
    }
}
