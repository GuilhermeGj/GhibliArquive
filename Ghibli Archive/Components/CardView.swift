import SwiftUI

struct CardView: View {
    var imageURL: String?
    var filmNumber: Int?
    var title: String
    
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            AsyncImage(url: URL(string: imageURL ?? "")) { phase in
                switch phase {
                case .empty:
                    placeholderView
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 240)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                case .failure:
                    placeholderView
                @unknown default:
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.gray)
                }
            }
                .frame(height: 240)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(
                            Color(red: 0.8, green: 0.5, blue: 0.3),
                            lineWidth: 3
                        )
                )
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            
            if filmNumber != nil {
                Circle()
                    .fill(Color(red: 0.6, green: 0.15, blue: 0.25))
                    .frame(width: 48, height: 48)
                    .overlay(
                        Text("\(filmNumber ?? 0)")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .padding(12)
            }
        }
    }
}

private extension CardView {
    private var placeholderView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.2, green: 0.3, blue: 0.5),
                            Color(red: 0.1, green: 0.2, blue: 0.4)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            VStack {
                Spacer()
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
                Spacer()
            }
        }
    }
}
