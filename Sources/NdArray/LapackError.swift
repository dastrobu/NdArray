public enum LapackError: Error {
    case getrf(_: Int32)
    case getri(_: Int32)
    case dgesv(_: Int32)
}
