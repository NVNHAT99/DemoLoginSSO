//
//  KeychainManager.swift
//  LoginSSOTestApp
//
//  Created by Nhat Nguyen on 8/24/25.
//

import Foundation

protocol KeychainManagerProtocol {
    func saveObject<T: Codable> (_ object: T, for key: String) throws
    func readObject<T: Codable> (for key: String, as type: T.Type) -> T?
    func delete(for key: String)
}

final class KeychainManager: KeychainManagerProtocol {
    
    public static let shared = KeychainManager()
    
    private init () {}
    
    func saveObject<T>(_ object: T, for key: String) throws where T : Decodable, T : Encodable {
        let data = try JSONEncoder().encode(object)
        let query: [String : Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }
    
    func readObject<T>(for key: String, as type: T.Type) -> T? where T : Decodable, T : Encodable {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        guard status == errSecSuccess, let data = dataTypeRef as? Data else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
    
    func delete(for key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
