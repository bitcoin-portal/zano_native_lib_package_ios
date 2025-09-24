public enum Either<L, R> {
    case left(L)
    case right(R)
}

extension Either {

    public init(_ left: L) {
        self = .left(left)
    }

    public init(_ right: R) {
        self = .right(right)
    }

    public var left: L? {
        guard case .left(let left) = self else { return nil }
        return left
    }

    public var right: R? {
        guard case .right(let right) = self else { return nil }
        return right
    }
}

extension Either: Equatable where L: Equatable, R: Equatable {

    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.left(let lhs), .left(let rhs)):
            return lhs == rhs
        case (.right(let lhs), .right(let rhs)):
            return lhs == rhs
        default:
            return false
        }
    }
}

extension Either: Hashable where L: Hashable, R: Hashable {}

extension Either: Codable where L: Codable, R: Codable {

    public init(from decoder: Decoder) throws {
        if let left = try? L(from: decoder) {
            self.init(left)
        } else if let right = try? R(from: decoder) {
            self.init(right)
        } else {
            let errorDescription = "Data couldn't be decoded into either of the underlying types."
            let errorContext = DecodingError.Context(
                codingPath: decoder.codingPath, debugDescription: errorDescription)
            throw DecodingError.typeMismatch(Self.self, errorContext)
        }
    }

    public func encode(to encoder: Encoder) throws {
        switch self {
        case .left(let left):
            try left.encode(to: encoder)
        case .right(let right):
            try right.encode(to: encoder)
        }
    }
}

extension Either: CustomStringConvertible {

    public var description: String {
        switch self {
        case .left(let left):
            return "\(left)"
        case .right(let right):
            return "\(right)"
        }
    }
}
