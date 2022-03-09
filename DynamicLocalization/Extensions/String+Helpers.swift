//
//  String+Helpers.swift
//  DynamicLocalization
//
//  Created by Ashfaq Shaikh on 09/02/22.
//

import Foundation

public extension String {

  ///
  /// Localize the current string to the selected language
  ///
  /// - returns: The localized string
  ///
  func localiz(comment: String = "") -> String {
    guard let bundle = Bundle.main.path(forResource: LanguageManager.shared.currentLanguage.rawValue,
                                        ofType: "lproj") else {
      return NSLocalizedString(self, comment: comment)
    }

    let langBundle = Bundle(path: bundle)
    return NSLocalizedString(self, tableName: nil, bundle: langBundle!, comment: comment)
  }

    func customlocaliz(comment: String = "") -> String {
//      guard let bundle = Bundle(path: BundleManager.share.getPathForLocalLanguage(language: "hi")) else {
//        return NSLocalizedString(self, comment: comment)
//      }
        let b = BundleManager.share.currentBundle
      //let langBundle = Bundle(path: bundle)
      return NSLocalizedString(self, tableName: nil, bundle: b, comment: comment)
    }
}
