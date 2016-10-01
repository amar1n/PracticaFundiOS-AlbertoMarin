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
        
        // Alta en notificacion
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(libraryDidChange), name: NSNotification.Name(rawValue: LibraryAvailableNotification), object: nil)
        nc.addObserver(self, selector: #selector(favoritesDidChange), name: NSNotification.Name(rawValue: FavoriteDidChangeNotification), object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        // Baja en la notificacion
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Actions
    @IBAction func segmentedAction(_ sender: AnyObject) {
        syncModelWithView()
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
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(UINib(nibName: "BookCellView", bundle: nil), forCellReuseIdentifier: BookCellId)
        tableView.register(UINib(nibName: "TagCellView", bundle: nil), forCellReuseIdentifier: TagCellId)
        
        setupSegmentedControlView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (autoSelectRow && selectedRow != nil) {
            self.tableView.selectRow(at: selectedRow, animated: false, scrollPosition: .middle)
            self.tableView(self.tableView, didSelectRowAt: selectedRow!)
        }
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Salvar el index seleccionado
        UserDefaults.standard.setIndexPath(indexPath, forKey: BookKey)
        
        // Averiguar cual es el libro
        guard let theBook = book(forIndexPath: indexPath) else {
            return
        }
        
        // Avisar al delegado
        delegate?.libraryViewController(self, didSelectBook: theBook)
        
        // Enviamos la misma info via notificaciones
        let nc = NotificationCenter.default
        let notif = Notification(name: Notification.Name(rawValue: BookDidChangeNotification), object: self, userInfo: [BookKey: theBook])
        nc.post(notif)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(BookCellHeight)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CGFloat(TagCellHeight)
    }
    
    // MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let theModel = model else {
            return 0
        }
        
        if (segmentControl.selectedSegmentIndex == 0) {
            return theModel.bookCountForTag(getTag(forSection: section))
        } else {
            return theModel.booksCount
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: BookCellId, for: indexPath) as! BookCellView
        
        guard let theBook = book(forIndexPath: indexPath) else {
            return cell
        }
        cell.bookTitle.text = theBook.title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: TagCellId) as! TagCellView

        if (segmentControl.selectedSegmentIndex == 0) {
            guard let tag = getTag(forSection: section) else {
                return nil
            }
            cell.tagImageView.image = UIImage(named: "\(section % 36)")
            cell.tagNameView.text = tag.name
            cell.backgroundColor = UIColor.lightGray
        } else {
            cell.backgroundColor = UIColor.lightGray
            cell.tagImageView.removeFromSuperview()
            cell.tagNameView.removeFromSuperview()
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height))
            label.textAlignment = NSTextAlignment.center
            label.textColor = UIColor.black
            label.text = TagCellHeader2
            label.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
            cell.addSubview(label)
        }
        
        return cell
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
        
        if (segmentControl.selectedSegmentIndex == 0) {
            return theModel.book(atIndex: (indexPath as NSIndexPath).row, forTag: getTag(forSection: (indexPath as NSIndexPath).section)!)!
        } else {
            return theModel.book(atIndex: (indexPath as NSIndexPath).row)
        }
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
    
    func favoritesDidChange(_ notification: Notification) {
        // Sacar el userInfo
        let info = (notification as NSNotification).userInfo!
        
        // Sacar el libro
        guard let book = info[BookKey] as? Book else {
            return
        }
        
        // Actualizar el modelo
        model?.refreshFavorites(book)
        
        // Sincronizar las vistas
        DispatchQueue.main.async {
            self.syncModelWithView()
        }
    }
    
    func setupSegmentedControlView() {
        var subViewOfSegment: UIView = segmentControl.subviews[0] as UIView
        subViewOfSegment.tintColor = UIColor.lightGray
        
        subViewOfSegment = segmentControl.subviews[1] as UIView
        subViewOfSegment.tintColor = UIColor.lightGray
        
        segmentControl.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.darkGray], for: UIControlState())
        segmentControl.setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.white], for: UIControlState.selected)
    }
    
    // MARK: - LibraryViewControllerDelegate
    func setDelegate(_ delegate: LibraryViewControllerDelegate?) {
        self.delegate = delegate
    }
    
    func libraryViewController(_ vc: LibraryViewController, didSelectBook book: Book) {
        let bookVC = BookViewController(model: book)
        navigationController?.pushViewController(bookVC, animated: true)
    }
}


protocol LibraryViewControllerDelegate {
    func libraryViewController(_ vc: LibraryViewController, didSelectBook book: Book)
}
