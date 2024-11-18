public struct JSONRPCError: Error, Equatable, Codable {
    // code should be `Int` but ZANO currently returns `String`
    public let code: String
    public let message: String
    public let data: AnyCodable?

    public init(code: String, message: String, data: AnyCodable? = nil) {
        self.code = code
        self.message = message
        self.data = data
    }
}
