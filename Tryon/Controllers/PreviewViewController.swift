//
//  PreviewViewController.swift
//  Print2PDF
//
//  Created by Gabriel Theodoropoulos on 14/06/16.
//  Copyright © 2016 Appcoda. All rights reserved.
//

import UIKit
import MessageUI

class PreviewViewController: UIViewController,MFMailComposeViewControllerDelegate {

    @IBOutlet weak var pdfButton: UIButton!
    @IBOutlet weak var signatureView: UIView!
    @IBOutlet weak var signImageView: UIImageView!
    @IBOutlet weak var webPreView: UIWebView!
    @IBOutlet weak var backButton: UIButton!

    var invoiceInfo: [String: AnyObject]!
    var salesSignImage : UIImage!
    var clientSignImage : UIImage!
    var descriptions : String!

    var invoiceComposer: InvoiceComposer!
    var HTMLContent: String!
    var items:[AnyObject] = []
 
    var prevPoint1: CGPoint!
    var prevPoint2: CGPoint!
    var lastPoint:CGPoint!
    var width: CGFloat!
    var red:CGFloat!
    var green:CGFloat!
    var blue:CGFloat!
    var alpha: CGFloat!
    
    var documentController: UIDocumentInteractionController = UIDocumentInteractionController()

    @IBAction func backButtonDidTap(_ sender: UIButton) {
         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "tabClose"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        width = 3.0
        red = (0.0/255.0)
        green = (0.0/255.0)
        blue = (0.0/255.0)
        alpha = 1.0
        
        backButton.addCornerRadius(15.0, inCorners: [.topRight, .bottomRight])
        backButton.clipsToBounds = true
        backButton.masksToBounds = true
        
        pdfButton.layer.cornerRadius = 5.0
        pdfButton.clipsToBounds = true
        pdfButton.masksToBounds = true
        
        signImageView.layer.borderWidth = 2.0
        signImageView.layer.borderColor = UIColor.black.cgColor
        signatureView.layer.shadowColor = UIColor.darkGray.cgColor
        signatureView.layer.shadowOffset = CGSize(width: 4, height: 4)
        signatureView.layer.shadowOpacity = 0.5
        signatureView.layer.shadowRadius = 6.0
        signatureView.layer.cornerRadius = 10
        signatureView.masksToBounds = true
        signImageView.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        createInvoiceAsHTML()
        signatureView.isHidden = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func signImageButton(_ sender: Any) {
//        createInvoiceAsHTML()
//        signatureView.isHidden = true
    }
    
    // MARK: IBAction Methods
    
    @IBAction func exportPDF(_ sender: AnyObject) {
        invoiceComposer.exportHTMLContentToPDF(HTMLContent: HTMLContent)
        showOptionsAlert()
        pdfButton.isHidden = true
    }
    
    // MARK: Custom Methods
    
    func createInvoiceAsHTML() {
        
        invoiceComposer = InvoiceComposer()

        if let invoiceHTML = invoiceComposer.renderInvoice(invoiceNumber: invoiceInfo["invoiceNumber"] as! String,
                                                           invoiceDate: invoiceInfo["invoiceDate"] as! String,
                                                           recipientInfo: invoiceInfo["recipientInfo"] as! String,
                                                           items: invoiceInfo["items"] as! [[String: String]],
                                                           totalAmount: invoiceInfo["totalAmount"] as! String,
                                                           totalQty: invoiceInfo["totalQty"] as! String,
                                                           signImage: salesSignImage,
                                                           clientImage:clientSignImage,
                                                           descriptions : descriptions) {
            
            webPreView.loadHTMLString(invoiceHTML, baseURL: NSURL(string: invoiceComposer.pathToInvoiceHTMLTemplate!)! as URL)
            HTMLContent = invoiceHTML
        }
    }
    
    func showOptionsAlert() {
        let alertController = UIAlertController(title: "Yeah!", message: "Your order has been successfully printed to a PDF file.", preferredStyle: UIAlertControllerStyle.alert)
        
        let actionPreview = UIAlertAction(title: "Share", style: UIAlertActionStyle.default) { (action) in
            if let filename = self.invoiceComposer.pdfFilename, let url = URL(string: filename) {
                let request = URLRequest(url: url)
                self.webPreView.loadRequest(request)
                let url = NSURL.init(fileURLWithPath: filename)
                self.documentController = UIDocumentInteractionController.init(url: url as URL)
                self.documentController.uti = "com.apple.ibooks"
                self.documentController.presentOpenInMenu(from: CGRect.zero,in:self.signImageView, animated:false)
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) in
            //
        }
      
        alertController.addAction(actionPreview)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - MFMail compose method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
