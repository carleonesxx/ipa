import Foundation

enum APIError: LocalizedError { case invalidResponse; case unauthorized; case network(Error); case decoding(Error); case message(String); var errorDescription: String? { switch self { case .invalidResponse: return "Некорректный ответ сервера"; case .unauthorized: return "Сессия истекла"; case .network(let error): return error.localizedDescription; case .decoding: return "Не удалось прочитать данные"; case .message(let value): return value } } }

actor FITLYAPIClient {
    static let shared = FITLYAPIClient()
    private let baseURL: URL
    private let keychain = KeychainStore()
    private var token: String?
    private let decoder = JSONDecoder()

    init(baseURL: URL? = nil) { self.baseURL = baseURL ?? URL(string: Bundle.main.object(forInfoDictionaryKey: "FITLY_API_BASE_URL") as? String ?? "http://localhost:4000/api")!; token = keychain.read("access-token") }
    func setToken(_ value: String?) { token = value; if let value { try? keychain.save(value, key: "access-token") } else { keychain.delete("access-token") } }
    func currentToken() -> String? { token }

    func request<T: Decodable>(_ path: String, method: String = "GET", body: Encodable? = nil, retry: Bool = true) async throws -> T {
        let suffix = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        var request = URLRequest(url: URL(string: baseURL.absoluteString + "/" + suffix)!)
        request.httpMethod = method; request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let token { request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") }
        if let body { request.httpBody = try JSONEncoder().encode(AnyEncodable(body)) }
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
            if http.statusCode == 401, retry, token != nil { try await refresh(); return try await request(path, method: method, body: body, retry: false) }
            guard (200..<300).contains(http.statusCode) else { let payload = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]; throw APIError.message(payload?["error"] as? String ?? "Ошибка API (\(http.statusCode))") }
            if T.self == EmptyResponse.self { return EmptyResponse() as! T }
            do { return try decoder.decode(T.self, from: data) } catch { throw APIError.decoding(error) }
        } catch let error as APIError { throw error } catch { throw APIError.network(error) }
    }
    func refresh() async throws { guard token != nil else { throw APIError.unauthorized }; let response: AuthResponse = try await request("/auth/refresh", method: "POST", retry: false); setToken(response.token) }
    func login(email: String, password: String) async throws -> AuthResponse { let r: AuthResponse = try await request("/auth/login", method: "POST", body: Credentials(email: email, password: password), retry: false); setToken(r.token); return r }
    func register(name: String, email: String, password: String) async throws -> AuthResponse { let r: AuthResponse = try await request("/auth/register", method: "POST", body: RegisterBody(name: name, email: email, password: password), retry: false); setToken(r.token); return r }
    func logout() async { try? await request("/auth/logout", method: "POST", retry: false); setToken(nil) }
}

struct EmptyResponse: Decodable {}
private struct Credentials: Encodable { let email: String; let password: String }
private struct RegisterBody: Encodable { let name: String; let email: String; let password: String }
private struct AnyEncodable: Encodable { private let encodeClosure: (Encoder) throws -> Void; init(_ value: Encodable) { encodeClosure = value.encode }; func encode(to encoder: Encoder) throws { try encodeClosure(encoder) } }
