//
//  BrowserViewController.swift
//  SecretFolder_ios
//
//  Created by Quang Ly Hoang on 11/7/17.
//  Copyright © 2017 FenrirQ. All rights reserved.
//

import UIKit
import WebKit

class BrowserViewController: BaseViewController {
    
    @IBOutlet weak var urlView: UIView!
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var cancelProgressButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var hostLabel: UILabel!
    @IBOutlet weak var textFieldRightConstraint: NSLayoutConstraint!
    @IBOutlet weak var urlViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var hostLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var toolViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var hostView: UIView!
    
    var webView: WKWebView = WKWebView()
    fileprivate var lastContentOffset: CGFloat = 0
    var isFinishLoading: Bool!
    var timer: Timer!
    
    var isSearching: Bool = false {
        didSet {
            if isSearching {
                searchingConstraint()
                UIView.animate(withDuration: 0.2, animations: {self.view.layoutIfNeeded()})
            } else {
                noSearchingConstraint()
                UIView.animate(withDuration: 0.2, animations: {self.view.layoutIfNeeded()})
            }
        }
    }
    
    var isScrollUp: Bool = true {
        didSet {
            if isScrollUp {
                scrollUpConstraint()
                UIView.animate(withDuration: 0.2, animations: {self.view.layoutIfNeeded()})
            } else {
                scrollDownContraint()
                UIView.animate(withDuration: 0.2, animations: {self.view.layoutIfNeeded()})
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.addSubview(webView)
        containerView.addSubview(toolView)
        containerView.addSubview(hostView)
        let urlRequest = URLRequest(url: URL(string: "http://www.google.com.vn")!,
                                    cachePolicy: .reloadIgnoringLocalCacheData,
                                    timeoutInterval: 10)
        webView.load(urlRequest)
        webView.snp.makeConstraints { (maker) in
            maker.top.equalTo(urlView.snp.bottom)
            maker.bottom.equalToSuperview()
            maker.left.equalToSuperview()
            maker.right.equalToSuperview()
        }
        urlTextField.delegate = self
        urlTextField.clearButtonMode = .whileEditing
        webView.navigationDelegate = self
        webView.scrollView.delegate = self
        backButton.isEnabled = false
        forwardButton.isEnabled = false
        cancelProgressButton.isHidden = true
        cancelButton.isHidden = true
        //set status bar color to white color
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        statusBarView.backgroundColor = .white
        view.addSubview(statusBarView)
        isScrollUp = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if #available(iOS 9.0, *) {
            let websiteDataTypes = Set<AnyHashable>([WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeOfflineWebApplicationCache, WKWebsiteDataTypeMemoryCache, WKWebsiteDataTypeLocalStorage, WKWebsiteDataTypeCookies, WKWebsiteDataTypeSessionStorage, WKWebsiteDataTypeIndexedDBDatabases, WKWebsiteDataTypeWebSQLDatabases])
            let dateFrom = Date(timeIntervalSince1970: 0)
            WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as? Set<String> ?? Set<String>(), modifiedSince: dateFrom, completionHandler: {() -> Void in})
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        webView.goBack()
        textFieldDidEndEditing(urlTextField)
    }
    
    @IBAction func goForward(_ sender: UIButton) {
        webView.goForward()
        textFieldDidEndEditing(urlTextField)
    }
    
    @IBAction func reload(_ sender: UIButton) {
        webView.reload()
        textFieldDidEndEditing(urlTextField)
    }
    
    @IBAction func onCancel(_ sender: UIButton) {
        isSearching = false
        urlTextField.text = webView.url?.host
        hostLabel.text = webView.url?.host
        reloadButton.isHidden = false
        urlTextField.resignFirstResponder()
    }
    
    @IBAction func cancelProgress(_ sender: UIButton) {
        webView.stopLoading()
        webView.goBack()
        cancelProgressButton.isHidden = true
        urlTextField.text = webView.url?.host
    }
    
    @IBAction func onShare(_ sender: UIButton) {
        share(items: [webView.url])
    }
    
    func searchingConstraint() {
        textFieldRightConstraint.constant = 70
        urlTextField.textAlignment = .left
        cancelButton.isHidden = false
    }
    
    func noSearchingConstraint() {
        textFieldRightConstraint.constant = 5
        urlTextField.textAlignment = .center
        cancelButton.isHidden = true
    }
    
}

extension BrowserViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let url = URL(string: "http://" + (textField.text ?? ""))
        guard let urlCorrect = url else {
            self.toast(String.urlIncorrect)
            textField.resignFirstResponder()
            isSearching = false
            return true
        }
        let urlRequest = URLRequest(url: urlCorrect, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        webView.load(urlRequest)
        textField.resignFirstResponder()
        isSearching = false
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        isSearching = true
        reloadButton.isHidden = true
        textField.text = webView.url?.absoluteString
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        isSearching = false
        textField.text = webView.url?.host
        textField.resignFirstResponder()
    }
}

extension BrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        cancelProgressButton.isHidden = false
        reloadButton.isHidden = true
        progressView.isHidden = false
        progressView.progress = 0
        isFinishLoading = false
        timer = Timer.scheduledTimer(timeInterval: 0.0001,
                                     target: self,
                                     selector: #selector(timerCallBack),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc func timerCallBack() {
        if isFinishLoading {
            if progressView.progress >= 1 {
                progressView.isHidden = true
                timer.invalidate()
            } else {
                progressView.progress += 0.1
            }
        } else {
            progressView.progress += 0.005
            if progressView.progress >= 0.95 {
                progressView.progress = 0.95
            }
        }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        backButton.isEnabled = webView.canGoBack
        forwardButton.isEnabled = webView.canGoForward
        urlTextField.text = webView.url?.host
        hostLabel.text = webView.url?.host
        cancelProgressButton.isHidden = true
        reloadButton.isHidden = false
        isFinishLoading = true
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        toast(error.localizedDescription)
        cancelProgressButton.isHidden = true
        progressView.isHidden = true
    }
}

extension BrowserViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastContentOffset = scrollView.contentOffset.y
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        if (lastContentOffset - 50) > scrollView.contentOffset.y {
            isScrollUp = true
        } else if (lastContentOffset + 10) < scrollView.contentOffset.y {
            isScrollUp = false
        }
    }
    
    func scrollDownContraint() {
        urlViewTopConstraint.constant = -urlView.bounds.height - 50
        toolViewBottomConstraint.constant = -toolView.bounds.height - 50
        hostLabelTopConstraint.constant = 0
    }
    
    func scrollUpConstraint() {
        urlViewTopConstraint.constant = 0
        toolViewBottomConstraint.constant = 0
        hostLabelTopConstraint.constant = -hostLabel.bounds.height - 50
    }
}
