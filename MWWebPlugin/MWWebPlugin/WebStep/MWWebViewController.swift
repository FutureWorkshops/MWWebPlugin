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
    lazy var continueButton: UIBarButtonItem = {
        let title = self.webStep.translate(text: self.isLastStepOnFlow ? "Done" : "Next")
        return UIBarButtonItem(title: title, style: .done, target: self, action: #selector(self.continueToNextStep(_:)))
    }()
    
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
    private var webStep: WebStepConfiguration {
        guard let webStep = self.mwStep as? WebStepConfiguration else {
            preconditionFailure("Unexpected step type. Expecting \(String(describing: WebStepConfiguration.self)), got \(String(describing: type(of: self.mwStep)))")
        }
        return webStep
    }
    private var hideNavigation: Bool {
        return self.webStep.hideNavigation
    }
    private var hideNavigationBar: Bool {
        return self.webStep.hideNavigationBar
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupWebView()
        self.setupLoadingIndicator()
        
        Task { await self.loadConfiguration() }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureUIElements(animated: animated)
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
    @MainActor
    private func configureUIElements(animated: Bool) {
        if self.webStep.sharingEnabled && self.hideNavigation {
            // show share button on navigation bar when sharing is enabled and toolbar is hidden
            let iconImage = UIImage(systemName: "square.and.arrow.up")
            self.utilityButtonItem = UIBarButtonItem(image: iconImage, style: .plain, target: self, action: #selector(self.shareAction))
        }
        if (self.hideNavigation) {
            self.navigationController?.setToolbarHidden(true, animated: animated)
        } else {
            if let navigationBar = self.navigationController?.navigationBar {
                self.configureNavigationBar(navigationBar)
            }
            self.navigationController?.setToolbarHidden(false, animated: animated)
        }
        self.configureNavigationBarActions()
        if (self.hideNavigationBar) {
            self.navigationController?.setNavigationBarHidden(true, animated: animated)
        } else {
            self.configureToolbar()
            self.navigationController?.setNavigationBarHidden(false, animated: animated)
        }
    }
    
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
    
    public override func configureNavigationBar(_ navigationBar: UINavigationBar) {
        if (!self.hideNavigationBar) {
            super.configureNavigationBar(navigationBar)
        }
    }
    
    private func configureNavigationBarActions() {
        var items = [UIBarButtonItem?]()
        if (self.hideNavigationBar) {
            let nextButtonToShow = self.hasNextStep() ? self.continueButton : nil
            items += [self.cancelButtonItem, self.utilityButtonItem, nextButtonToShow]
        }
        items += self.webStep.actions?.mapIndexed(build(tag:action:)) ?? []
        self.navigationItem.rightBarButtonItems = items.compactMap { $0 }
    }
    
    private func build(tag: Int, action: WebViewWebViewItem) -> UIBarButtonItem? {
        guard let icon = UIImage(systemName: action.sfSymbolName) else { return nil }
        let item = UIBarButtonItem(image: icon, style: .plain, target: self, action: #selector(performRemoteAction(sender:)))
        item.tag = tag //Tag is used to discover the item later on.
        return item
    }
    
    @objc private func performRemoteAction(sender: UIBarButtonItem) {
        guard let actions = self.webStep.actions, sender.tag < actions.count, sender.tag >= 0 else { return }
        let action = actions[sender.tag]
        Task {
            do {
                sender.isEnabled = false //Disabling item to prevent multiple triggers
                self.showActionLoading(sender: sender)
                let reloadWebView = try await self.webStep.perform(action: action)
                self.configureUIElements(animated: false)
                if reloadWebView {
                    self.load(showLoading: true)
                }
            } catch {
                self.configureUIElements(animated: false) //Re-showing elements to match current state
                await self.show(error)
            }
        }
    }
    
    private func showActionLoading(sender: UIBarButtonItem) {
        let indicator = UIActivityIndicatorView()
        indicator.startAnimating()
        sender.customView = indicator
    }
    
    private func configureToolbar() {
        let backwards = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(self.navigateBack(_:)))
        let forwards = UIBarButtonItem(image: UIImage(systemName: "chevron.forward"), style: .plain, target: self, action: #selector(self.navigateForward(_:)))
        let reload = UIBarButtonItem(image: UIImage(systemName: "arrow.clockwise"), style: .plain, target: self, action: #selector(self.reloadCurrentPageOrOriginal(_:)))
        let share = UIBarButtonItem(image: UIImage(systemName: "square.and.arrow.up"), style: .plain, target: self, action: #selector(self.shareAction))
        
        let items: [UIBarButtonItem] = [
            backwards,
            forwards,
            reload,
            self.webStep.sharingEnabled ? share : nil,
            self.hasNextStep() ? self.continueButton : nil,
        ]
            .compactMap {$0} // remove nils
        
        // put `.flexibleSpace` between each item
        let itemsWithSpaces = items
            .map { [$0] }
            .joined(separator: [UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)])
            .flatMap { $0 }
        
        self.setToolbarItems(itemsWithSpaces, animated: true)
    }
    
    private func loadConfiguration() async {
        self.showLoading()
        do {
            if try await self.webStep.preloadConfiguration() {
                self.configureUIElements(animated: false)
            }
            self.load(showLoading: false)
        } catch {
            self.showUnableToResolveURLError()
        }
    }
    
    private func load(showLoading: Bool = true) {
        self.showLoading()
        guard let url = self.webStep.resolvedUrl else {
            return self.showUnableToResolveURLError()
        }
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 60)
        self.webView.load(request)
    }
    
    @MainActor
    private func showUnableToResolveURLError() {
        self.hideLoading()
        self.show(WebViewError.unableToResolveURL)
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
        self.load()
    }
    
    @IBAction private func continueToNextStep(_ sender: UIBarButtonItem) {
        self.goForward()
    }
}

extension Collection {
    func mapIndexed<T>(_ transform: (Int, Element) -> T) -> [T] {
        var response = [T]()
        for (index, element) in self.enumerated() {
            response.append(transform(index, element))
        }
        return response
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
    
    public func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        Task {
            await self.hideLoading()
            await self.show(error)
        }
    }
}

extension MWWebViewController {
    
    // MARK: Share
    
    @IBAction func shareAction() {
        let title = self.mwStep.title ?? self.mwStep.identifier
        
        guard let url = self.webStep.resolvedUrl else {
            self.show(WebViewError.unableToResolveURL)
            return
        }
        
        let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        
        if let popoverPresentationController = activityViewController.popoverPresentationController {
            popoverPresentationController.barButtonItem = self.utilityButtonItem
        }
        
        self.present(activityViewController, animated: true, completion: nil)
    }
}
