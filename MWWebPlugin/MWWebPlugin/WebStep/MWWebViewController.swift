//
//  MWWebViewController.swift
//  MWWebPlugin
//
//  Created by Xavi Moll on 23/12/20.
//

import WebKit
import Foundation
import MobileWorkflowCore

enum L10n {
    enum Web {
        static let unableToResolveURLError = "Failed to construct the final URL"
    }
}

enum MWWebStepViewControllerError: LocalizedError {
    case unableToResolveURL
    
    var errorDescription: String? {
        switch self {
        case .unableToResolveURL:
            return L10n.Web.unableToResolveURLError
        }
    }
    
    var localizedDescription: String {
        return self.errorDescription ?? L10n.Web.unableToResolveURLError
    }
}

public class MWWebViewController: MWStepViewController {
    
    private let webView = WKWebView()
    private var webStep: MWWebStep { self.step as! MWWebStep }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupWebView()
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: animated)
        
        if self.isMovingToParent {
            self.loadOriginal()
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    //MARK: Private methods
    private func setupWebView() {
        self.webView.frame = self.view.bounds
        self.webView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.view.addSubview(self.webView)
        self.setToolbarItems([
            UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(self.navigateBack(_:))),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(image: UIImage(systemName: "chevron.forward"), style: .plain, target: self, action: #selector(self.navigateForward(_:))),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .plain, target: self, action: #selector(self.reloadCurrentPageOrOriginal(_:))),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(title: "Continue", style: .done, target: self, action: #selector(self.continueToNextStep(_:)))
        ], animated: false)
    }
    
    private func loadOriginal() {
        guard let url = self.webStep.resolvedUrl else {
            self.show(MWWebStepViewControllerError.unableToResolveURL)
            return
        }
        self.load(url: url)
    }
    
    private func load(url: URL) {
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
        self.webView.load(request)
    }
    
    //MARK: IBActions
    @IBAction private func navigateBack(_ sender: UIBarButtonItem) {
        if self.webView.canGoBack {
            self.webView.goBack()
        }
    }
    
    @IBAction private func navigateForward(_ sender: UIBarButtonItem) {
        if self.webView.canGoForward {
            self.webView.goForward()
        }
    }
    
    @IBAction private func reloadCurrentPageOrOriginal(_ sender: UIBarButtonItem) {
        let urlToReload: URL?
        if let currentUrl = self.webView.url {
            self.load(url: currentUrl)
        } else {
            self.loadOriginal()
        }
    }
    
    @IBAction private func continueToNextStep(_ sender: UIBarButtonItem) {
        self.goForward()
    }
    
}
