import Accelerate

public enum LapackError: Error {
    case getrf(_: __CLPK_integer)
    case getri(_: __CLPK_integer)
    case dgesv(_: __CLPK_integer)
    case gesdd(_: __CLPK_integer)
}
