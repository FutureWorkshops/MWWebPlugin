//
//  MWWebViewController.swift
//  MWWebPlugin
//
//  Created by Xavi Moll on 23/12/20.
//

import WebKit
import Foundation
import MobileWorkflowCore
import UIKit

public class MWWebViewController: MWStepViewController {
    
    public override var titleMode: StepViewControllerTitleMode { .smallTitle }
    lazy var continueButton = UIBarButtonItem(title: self.webStep.translate(text: "Next"), style: .done, target: self, action: #selector(self.continueToNextStep(_:)))
    
    private lazy var webView = {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        return webView
    }()
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let loadingIndicator = UIActivityIndicatorView(style: .large)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.hidesWhenStopped = true
        return loadingIndicator
    }()
    private var webStep: MWWebStep {
        guard let webStep = self.mwStep as? MWWebStep else {
            preconditionFailure("Unexpected step type. Expecting \(String(describing: MWWebStep.self)), got \(String(describing: type(of: self.mwStep)))")
        }
        return webStep
    }
    private var hideNavigation: Bool {
        return self.webStep.hideNavigation
    }
    private var hideNavigationBar: Bool {
        return self.webStep.hideNavigationBar
    }
    
    public override var restorNavigationBarOnAppear: Bool {
        get { !self.webStep.hideNavigationBar }
        set {}
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupWebView()
        self.setupLoadingIndicator()
        self.resolveUrlAndLoad()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (!self.hideNavigation) {
            self.navigationController?.setToolbarHidden(false, animated: animated)
        } else {
            self.configureNavigationBarActions()
        }
        if (self.hideNavigationBar) {
            self.navigationController?.setNavigationBarHidden(true, animated: animated)
        }
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (!self.hideNavigation) {
            self.navigationController?.setToolbarHidden(true, animated: animated)
        }
        if (self.hideNavigationBar) {
            self.navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
    
    //MARK: Private methods
    private func setupLoadingIndicator() {
        self.view.addSubview(self.loadingIndicator)
        NSLayoutConstraint.activate([
            self.loadingIndicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            self.loadingIndicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
    }
    private func setupWebView() {
        self.view.addPinnedSubview(self.webView, verticalLayoutGuide: self.view.safeAreaLayoutGuide)
        
        if (!self.hideNavigation) {
            self.configureToolbar()
        }
    }
    
    private func configureNavigationBarActions() {
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
        self.showLoading()
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

extension MWWebViewController {
    @MainActor
    private func showLoading() {
        if (self.loadingIndicator.isAnimating) { return }
        self.webView.isHidden = true
        self.loadingIndicator.startAnimating()
    }
    
    @MainActor
    private func hideLoading() {
        if (!self.loadingIndicator.isAnimating) { return }
        self.webView.isHidden = false
        self.loadingIndicator.stopAnimating()
    }
}

extension MWWebViewController: WKUIDelegate {
    public func webView(_ webView: WKWebView, decideMediaCapturePermissionsFor origin: WKSecurityOrigin, initiatedBy frame: WKFrameInfo, type: WKMediaCaptureType) async -> WKPermissionDecision {
        return .prompt
    }
    
    // WebKit doesn't provide async counterpart for this delegate
    public func webView(_ webView: WKWebView, requestDeviceOrientationAndMotionPermissionFor origin: WKSecurityOrigin, initiatedByFrame frame: WKFrameInfo, decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        decisionHandler(.prompt)
    }
}

extension MWWebViewController: WKNavigationDelegate {
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        Task { await self.hideLoading() }
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        Task {
            await self.hideLoading()
            await self.show(error)
        }
    }
}
