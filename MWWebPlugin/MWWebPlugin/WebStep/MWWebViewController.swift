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
    
    private let webView = WKWebView()
    private var webStep: MWWebStep {
        guard let webStep = self.mwStep as? MWWebStep else {
            preconditionFailure("Unexpected step type. Expecting \(String(describing: MWWebStep.self)), got \(String(describing: type(of: self.mwStep)))")
        }
        return webStep
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupWebView()
        self.resolveUrlAndLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(false, animated: animated)
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setToolbarHidden(true, animated: animated)
    }
    
    //MARK: Private methods
    private func setupWebView() {
        self.view.addPinnedSubview(self.webView, verticalLayoutGuide: self.view.safeAreaLayoutGuide)
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
