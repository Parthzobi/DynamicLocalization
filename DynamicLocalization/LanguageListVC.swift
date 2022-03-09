//
//  LanguageListVC.swift
//  DynamicLocalization
//
//  Created by Ashfaq Shaikh on 10/02/22.
//

import UIKit
import MLKit

class tblLanguage: UITableViewCell{
    
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var btnCheckMark: UIButton!
    
}

class LanguageListVC: UIViewController {
    
    @IBOutlet weak var tblLanguageList: UITableView!
    @IBOutlet weak var btnApply: UIButton!

    var labelView:UIVisualEffectView = UIVisualEffectView()
    var labelVerifying:UILabel = UILabel()
    var spinner:UIActivityIndicatorView = UIActivityIndicatorView(style: .medium)
    var translator: Translator!
    let locale = Locale.current
    lazy var allLanguages = TranslateLanguage.allLanguages().sorted {
      return locale.localizedString(forLanguageCode: $0.rawValue)!
        < locale.localizedString(forLanguageCode: $1.rawValue)!
    }
    
    var selectedRow: Int = {
        if let index = TranslateLanguage.allLanguages().firstIndex(where: { $0 == .english }){
            return index.hashValue
        }
        return 0
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(
          self, selector: #selector(remoteModelDownloadDidComplete(notification:)),
          name: .mlkitModelDownloadDidSucceed, object: nil)
        NotificationCenter.default.addObserver(
          self, selector: #selector(remoteModelDownloadDidComplete(notification:)),
          name: .mlkitModelDownloadDidFail, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }

    static func instance() -> LanguageListVC{
        return UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LanguageListVC") as! LanguageListVC
    }
    
    func model(forLanguage: TranslateLanguage) -> TranslateRemoteModel {
      return TranslateRemoteModel.translateRemoteModel(language: forLanguage)
    }

    func isLanguageDownloaded(_ language: TranslateLanguage) -> Bool {
      let model = self.model(forLanguage: language)
      let modelManager = ModelManager.modelManager()
      return modelManager.isModelDownloaded(model)
    }
    
    @IBAction func btnApply(_ sender: UIButton){
        let index = self.selectedRow
        let language = allLanguages[index]
        if language == .english {
            BundleManager.share.setCurrentBundle(forLanguage: "en")
            LanguageManager.shared.setLanguage(language: .en) { title -> UIViewController in
                print("title of the scene: \(title ?? "")")
                // The view controller that you want to show after changing the language
                return self.viewControllerToShow()
            } animation: { view in
                // Do custom animation
                view.transform = CGAffineTransform(scaleX: 2, y: 2)
                view.alpha = 0
            }
          return
        }
        sender.setTitle("working...", for: .normal)
        let model = self.model(forLanguage: language)
        let modelManager = ModelManager.modelManager()
        let languageName = Locale.current.localizedString(forLanguageCode: language.rawValue)!
        let options = TranslatorOptions(sourceLanguage: .english, targetLanguage: language)
        translator = Translator.translator(options: options)
        if modelManager.isModelDownloaded(model) {
          /*self.statusTextView.text = "Deleting \(languageName)"
          modelManager.deleteDownloadedModel(model) { error in
            self.statusTextView.text = "Deleted \(languageName)"
            self.setDownloadDeleteButtonLabels()
          }*/
            self.getLocalizeFile { arrDic in
                print(arrDic)
                var stringDict: Dictionary<String, String> = Dictionary<String, String>()
                arrDic.forEach { (key, value) in
                    stringDict[key] = value
                }
                print(stringDict)
                let translations = stringDict
                let langName = language.rawValue
                let dict : Dictionary<String, Dictionary<String, String>> = [langName: translations]
                let rt = LocalizableWrite(translations:dict)
                do {
                    BundleManager.share.currentBundle = try rt.writeToBundle()
                    let lang = Languages.init(rawValue: language.rawValue)
                    BundleManager.share.setCurrentBundle(forLanguage: lang?.rawValue ?? "en")
                    LanguageManager.shared.setLanguage(language: lang!) { title -> UIViewController in
                        print("title of the scene: \(title ?? "")")
                        // The view controller that you want to show after changing the language
                        return self.viewControllerToShow()
                    } animation: { view in
                        // Do custom animation
                        view.transform = CGAffineTransform(scaleX: 2, y: 2)
                        view.alpha = 0
                    }
                }catch {
                    print("error")
                }
            }
            //self.dismiss(animated: true, completion: nil)
        } else {
          //self.statusTextView.text = "Downloading \(languageName)"
            self.showLoading(languageName: languageName)
          let conditions = ModelDownloadConditions(
            allowsCellularAccess: true,
            allowsBackgroundDownloading: true
          )
          modelManager.download(model, conditions: conditions)
        }
    }

    @objc
    func remoteModelDownloadDidComplete(notification: NSNotification) {
      let userInfo = notification.userInfo!
      guard
        let remoteModel =
          userInfo[ModelDownloadUserInfoKey.remoteModel.rawValue] as? TranslateRemoteModel
      else {
        return
      }
      weak var weakSelf = self
      DispatchQueue.main.async {
        guard let strongSelf = weakSelf else {
          print("Self is nil!")
          return
        }
          strongSelf.btnApply.setTitle("APPLY", for: .normal)
          strongSelf.dismissLoading()
        let languageName = Locale.current.localizedString(
          forLanguageCode: remoteModel.language.rawValue)!
        if notification.name == .mlkitModelDownloadDidSucceed {
          //strongSelf.statusTextView.text = "Download succeeded for \(languageName)"
            self.getLocalizeFile { arrDic in
                var stringDict: Dictionary<String, String> = Dictionary<String, String>()
                arrDic.forEach { (key, value) in
                    stringDict[key] = value
                }
                print(stringDict)
                let translations = stringDict
                let langName = remoteModel.language.rawValue
                let dict : Dictionary<String, Dictionary<String, String>> = [langName: translations]
                let rt = LocalizableWrite(translations:dict)
                do {
                    BundleManager.share.currentBundle = try rt.writeToBundle()
                    let lang = Languages.init(rawValue: langName)
                    BundleManager.share.setCurrentBundle(forLanguage: lang?.rawValue ?? "en")
                    LanguageManager.shared.setLanguage(language: lang!) { title -> UIViewController in
                        print("title of the scene: \(title ?? "")")
                        // The view controller that you want to show after changing the language
                        return self.viewControllerToShow()
                    } animation: { view in
                        // Do custom animation
                        view.transform = CGAffineTransform(scaleX: 2, y: 2)
                        view.alpha = 0
                    }
                }catch {
                    print("error")
                }
            }
        } else {
          //strongSelf.statusTextView.text = "Download failed for \(languageName)"
        }
        //strongSelf.setDownloadDeleteButtonLabels()
          self.dismiss(animated: true, completion: nil)
      }
    }
    
    private func viewControllerToShow() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateInitialViewController()!
    }
    
    func translate(inputText: String, complation: @escaping (String) -> ()){
      let translatorForDownloading = self.translator!

      translatorForDownloading.downloadModelIfNeeded { error in
        guard error == nil else {
            complation("Failed to ensure model downloaded with error \(error!)")
            return
        }
        if translatorForDownloading == self.translator {
          translatorForDownloading.translate(inputText) { result, error in
            guard error == nil else {
                complation("Failed with error \(error!)")
                return
            }
            if translatorForDownloading == self.translator {
                complation(result ?? "N/A")
                return
            }
          }
        }
      }
    }
}

extension LanguageListVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allLanguages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tblLanguage", for: indexPath) as! tblLanguage
        cell.lblName.text = Locale.current.localizedString(forLanguageCode: allLanguages[indexPath.row].rawValue)
        cell.btnCheckMark.isHidden = indexPath.row != self.selectedRow
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedRow = indexPath.row
        tableView.reloadData()
        self.btnApply.isHidden = false
    }
}

extension LanguageListVC{
    
    func getLocalizeFile(complation: @escaping ([(String, String)]) -> ()){
        guard let path = Bundle.main.url(forResource: "Localizable", withExtension: "strings", subdirectory: nil, localization: "en") else {
            return
        }
        guard let dict = NSDictionary(contentsOf: path) else {
            return
        }
        var dic = [(String, String)]()
        dict.forEach { (key, value) in
            dic.append((key as? String ?? "", value as? String ?? ""))
        }
        var count = 0
        getConvertedStr()
        func getConvertedStr(){
            for i in count..<dic.count{
                if i == count{
                    self.translate(inputText: dic[i].0) { result in
                        dic[i].1 = result
                        count += 1
                        getConvertedStr()
                    }
                }else{
                    break
                }
            }
            if count == dic.count{
                print("Finish...")
                complation(dic)
            }
        }
    }
}

extension LanguageListVC{
    
    func showLoading(languageName: String){
        let scene = UIApplication.shared.connectedScenes.first
        if let sd : SceneDelegate = (scene?.delegate as? SceneDelegate) {
            if  let window = sd.window {
                let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
                labelVerifying.removeFromSuperview()
                labelView.removeFromSuperview()
                labelVerifying = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 25))
                labelVerifying.textAlignment = .center
                labelVerifying.center = (window.center)
                labelVerifying.frame = CGRect(x: labelVerifying.frame.origin.x,
                                              y: labelVerifying.frame.origin.y + 40,
                                              width: labelVerifying.frame.width,
                                              height: labelVerifying.frame.height)
                labelVerifying.text = "Downloading \(languageName) Language Files"
                labelVerifying.textColor = UIColor.darkGray
                labelView.effect = blurEffect
                labelView.contentView.addSubview(spinner)
                labelView.backgroundColor = UIColor(white: 1, alpha: 1)
                labelView.contentView.addSubview(labelVerifying)
                labelView.frame = (window.bounds)
                spinner.center = ((window.center))
                spinner.startAnimating()
                
                window.addSubview(labelView)
                UIView.animate(withDuration: 0.2, animations: { [unowned self] () -> Void in
                    self.labelView.alpha = 1
                })
            }
        }
    }
    
    func dismissLoading() {
        DispatchQueue.main.async()  { [weak self] () -> Void in
            self?.labelView.removeFromSuperview()
            self?.labelVerifying.removeFromSuperview()
        }
    }
    
}
