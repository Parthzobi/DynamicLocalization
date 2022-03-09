//
//  ViewController.swift
//  DynamicLocalization
//
//  Created by Ashfaq Shaikh on 09/02/22.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var lblHeading: UILabel!
    @IBOutlet weak var lblDes: UILabel!
    @IBOutlet weak var txtInput: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet weak var btnChangeLan: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.lblHeading.text = "Heading".customlocaliz()
        self.lblDes.text = "Description".customlocaliz()
        self.txtInput.placeholder = "Enter Text Here...".customlocaliz()
        self.btnSend.setTitle("Send".customlocaliz(), for: .normal)
        self.btnChangeLan.setTitle("Change Language".customlocaliz(), for: .normal)
    }

    @IBAction func btnChangeLan(_ sender: UIButton){
        /*let alert = UIAlertController.init(title: "Language", message: "Change Language", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "English", style: .default, handler: { action in
            self.changeLan(selectedLanguage: .en)
        }))
        alert.addAction(UIAlertAction.init(title: "Hindi", style: .default, handler: { action in
            self.changeLan(selectedLanguage: .hi)
        }))
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        */
        
        let vc = LanguageListVC.instance()
        self.navigationController?.pushViewController(vc, animated: true)
    }

    func changeLan(selectedLanguage: Languages){
        guard selectedLanguage != LanguageManager.shared.currentLanguage else { return }
        // Change the language
        LanguageManager.shared.setLanguage(language: selectedLanguage) { title -> UIViewController in
            print("title of the scene: \(title ?? "")")
            // The view controller that you want to show after changing the language
            return self.viewControllerToShow()
        } animation: { view in
            // Do custom animation
            view.transform = CGAffineTransform(scaleX: 2, y: 2)
            view.alpha = 0
        }
    }
    
    private func viewControllerToShow() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateInitialViewController()!
      }
}

