//
//  SettingsViewController.swift
//  Mix
//
//  Created by Maxwell on 01/09/2017.
//  Copyright © 2017 Maxsey Inc. All rights reserved.
//

import UIKit
import RealmSwift

class SettingsViewController: UITableViewController {
    
    fileprivate let settingsArray: [[SettingConfigProtocol]] = [
        [SettingsConfig.Common.picture,
         SettingsConfig.Common.animation,
         SettingsConfig.Common.typeface,
         SettingsConfig.Common.statistics,
         ],
        [SettingsConfig.Advanced.cache],
        ]
    
    override func loadView() {
        super.loadView()
        tableView.registerClassOf(UITableViewCell.self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = NSLocalizedString("Settings", comment: "")
        
        if ((navigationController?.presentingViewController) != nil) {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "关闭", style: .done, target: self, action: #selector(SettingsViewController.closeSettings))
        }
    }
    
    @objc fileprivate func closeSettings() -> () {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return settingsArray.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsArray[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell()
        let setting: SettingConfigProtocol = settingsArray[indexPath.section][indexPath.row]
        cell.textLabel?.text = setting.title
        cell.imageView?.image = setting.image
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let setting: SettingConfigProtocol = settingsArray[indexPath.section][indexPath.row]
        switch setting {
        case SettingsConfig.Common.animation:
            if Theme.linkColor == UIColor.red {
                Theme.linkColor = UIColor.blue
            } else {
                Theme.linkColor = UIColor.red
            }
        default:
            break
        }
    }
    
}

fileprivate protocol SettingConfigProtocol {
    
    var title: String { get }
    
    var image: UIImage? { get }
    
}

extension SettingsViewController {
    
    fileprivate struct SettingsConfig {
        
        enum Common: SettingConfigProtocol {
            case picture
            case statistics
            case typeface
            case animation
            
            var title: String {
                switch self {
                case .picture:
                    return NSLocalizedString("Picture", comment: "")
                case .statistics:
                    return NSLocalizedString("Statistics", comment: "")
                case .typeface:
                    return NSLocalizedString("Typeface", comment: "")
                case .animation:
                    return NSLocalizedString("Animation", comment: "")
                }
            }
            
            var image: UIImage? {
                return nil
                switch self {
                case .picture:
                    return UIImage(named: "tabbar_home")!
                case .statistics:
                    return UIImage(named: "tabbar_message")!
                case .typeface:
                    return UIImage(named: "tabbar_discover")!
                case .animation:
                    return UIImage(named: "tabbar_profile")!
                }
            }
        }
        
        enum Advanced: SettingConfigProtocol {
            case cache
            
            var title: String {
                return NSLocalizedString("Cache", comment: "")
            }
            
            var image: UIImage? {
                return nil
            }
        }
        
    }
    
}




