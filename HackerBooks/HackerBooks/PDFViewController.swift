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
        activityView.hidden = false
        activityView.startAnimating()
        
        let pdfData = getPDFCached()
        if (pdfData == nil) {
            getRemotePDF()
        } else {
            browserView.loadData(pdfData!, MIMEType: "application/pdf", textEncodingName: "", baseURL: NSURL())
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
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Alta en notificacion
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: #selector(bookDidChange), name: BookDidChangeNotification, object: nil)
        nc.addObserver(self, selector: #selector(syncModelWithView), name: PDFViewControllerPDFAvailableNotification, object: nil)
        
        syncModelWithView()
    }
    
    func bookDidChange(notification: NSNotification) {
        // Sacar el userInfo
        let info = notification.userInfo!
        
        // Sacar el personaje
        let book = info[BookKey] as? Book
        
        // Actualizar el modelo
        model = book!
        
        // Sincronizar las vistas
        syncModelWithView()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Baja en la notificacion
        let nc = NSNotificationCenter.defaultCenter()
        nc.removeObserver(self)
    }
    
    
    //MARK: - UIWebViewDelegate
    func webViewDidFinishLoad(webView: UIWebView) {
        // Parar el activityView
        activityView.stopAnimating()
        
        // Ocultarlo
        activityView.hidden = true
    }
    
    //MARK:- Utilities
    func getPDFCached() -> NSData? {
        return getPDFFromTmp()
    }
    
    func getRemotePDF() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            if let url = self.model.pdfUrl,
                pdfData = NSData(contentsOfURL: url) {
                
                let bFlag = self.cachePDF(pdfData)
                if (bFlag) {
                    // Notificar a todo dios diciendo que tengo el pdf
                    let nc = NSNotificationCenter.defaultCenter()
                    let notif = NSNotification(name: PDFViewControllerPDFAvailableNotification, object: self)
                    nc.postNotification(notif)
                }
            }
        }
    }
    
    func cachePDF(pdfData: NSData) -> Bool {
        return savePDFInTmp(pdfData)
    }
    
    func getPDFFromTmp() -> NSData? {
        let path = "\(NSTemporaryDirectory())\(pdfPrefix)\(self.hashValue)"
        let pdfData: NSData? = NSData(contentsOfFile: path)
        return pdfData
    }
    
    func savePDFInTmp(pdfData: NSData) -> Bool {
        let pdfFilePath = "\(NSTemporaryDirectory())\(pdfPrefix)\(self.hashValue)"
        let bFlag = pdfData.writeToFile(pdfFilePath, atomically: true)
        if (!bFlag) {
            print("PDF caching failed")
        }
        return bFlag
    }

}
