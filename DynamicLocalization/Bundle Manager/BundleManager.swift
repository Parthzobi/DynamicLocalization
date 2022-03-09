//
//  BundleManager.swift
//  DynamicLocalization
//
//  Created by Ashfaq Shaikh on 10/02/22.
//

import UIKit

class BundleManager: NSObject {

    static let share = BundleManager()
    var currentBundle = Bundle.main
    static let MyBundleName = "MyLocalizable.bundle"
    let manager = FileManager.default
    lazy var bundlePath: URL = {
        let documents = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!)
        let bundlePath = documents.appendingPathComponent(BundleManager.MyBundleName, isDirectory: true)
        return bundlePath
    }()
    
    func setCurrentBundle(forLanguage:String){
        do {
            currentBundle = try returnCurrentBundleForLanguage(lang: forLanguage)
        }catch {
            currentBundle = Bundle(path: getPathForLocalLanguage(language: "en"))!
        }
    }
    
    public func returnCurrentBundleForLanguage(lang:String) throws -> Bundle {
        if manager.fileExists(atPath: bundlePath.path) == false {
            return Bundle(path: getPathForLocalLanguage(language: lang))!
        }
        do {
            let resourceKeys : [URLResourceKey] = [.creationDateKey, .isDirectoryKey]
            _ = try manager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            let enumerator = FileManager.default.enumerator(at: bundlePath ,
                                                            includingPropertiesForKeys: resourceKeys,
                                                            options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
                                                                return true
            })!
            for case let folderURL as URL in enumerator {
                _ = try folderURL.resourceValues(forKeys: Set(resourceKeys))
                if folderURL.lastPathComponent == ("\(lang).lproj"){
                    let enumerator2 = FileManager.default.enumerator(at: folderURL,
                                                                     includingPropertiesForKeys: resourceKeys,
                                                                     options: [.skipsHiddenFiles], errorHandler: { (url, error) -> Bool in
                                                                        return true
                    })!
                    for case let fileURL as URL in enumerator2 {
                        _ = try fileURL.resourceValues(forKeys: Set(resourceKeys))
                        if fileURL.lastPathComponent == "Localizable.strings" {
                            return Bundle(url: folderURL)!
                        }
                    }
                }
            }
        } catch {
            return Bundle(path: getPathForLocalLanguage(language: lang))!
        }
        return Bundle(path: getPathForLocalLanguage(language: lang))!
    }
    
    public func getPathForLocalLanguage(language: String) -> String {
        return Bundle.main.path(forResource: language, ofType: "lproj")!
    }
    
    func writeNewLanguage(lang: String, translations: Dictionary<String,String>){
        let translations = translations
        let langName = lang
        let dict : Dictionary<String, Dictionary<String, String>> = [langName: translations]
        let rt = LocalizableWrite(translations:dict)
        do {
            _ = try rt.writeToBundle()
        }catch {
            print("error")
        }
    }
}
