//
//  AppDelegate.swift
//  HackerBooks
//
//  Created by Alberto Marín García on 4/7/16.
//  Copyright © 2016 Alberto Marín García. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //MARK: - Properties
    var window: UIWindow?
    
    //MARK: - App life cycle
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        do {
            // Configuramos controladores, combinadores y sus delegados según el tipo de dispositivo
            let rootVC: UIViewController
            switch UIDevice.currentDevice().userInterfaceIdiom {
            case .Pad:
                rootVC = rootViewControllerForPad()
            case .Phone:
                rootVC = rootViewControllerForPhone()
            default:
                throw LibraryErrors.deviceNotSupported
            }
            
            // Asignar el rootVC
            window?.rootViewController = rootVC

            // Hacer visible & key a la window
            window?.makeKeyAndVisible()

            return true
        } catch {
            fatalError("Error while did finish launching with options")
        }
    }
    
    //MARK: - Memory
    func applicationDidReceiveMemoryWarning(application: UIApplication) {
        clearTmpDirectory()
    }
    
    func clearTmpDirectory() {
        do {
            let tmpDirectory = try NSFileManager.defaultManager().contentsOfDirectoryAtPath(NSTemporaryDirectory())
            for file in tmpDirectory {
                let path = "\(NSTemporaryDirectory())\(file)"
                try NSFileManager.defaultManager().removeItemAtPath(path)
            }
        } catch {
            print(error)
        }
    }
    
    //MARK: - Universal
    func rootViewControllerForPad() -> UIViewController {
        // Controladores
        let index = NSUserDefaults.standardUserDefaults().indexPathForKey(BookKey)
        let libraryVC = LibraryViewController(model: nil, selectedRow: index, autoSelectRow: true)
        let libraryNav = UINavigationController(rootViewController: libraryVC)
        
        // let initialBook = model.book(atIndex: 0)!
        let bookVC = BookViewController(model: nil)
        let bookNav = UINavigationController(rootViewController: bookVC)
        
        // Combinadores
        let splitVC = UISplitViewController()
        splitVC.viewControllers = [libraryNav, bookNav]
        
        // Delegados
        splitVC.delegate = bookVC
        libraryVC.setDelegate(bookVC)
        
        // Asignar el mismo tipo de letra en todas las barras de navegación
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Star Jedi", size: 20)!]

        return splitVC
    }

    func rootViewControllerForPhone() -> UIViewController {
        // Controladores
        let libraryVC = LibraryViewController(model: nil, selectedRow: nil, autoSelectRow: false)
        
        // Combinadores
        let libraryNav = UINavigationController(rootViewController: libraryVC)
        
        // Delegados
        libraryVC.setDelegate(libraryVC)
        
        // Asignar el mismo tipo de letra en todas las barras de navegación
        let navigationBarAppearace = UINavigationBar.appearance()
        navigationBarAppearace.titleTextAttributes = [NSFontAttributeName: UIFont(name: "Star Jedi", size: 15)!]

        return libraryNav
    }
}