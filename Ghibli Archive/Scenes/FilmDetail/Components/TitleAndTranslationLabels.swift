import SwiftUI

struct TitleAndTranslationLabels: View {
    var title: String
    var japaneseTitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 24))
                    .foregroundColor(.yellow)
                    .padding(.top, 4)
                
                Text(title)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Text(japaneseTitle)
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(.white.opacity(0.9))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
}
