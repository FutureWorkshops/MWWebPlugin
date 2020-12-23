//
//  MWWebViewController.swift
//  MWWebPlugin
//
//  Created by Xavi Moll on 23/12/20.
//

import Foundation
import SafariServices
import MobileWorkflowCore

public class MWWebViewController: ORKStepViewController {
    
    private var webStep: MWWebStep {
        guard let webStep = self.step as? MWWebStep else {
            preconditionFailure("Unexpected step type. Expecting \(String(describing: MWWebStep.self)), got \(String(describing: type(of: self.step)))")
        }
        return webStep
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.setupWebView()
        self.loadWebView()
    }
    
    private func setupWebView() {
        
    }
    
    private func loadWebView() {
        
    }
    
}
