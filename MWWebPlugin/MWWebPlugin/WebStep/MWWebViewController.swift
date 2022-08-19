//
//  MWWebViewController.swift
//  MWWebPlugin
//
//  Created by Xavi Moll on 23/12/20.
//

import WebKit
import Foundation
import MobileWorkflowCore

public class MWWebViewController: MWStepViewController {
    
    public override var titleMode: StepViewControllerTitleMode { .smallTitle }
    lazy var continueButton = UIBarButtonItem(title: self.webStep.translate(text: "Next"), style: .done, target: self, action: #selector(self.continueToNextStep(_:)))
    
    private let webView = WKWebView()
    private var webStep: MWWebStep {
        guard let webStep = self.mwStep as? MWWebStep else {
            preconditionFailure("Unexpected step type. Expecting \(String(describing: MWWebStep.self)), got \(String(describing: type(of: self.mwStep)))")
        }
        return webStep
    }
    private var hideNavigation: Bool {
        return self.webStep.hideNavigation
    }
    private var showToolbar: Bool {
        self.hasNextStep() || !self.webStep.hideNavigation
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupWebView()
        self.resolveUrlAndLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (!self.hideNavigation) {
            self.navigationController?.setToolbarHidden(false, animated: animated)
        } else {
            self.configureNavigationBar()
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (!self.hideNavigation) {
            self.navigationController?.setToolbarHidden(true, animated: animated)
        }
    }
    
    //MARK: Private methods
    private func setupWebView() {
        self.view.addPinnedSubview(self.webView, verticalLayoutGuide: self.view.safeAreaLayoutGuide)
        
        if (!self.hideNavigation) {
            self.configureToolbar()
        }
    }
    
    private func configureNavigationBar() {
        let nextButtonToShow = self.hasNextStep() ? self.continueButton : nil
        self.navigationItem.rightBarButtonItems = [self.cancelButtonItem, self.utilityButtonItem, nextButtonToShow].compactMap { $0 }
    }
    
    private func configureToolbar() {
        let backwards = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(self.navigateBack(_:)))
        let forwards = UIBarButtonItem(image: UIImage(systemName: "chevron.forward"), style: .plain, target: self, action: #selector(self.navigateForward(_:)))
        let reload = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .plain, target: self, action: #selector(self.reloadCurrentPageOrOriginal(_:)))
        
        let items: [UIBarButtonItem]
        
        if (self.hasNextStep()) {
            items = [
                backwards,
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                forwards,
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                reload,
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                self.continueButton
            ]
        } else {
            items = [
                backwards,
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                forwards,
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                reload
            ]
        }
        
        self.setToolbarItems(items, animated: true)
    }
    
    private func resolveUrlAndLoad() {
        if let resolvedUrl = self.webStep.resolvedUrl {
            self.load(url: resolvedUrl)
        } else {
            self.show(WebViewError.unableToResolveURL)
        }
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
        if let currentUrl = self.webView.url {
            self.load(url: currentUrl)
        } else {
            self.resolveUrlAndLoad()
        }
    }
    
    @IBAction private func continueToNextStep(_ sender: UIBarButtonItem) {
        self.goForward()
    }
}
