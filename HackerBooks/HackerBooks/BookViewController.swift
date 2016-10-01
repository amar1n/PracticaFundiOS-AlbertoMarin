//
//  BookViewController.swift
//  HackerBooks
//
//  Created by Alberto Marín García on 8/7/16.
//  Copyright © 2016 Alberto Marín García. All rights reserved.
//

import UIKit

class BookViewController: UIViewController, LibraryViewControllerDelegate, UISplitViewControllerDelegate {
    
    //MARK: - Properties
    @IBOutlet weak var authorsView: UILabel!
    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var tagsView: UILabel!
    var model: Book?
    
    //MARK: - Initialization
    init(model: Book?) {
        if (model != nil) {
            self.model = model
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Syncing
    func syncModelWithView() {
        guard let theModel = model else {
            return
        }
        
        authorsView.text = "de \(theModel.authors.joined(separator: ", "))"
        tagsView.text = "Etiquetas: \(theModel.tags.map({"\($0.name)"}).joined(separator: ", "))"
        coverView.image = theModel.coverImage.image
        title = theModel.title
        syncFavoriteTitle()
    }
    
    func syncFavoriteTitle() {
        let myToolBarArray = self.view.subviews.filter{$0 is UIToolbar}
        let myToolBar : UIToolbar = myToolBarArray[0] as! UIToolbar
        let favoriteButton = myToolBar.items![0]
        
        guard let theModel = model else {
            favoriteButton.title = "B A Z I N G A"
            return
        }
        
        if theModel.favorite {
            favoriteButton.title = "Quítame de favoritos..."
        } else {
            favoriteButton.title = "Hazme favorito!!!"
        }
    }

    //MARK: - Actions
    @IBAction func makeFavorite(_ sender: AnyObject) {
        guard let theModel = model else {
            return
        }
        
        theModel.favorite = !theModel.favorite
        syncModelWithView()
    }
    
    @IBAction func viewPdf(_ sender: AnyObject) {
        guard let theModel = model else {
            return
        }
        
        if theModel.pdfUrl != nil {
            let pdfVC = PDFViewController(model: theModel)
            
            // Hacer unpush sobre mi NavigationController
            navigationController?.pushViewController(pdfVC, animated: true)
        }
    }
    
    //MARK: - View life cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Alta en notificacion
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(imageDidChange), name: NSNotification.Name(rawValue: AsyncImageDidChangeNotification), object: nil)
        
        syncModelWithView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Baja en la notificacion
        let nc = NotificationCenter.default
        nc.removeObserver(self)
    }
    
    //MARK: - Utilities
    func imageDidChange(_ notification: Notification) {
        // Sincronizar las vistas
        DispatchQueue.main.async {
            self.syncModelWithView()
        }
    }
    
    //MARK: - LibraryViewControllerDelegate
    func libraryViewController(_ vc: LibraryViewController, didSelectBook book: Book) {
        // Actualizar el modelo
        model = book
        
        // Sincronizar las vistas con el nuevo modelo
        syncModelWithView()
    }
    
    //MARK: - UISplitViewControllerDelegate
    func splitViewController(_ svc: UISplitViewController, willHide aViewController: UIViewController, with barButtonItem: UIBarButtonItem, for pc: UIPopoverController) {
        self.navigationItem.rightBarButtonItem = barButtonItem;
    }
    
    func splitViewController(_ svc: UISplitViewController, willShow aViewController: UIViewController, invalidating barButtonItem: UIBarButtonItem) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}
