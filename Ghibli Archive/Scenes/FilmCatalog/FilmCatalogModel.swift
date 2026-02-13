import Foundation



// MARK: - FilmListResponse

struct FilmListDTO: Decodable {
    let id: String
    let title: String
    let originalTitle: String
    let image: String
    let releaseDate: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, image
        case originalTitle = "original_title"
        case releaseDate = "release_date"
    }
}


// MARK: - FilmCatalogModel

struct FilmListItem: Identifiable, Hashable {
    let id: UUID
    let apiId: String
    let title: String
    let japaneseTitle: String
    let year: Int
    let imageName: String
    let position: Int
    
    init(
        id: UUID = UUID(),
        apiId: String,
        title: String,
        japaneseTitle: String,
        year: Int,
        imageName: String,
        position: Int
    ) {
        self.id = id
        self.apiId = apiId
        self.title = title
        self.japaneseTitle = japaneseTitle
        self.year = year
        self.imageName = imageName
        self.position = position
    }
}


// MARK: - Conversion

extension FilmListItem {
    init(from dto: FilmListDTO, position: Int = 0) {
        self.id = UUID()
        self.apiId = dto.id
        self.title = dto.title
        self.japaneseTitle = dto.originalTitle
        self.year = Int(dto.releaseDate) ?? 0
        self.imageName = dto.image
        self.position = position
    }
}
