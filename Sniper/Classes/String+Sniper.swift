import Foundation

extension String {
  public func localizedString() -> String {
    let localized = Sniper.sharedInstance.getString(self)
    if localized.characters.count > 0 {
      return localized
    }
    return self
  }
}

extension NSString {
  public func localizedString() -> NSString {
    let localized = Sniper.sharedInstance.getString(self as String)
    if localized.characters.count > 0 {
      return localized
    }
    return self
  }
}
