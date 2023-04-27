//
//  PersonaViewController.swift
//  wkwebview
//
//  Copyright (c) 2019 Persona Identities Inc. All rights reserved.
//

import UIKit
import WebKit

/// Delegate methods that get called once a verification is completed.
protocol PersonaViewControllerDelegate: AnyObject {
    /// Verification completed successfully.
    func verificationSucceeded(viewController: PersonaViewController, inquiryId: String)

    /// Verification failed.
    func verificationFailed(viewController: PersonaViewController)
}

/// Wrapper around a web view that handles the verification.
class PersonaViewController: UIViewController {
    /// The template you want to load
    private let inquiryTemplateId = "itmpl_y3B7qEELMkQ8XogGev77QsZn"
    
    /// A unique identifier to associate the inquiry to an account
    private let referenceId = "myReference"

    /// The URL to redirect to once the verification is complete
    private let redirectUri = "https://withpersona.com"

    // The web view.
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        // Very important!
        // Without this, the camera feed element will enter fullscreen mode by default.
        config.allowsInlineMediaPlayback = true
        
        let webView = WKWebView(frame: .zero, configuration: config)
        return webView
    }()

    // The delegate that gets called when verification is complete.
    weak var delegate: PersonaViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        addWebView()

        // Add the Persona configuration options as query items.
        // See the Persona docs (http://docs.withpersona.com) for full documentation.
        var components = URLComponents(string: "https://inquiry.withpersona.com/verify")
        components?.queryItems = [
            URLQueryItem(name: "inquiry-template-id", value: inquiryTemplateId),
            URLQueryItem(name: "environment", value: "sandbox"),
            URLQueryItem(name: "reference-id", value: referenceId),
            URLQueryItem(name: "redirect-uri", value: redirectUri),
            URLQueryItem(name: "is-webview", value: "true")
        ]

        // Create and load the Persona URL request
        guard let urlString = components?.string, let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url)
        webView.load(request)
    }
}

// MARK: - WKWebView Navigation Methods

extension PersonaViewController: WKNavigationDelegate {

    /// Handle navigation actions from the web view.
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Check if we are being redirected to our `redirectUri`. This happens once verification is completed.
        guard let redirectUri = navigationAction.request.url?.absoluteString, redirectUri.starts(with: self.redirectUri) else {
            // We're not being redirected, so load the URL.
            decisionHandler(.allow)
            return
        }

        // At this point we're done, so we don't need to load the URL.
        decisionHandler(.cancel)

        // Get the inquiryId from the query string parameters.
        guard let queryParams = parseQueryParameters(url: navigationAction.request.url),
            let inquiryId = queryParams["inquiry-id"] else {

            // If we do not have an inquiry ID we know we have failed verification.
            delegate?.verificationFailed(viewController: self)
            return
        }

        // If we have an inquiry ID we know we have passed verification.
        delegate?.verificationSucceeded(viewController: self, inquiryId: inquiryId)
    }
}

// MARK: - Helper Methods

extension PersonaViewController {

    /// Set up and add the web view
    private func addWebView() {
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = false
        webView.scrollView.bounces = false
        // Add the web view and set up its contstraints
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        // Account for iPhone notch
        let g = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            // constrain web view to all 4 sides of the Safe Area
            webView.topAnchor.constraint(equalTo: g.topAnchor, constant: 0.0),
            webView.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 0.0),
            webView.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: 0.0),
            webView.bottomAnchor.constraint(equalTo: g.bottomAnchor, constant: 0.0),
        ])
    }

    /// Parses query parameters into a Dictionary
    private func parseQueryParameters(url: URL?) -> [String: String]? {
        guard let url = url, let items = URLComponents(string: (url.absoluteString))?.queryItems else {
            return nil
        }
        var paramsDictionary: [String: String] = [:]
        items.forEach { paramsDictionary[$0.name] = $0.value }
        return paramsDictionary
    }
}
