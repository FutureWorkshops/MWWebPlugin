//
//  MWWebStep.swift
//  MWWebPlugin
//
//  Created by Xavi Moll on 23/12/20.
//

import Foundation
import MobileWorkflowCore

public class MWWebStep: MWStep {
    
    let url: String
    let session: Session
    
    var resolvedUrl: URL? {
        self.session.resolve(url: url)
    }
    
    init(identifier: String, url: String, session: Session) {
        self.url = url
        self.session = session
        super.init(identifier: identifier)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func instantiateViewController() -> StepViewController {
        MWWebViewController(step: self)
    }
}

extension MWWebStep: BuildableStep {
    
    public static var mandatoryCodingPaths: [CodingKey] {
        ["url"]
    }
    
    public static func build(stepInfo: StepInfo, services: StepServices) throws -> Step {
        guard let url = stepInfo.data.content["url"] as? String else {
            throw ParseError.invalidStepData(cause: "Mandatory 'url' property not found")
        }
        return MWWebStep(identifier: stepInfo.data.identifier, url: url, session: stepInfo.session)
    }
}

enum L10n {
    enum WebView {
        static let unableToResolveUrl = "Unable to resolve URL"
    }
}

public enum WebViewError: LocalizedError {
    case unableToResolveURL
    
    public var errorDescription: String? {
        return self.description
    }
    
    public var description: String {
        switch self {
        case .unableToResolveURL:
            return L10n.WebView.unableToResolveUrl
        }
    }
}
