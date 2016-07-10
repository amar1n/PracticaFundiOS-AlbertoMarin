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
    let model: Library
    var delegate: LibraryTableViewControllerDelegate?
    var selectedRow: NSIndexPath?
    
    //MARK: - Initialization
    init(model: Library, selectedRow: NSIndexPath?) {
        self.model = model
        self.selectedRow = selectedRow
        super.init(nibName: nil, bundle: nil)
        self.title = AppName;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDelegate(delegate: LibraryTableViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    //MARK: - View life cycle
    override func viewDidAppear(animated: Bool) {
        if (selectedRow != nil) {
            self.tableView.selectRowAtIndexPath(selectedRow, animated: false, scrollPosition: .Middle)
            self.tableView(self.tableView, didSelectRowAtIndexPath: selectedRow!)
        }
    }
    
    // MARK: - Table view delegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Salvar el index seleccionado
        NSUserDefaults.standardUserDefaults().setIndexPath(indexPath, forKey: BookKey)

        // Averiguar cual es el personaje
        let b = book(forIndexPath: indexPath)
        
        // Avisar al delegado
        delegate?.libraryTableViewController(self, didSelectBook: b)
        
        // Enviamos la misma info via notificaciones
        let nc = NSNotificationCenter.defaultCenter()
        let notif = NSNotification(name: BookDidChangeNotification, object: self, userInfo: [BookKey: b])
        nc.postNotification(notif)
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return model.tagsCount
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.bookCountForTag(getTag(forSection: section))
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Averiguar el libro
        let b = book(forIndexPath: indexPath)
        
        // Crear la celda
        var cell = tableView.dequeueReusableCellWithIdentifier(BookCellId)
        if cell == nil {
            // El optional está vacía: hay que crearla a pelo
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: BookCellId)
        }
        
        // Sincronizar libro -> celda
        cell?.textLabel?.text = b.title
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return getTag(forSection: section).name
    }
    
    // MARK: - Utilities
    func getTag(forSection section: Int) -> Tag {
        let tagsArray = Array(model.tags)
        let tagsArraySorted = tagsArray.sort()
        return tagsArraySorted[section]
    }
    
    func book(forIndexPath indexPath: NSIndexPath) -> Book {
        return model.book(atIndex: indexPath.row, forTag: getTag(forSection: indexPath.section))!
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
