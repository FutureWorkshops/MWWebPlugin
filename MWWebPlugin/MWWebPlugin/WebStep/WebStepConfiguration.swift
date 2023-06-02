//
//  WebStepConfiguration.swift
//  MWWebPlugin
//
//  Created by Igor Ferreira on 2/6/23.
//

import Foundation

public protocol WebStepConfiguration {
    var hideNavigation: Bool { get }
    var hideNavigationBar: Bool { get }
    var resolvedUrl: URL? { get }
    var sharingEnabled: Bool { get }
    var actions: [WebViewWebViewItem]? { get }
    
    func translate(text: String) -> String
    func preloadConfiguration() async throws -> Bool
}
