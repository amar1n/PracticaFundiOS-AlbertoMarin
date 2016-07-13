//
//  LibraryViewController.swift
//  HackerBooks
//
//  Created by Alberto Marín García on 12/7/16.
//  Copyright © 2016 Alberto Marín García. All rights reserved.
//

import UIKit

class LibraryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, LibraryViewControllerDelegate {

    //MARK: - Properties
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    var model: Library?
    var delegate: LibraryViewControllerDelegate?
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

        // Alta en notificacion
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: #selector(libraryDidChange), name: LibraryAvailableNotification, object: nil)
        nc.addObserver(self, selector: #selector(favoritesDidChange), name: FavoriteDidChangeNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        // Baja en la notificacion
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    //MARK: - Actions
    @IBAction func segmentedAction(sender: AnyObject) {
        syncModelWithView()
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
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self

        tableView.registerNib(UINib(nibName: "BookCellView", bundle: nil), forCellReuseIdentifier: BookCustomCellId)
    }

    override func viewDidAppear(animated: Bool) {
        if (autoSelectRow && selectedRow != nil) {
            self.tableView.selectRowAtIndexPath(selectedRow, animated: false, scrollPosition: .Middle)
            self.tableView(self.tableView, didSelectRowAtIndexPath: selectedRow!)
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Salvar el index seleccionado
        NSUserDefaults.standardUserDefaults().setIndexPath(indexPath, forKey: BookKey)
        
        // Averiguar cual es el libro
        guard let theBook = book(forIndexPath: indexPath) else {
            return
        }
        
        // Avisar al delegado
        delegate?.libraryViewController(self, didSelectBook: theBook)
        
        // Enviamos la misma info via notificaciones
        let nc = NSNotificationCenter.defaultCenter()
        let notif = NSNotification(name: BookDidChangeNotification, object: self, userInfo: [BookKey: theBook])
        nc.postNotification(notif)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CGFloat(BookCustomCellHeight)
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard let theModel = model else {
            return 0
        }
        
        if (segmentControl.selectedSegmentIndex == 0) {
            return theModel.tagsCount
        } else {
            if theModel.booksCount > 0 {
                return 1
            } else {
                return 0
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let theModel = model else {
            return 0
        }

        if (segmentControl.selectedSegmentIndex == 0) {
            return theModel.bookCountForTag(getTag(forSection: section))
        } else {
            return theModel.booksCount
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier(BookCustomCellId, forIndexPath: indexPath) as! BookCellView
        
        guard let theBook = book(forIndexPath: indexPath) else {
            return cell
        }
        cell.bookTitle.text = theBook.title
        
        return cell
//        // Crear la celda
//        var cell = tableView.dequeueReusableCellWithIdentifier(BookCellId)
//        if cell == nil {
//            // El optional está vacía: hay que crearla a pelo
//            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: BookCellId)
//        }
//        
//        // Averiguar el libro
//        guard let theBook = book(forIndexPath: indexPath) else {
//            return cell!
//        }
//        
//        // Sincronizar libro -> celda
//        cell?.textLabel?.text = theBook.title
//        
//        return cell!
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (segmentControl.selectedSegmentIndex == 0) {
            guard let tag = getTag(forSection: section) else {
                return nil
            }
            return tag.name
        } else {
            return nil
        }
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
        
        if (segmentControl.selectedSegmentIndex == 0) {
            return theModel.book(atIndex: indexPath.row, forTag: getTag(forSection: indexPath.section)!)!
        } else {
            return theModel.book(atIndex: indexPath.row)
        }
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

    func favoritesDidChange(notification: NSNotification) {
        // Sacar el userInfo
        let info = notification.userInfo!
        
        // Sacar el libro
        guard let book = info[BookKey] as? Book else {
            return
        }

        // Actualizar el modelo
        model?.refreshFavorites(book)
        
        // Sincronizar las vistas
        dispatch_async(dispatch_get_main_queue()) {
            self.syncModelWithView()
        }
    }

    // MARK: - LibraryViewControllerDelegate
    func setDelegate(delegate: LibraryViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    func libraryViewController(vc: LibraryViewController, didSelectBook book: Book) {
        let bookVC = BookViewController(model: book)
        navigationController?.pushViewController(bookVC, animated: true)
    }
}


protocol LibraryViewControllerDelegate {
    func libraryViewController(vc: LibraryViewController, didSelectBook book: Book)
}
