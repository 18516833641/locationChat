//
//  homeViewController.swift
//  LocationChat
//
//  Created by Mac on 2020/10/27.
//

import UIKit

class homeViewController: AnalyticsViewController {

    @IBOutlet weak var userIamge: UIImageView!
    @IBOutlet weak var nickName: UILabel!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var address: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var nameArr:[String] = []
    var addressArr:[String] = []
    var headerImage:[String] = []
    var objectID:[String] = []
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "关心的人"

        // Do any additional setup after loading the view.
        tableView.register(UINib(nibName: "friendTableViewCell", bundle: nil), forCellReuseIdentifier: "friendTableViewCell")
        
//        self.navigationItem.leftBarButtonItem = nil
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let user = BmobUser.current()
        if user != nil {
            
            nickName.text = user?.object(forKey: "nickName") as? String
            time.text = user?.object(forKey: "LocationTime") as? String
            address.text = user?.object(forKey: "location") as? String
            quertLocation()
        }else{
            
            //对象为空时，可打开用户注册界面
            BmobUser.logout()
            let vc = loginViewController()
            vc.title = "登录"
            self.navigationController?.pushViewController(vc, animated: false)
            
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
//        locationManager.stopUpdatingLocation()

    }
    
    
    
    @IBAction func addAction(_ sender: Any) {
        let vc = addFriendViewController()
        vc.title = "添加关心的人"
        self.navigationController?.pushViewController(vc, animated: false)
    }
    
    @IBAction func baojingAction(_ sender: Any) {
        
        let user = BmobUser.current()
        
//        let address = user?.object(forKey: "location") as? String
        
        if user != nil {
            //进行操作
            let vip = user?.object(forKey: "vip")
            
            if vip as! String == "1" {//已经开通vip
                
                
                
            }else if vip as! String == "0"{//未开通vip
            
                let alertView = SmileAlert(title: "赶快去解锁吧", message: "位置变动提醒.\n实时定位和轨迹移动提醒.\n一键报警.", cancelButtonTitle: "取 消", sureButtonTitle: "确 定")
                        alertView.show()
                        //获取点击事件
                        alertView.clickIndexClosure { (index) in
                            print("点击了第" + "\(index)" + "个按钮")
                            
                            if(index == 2){
                                let vc = vipViewController()
                                vc.title = "解锁特权"
                                self.navigationController?.pushViewController(vc, animated: false)
                                alertView.dismiss()
                            }
                            
                        }
                
               
            }
        }else{
            //对象为空时，可打开用户注册界面
            
        }
        
        
        
    }
    
    func quertLocation() {
        
        self.nameArr.removeAll()
        self.addressArr.removeAll()
        self.objectID.removeAll()
        
        let user = BmobUser.current()
            
        let query:BmobQuery = BmobQuery(className: "friend" + user!.mobilePhoneNumber)
            query.findObjectsInBackground { (array, error) in
                for i in 0..<array!.count{
                    let obj = array?[i] as! BmobObject
                    
                    self.nameArr.append(obj.object(forKey: "userPhone") as? String ?? "")
                    self.addressArr.append(obj.object(forKey: "location") as? String ?? "")
                    self.objectID.append(obj.object(forKey: "objectId") as? String ?? "")
//                    print("-------- \(self.nameArr + self.addressArr))")
           
               }
                self.tableView.reloadData()
           }

                
     
        
        
    
}
}

extension homeViewController:UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell:friendTableViewCell = tableView.dequeueReusableCell(withIdentifier: "friendTableViewCell") as? friendTableViewCell else {
            let cells = friendTableViewCell(style: .default, reuseIdentifier: "friendTableViewCell")
            cells.backgroundColor = .groupTableViewBackground
            return cells
        }
        
//        let nameData = nameArr[indexPath.row]
//
        cell.userPhone.text = nameArr[indexPath.row]
        cell.userAddress.text = addressArr[indexPath.row]
//        cell.u.text = listData.tile
//
//        cell.listImage.sd_setImage(with: URL(string:BERKKURL.Url_SeverImage + listData.thmb!), placeholderImage: UIImage(named: "zwsj"), options: .refreshCached, completed: nil)
      
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let cellData = dataSource[indexPath.row]
//        let vc = listDetailViewController()
//        vc.title = "工程案例详情"
//        vc.url = BERKKURL.URL_EngineeringList + "/" + cellData.id!
//        
//        self.navigationController?.pushViewController(vc, animated: true)
//        
    }
    
   func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true;
    }
        
   func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let user = BmobUser.current()
            
            let gamescore:BmobObject = BmobObject(outDataWithClassName: "friend" + user!.mobilePhoneNumber, objectId: objectID[indexPath.row])
            gamescore.deleteInBackground { (isSuccessful, error) in
                    if (isSuccessful) {
                        //删除成功后的动作
                        print ("-----success");
                        self.quertLocation()
                        
                        tableView.reloadData()
                    }else{
                        print("delete error \(String(describing: error?.localizedDescription))")
                    }
                }
        }

   }
}
