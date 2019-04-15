//
//  ViewController.swift
//  ReoderingTableView
//
//  Created by goat_herd on 4/15/19.
//  Copyright © 2019 goat_herd. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    private var items: [String] = []
    private var reoderingGesture = UILongPressGestureRecognizer()
    private var snapshot: UIImageView!
    private var sourceIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        for i in 1...20 {
            items.append(String(i))
        }
        setupTableView()
        setupReoderingGesture()
    }
    
    private func setupReoderingGesture() {
        reoderingGesture = UILongPressGestureRecognizer(target: self, action: #selector(handlerReoderingGesture(sender:)))
        tableView.addGestureRecognizer(reoderingGesture	)
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "ReoderingTableViewCell", bundle: nil), forCellReuseIdentifier: "ReoderingTableViewCell")
    }
    
    @objc
    func handlerReoderingGesture(sender: UILongPressGestureRecognizer) {
        let state = sender.state
        let touchLocation = sender.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: touchLocation)
        switch state {
        case .began:
            guard let `indexPath` = tableView.indexPathForRow(at: touchLocation), let cell = tableView.cellForRow(at: indexPath) else {
                return
            }
            snapshot = customSnapshotForView(cell)
            sourceIndexPath = indexPath
            snapshot.center = cell.center
            snapshot.alpha = 0
            tableView.addSubview(snapshot)
            UIView.animate(withDuration: 0.29, animations: {
                self.snapshot.center.y = touchLocation.y
                self.snapshot.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                self.snapshot.alpha = 0.98
                cell.alpha = 0
            }) { _ in
                cell.isHidden = true
            }
        case .changed:
            guard let `indexPath` = tableView.indexPathForRow(at: touchLocation), let cell = tableView.cellForRow(at: indexPath) else {
                return
            }
            snapshot.center.y = touchLocation.y
            if let `sourceIndexPath` = sourceIndexPath,
                indexPath != sourceIndexPath {
                swapItemAt(firstIndex: indexPath.row, secondIndex: sourceIndexPath.row)
                tableView.moveRow(at: sourceIndexPath, to: indexPath)
                self.sourceIndexPath = indexPath
            }
        default:
            guard let `sourceIndexPath` = sourceIndexPath,
                let cell = tableView.cellForRow(at: sourceIndexPath) else {
                return
            }
            cell.alpha = 0
            UIView.animate(withDuration: 0.29, animations: {
                self.snapshot.center = cell.center
                self.snapshot.transform = .identity
                self.snapshot.alpha = 0.0
                cell.alpha = 1.0
            }) { _ in
                cell.isHidden = false
                self.sourceIndexPath = nil
                self.snapshot.removeFromSuperview()
                self.snapshot = nil
            }
            break
        }
    }
    
    private func customSnapshotForView(_ inputView: UIView) -> UIImageView {
        UIGraphicsBeginImageContext(inputView.bounds.size)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        snapshot = UIImageView(image: image)
        return snapshot ?? UIImageView()
    }
    
    private func swapItemAt(firstIndex: Int, secondIndex: Int) {
        if firstIndex < 0 || firstIndex > items.count || secondIndex < 0 || secondIndex > items.count {
            return
        }
        let tg = items[firstIndex]
        items[firstIndex] = items[secondIndex]
        items[secondIndex] = tg
    }

}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let reoderingCell = tableView.dequeueReusableCell(withIdentifier: "ReoderingTableViewCell", for: indexPath) as? ReoderingTableViewCell else {
            return UITableViewCell()
        }
        reoderingCell.setTitle(items[indexPath.row])
        return reoderingCell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}
