//
//  RoutingController.swift
//  Piazza
//
//  Created by Jared Rader on 12/29/22.
//

import UIKit
import Turbo
import SafariServices
import WebKit

class RoutingController: BaseNavigationController {
    private enum PresentationType: String {
        case advance, replace, modal
    }
    private static var sharedProcessPool = WKProcessPool()
    private static let modalSession = createSession()
    
    private(set) lazy var session: Session = {
        let session = Self.createSession()
        session.delegate = self
        return session
    }()
    
    private static func createSession() -> Session {
        let configuration = WKWebViewConfiguration()
        configuration.applicationNameForUserAgent = "Piazza Turbo Native iOS"
        configuration.processPool = sharedProcessPool
        
        let session = Session(webViewConfiguration: configuration)
        session.pathConfiguration = Global.pathConfiguration
        
        return session
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshWebView()
    }
    
    func refreshWebView() {
        if let vc = topViewController as? VisitableViewController {
            session.visit(vc)
        }
    }
}

extension RoutingController: SessionDelegate {
    func session(_ session: Session, didProposeVisit proposal: VisitProposal) {
        visit(proposal)
    }
    
    func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, error: Error) {
        if let turboError = error as? TurboError, turboError == .http(statusCode: 401) {
            showLoginScreen()
        } else {
            let alert = UIAlertController(
                title: NSLocalizedString("error.title", comment: ""),
                message: error.localizedDescription,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(
                title: NSLocalizedString("error.ok", comment: ""),
                style: .default,
                handler: nil
            ))
            presentedViewController?.dismiss(animated: true)
            present(alert, animated: true)
        }
    }
    
    private func showLoginScreen() {
        let properties = Global.pathConfiguration.properties(for: Api.Path.login)
        
        let proposal = VisitProposal(
            url: Api.Path.login,
            options: VisitOptions(),
            properties: properties
        )
        
        visit(proposal)
    }
    
    func visit(_ proposal: VisitProposal) {
        let viewController = ViewControllerVendor.viewController(
            for: proposal.url,
            properties: proposal.properties
        )
        
        let presentation = proposal.properties["presentation"] as? String ?? "advance"
        
        let presentationType = PresentationType(rawValue: presentation)!
        
        navigateTo(viewController, using: presentationType)
        
        visit(
            viewController,
            options: proposal.options,
            presentationType: presentationType
        )
    }
    
    private func navigateTo(_ vc: UIViewController, using presentationType: PresentationType) {
        switch presentationType {
        case .advance:
            presentedViewController?.dismiss(animated: true)
            pushViewController(vc, animated: true)
        
        case .replace:
            presentedViewController?.dismiss(animated: true)
            let viewControllers = Array(viewControllers.dropLast()) + [vc]
            setViewControllers(viewControllers, animated: true)
            
        case .modal:
            let modalNavController = BaseNavigationController(rootViewController: vc)
            
            if let presentedViewController = presentedViewController {
                presentedViewController.dismiss(
                    animated: true,
                    completion: { [unowned self] in self.present(modalNavController, animated: true)
                    })
            } else {
                present(modalNavController, animated: true)
            }
        }
    }
    
    private func visit(_ vc: UIViewController,
                       options: VisitOptions,
                       presentationType: PresentationType) {
        guard let visitable = vc as? Visitable else { return }
        
        switch presentationType {
        case .advance, .replace:
            Self.modalSession.delegate = nil
            session.visit(visitable, options: options)
        case .modal:
            Self.modalSession.delegate = self
            Self.modalSession.visit(visitable, options: options)
        }
        
        session.visit(visitable, options: options)
    }
    
    func sessionWebViewProcessDidTerminate(_ session: Session) {}
}
