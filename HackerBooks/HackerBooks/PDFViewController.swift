//
//  PDFViewController.swift
//  HackerBooks
//
//  Created by Alberto Marín García on 9/7/16.
//  Copyright © 2016 Alberto Marín García. All rights reserved.
//

import UIKit

class PDFViewController: UIViewController, UIWebViewDelegate {
    
    //MARK: - Properties
    var model: Book
    @IBOutlet weak var browserView: UIWebView!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    //MARK: - Initialization
    init(model: Book) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        title = self.model.title
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Syncing
    func syncModelWithView() {
        browserView.delegate = self
        activityView.isHidden = false
        activityView.startAnimating()
        
        let pdfData = getPDFCached()
        if (pdfData == nil) {
            getRemotePDF()
        } else {
            let localFilePath = Bundle.main.path(forResource: "home", ofType:"txt");
            let data = FileManager.default.contents(atPath: localFilePath!);
            browserView.loadData(data!, MIMEType: "application/txt", textEncodingName: "UTF-8", baseURL: nil);
        
            //browserView.load(pdfData!, mimeType: "application/pdf", textEncodingName: "", baseURL: nil)
        }
        
        title = self.model.title
    }
    
    //MARK: - Hashable
    override var hashValue: Int {
        get{
            return model.title.hashValue
        }
    }

    //MARK: - View life cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Alta en notificacion
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(bookDidChange), name: NSNotification.Name(rawValue: BookDidChangeNotification), object: nil)
        nc.addObserver(self, selector: #selector(syncModelWithView), name: NSNotification.Name(rawValue: PDFViewControllerPDFAvailableNotification), object: nil)
        
        syncModelWithView()
    }
    
    func bookDidChange(_ notification: Notification) {
        // Sacar el userInfo
        let info = (notification as NSNotification).userInfo!
        
        // Sacar el personaje
        let book = info[BookKey] as? Book
        
        // Actualizar el modelo
        model = book!
        
        // Sincronizar las vistas
        syncModelWithView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Baja en la notificacion
        let nc = NotificationCenter.default
        nc.removeObserver(self)
    }
    
    
    //MARK: - UIWebViewDelegate
    func webViewDidFinishLoad(_ webView: UIWebView) {
        // Parar el activityView
        activityView.stopAnimating()
        
        // Ocultarlo
        activityView.isHidden = true
    }
    
    //MARK:- Utilities
    func getPDFCached() -> Data? {
        return getPDFFromTmp()
    }
    
    func getRemotePDF() {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            if let url = self.model.pdfUrl,
                let pdfData = try? Data(contentsOf: url as URL) {
                
                let bFlag = self.cachePDF(pdfData)
                if (bFlag) {
                    // Notificar a todo dios diciendo que tengo el pdf
                    let nc = NotificationCenter.default
                    let notif = Notification(name: Notification.Name(rawValue: PDFViewControllerPDFAvailableNotification), object: self)
                    nc.post(notif)
                }
            }
        }
    }
    
    func cachePDF(_ pdfData: Data) -> Bool {
        return savePDFInTmp(pdfData)
    }
    
    func getPDFFromTmp() -> Data? {
        let path = "\(NSTemporaryDirectory())\(pdfPrefix)\(self.hashValue)"
        let pdfData: Data? = try? Data(contentsOf: URL(fileURLWithPath: path))
        return pdfData
    }
    
    func savePDFInTmp(_ pdfData: Data) -> Bool {
        let pdfFilePath = "\(NSTemporaryDirectory())\(pdfPrefix)\(self.hashValue)"
        let bFlag = (try? pdfData.write(to: URL(fileURLWithPath: pdfFilePath), options: [.atomic])) != nil
        if (!bFlag) {
            print("PDF caching failed")
        }
        return bFlag
    }

}
