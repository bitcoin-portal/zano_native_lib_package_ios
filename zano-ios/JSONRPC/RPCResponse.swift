public struct RPCResponse: Equatable {

    public let jsonrpc: String

    public let id: RPCID?

    public var result: AnyCodable? {
        if case .response(let value) = outcome { return value }
        return nil
    }

    public var error: JSONRPCError? {
        if case .error(let error) = outcome { return error }
        return nil
    }

    public let outcome: RPCResult

    public init(id: RPCID?, outcome: RPCResult) {
        self.jsonrpc = "2.0"
        self.id = id
        self.outcome = outcome
    }

    public init<C>(matchingRequest: RPCRequest, result: C) where C: Codable {
        self.init(id: matchingRequest.id, outcome: .response(AnyCodable(result)))
    }

    public init(matchingRequest: RPCRequest, error: JSONRPCError) {
        self.init(id: matchingRequest.id, outcome: .error(error))
    }

    public init<C>(id: Int64, result: C) where C: Codable {
        self.init(id: RPCID(id), outcome: .response(AnyCodable(result)))
    }

    public init<C>(id: String, result: C) where C: Codable {
        self.init(id: RPCID(id), outcome: .response(AnyCodable(result)))
    }

    public init<C>(id: RPCID, result: C) where C: Codable {
        self.init(id: id, outcome: .response(AnyCodable(result)))
    }

    public init(id: RPCID?, error: JSONRPCError) {
        self.init(id: id, outcome: .error(error))
    }

    public init(id: Int64, error: JSONRPCError) {
        self.init(id: RPCID(id), outcome: .error(error))
    }

    public init(id: String, error: JSONRPCError) {
        self.init(id: RPCID(id), outcome: .error(error))
    }

    public init(id: Int64, errorCode: String, message: String, associatedData: AnyCodable? = nil) {
        self.init(id: RPCID(id), outcome: .error(JSONRPCError(code: errorCode, message: message, data: associatedData)))
    }

    public init(id: String, errorCode: String, message: String, associatedData: AnyCodable? = nil) {
        self.init(id: RPCID(id), outcome: .error(JSONRPCError(code: errorCode, message: message, data: associatedData)))
    }

    public init(errorWithoutID: JSONRPCError) {
        self.init(id: nil, outcome: .error(errorWithoutID))
    }
}

extension RPCResponse: Codable {

    enum CodingKeys: CodingKey {
        case jsonrpc
        case result
        case error
        case id
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        jsonrpc = try container.decode(String.self, forKey: .jsonrpc)
        // Since ZANO returns "" for jsonrpc, the below guard should be removed
//        guard jsonrpc == "2.0" else {
//            throw DecodingError.dataCorruptedError(
//                forKey: .jsonrpc,
//                in: container,
//                debugDescription: "The JSON-RPC protocol version must be exactly \"2.0\".")
//        }
        id = try? container.decode(RPCID.self, forKey: .id)
        let result = try? container.decode(AnyCodable.self, forKey: .result)
        let error = try? container.decode(JSONRPCError.self, forKey: .error)
        if let result = result {
            guard error == nil else {
                throw DecodingError.dataCorrupted(.init(
                    codingPath: [CodingKeys.result, CodingKeys.error],
                    debugDescription: "Response is ambiguous: Both result and error members exists simultaneously."))
            }
            guard id != nil else {
                throw DecodingError.dataCorrupted(.init(
                    codingPath: [CodingKeys.result, CodingKeys.id],
                    debugDescription: "A success response must have a valid `id`."))
            }
            outcome = .response(result)
        } else if let error = error {
            outcome = .error(error)
        } else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: [CodingKeys.result, CodingKeys.error],
                debugDescription: "Couldn't find neither a result nor an error in the response."))
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(jsonrpc, forKey: .jsonrpc)
        try container.encode(id, forKey: .id)
        switch outcome {
        case .response(let anyCodable):
            try container.encode(anyCodable, forKey: .result)
        case .error(let rpcError):
            try container.encode(rpcError, forKey: .error)
        }
    }
}
