//
//  BookViewController.swift
//  HackerBooks
//
//  Created by Alberto Marín García on 8/7/16.
//  Copyright © 2016 Alberto Marín García. All rights reserved.
//

import UIKit

class BookViewController: UIViewController, LibraryTableViewControllerDelegate, UISplitViewControllerDelegate {
    //    {
    //    "authors": "Scott Chacon, Ben Straub",
    //    "image_url": "http://hackershelf.com/media/cache/b4/24/b42409de128aa7f1c9abbbfa549914de.jpg",
    //    "pdf_url": "https://progit2.s3.amazonaws.com/en/2015-03-06-439c2/progit-en.376.pdf",
    //    "tags": "version control, git",
    //    "title": "Pro Git"
    //    }
    
    //MARK: - Properties
    @IBOutlet weak var authorsView: UILabel!
    @IBOutlet weak var coverView: UIImageView!
    @IBOutlet weak var tagsView: UILabel!
    var model: Book
    
    //MARK: - Initialization
    init(model: Book) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        self.title = self.model.title;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func syncModelWithView() {
        authorsView.text = "de \(model.authors.joinWithSeparator(", "))"
        
        tagsView.text = "Etiquetas: \(model.tags.map({"\($0.name)"}).joinWithSeparator(", "))"
        
        coverView.image = model.coverImage.image
        
        title = model.title
    }
    
    //MARK: - Actions
    @IBAction func makeFavorite(sender: AnyObject) {
    }
    
    @IBAction func viewPdf(sender: AnyObject) {
        if model.pdfUrl != nil {
            let pdfVC = PDFViewController(model: model)
            
            // Hacer unpush sobre mi NavigationController
            navigationController?.pushViewController(pdfVC, animated: true)
        }
    }
    
    //MARK: - LifeCycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Alta en notificacion
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: #selector(bookDidChange), name: AsyncImageDidChangeNotification, object: nil)
        
        syncModelWithView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Baja en la notificacion
        let nc = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self)
    }
    
    //MARK: - Utilities
    func bookDidChange(notification: NSNotification) {
        // Sincronizar las vistas
        syncModelWithView()
    }
    
    // MARK: - LibraryTableViewControllerDelegate
    func libraryTableViewController(vc: LibraryTableViewController, didSelectBook book: Book) {
        // Actualizar el modelo
        model = book
        
        // Sincronizar las vistas con el nuevo modelo
        syncModelWithView()
    }
}