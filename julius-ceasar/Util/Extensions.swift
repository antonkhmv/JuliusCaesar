//
//  Extensions.swift
//  julius-ceasar
//
//  Created by Anton Khomyakov on 07.05.2021.
//

import SwiftUI

extension NSColor {
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }

        return nil
    }
}

extension Color {
    static let Blue = Color(NSColor(hex: "#027abaff")!)
}

// util
extension View {
   @ViewBuilder func isHidden(_ shouldHide: Bool) -> some View {
       switch shouldHide {
       case true: self.hidden()
       case false: self
       }
   }
}

extension RangeReplaceableCollection {
   public mutating func cutTo(size: Int) {
       let c = count
       
       if c > size {
           let newEnd = index(startIndex, offsetBy: size)
           removeSubrange(newEnd ..< endIndex)
       }
   }
}

extension UserDefaults {

   func object<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
       guard let data = self.value(forKey: key) as? Data else { return nil }
       return try? decoder.decode(type.self, from: data)
   }

   func set<T: Codable>(object: T, forKey key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {
       let data = try? encoder.encode(object)
       self.set(data, forKey: key)
   }
   
   private enum Keys {
       static let users = "users"
       static let pictures = "pictures"
       static let chatPhotos = "profilePhotos"
   }

   class var users: [Int: UserInfo] {
       get { UserDefaults.standard.object([Int: UserInfo].self, with: Keys.users) ?? [:] }
       set { UserDefaults.standard.set(object: newValue, forKey: Keys.users) }
   }
   class var pictures: [Int: String?] {
       get { UserDefaults.standard.object([Int: String?].self, with: Keys.pictures) ?? [:] }
       set { UserDefaults.standard.set(object: newValue, forKey: Keys.pictures) }
   }
   class var chatPhotos: [Int64: String?] {
       get { UserDefaults.standard.object([Int64: String?].self, with: Keys.chatPhotos) ?? [:] }
       set { UserDefaults.standard.set(object: newValue, forKey: Keys.chatPhotos) }
   }
}
