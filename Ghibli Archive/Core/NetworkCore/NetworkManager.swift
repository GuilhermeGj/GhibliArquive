//
//  NetworkManager.swift
//  Ghibli Archive
//
//  Created by Guilherme Gonçalves de Oliveira Junior on 11/02/26.
//

import Foundation

/// Gerenciador de requisições de rede com isolamento no MainActor
@MainActor
final class NetworkManager {
    
    // MARK: - Singleton
    static let shared = NetworkManager()
    
    // MARK: - Properties
    private let baseURL = "https://ghibliapi.vercel.app"
    private let session: URLSession
    private let decoder: JSONDecoder
    
    // MARK: - Initialization
    private init() {
        // Configuração do URLSession com timeout customizado
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        self.session = URLSession(configuration: configuration)
        
        // Configuração do JSONDecoder
        self.decoder = JSONDecoder()
        // Não usar .convertFromSnakeCase pois o FilmDTO já faz o mapeamento manual via CodingKeys
    }
    
    // MARK: - Generic Request Method
    
    /// Realiza uma requisição HTTP genérica
    /// - Parameters:
    ///   - endpoint: Endpoint da API (ex: "/films")
    ///   - type: Tipo do objeto a ser decodificado
    /// - Returns: Objeto decodificado do tipo especificado
    func request<T: Decodable>(
        endpoint: String,
        type: T.Type
    ) async throws -> T {
        // 1. Construir URL
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        // 2. Criar Request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // 3. Executar Request
        let (data, response) = try await session.data(for: request)
        
        // 4. Validar Response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        // 5. Verificar Status Code
        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }
        
        // 6. Debug: Imprimir resposta (remover em produção)
        #if DEBUG
        if let jsonString = String(data: data, encoding: .utf8) {
            print("📥 Response from \(endpoint):")
            print(jsonString)
        }
        #endif
        
        // 7. Decodificar dados
        do {
            let decodedData = try decoder.decode(T.self, from: data)
            return decodedData
        } catch {
            print("❌ Decoding Error: \(error)")
            if let decodingError = error as? DecodingError {
                printDecodingError(decodingError)
            }
            throw NetworkError.decodingError(error)
        }
    }
    
    // MARK: - Helper Methods
    
    /// Imprime detalhes do erro de decodificação para facilitar debug
    private func printDecodingError(_ error: DecodingError) {
        switch error {
        case .keyNotFound(let key, let context):
            print("🔑 Key '\(key.stringValue)' not found: \(context.debugDescription)")
            print("📍 Coding path: \(context.codingPath)")
            
        case .typeMismatch(let type, let context):
            print("🔀 Type mismatch for type \(type): \(context.debugDescription)")
            print("📍 Coding path: \(context.codingPath)")
            
        case .valueNotFound(let type, let context):
            print("❓ Value not found for type \(type): \(context.debugDescription)")
            print("📍 Coding path: \(context.codingPath)")
            
        case .dataCorrupted(let context):
            print("💥 Data corrupted: \(context.debugDescription)")
            print("📍 Coding path: \(context.codingPath)")
            
        @unknown default:
            print("❓ Unknown decoding error: \(error)")
        }
    }
}

// MARK: - Network Errors

/// Erros de rede customizados
enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    case noInternetConnection
    case timeout
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL inválida. Verifique o endpoint."
            
        case .invalidResponse:
            return "Resposta inválida do servidor."
            
        case .httpError(let statusCode):
            switch statusCode {
            case 400:
                return "Requisição inválida (400)."
            case 401:
                return "Não autorizado (401)."
            case 403:
                return "Acesso negado (403)."
            case 404:
                return "Recurso não encontrado (404)."
            case 500...599:
                return "Erro no servidor (\(statusCode))."
            default:
                return "Erro HTTP (\(statusCode))."
            }
            
        case .decodingError:
            return "Erro ao processar os dados. Tente novamente."
            
        case .noInternetConnection:
            return "Sem conexão com a internet. Verifique sua conexão."
            
        case .timeout:
            return "Tempo esgotado. Tente novamente."
            
        case .unknown(let error):
            return "Erro desconhecido: \(error.localizedDescription)"
        }
    }
}

// MARK: - Service Errors

/// Erros possíveis do serviço de filmes
enum FilmServiceError: LocalizedError {
    case networkError(NetworkError)
    case filmNotFound
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let networkError):
            return networkError.localizedDescription
            
        case .filmNotFound:
            return "Filme não encontrado."
            
        case .unknown(let error):
            return "Erro inesperado: \(error.localizedDescription)"
        }
    }
}

