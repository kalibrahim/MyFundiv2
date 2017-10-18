//
//  ProfileVC.swift
//  MyFundi
//
//  Created by Joseph  Ishak on 10/15/17.
//  Copyright © 2017 Bachmanity. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class ProfileVC: UIViewController,  UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    var imagePicker: UIImagePickerController!
    
    @IBOutlet weak var profileImage: UIImageView!
    var posts = [Post]()
    var fundraiserKeys = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userID : String = (Auth.auth().currentUser?.uid)!
        print("JOE Current user ID is:" + userID)

        tableView.delegate = self
        tableView.dataSource = self
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        DataService.ds.REF_USERS.observe(.value) { (snapshot) in
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot]{
                for snap in snapshot{
                    if userID == snap.key{
                        if let userDict = snap.value as? Dictionary<String,AnyObject>{
//                            print("JOE: \(userDict["fundraisers",value].values)")
                            if let fundraisers =  userDict["fundraisers"] as? [String:AnyObject]  {
                                for fund in fundraisers{
                                    self.fundraiserKeys.append(fund.key)
                                    print("JOE: Fundraisers Found for User: \(snap.key)")
                                    
                                }
                                   self.loadFundraisers()
                            }
                            else {
                                print("Joe: Fundraisers not found for user: \(snap.key)")
                            }
                        }
                        
                    }
                }
            }
        }
}
    
    func loadFundraisers(){
    
    DataService.ds.REF_FUNDRAISERS.observe(.value, with: { (snapshot) in
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshot {
                        for fundKey in self.fundraiserKeys{
                            if snap.key == fundKey{
                                if let postDict = snap.value as? Dictionary<String, AnyObject> {
                                    let key = snap.key
                                    let post = Post(postKey: key, postData: postDict)
                                    self.posts.append(post)
                                }
                            }
                        }
                    }
                }
                self.tableView.reloadData()
            })
    
    }


    func numberOfSections(in tableView: UITableView) -> Int {
       return 1
    }
    @IBAction func homeImageTapped(_ sender: AnyObject) {
        performSegue(withIdentifier: "goToFeedFromProf", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileHistoryCell") as? ProfileHistoryCell {
            
                cell.configureCell(post: post)
                return cell
            
        } else {
            return PostCell()
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImage.image = image
        } else {
            print("KHALID: A valid image wasnt selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    @IBAction func addImageTapped(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("KHALID: ID removed from keychain \(keychainResult)")
        try! Auth.auth().signOut()
        performSegue(withIdentifier: "goToSignInFromProf", sender: nil)
    }
    
  
}
