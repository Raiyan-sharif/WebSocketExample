//
//  NetworkLoggerViewController.swift
//  PockeTalk
//
//

import UIKit

class NetworkLoggerViewController: UIViewController {


    private var tableView:UITableView!

    override func loadView() {
        view = UIView()
        view.backgroundColor = .black
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.isHidden = true
    }
    


    private func setUpUI() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor)
            .isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.dataSource = self
        tableView.backgroundColor = UIColor.black
        tableView.register(cellType: NeworkLoggerCell.self)
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()

    }

    @objc func closeButtonEventListener(_ button: UIButton) {

        self.navigationController?.popViewController(animated: false)
    }

}

extension NetworkLoggerViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ResponseLogger.shareInstance.dataArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = ResponseLogger.shareInstance.dataArray[indexPath.row]

        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd hh:mm:ss"
        let dateStr = df.string(from: item.date)
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: NeworkLoggerCell.self)
        cell.dateLabel.text = dateStr
        cell.responseLabel.text = "URL: " + item.url + "\n" + "Parameter: " + item.params +  "\n" + "Ressponse: " + item.response
        return cell
    }


}
