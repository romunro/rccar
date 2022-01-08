import Foundation

func secureRandomData(count: Int) throws -> Data {
    var bytes = [Int8](repeating: 0, count: count)

    // Fill bytes with secure random data
    let status = SecRandomCopyBytes(
        kSecRandomDefault,
        count,
        &bytes
    )
    
    // A status of errSecSuccess indicates success
    if status == errSecSuccess {
        // Convert bytes to Data
        let data = Data(bytes: bytes, count: count)
        return data
    }
    else {
        throw POSIXError(.EBADEXEC)
    }
}
