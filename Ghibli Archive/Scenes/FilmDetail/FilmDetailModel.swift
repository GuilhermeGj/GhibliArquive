import Foundation


// MARK: - FilmDetailsResponse

struct FilmDetailDTO: Codable {
    let id: String
    let title: String
    let originalTitle: String
    let image: String
    let movieBanner: String
    let description: String
    let director: String
    let producer: String
    let releaseDate: String
    let runningTime: String
    let rtScore: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, image, description, director, producer
        case originalTitle = "original_title"
        case movieBanner = "movie_banner"
        case releaseDate = "release_date"
        case runningTime = "running_time"
        case rtScore = "rt_score"
    }
}


// MARK: - FilmDetailModel

struct FilmDetail: Identifiable, Hashable {
    let id: UUID
    let apiId: String
    let title: String
    let japaneseTitle: String
    let year: Int
    let rating: Int
    let duration: Int
    let synopsis: String
    let director: String
    let producer: String
    let imageName: String
    let bannerImageURL: String?
    
    init(id: UUID = UUID(),
        apiId: String,
        title: String,
        japaneseTitle: String,
        year: Int,
        rating: Int,
        duration: Int,
        synopsis: String,
        director: String,
        producer: String,
        imageName: String,
        bannerImageURL: String?) {
        self.id = id
        self.apiId = apiId
        self.title = title
        self.japaneseTitle = japaneseTitle
        self.year = year
        self.rating = rating
        self.duration = duration
        self.synopsis = synopsis
        self.director = director
        self.producer = producer
        self.imageName = imageName
        self.bannerImageURL = bannerImageURL
    }
}


// MARK: - Conversion

extension FilmDetail {
    init(from dto: FilmDetailDTO) {
        self.id = UUID()
        self.apiId = dto.id
        self.title = dto.title
        self.japaneseTitle = dto.originalTitle
        self.year = Int(dto.releaseDate) ?? 0
        self.rating = Int(dto.rtScore) ?? 0
        self.duration = Int(dto.runningTime) ?? 0
        self.synopsis = dto.description
        self.director = dto.director
        self.producer = dto.producer
        self.imageName = dto.image
        self.bannerImageURL = dto.movieBanner
    }
}
