//
//  AppDelegate.swift
//  HackerBooks
//
//  Created by Alberto Marín García on 4/7/16.
//  Copyright © 2016 Alberto Marín García. All rights reserved.
//

/*
Vainas que me faltan...
 
 1) Favoritos
 2) Ordenación Tags/Alphabetically
 3) Celda personalizada
 4) En JSONProcessing tengo que getLibraryFromRemote de manera asíncrona
 5) Subir mi código a GitHub usando SourceTree
 
 
 1) Crear repo en github, seleccionando la opción del readme
 2) Usando SourceTree, clonar el repo en el folder donde vaya a poner mi proy
 3) Usando SourceTree, hacer gitflow para conseguir la rama develop en local
 4) Crear mi proy con xcode sin indicarle nada de git
 5) Añadir al proy de xcode el .gitignore
 6) Usando SourceTree, hacer el commit estando en la rama develop
 7) Usando SourceTree, hacer push
 8) Usando SourceTree, seguir haciendo commits/pushs en la rama develop
 9) Para entregar la práctica y usando SourceTree, hacer un merge de la rama develop en la rama master
*/

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    //MARK: - Properties
    var window: UIWindow?
    
    //MARK: - App life cycle
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        do {
            // Creamos el modelo
            let json: JSONArray = try loadFrom(remoteURL: remoteLibraryUrl)
            var books = Set<Book>()
            for dict in json {
                do {
                    let book = try decode(book: dict)
                    books.insert(book)
                }
            }
            let model = Library(books: books)

            // Configuramos controladores, combinadores y sus delegados según el tipo de dispositivo
            let rootVC: UIViewController
            switch UIDevice.currentDevice().userInterfaceIdiom {
            case .Pad:
                rootVC = rootViewControllerForPad(model)
            case .Phone:
                rootVC = rootViewControllerForPhone(model)
            default:
                throw LibraryErrors.deviceNotSupported
            }

            // Asignar el rootVC
            window?.rootViewController = rootVC

            // Hacer visible & key a la window
            window?.makeKeyAndVisible()

            return true
        } catch {
            fatalError("Error while loading JSON")
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
    func rootViewControllerForPad(model: Library) -> UIViewController {
        // Controladores
        let index = NSUserDefaults.standardUserDefaults().indexPathForKey(BookKey)
        let libraryTVC = LibraryTableViewController(model: model, selectedRow: index)
        let libraryNav = UINavigationController(rootViewController: libraryTVC)
        
        let bookVC = BookViewController(model: model.book(atIndex: 0)!)
        let bookNav = UINavigationController(rootViewController: bookVC)

        // Combinadores
        let splitVC = UISplitViewController()
        splitVC.viewControllers = [libraryNav, bookNav]
        
        // Delegados
        splitVC.delegate = bookVC
        libraryTVC.delegate = bookVC
        
        return splitVC
    }

    func rootViewControllerForPhone(model: Library) -> UIViewController {
        // Controladores
        let libraryTVC = LibraryTableViewController(model: model, selectedRow: nil)

        // Combinadores
        let libraryNav = UINavigationController(rootViewController: libraryTVC)
        
        // Delegados
        libraryTVC.setDelegate(libraryTVC)
        
        return libraryNav
    }
}

