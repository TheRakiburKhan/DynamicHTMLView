//
//  DynamicHTMLView.swift
//  
//
//  Created by Rakibur Khan on 1/May/22.
//

import Foundation

import Foundation
import UIKit
import WebKit

public class DynamicHTMLView: UIView {
    let webViewKeyPathsToObserve = [StringConstants.webViewKeyPathsToObserve.rawValue]
    var webViewHeightConstraint: NSLayoutConstraint!
    
    public var baseUrl:URL? = nil {
        didSet {
            webView.loadHTMLString(html ?? "", baseURL: baseUrl)
        }
    }
    
    public weak var delegate: DynamicHTMLViewDelegate?
    
    public var webView: WKWebView! {
        didSet {
            addSubview(webView)
            webView.translatesAutoresizingMaskIntoConstraints = false
            webView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
            webView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
            webView.topAnchor.constraint(equalTo: topAnchor).isActive = true
            webView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
            webViewHeightConstraint = webView.heightAnchor.constraint(equalToConstant: self.bounds.height)
            webViewHeightConstraint.isActive = true
            webView.scrollView.isScrollEnabled = false
            webView.allowsBackForwardNavigationGestures = false
            webView.contentMode = .scaleToFill
            webView.navigationDelegate = self
            webView.uiDelegate = self
            webView.scrollView.delaysContentTouches = false
            webView.scrollView.delegate = self
        }
    }
    public var html: String? {
        didSet {
            webView.loadHTMLString(html ?? "", baseURL: baseUrl)
        }
    }
    
    private func commonInit() {
        
        let controller = WKUserContentController()
        addDefaultScripts(controller: controller)
        
        let config = WKWebViewConfiguration()
        config.userContentController = controller
        
        webView = WKWebView(frame: CGRect.zero, configuration: config)
        
        for keyPath in webViewKeyPathsToObserve {
            webView.addObserver(self, forKeyPath: keyPath, options: .new, context: nil)
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    deinit {
        for keyPath in webViewKeyPathsToObserve {
            webView.removeObserver(self, forKeyPath: keyPath)
        }
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath else { return }
        
        switch keyPath {
                
            case StringConstants.webViewKeyPathsToObserve.rawValue:
                delegate?.loadingProgress(progress: Float(webView.estimatedProgress))
                
            default:
                break
        }
    }
    
    private func addDefaultScripts(controller: WKUserContentController) {
        controller.addUserScript(DynamicHTMLViewScripts.viewportScript)
        controller.addUserScript(DynamicHTMLViewScripts.disableSelectionScript)
        controller.addUserScript(DynamicHTMLViewScripts.disableCalloutScript)
        controller.addUserScript(DynamicHTMLViewScripts.addToOnloadScript)
        
        //add contentHeight script and handler
        controller.add(self, name: DynamicHTMLViewScriptMessage.HandlerName.onContentHeightChange.rawValue)
        controller.addUserScript(DynamicHTMLViewScripts.heigthOnLoadScript)
        controller.addUserScript(DynamicHTMLViewScripts.heigthOnResizeScript)
    }
    
}

extension DynamicHTMLView: WKNavigationDelegate {
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        delegate?.didFinishLoad()
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let delegate = delegate {
            return decisionHandler(delegate.shouldNavigate(for: navigationAction) ? .allow : .cancel)
        }
        return decisionHandler(.allow)
    }
}

extension DynamicHTMLView: WKScriptMessageHandler {
    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == DynamicHTMLViewScriptMessage.HandlerName.onContentHeightChange.rawValue {
            guard let responseDict = message.body as? [String:Any], let height = responseDict["height"] as? Float, webViewHeightConstraint.constant != CGFloat(height) else {
                return
            }
            webViewHeightConstraint.constant = CGFloat(height)
            delegate?.heightChanged(height: CGFloat(height))
        }
        delegate?.handleScriptMessage(message)
    }
    
    
}

extension DynamicHTMLView: WKUIDelegate {
    /// Handle javascript:alert(...)
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Button: Alert OK button"), style: .default) { _ in
            completionHandler()
        }
        
        alertController.addAction(okAction)
        
        delegate?.presentAlert(alertController)
    }
    
    /// Handle javascript:confirm(...)
    public func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        
        let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Button: Alert OK button"), style: .default) { _ in
            completionHandler(true)
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Button: Alert Cancel button"), style: .cancel) { _ in
            completionHandler(false)
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        delegate?.presentAlert(alertController)
    }
    
    /// Handle javascript:prompt(...)
    public func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
        let alertController = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: "Button: Alert OK button"), style: .default) { action in
            let textField = alertController.textFields![0] as UITextField
            completionHandler(textField.text)
        }
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "Button: Alert Cancel button"), style: .cancel) { _ in
            completionHandler(nil)
        }
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        
        delegate?.presentAlert(alertController)
    }
    
    
}

extension DynamicHTMLView: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
}
