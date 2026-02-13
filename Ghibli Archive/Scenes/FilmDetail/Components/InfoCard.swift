//
//  InfoCard.swift
//  Ghibli Archive
//
//  Created by Guilherme Gonçalves de Oliveira Junior on 12/02/26.
//
import SwiftUI

// MARK: - Style Scheme
struct InfoCardStyleScheme {
    let icon: String
    let iconColor: Color
    let backgroundColor: Color
    
    // Predefined styles
    static let year = InfoCardStyleScheme(
        icon: "calendar",
        iconColor: Color(red: 0.6, green: 0.15, blue: 0.25),
        backgroundColor: Color(red: 0.98, green: 0.94, blue: 0.90)
    )
    
    static let duration = InfoCardStyleScheme(
        icon: "clock",
        iconColor: Color(red: 0.6, green: 0.15, blue: 0.25),
        backgroundColor: Color(red: 0.98, green: 0.93, blue: 0.85)
    )
    
    static let rating = InfoCardStyleScheme(
        icon: "star.fill",
        iconColor: Color(red: 0.85, green: 0.65, blue: 0.25),
        backgroundColor: Color(red: 0.99, green: 0.96, blue: 0.88)
    )
}

// MARK: - InfoCard View
struct InfoCard: View {
    let styleScheme: InfoCardStyleScheme
    let label: String
    let value: String
    
    // New initializer with style scheme
    init(styleScheme: InfoCardStyleScheme, label: String, value: String) {
        self.styleScheme = styleScheme
        self.label = label
        self.value = value
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: styleScheme.icon)
                .font(.system(size: 32))
                .foregroundColor(styleScheme.iconColor)
            
            Text(label)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.brown.opacity(0.8))
            
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(styleScheme.backgroundColor)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}
