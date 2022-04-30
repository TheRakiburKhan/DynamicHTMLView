//
//  DynamicHTMLViewDelegate.swift
//  
//
//  Created by Rakibur Khan on 1/May/22.
//

import Foundation
import UIKit
import WebKit

public protocol DynamicHTMLViewDelegate: AnyObject {
    func presentAlert(_ alertController: UIAlertController)
    func heightChanged(height: CGFloat)
    func shouldNavigate(for navigationAction: WKNavigationAction) -> Bool
    func handleScriptMessage(_ message: WKScriptMessage)
    func loadingProgress(progress: Float)
    func didFinishLoad()
}
