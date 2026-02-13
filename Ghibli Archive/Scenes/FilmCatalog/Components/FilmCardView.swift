import SwiftUI

struct FilmCardView: View {
    let film: FilmListItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            CardView(imageURL: film.imageName,
                     filmNumber: film.position,
                     title: film.title)
            Text(film.title + "...")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
                .lineLimit(1)
            
            Text(film.japaneseTitle)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.gray)
                .lineLimit(1)

            HStack(spacing: 12) {
                Text("\(film.year)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.65, green: 0.45, blue: 0.25))
                
                // Placeholder para o rating (não disponível na lista)
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.85, green: 0.65, blue: 0.25))
                    
                    Text("--")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(Color(red: 0.98, green: 0.95, blue: 0.88))
                .cornerRadius(12)
            }
        }
    }
}

