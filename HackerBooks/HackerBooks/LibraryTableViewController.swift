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
    var selectedRow: IndexPath?
    var autoSelectRow: Bool
    
    //MARK: - Initialization
    init(model: Library?, selectedRow: IndexPath?, autoSelectRow: Bool) {
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
    
    //MARK: - Syncing
    func syncModelWithView() {
        self.tableView.reloadData()
        if (self.autoSelectRow && self.selectedRow != nil) {
            self.tableView.selectRow(at: self.selectedRow, animated: false, scrollPosition: .middle)
            self.tableView(self.tableView, didSelectRowAt: self.selectedRow!)
        }
    }
    
    //MARK: - View life cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Alta en notificacion
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(libraryDidChange), name: NSNotification.Name(rawValue: LibraryAvailableNotification), object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Baja en la notificacion
        let nc = NotificationCenter.default
        nc.removeObserver(self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (autoSelectRow && selectedRow != nil) {
            self.tableView.selectRow(at: selectedRow, animated: false, scrollPosition: .middle)
            self.tableView(self.tableView, didSelectRowAt: selectedRow!)
        }
    }
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Salvar el index seleccionado
        UserDefaults.standard.setIndexPath(indexPath, forKey: BookKey)
        
        // Averiguar cual es el libro
        guard let theBook = book(forIndexPath: indexPath) else {
            return
        }
        
        // Avisar al delegado
        delegate?.libraryTableViewController(self, didSelectBook: theBook)
        
        // Enviamos la misma info via notificaciones
        let nc = NotificationCenter.default
        let notif = Notification(name: Notification.Name(rawValue: BookDidChangeNotification), object: self, userInfo: [BookKey: theBook])
        nc.post(notif)
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let theModel = model else {
            return 0
        }
        return theModel.tagsCount
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let theModel = model else {
            return 0
        }
        return theModel.bookCountForTag(getTag(forSection: section))
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Crear la celda
        var cell = tableView.dequeueReusableCell(withIdentifier: BookCellId)
        if cell == nil {
            // El optional está vacía: hay que crearla a pelo
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: BookCellId)
        }
        
        // Averiguar el libro
        guard let theBook = book(forIndexPath: indexPath) else {
            return cell!
        }
        
        // Sincronizar libro -> celda
        cell?.textLabel?.text = theBook.title
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
        let tagsArraySorted = tagsArray.sorted()
        return tagsArraySorted[section]
    }
    
    func book(forIndexPath indexPath: IndexPath) -> Book? {
        guard let theModel = self.model else {
            return nil
        }
        return theModel.book(atIndex: (indexPath as NSIndexPath).row, forTag: getTag(forSection: (indexPath as NSIndexPath).section)!)!
    }
    
    func libraryDidChange(_ notification: Notification) {
        // Sacar el userInfo
        let info = (notification as NSNotification).userInfo!
        
        // Sacar la librería
        guard let library = info[LibraryKey] as? Library else {
            return
        }
        
        // Actualizar el modelo
        model = library
        
        // Inicializar y salvar el index seleccionado
        if model!.booksCount > 0 {
            selectedRow = IndexPath(row: 0, section: 0)
            UserDefaults.standard.setIndexPath(selectedRow!, forKey: BookKey)
        }
        
        // Sincronizar las vistas
        DispatchQueue.main.async {
            self.syncModelWithView()
        }
    }
    
    // MARK: - LibraryTableViewControllerDelegate
    func setDelegate(_ delegate: LibraryTableViewControllerDelegate?) {
        self.delegate = delegate
    }

    func libraryTableViewController(_ vc: LibraryTableViewController, didSelectBook book: Book) {
        let bookVC = BookViewController(model: book)
        navigationController?.pushViewController(bookVC, animated: true)
    }
}

protocol LibraryTableViewControllerDelegate {
    func libraryTableViewController(_ vc: LibraryTableViewController, didSelectBook book: Book)
}
