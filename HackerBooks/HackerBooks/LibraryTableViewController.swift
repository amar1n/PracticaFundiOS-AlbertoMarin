//
//  LibraryTableViewController.swift
//  HackerBooks
//
//  Created by Alberto Marín García on 5/7/16.
//  Copyright © 2016 Alberto Marín García. All rights reserved.
//

import UIKit

class LibraryTableViewController: UITableViewController, LibraryTableViewControllerDelegate {
    
    //MARK: - Properties
    var model: Library?
    var delegate: LibraryTableViewControllerDelegate?
    var selectedRow: NSIndexPath?
    var autoSelectRow: Bool
    
    //MARK: - Initialization
    init(model: Library?, selectedRow: NSIndexPath?, autoSelectRow: Bool) {
        if model == nil {
            self.model = Library()
        } else {
            self.model = model
        }
        self.selectedRow = selectedRow
        self.autoSelectRow = autoSelectRow
        super.init(nibName: nil, bundle: nil)
        self.title = AppName;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDelegate(delegate: LibraryTableViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    //MARK: - Syncing
    func syncModelWithView() {
        self.tableView.reloadData()
        if (self.autoSelectRow && self.selectedRow != nil) {
            self.tableView.selectRowAtIndexPath(self.selectedRow, animated: false, scrollPosition: .Middle)
            self.tableView(self.tableView, didSelectRowAtIndexPath: self.selectedRow!)
        }
    }
    
    //MARK: - View life cycle
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Alta en notificacion
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: #selector(libraryDidChange), name: LibraryAvailableNotification, object: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Baja en la notificacion
        let nc = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self)
    }
    
    override func viewDidAppear(animated: Bool) {
        if (autoSelectRow && selectedRow != nil) {
            self.tableView.selectRowAtIndexPath(selectedRow, animated: false, scrollPosition: .Middle)
            self.tableView(self.tableView, didSelectRowAtIndexPath: selectedRow!)
        }
    }
    
    // MARK: - Table view delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Salvar el index seleccionado
        NSUserDefaults.standardUserDefaults().setIndexPath(indexPath, forKey: BookKey)
        
        // Averiguar cual es el libro
        guard let theBook = book(forIndexPath: indexPath) else {
            return
        }
        
        // Avisar al delegado
        delegate?.libraryTableViewController(self, didSelectBook: theBook)
        
        // Enviamos la misma info via notificaciones
        let nc = NSNotificationCenter.defaultCenter()
        let notif = NSNotification(name: BookDidChangeNotification, object: self, userInfo: [BookKey: theBook])
        nc.postNotification(notif)
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard let theModel = model else {
            return 0
        }
        return theModel.tagsCount
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let theModel = model else {
            return 0
        }
        return theModel.bookCountForTag(getTag(forSection: section))
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Crear la celda
        var cell = tableView.dequeueReusableCellWithIdentifier(BookCellId)
        if cell == nil {
            // El optional está vacía: hay que crearla a pelo
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: BookCellId)
        }
        
        // Averiguar el libro
        guard let theBook = book(forIndexPath: indexPath) else {
            return cell!
        }
        
        // Sincronizar libro -> celda
        cell?.textLabel?.text = theBook.title
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let tag = getTag(forSection: section) else {
            return nil
        }
        return tag.name
    }
    
    // MARK: - Utilities
    func getTag(forSection section: Int) -> Tag? {
        guard let theModel = model else {
            return nil
        }
        let tagsArray = Array(theModel.tags)
        let tagsArraySorted = tagsArray.sort()
        return tagsArraySorted[section]
    }
    
    func book(forIndexPath indexPath: NSIndexPath) -> Book? {
        guard let theModel = self.model else {
            return nil
        }
        return theModel.book(atIndex: indexPath.row, forTag: getTag(forSection: indexPath.section)!)!
    }
    
    func libraryDidChange(notification: NSNotification) {
        // Sacar el userInfo
        let info = notification.userInfo!
        
        // Sacar la librería
        guard let library = info[LibraryKey] as? Library else {
            return
        }
        
        // Actualizar el modelo
        model = library
        
        // Inicializar y salvar el index seleccionado
        if model!.booksCount > 0 {
            selectedRow = NSIndexPath(forRow: 0, inSection: 0)
            NSUserDefaults.standardUserDefaults().setIndexPath(selectedRow!, forKey: BookKey)
        }
        
        // Sincronizar las vistas
        dispatch_async(dispatch_get_main_queue()) {
            self.syncModelWithView()
        }
    }
    
    // MARK: - LibraryTableViewControllerDelegate
    func libraryTableViewController(vc: LibraryTableViewController, didSelectBook book: Book) {
        let bookVC = BookViewController(model: book)
        navigationController?.pushViewController(bookVC, animated: true)
    }
}

protocol LibraryTableViewControllerDelegate {
    func libraryTableViewController(vc: LibraryTableViewController, didSelectBook book: Book)
}
