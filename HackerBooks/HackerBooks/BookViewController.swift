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
        
        authorsView.text = "de \(theModel.authors.joinWithSeparator(", "))"
        tagsView.text = "Etiquetas: \(theModel.tags.map({"\($0.name)"}).joinWithSeparator(", "))"
        coverView.image = theModel.coverImage.image
        title = theModel.title
    }
    
    //MARK: - Actions
    @IBAction func makeFavorite(sender: AnyObject) {
    }
    
    @IBAction func viewPdf(sender: AnyObject) {
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
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Alta en notificacion
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: #selector(imageDidChange), name: AsyncImageDidChangeNotification, object: nil)
        
        syncModelWithView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Baja en la notificacion
        let nc = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self)
    }
    
    //MARK: - Utilities
    func imageDidChange(notification: NSNotification) {
        // Sincronizar las vistas
        dispatch_async(dispatch_get_main_queue()) {
            self.syncModelWithView()
        }
    }
    
    //MARK: - LibraryViewControllerDelegate
    func libraryViewController(vc: LibraryViewController, didSelectBook book: Book) {
        // Actualizar el modelo
        model = book
        
        // Sincronizar las vistas con el nuevo modelo
        syncModelWithView()
    }
    
    //MARK: - UISplitViewControllerDelegate
    func splitViewController(svc: UISplitViewController, willHideViewController aViewController: UIViewController, withBarButtonItem barButtonItem: UIBarButtonItem, forPopoverController pc: UIPopoverController) {
        self.navigationItem.rightBarButtonItem = barButtonItem;
    }
    
    func splitViewController(svc: UISplitViewController, willShowViewController aViewController: UIViewController, invalidatingBarButtonItem barButtonItem: UIBarButtonItem) {
        self.navigationItem.rightBarButtonItem = nil;
    }
}