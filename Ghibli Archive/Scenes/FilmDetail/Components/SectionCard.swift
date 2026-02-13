//
//  SectionCard.swift
//  Ghibli Archive
//
//  Created by Guilherme Gonçalves de Oliveira Junior on 12/02/26.
//
import SwiftUI

// MARK: - Style Scheme
struct SectionCardStyleScheme {
    let titleColor: Color
    let borderColor: Color
    
    // Predefined styles
    static let primary = SectionCardStyleScheme(
        titleColor: Color(red: 0.6, green: 0.15, blue: 0.25),
        borderColor: Color(red: 0.6, green: 0.15, blue: 0.25)
    )
    
    static let secondary = SectionCardStyleScheme(
        titleColor: Color(red: 0.85, green: 0.65, blue: 0.25),
        borderColor: Color(red: 0.85, green: 0.65, blue: 0.25)
    )
    
    static let synopsis = SectionCardStyleScheme(
        titleColor: Color(red: 0.6, green: 0.15, blue: 0.25),
        borderColor: Color(red: 0.6, green: 0.15, blue: 0.25)
    )
    
    static let director = SectionCardStyleScheme(
        titleColor: Color(red: 0.85, green: 0.65, blue: 0.25),
        borderColor: Color(red: 0.85, green: 0.65, blue: 0.25)
    )
    
    static let producer = SectionCardStyleScheme(
        titleColor: Color(red: 0.6, green: 0.15, blue: 0.25),
        borderColor: Color(red: 0.6, green: 0.15, blue: 0.25)
    )
}

// MARK: - SectionCard View
struct SectionCard: View {
    let styleScheme: SectionCardStyleScheme
    let title: String
    let content: String
    
    // New initializer with style scheme
    init(styleScheme: SectionCardStyleScheme, title: String, content: String) {
        self.styleScheme = styleScheme
        self.title = title
        self.content = content
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                Circle()
                    .fill(styleScheme.titleColor)
                    .frame(width: 12, height: 12)
                
                Text(title)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(styleScheme.titleColor)
                
                Circle()
                    .fill(Color(red: 0.85, green: 0.65, blue: 0.25))
                    .frame(width: 12, height: 12)
            }
            
            Text(content)
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.black.opacity(0.8))
                .lineSpacing(6)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(24)
        .background(Color.white)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(styleScheme.borderColor, lineWidth: 3)
        )
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 20)
    }
}
