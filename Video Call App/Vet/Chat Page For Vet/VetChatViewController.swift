//
//  VetChatViewController.swift
//  VetRedirect
//
//  Created by IOS MAC5 on 01/12/17.
//  Copyright © 2017 Blusyscorp. All rights reserved.
//

import UIKit
import Alamofire
import SVProgressHUD
import SocketIO
import MobileCoreServices
import AVFoundation
import Photos

class VetChatViewController: UIViewController,UITextFieldDelegate,UITableViewDelegate, UITableViewDataSource , UIImagePickerControllerDelegate,UIPopoverControllerDelegate,UINavigationControllerDelegate , URLSessionDownloadDelegate, UIDocumentInteractionControllerDelegate,UIDocumentMenuDelegate,UIDocumentPickerDelegate{
    @IBOutlet weak var docViewOutlet: UIView!
    @IBOutlet weak var receiverNameLabel: UILabel!
    @IBOutlet weak var onlineOfflineStatusLabel: UILabel!
    @IBOutlet weak var petImageView: UIImageView!
    @IBOutlet weak var PetDetailsLabel: UILabel!
    @IBOutlet weak var messageText: UITextField!
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var petColorView: UIView!
    @IBOutlet weak var msgView: UIView!
    @IBOutlet weak var sendButtonOutlet: UIButton!
    @IBOutlet weak var blockButtonOutlet: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var attachmentButton: UIButton!
    // @IBOutlet var progressView: UIProgressView!
     let url = URL(string: "file:///private/var/mobile/Containers/Data/Application/4CEB945E-FD9F-46AF-851E-B632166EF76D/Library/Caches/com.apple.nsurlsessiond/Downloads/com.technoexponent.SCRIBSRIDES/CFNetworkDownload_AWyTOa.tmp")
    
    var imagePickerController = UIImagePickerController()
    var videoURL : NSURL?
    var videoData : NSData?
    private var uploadRequest: Request?
    private var lastContentOffset: CGFloat = 0
    var picker:UIImagePickerController?=UIImagePickerController()
    var GetReceiverData : NSDictionary?
    var ReceiverDetails = NSDictionary()
    var SenderDetails = NSDictionary()
    var PetDetails = NSDictionary()
    var ChatID = String()
    var receiverId = String()
    var ArrayForChatData = NSArray()
    var ContenerArray = NSArray()
    var AllChatData = NSMutableArray()
    var kheight = CGFloat()
    var msgWidth = CGFloat()
    var check = false
    var checkForScroll = false
    var pageIndex = Int()
    var userType = String()
    var UserAccessToken = String()
    var blockStatus = String()
    var SelectImage = UIImage()
    var cellHeight = CGFloat()
    var endTimestamp = String()
   // var user_details = NSDictionary()
    var downloadTask: URLSessionDownloadTask!
    var backgroundSession: URLSession!
    var DocPath = String()
    var fileName = String()
    var resurl : URL!
    var readStatus = String()
    var ApiCallOrNot = false
    var GetBlockStatus = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       picker?.delegate = self
        docViewOutlet.isHidden = true
        self.onlineOfflineStatusLabel.text = "Offline"
       

        UserAccessToken = "\(UserDefaults.standard.string(forKey: "user_access_token")!)"
        
      
            print(GetReceiverData!)
            userType = GetReceiverData!["userType"] as! String
            receiverNameLabel.text = GetReceiverData!["userName"] as! String
            if UserDefaults.standard.bool(forKey: "noti")
            {
                let ChatId = GetReceiverData!["id"] as! Int
                receiverId = String(ChatId)
            }
            else
            {
               receiverId = GetReceiverData!["id"] as! String
            }
        
            
            let petPicture = PetDetails["petPicture"] as! String
            let petName = PetDetails["petName"] as! String
            let petAge = PetDetails["petAge"] as! String
            let petGender = PetDetails["petSex"] as! String
           // let age = (Int(petAge))! / 12
            //  print(age)
            
            var boldText = "\(petName),"
            var normalText   = " \(petAge) Years Old, \(petGender)"
            
            var attrs = [NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 12)]
            var attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)
            var boldString = NSMutableAttributedString(string:normalText)
            
            attributedString.append(boldString)
            PetDetailsLabel.attributedText = attributedString

        PetDetailsLabel.sizeToFit()
        PetDetailsLabel.frame = CGRect(x:PetDetailsLabel.frame.origin.x, y: PetDetailsLabel.frame.origin.y, width:PetDetailsLabel.frame.size.width + 6, height: 21)
        
         petColorView.frame = CGRect(x:PetDetailsLabel.frame.origin.x + PetDetailsLabel.frame.size.width, y: petColorView.frame.origin.y, width:petColorView.frame.size.width, height: 14)
        
        let temp = PetDetails["petColor"] as! String
   //     print(temp)
        var color1 = hexStringToUIColor(hex: temp)
   //     print(color1)
        petColorView.backgroundColor = color1
        
        messageText.attributedPlaceholder = NSAttributedString(string:"Type your message...", attributes:[NSAttributedStringKey.foregroundColor: UIColor.white,NSAttributedStringKey.font :UIFont(name: "Arial", size: 14)!])
        
        petImageView.sd_setImage(with: URL(string: pet_Image_base_url+"\(PetDetails["petPicture"] as! String)"), placeholderImage: UIImage(named: "placeholder.png"))

        
        NotificationCenter.default.addObserver(self, selector: #selector(VetChatViewController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(VetChatViewController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        messageText.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        let outData = UserDefaults.standard.data(forKey: "user_details")
        SenderDetails = NSKeyedUnarchiver.unarchiveObject(with: outData!) as! NSDictionary
      //  print(profileDetails)
        //user_details = profileDetails["user_details"] as! NSDictionary
        //SenderDetails = profileDetails["user_details"] as! NSDictionary
        
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            self.SendUserIdForEmit()
            self.room_join()
            self.new_message()
        }
        
        socket.connect()
        self.SendUserIdForEmit()
        self.room_join()
        self.new_message()
        self.func_typing()
        self.func_stop_typing()
        self.func_room_join()
        self.func_room_left()
        self.func_user_joined()
        self.func_user_left()
        self.func_room_status()
        UserDefaults.standard.set(false, forKey: "noti")
        
        if GetBlockStatus == "U"
        {
            if userType == "P"
            {
                self.blockStatus = "VB"
            }
            else
            {
                self.blockStatus = "PB"
            }
          
        }
        else if GetBlockStatus == "PB"
        {
            if userType == "P"
            {
                self.blockStatus = "VB"
            }
            else
            {
                self.blockStatus = "U"
            }
        }
        else if GetBlockStatus == "VB"
        {
            if userType == "P"
            {
                self.blockStatus = "U"
            }
            else
            {
                self.blockStatus = "PB"
            }
        }
        else if GetBlockStatus == "BB"
        {
            self.blockStatus = "U"
        }
        else
        {
            if userType == "P"
            {
                self.blockStatus = "VB"
            }
            else
            {
                self.blockStatus = "PB"
            }
        }
        
        // Do any additional setup after loading the view.
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
     //MARK:- document pickerdelegate
    
    @available(iOS 8.0, *)
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {

        let cico = url as URL
        resurl = cico
        print("The Url is :",  (cico))
        self.fileUpload()
        print(cico.lastPathComponent)
        let  pdfURL = cico.appendingPathComponent("example.pdf") as URL
        print(pdfURL)

        //optional, case PDF -> render
        
        // displayPDFweb.loadRequest(NSURLRequest(url: cico) as URLRequest)
        
    }
    
    
    
    @available(iOS 8.0, *)
    
    public func documentMenu(_ documentMenu:     UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {

        documentPicker.delegate = self
        present(documentPicker, animated: true, completion: nil)

    }
 
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {

        print("we cancelled")
        dismiss(animated: true, completion: nil)

    }

    //MARK:- Socket send data
    func SendUserIdForEmit()
    {
        let MyId = SenderDetails["id"] as! String
        let str = "{\"userId\":\"\(MyId)\"}"
        
        print("Emit Call for add user ==========> \(str)")
        socket.emit("add user",str)
    }
    
    func room_join()
    {
        let socketData = "{\"chatId\":\"\(ChatID)\"}"
        print("room join ==========> \(socketData)")
        socket.emit("room join",socketData)
    }
    
    func Send_new_message()
    {
        let socketData = "{\"senderId\":\"\(SenderDetails["id"] as! String)\",\"chatId\":\"\(ChatID)\",\"message\":\"\(messageText.text!)\"}"
        print("send new message ==========> \(socketData)")
        socket.emit("new message",socketData)
    }
    
    func new_message()
    {
        socket.on("new message") { ( dataArray, ack) -> Void in
            print("new message ===>\(dataArray)")
            let dict = dataArray[0] as! NSDictionary
            socket.emit("stop typing","")
            self.AllChatData.add(dict)
            let indexPath = IndexPath(row: self.AllChatData.count - 1,section: 0)
            self.chatTableView.insertRows(at: [indexPath as IndexPath], with: .automatic)
            self.scrollToBottom()
            
        }
    }
    
    func func_room_join()
    {
        socket.on("room join") { ( dataArray, ack) -> Void in
            print("func room join ===>\(dataArray)")
            //self.onlineOfflineStatusLabel.text = "Online"
        }
    }
    
    func func_room_left()
    {
        socket.on("room left") { ( dataArray, ack) -> Void in
            print("room left ===>\(dataArray)")
            //self.onlineOfflineStatusLabel.text = "Offline"
        }
    }
    
    func func_user_joined()
    {
        socket.on("user joined") { ( dataArray, ack) -> Void in
            print("user joined ===>\(dataArray)")
//            let dic = dataArray[0] as! NSDictionary
//            let username = dic["username"] as! Int
//            if self.receiverId == String(username)
//            {
//               // self.onlineOfflineStatusLabel.text = "Online"
//            }
            
        }
    }
    
    func func_user_left()
    {
        socket.on("user left") { ( dataArray, ack) -> Void in
            print("user left ===>\(dataArray)")
            let dic = dataArray[0] as! NSDictionary
            
            if let username = dic["username"] as? Int
            {
                if self.receiverId == String(username)
                {
                    //self.onlineOfflineStatusLabel.text = "Offline"
                }
            }
            
            
        }
    }
    
    func func_typing()
    {
        socket.on("typing") { ( dataArray, ack) -> Void in
            print("typing ===>\(dataArray)")
            self.onlineOfflineStatusLabel.text = "typing..."
        }
    }
    
    func func_stop_typing()
    {
        socket.on("stop typing") { ( dataArray, ack) -> Void in
            print("stop typing ===>\(dataArray)")
            self.onlineOfflineStatusLabel.text = "Online"
        }
    }
    func func_room_status()
    {
        socket.on("room status") { ( dataArray, ack) -> Void in
            print("stop typing ===>\(dataArray)")
            let dic = dataArray[0] as! NSDictionary
            let status = dic["status"] as! String
            if status == "Online"
            {
                self.readStatus = "R"
            }
            else
            {
                self.readStatus = "U"
            }
            self.onlineOfflineStatusLabel.text = status
            if self.ApiCallOrNot == false
            {
                self.pageIndex = 0
                self.AllChatData = NSMutableArray()
                self.ContenerArray = NSArray()
                self.APICallForPreviousChat()
                self.ApiCallOrNot = true
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.lastContentOffset > self.chatTableView.contentOffset.y) {
            // move up
            print("move up")
            print(self.chatTableView.contentOffset.y)
        }
        else if (self.lastContentOffset < self.chatTableView.contentOffset.y) {
            // move down
            print("move down")
            print(self.chatTableView.contentOffset.y)
            if(self.chatTableView.contentOffset.y < -60)
            {
                if check == false
                {
                    check = true
                    pageIndex = pageIndex+1
                    APICallForPreviousChat()
                    
                }
            }
        }
        
        // update the new position acquired
        self.lastContentOffset = scrollView.contentOffset.y
    }
    
    func scrollToBottom(){
        if AllChatData.count > 0
        {
            DispatchQueue.global(qos: .background).async {
                let indexPath = IndexPath(row: self.AllChatData.count-1, section: 0)
                self.chatTableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
        
    }
    func getFormattedDate(myString: Double) -> String{
        let date = Date(timeIntervalSince1970: myString)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "MMM d, h:mm a" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        
        return strDate
    }
    // MARK: - All Button Action 
    
    @IBAction func BackButtonClick(_ sender: Any)
    {
        let socketData = "{\"chatId\":\"\(ChatID)\"}"
        print("room left ==========> \(socketData)")
        socket.emit("room left",socketData)
        
       // socket.emit("room left","")
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func BlockUserButtonClick(_ sender: Any)
    {
        //APICallForBlockUser()
        if let buttonTitle = (sender as AnyObject).title(for: .normal)
        {
            if buttonTitle == "Unblock"
            {
                APICallForBlockUser()
            }
            else{
                self.datePickerTapped()
            }
        }
        
    }
    @IBAction func sendButtonClick(_ sender: Any)
    {
        if self.messageText.text == ""
        {
            
        }
        else
        {
            let timestamp = NSDate().timeIntervalSince1970
            print(timestamp)
            Send_new_message()
            let dict:[String:Any] = [
                "message": messageText.text!,
                "messageType":"M",
                "senderId": SenderDetails["id"] as! String,
                "sentTime": timestamp,
                "readStatus":self.readStatus
            ]
            if self.readStatus == "R"
            {
                self.ApiCallOrNot = true
            }
            else
            {
                self.ApiCallOrNot = false
            }
            
            self.AllChatData.add(dict)
            let indexPath = IndexPath(row: self.AllChatData.count - 1,section: 0)
            self.chatTableView.insertRows(at: [indexPath as IndexPath], with: .automatic)
            
            self.scrollToBottom()
            self.messageText.text = ""
            // self.messageText.resignFirstResponder()

        }
        
    }
    
    @IBAction func fileattachmentButtonClick(_ sender: Any) {
        // create an actionSheet
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // create an action
        let TakePhoto: UIAlertAction = UIAlertAction(title: "Take Photo", style: .default) { action -> Void in
            
            print("First Action pressed")
            self.openCamera()
        }
        
        let OpenGallery: UIAlertAction = UIAlertAction(title: "Open Gallery", style: .default) { action -> Void in
            
            print("Second Action pressed")
            self.openGallary()
        }
        let OpenVideo: UIAlertAction = UIAlertAction(title: "Open Video List", style: .default) { action -> Void in
            
            print("Second Action pressed")
            self.openVideo()
        }
        let OpenDocument: UIAlertAction = UIAlertAction(title: "Open Document List", style: .default) { action -> Void in
            
            let importMenu = UIDocumentMenuViewController(documentTypes: [String(kUTTypePDF)], in: .import)
            importMenu.delegate = self
            importMenu.modalPresentationStyle = .formSheet
            self.present(importMenu, animated: true, completion: nil)
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .cancel) { action -> Void in }
        
        // add actions
        actionSheetController.addAction(TakePhoto)
        actionSheetController.addAction(OpenGallery)
        actionSheetController.addAction(OpenVideo)
        actionSheetController.addAction(cancelAction)
         actionSheetController.addAction(OpenDocument)
        // present an actionSheet...
        present(actionSheetController, animated: true, completion: nil)
    }
    
    
    func openCamera()
    {
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)){
            picker!.allowsEditing = false
            picker!.sourceType = UIImagePickerControllerSourceType.camera
            picker!.cameraCaptureMode = .photo
            present(picker!, animated: true, completion: nil)
        }else{
            let alert = UIAlertController(title: "Camera Not Found", message: "This device has no Camera", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style:.default, handler: nil)
            alert.addAction(ok)
            present(alert, animated: true, completion: nil)
        }
    }
    
    func openGallary()
    {
        picker!.allowsEditing = false
        picker!.sourceType = UIImagePickerControllerSourceType.photoLibrary
        present(picker!, animated: true, completion: nil)
    }
    
    
    func openVideo()
    {
        imagePickerController.sourceType = .savedPhotosAlbum
        imagePickerController.delegate = self
        imagePickerController.mediaTypes = [kUTTypeMovie as String]
        present(imagePickerController, animated: true, completion: nil)
    }
    func resizeImage(image: UIImage, newWidth: CGFloat) -> UIImage? {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        print(info)
        if chosenImage != nil
        {
           // imageView.contentMode = .scaleAspectFit
            SelectImage = resizeImage(image: chosenImage!, newWidth: 200)!
            
            self.imageUpload()
            self.dismiss(animated: true, completion: nil)
        }
        else
        {
            videoURL = info[UIImagePickerControllerMediaURL]as? NSURL
            print(videoURL!)
            do {
                let asset = AVURLAsset(url: videoURL as! URL , options: nil)
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                imgGenerator.appliesPreferredTrackTransform = true
                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                videoData = try NSData(contentsOfFile: (videoURL?.relativePath)!, options: NSData.ReadingOptions.alwaysMapped)
                SelectImage = thumbnail
                self.videoUpload()
            } catch let error {
                print("*** Error generating thumbnail: \(error.localizedDescription)")
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - Table View Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.AllChatData.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let selectChatData = self.AllChatData[indexPath.row] as! NSDictionary
        let msgID = selectChatData["senderId"] as! String
        if msgID == receiverId
        {
            let messageType = selectChatData["messageType"] as! String
            if messageType == "F"
            {
                let cell = Bundle.main.loadNibNamed("ReceiverOnlyFileCell", owner: self, options: nil)?.first as! ReceiverOnlyFileCell
                cell.fileNameLabel.text = selectChatData["fileName"] as? String
                cell.downloadButton.addTarget(self,action:#selector(downloadButtonClick(sender:)), for: .touchUpInside)
                cell.downloadButton.tag=indexPath.row
                
                return cell
            }
             let cell = Bundle.main.loadNibNamed("ReceiverOnlyTextCell", owner: self, options: nil)?.first as! ReceiverOnlyTextCell
            let textMsg = selectChatData["message"] as? String
            cell.ReceiverMsgLabel.text = textMsg?.decodeEmoji
            msgWidth = cell.ReceiverMsgLabel.frame.size.width
            print("msgWidth == \(msgWidth)")
            let TimeStm = selectChatData["sentTime"] as! Double
            cell.ReceiverMsgTime.text = self.getFormattedDate(myString: TimeStm)
            return cell
        }
        let messageType = selectChatData["messageType"] as! String
        if messageType == "F"
        {
            let cell = Bundle.main.loadNibNamed("SenderOnlyFileCell", owner: self, options: nil)?.first as! SenderOnlyFileCell
            cell.fileNameLabel.text = selectChatData["fileName"] as? String
            cell.downloadButton.addTarget(self,action:#selector(downloadButtonClick(sender:)), for: .touchUpInside)
            cell.downloadButton.tag=indexPath.row
            
            let readStatus = selectChatData["readStatus"] as! String
            if readStatus == "R"
            {
                cell.seenImg.image = UIImage(named:"seen.png")!
            }else{
                cell.seenImg.image = UIImage(named:"unseen.png")!
            }
            
            return cell
        }
         let cell = Bundle.main.loadNibNamed("SenderOnlyTextCell", owner: self, options: nil)?.first as! SenderOnlyTextCell
        let textMsg = selectChatData["message"] as? String
        cell.SenderMsgLabel.text = textMsg?.decodeEmoji
        
        // cell.SenderMsgLabel.text = selectChatData["message"] as? String
        msgWidth = cell.SenderMsgLabel.frame.size.width
        print("msgWidth == \(msgWidth)")
       
        let TimeStm = selectChatData["sentTime"] as! Double
        cell.SenderMsgTime.text = self.getFormattedDate(myString: TimeStm)

        let readStatus = selectChatData["readStatus"] as! String
        if readStatus == "R"
        {
            cell.seenImg.image = UIImage(named:"seen.png")!
        }else{
            cell.seenImg.image = UIImage(named:"unseen.png")!
        }
        
        
         return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if(indexPath.row == 0)
//        {
//            if check == true
//            {
//                check = false
//                 print(indexPath.row)
//                 pageIndex = pageIndex+1
//                APICallForPreviousChat()
//            }
//            else
//            {
//                check = true
//            }
//        }

    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        
        let selectChatData = self.AllChatData[indexPath.row] as! NSDictionary
        let msgID = selectChatData["senderId"] as! String
        // print(selectChatData)
        let messageType = selectChatData["messageType"] as! String
        if messageType == "F"
        {
            return 90.0
        }
        let font = UIFont(name: "Helvetica", size: 14.0)
        let height = heightForView(text: (selectChatData["message"] as? String)!, font: font!, width: msgWidth)
        cellHeight = height + 60
        return (height + 60)
    }
    
    @objc func downloadButtonClick(sender:UIButton)
    {
        SVProgressHUD.show(withStatus: "downloading...")
        
        let buttonRow = sender.tag
        let SelectValue = self.AllChatData[buttonRow] as! NSDictionary
        print(SelectValue)
        if let path = SelectValue["message"] as? String
        {
            if SelectValue["message"] as! String != ""
            {
                var stringArray = path.characters.split{$0 == "."}.map(String.init)
                var fileExtension: String = stringArray[stringArray.count-1]
                print(fileExtension)
                
                //     let mimeType = SelectValue["mimeType"] as! String
                if fileExtension == "jpg"
                {
                    let image = SelectValue["message"] as! String
                    let fileUrl = NSURL(string: image)
                    print(fileUrl)
                    self.getDataFromUrl(url: fileUrl! as URL) { (data, response, error)  in
                        guard let data = data, error == nil else { return }
                        print("Download Finished")
                        
                        let downloadedImage = UIImage(data: data)
                        DispatchQueue.main.async() { () -> Void in
                            if (downloadedImage != nil)
                            {
                                
                                UIImageWriteToSavedPhotosAlbum(downloadedImage!, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
                            }
                            else
                            {
                                
                            }
                        }
                    }
                }
                else if fileExtension == "mp4"
                {
                    let videoImageUrl = SelectValue["message"] as! String
                    // let theVideoURL = URL(videoImageUrl)
                    // downloadVideoLinkAndCreateAsset(videoImageUrl)
                    // let videoImageUrl = "http://www.sample-videos.com/video/mp4/720/big_buck_bunny_720p_1mb.mp4"
                    DispatchQueue.global(qos: .background).async {
                        if let url = URL(string: videoImageUrl),
                            let urlData = NSData(contentsOf: url) {
                            let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0];
                            let filePath="\(documentsPath)/tempFile.mp4"
                            DispatchQueue.main.async {
                                urlData.write(toFile: filePath, atomically: true); PHPhotoLibrary.shared().performChanges({ PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: URL(fileURLWithPath: filePath)) })
                                {
                                    completed, error in if completed {
                                        print("Video is saved!")
                                        SVProgressHUD.dismiss()
                                        
                                    }
                                    
                                }
                                
                            }
                            
                        }
                        
                        
                        
                    }
                }
                else if fileExtension == "pdf"
                {
                    SVProgressHUD.dismiss()
                    webView.loadRequest(URLRequest(url: URL(string: path)!))
                    docViewOutlet.isHidden = false
                    //            var fullNameArr = path.components(separatedBy: "/")
                    //            fileName = fullNameArr[fullNameArr.count-1]
                    //            print(fileName)
                    //
                    //            let url = URL(string: path)!
                    //            downloadTask = backgroundSession.downloadTask(with: url)
                    //            downloadTask.resume()
                }
                else if fileExtension == "txt"
                {
                    SVProgressHUD.dismiss()
                    webView.loadRequest(URLRequest(url: URL(string: path)!))
                    
                    docViewOutlet.isHidden = false
                    //            var fullNameArr = path.components(separatedBy: "/")
                    //            fileName = fullNameArr[fullNameArr.count-1]
                    //            print(fileName)
                    //
                    //            let url = URL(string: path)!
                    //            downloadTask = backgroundSession.downloadTask(with: url)
                    //            downloadTask.resume()
                }
                else
                {
                    SVProgressHUD.dismiss()
                    webView.loadRequest(URLRequest(url: URL(string: path)!))
                    docViewOutlet.isHidden = false
                }
            }
            else
            {
                let alert = UIAlertView()
                alert.title="Alert"
                alert.message = "this file is already exist"
                alert.cancelButtonIndex = 0
                alert.addButton(withTitle: "Ok")
                alert.show()
            }
            
        }
        
    
        //
        
        
    }
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    
    if error == nil {
        SVProgressHUD.dismiss()
        let ac = UIAlertController(title: "Saved!", message: "Image saved to your photos.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
    } else {
        SVProgressHUD.dismiss()
        let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
        }
    }
    func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
        URLSession.shared.dataTask(with: url) {
            (data, response, error) in
            completion(data, response, error)
            }.resume()
    }
    
    
    func downloadVideoLinkAndCreateAsset(_ videoLink: String) {
        
        // use guard to make sure you have a valid url
        guard let videoURL = URL(string: videoLink) else { return }
        
        guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        
        // check if the file already exist at the destination folder if you don't want to download it twice
        // if !FileManager.default.fileExists(atPath: documentsDirectoryURL.appendingPathComponent(videoURL.lastPathComponent).path) {
        
        // set up your download task
        URLSession.shared.downloadTask(with: videoURL) { (location, response, error) -> Void in
            
            // use guard to unwrap your optional url
            guard let location = location else { return }
            
            // create a deatination url with the server response suggested file name
            let destinationURL = documentsDirectoryURL.appendingPathComponent(response?.suggestedFilename ?? videoURL.lastPathComponent)
            
            do {
                
                try FileManager.default.moveItem(at: location, to: destinationURL)
                
                PHPhotoLibrary.requestAuthorization({ (authorizationStatus: PHAuthorizationStatus) -> Void in
                    
                    // check if user authorized access photos for your app
                    if authorizationStatus == .authorized {
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: destinationURL)}) { completed, error in
                                if completed {
                                    print("Video asset created")
                                    
                                } else {
                                    print(error)
                                }
                        }
                    }
                })
                
            } catch { print(error) }
            
            }.resume()
        
        
        
    }
    @IBAction func doneWebView(_ sender: Any) {
        docViewOutlet.isHidden = true
    }
    func video(videoPath: String, didFinishSavingWithError error: Error?, contextInfo info: AnyObject)
    {
        if let _ = error {
            print("Error,Video failed to save")
        }else{
            print("Successfully,Video was saved")
        }
    }
     // MARK: - Api Call For Previous Chat Load
    func APICallForPreviousChat()
    {
        SVProgressHUD.show()
        
        let myUrl = URL(string:BASE_URL+"prevchats");
        
        var request = URLRequest(url:myUrl!)
        
        request.httpMethod = "POST"
        
        let postString = "user_access_token=\(UserAccessToken)&chatId=\(ChatID)&index=\(pageIndex)"
        
        print("postString==>\(postString)")
        
        request.httpBody = postString.data(using: String.Encoding.utf8);
        
        
        
        Alamofire.request(request)
            
            .responseJSON { response in
                
                guard let json = response.result.value as? [String: Any] else {
                    
                    print("didn't get todo object as JSON from API")
                    
                   // print("Error: \(response.result.error as! NSString)")
                    
                    SVProgressHUD.dismiss()
                    
                    return
                    
                }
                
                print(json)
                SVProgressHUD.dismiss()
                self.check = false
               // print("JSON: \(json)")
                if (json["has_error"] as? Int) == 1
                {
                    let alert = UIAlertController(title: "Alert", message: json["errors"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                }
                else if (json["has_error"] as? Int) == 0
                    
                {
                    self.ArrayForChatData = json["chats"] as! NSArray
                   if self.ArrayForChatData.count > 0
                    {
//                        self.ArrayForChatData = self.ArrayForChatData.reversed() as NSArray
                        
                        //self.ArrayForChatData.addingObjects(from: self.AllChatData as! [Any] )
                        self.AllChatData = NSMutableArray()
                        self.AllChatData.addObjects(from: self.ArrayForChatData as! [Any])
                        if self.ContenerArray.count > 0
                        {
                             self.AllChatData.addObjects(from: self.ContenerArray as! [Any])
                        }
                      //  print(self.AllChatData)
                        self.chatTableView.reloadData()
                        if self.checkForScroll == false
                        {
                            self.checkForScroll = true
                            if self.AllChatData.count > 0
                            {
                                self.scrollToBottom()
                            }
                        }
                        
                        self.ContenerArray = self.AllChatData
                        print(self.ContenerArray)
                    }
                }
        }
        
    }
    
    func APICallForBlockUser()
    {
        SVProgressHUD.show()
        let myUrl = URL(string:BASE_URL+"chatrequest");
        var request = URLRequest(url:myUrl!)
        request.httpMethod = "POST"
        let postString = "user_access_token=\(UserAccessToken)&reqTo=\(self.receiverId)&status=\("")&blocked=\(self.blockStatus)&endTime=\(self.endTimestamp)&blockedId=\(self.receiverId)"
        print("postString==>\(postString)")
        request.httpBody = postString.data(using: String.Encoding.utf8);
        Alamofire.request(request)
            
            .responseJSON { response in
                
                guard let json = response.result.value as? [String: Any] else {
                    
                    print("didn't get todo object as JSON from API")
                    
                    // print("Error: \(response.result.error as! NSString)")
                    
                    SVProgressHUD.dismiss()
                    
                    return
                    
                }
                
                //   print(json)
                SVProgressHUD.dismiss()
                print("JSON: \(json)")
                if (json["has_error"] as? Int) == 1
                {
                    let alert = UIAlertController(title: "Alert", message: json["errors"] as? String, preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    
                }
                else if (json["has_error"] as? Int) == 0
                {
                   
                    let uiAlertController = UIAlertController(// create new instance alert  controller
                        title: "Alert",
                        message: "\(json["request_success"] as! String)",
                        preferredStyle:.alert)
                    
                    uiAlertController.addAction(// add Custom action on Event is Cancel
                        UIAlertAction.init(title: "Ok", style: .default, handler: { (UIAlertAction) in
                            //TO DO code
                            self.navigationController?.popViewController(animated: true)
                            uiAlertController.dismiss(animated: true, completion: nil)//dismiss show You alert, on click is Cancel
                        }))
                    //show You alert
                    self.present(uiAlertController, animated: true, completion: nil)
                }
                
        }
        
    }
    
    func fileUpload()
        
    {
        
        SVProgressHUD.show()
        
        let myUrl = URL(string: "http://www.vetredirect.com:8080/uploadFile");
        let request = NSMutableURLRequest(url:myUrl! as URL);
        request.httpMethod = "POST";
        //  let boundary = generateBoundaryString()
        let params: Parameters = ["senderId": "\(SenderDetails["id"] as! String)","chatId": "\(ChatID)"]
        print("postString==>\(params)")
        Alamofire.upload(multipartFormData: { multipartFormData in
            multipartFormData.append(self.resurl, withName:"somefile", fileName: "documents.pdf", mimeType: "application/pdf")
            for (key, value) in params {
                
                multipartFormData.append(String(describing: value).data(using: String.Encoding.utf8)!, withName: key)
     
            }
            
        }, to: myUrl!, method: .post, headers: nil,
           
           encodingCompletion: { encodingResult in
            
            switch encodingResult {
                
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    
                    print("Upload Progress: \(progress.fractionCompleted)")
                    
                })
                
                
                
                upload.responseJSON { response in
                    
                    debugPrint("SUCCESS RESPONSE: \(response)")
                    
                    guard let json = response.value else {
                        
                        print("didn't get todo object as JSON from API")
                        
                        //print("Error: \(response.result.error as! NSString)")
                        
                        SVProgressHUD.dismiss()
                        
                        return
                        
                    }
                    
                    //print(json)
                    
                    print("JSON: \(json)")
                    
                    let responseData: [String:Any] = json as! [String : Any]
                    
                    print("Response Data: \(responseData)")
                    
                    
                    
                    if ((responseData["has_error"] as! String) == "0")
                    {

                        self.pageIndex = 0
                        self.AllChatData = NSMutableArray()
                        self.ContenerArray = NSArray()
                        self.APICallForPreviousChat()
//                        let timestamp = NSDate().timeIntervalSince1970
//                        let dict:[String:Any] = [
//                            "message": "",
//                            "fileName": "resume.pdf",
//                            "messageType":"F",
//                            "senderId": self.SenderDetails["id"] as! String,
//                            "sentTime": timestamp
//                        ]
//
//                        self.AllChatData.add(dict)
//                        let indexPath = IndexPath(row: self.AllChatData.count - 1,section: 0)
//                        self.chatTableView.insertRows(at: [indexPath as IndexPath], with: .automatic)
//                        self.scrollToBottom()
//                        SVProgressHUD.dismiss()
                        
                    }else{
                        let mesage = responseData["errors"] as? String
                        
                        print("Message: \(mesage)")
                        
                        let alert = UIAlertView()
                        
                        alert.title="Error"
                        
                        alert.message = mesage
                        
                        alert.cancelButtonIndex = 0
                        
                        alert.addButton(withTitle: "Ok")
                        
                        alert.show()
                        
                    }
                }
                
            case .failure(let encodingError):
                
                print("error:\(encodingError)")
                
                SVProgressHUD.dismiss()
                
            }
            
        })
        
        
        
    }
    
    func imageUpload()
        
    {
        
        SVProgressHUD.show()
        
        let myUrl = URL(string: "http://videocall.vetredirect.com:3701/uploadFile");
        
        let request = NSMutableURLRequest(url:myUrl! as URL);
        
        request.httpMethod = "POST";
        
        let boundary = generateBoundaryString()
        
        let params: Parameters = ["senderId": "\(SenderDetails["id"] as! String)","chatId": "\(ChatID)"]
        print("postString==>\(params)")
 
        Alamofire.upload(multipartFormData: { multipartFormData in
            
            if let imageData = UIImageJPEGRepresentation(self.SelectImage, 1) {
                
                multipartFormData.append(imageData, withName: "somefile", fileName: "Image File.jpg", mimeType: "image/png")
                
            }

            for (key, value) in params {
                
                multipartFormData.append(String(describing: value).data(using: String.Encoding.utf8)!, withName: key)
                
            }
            
        }, to: myUrl!, method: .post, headers: nil,
           
           encodingCompletion: { encodingResult in
            
            switch encodingResult {
                
            case .success(let upload, _, _):
                
                upload.uploadProgress(closure: { (progress) in
                    
                    print("Upload Progress: \(progress.fractionCompleted)")
                    
                })
                upload.responseString { response in
                    
                    debugPrint("SUCCESS RESPONSE: \(response)")
                    SVProgressHUD.dismiss()
                    self.pageIndex = 0
                    self.AllChatData = NSMutableArray()
                    self.ContenerArray = NSArray()
                    self.APICallForPreviousChat()
                    
//                    let timestamp = NSDate().timeIntervalSince1970
//                    let dict:[String:Any] = [
//                        "message": "",
//                        "fileName": "Image File.jpg",
//                        "messageType":"F",
//                        "senderId": self.SenderDetails["id"] as! String,
//                        "sentTime": timestamp
//                    ]
//
//                    self.AllChatData.add(dict)
//                    let indexPath = IndexPath(row: self.AllChatData.count - 1,section: 0)
//                    self.chatTableView.insertRows(at: [indexPath as IndexPath], with: .automatic)
//                    self.scrollToBottom()
                    
                }
                
            case .failure(let encodingError):
                
                print("error:\(encodingError)")
                
                SVProgressHUD.dismiss()
                
            }
            
        })
        
        
        
    }
    
    func videoUpload()
        
    {
            SVProgressHUD.show()
            let myUrl = URL(string: "http://videocall.vetredirect.com:3701/uploadFile");
        
            let request = NSMutableURLRequest(url:myUrl! as URL);
            request.httpMethod = "POST";
            let boundary = generateBoundaryString()
        
        let params: Parameters = ["senderId": "\(SenderDetails["id"] as! String)","chatId": "\(ChatID)"]
            
            print("postString==>\(params)")
        
            Alamofire.upload(multipartFormData: { multipartFormData in
                
                if let imageData = UIImageJPEGRepresentation(self.SelectImage, 1) {
                    
                    multipartFormData.append((self.videoData as Data?)!, withName: "somefile", fileName: "Video File.mp4", mimeType: "video/quicktime")
                }
                
                for (key, value) in params {
                    
                    multipartFormData.append(String(describing: value).data(using: String.Encoding.utf8)!, withName: key)
                    
                }
                
            }, to: myUrl!, method: .post, headers: nil,
               
               encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    
                    upload.uploadProgress(closure: { (progress) in
                        print("Upload Progress: \(progress.fractionCompleted)")
                        
                    })

                    self.uploadRequest = upload
                    upload.responseJSON { response in
                        
                        debugPrint(response)
                        
                        if self.uploadRequest == nil{
                            self.uploadRequest = nil
                            let alert = UIAlertView()
                            alert.title="Error"
                            alert.message = "Uploaded cancelled by user."
                            alert.cancelButtonIndex = 0
                            alert.addButton(withTitle: "Ok")
                            alert.show()
                            SVProgressHUD.dismiss()
                            
                        }else{
                            
                            let alert = UIAlertView()
                            alert.title="Success"
                            alert.message = "Uploaded Succcessfully!"
                            alert.cancelButtonIndex = 0
                            alert.addButton(withTitle: "Ok")
                            alert.show()
                            SVProgressHUD.dismiss()
                            
                            self.pageIndex = 0
                            self.AllChatData = NSMutableArray()
                            self.ContenerArray = NSArray()
                            self.APICallForPreviousChat()

//                            let timestamp = NSDate().timeIntervalSince1970
//                            let dict:[String:Any] = [
//                                "message": "",
//                                "fileName": "Image File.mp4",
//                                "messageType":"F",
//                                "senderId": self.SenderDetails["id"] as! String,
//                                "sentTime": timestamp
//                            ]
//
//                            self.AllChatData.add(dict)
//                            let indexPath = IndexPath(row: self.AllChatData.count - 1,section: 0)
//                            self.chatTableView.insertRows(at: [indexPath as IndexPath], with: .automatic)
//                            self.scrollToBottom()
                            
                            
                        }
                        
                    }
                    
                case .failure(let encodingError):
                    
                    print("error:\(encodingError)")
                    
                    let alert = UIAlertView()
                    
                    alert.title="Error"
                    
                    alert.message = "Failed to post"
                    
                    alert.cancelButtonIndex = 0
                    
                    alert.addButton(withTitle: "Ok")
                    
                    alert.show()
                    
                    SVProgressHUD.dismiss()
                    
                }
                
            })
            
        }
    
    
    
    func generateBoundaryString() -> String
        
    {
        
        return "Boundary-\(NSUUID().uuidString)"
        
    }
    
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        
        return label.frame.height
    }
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.characters.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    //MARK: - Text Filde Delegate Func
    @objc func keyboardWillShow(notification: NSNotification)
    {
        if let keyboardRectValue = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            let keyboardHeight = keyboardRectValue.height
            kheight = keyboardHeight
            print(keyboardHeight)
            if self.msgView.frame.origin.y == self.view.frame.size.height - 60{
                
                self.msgView.frame.origin.y -= keyboardHeight
                self.chatTableView.frame.size.height -= keyboardHeight
                self.scrollToBottom()
            }
            
        }
    }
    
    
    
    @objc func keyboardWillHide(notification: NSNotification)
    {
        if let keyboardRectValue = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            
            let keyboardHeight = keyboardRectValue.height
            
            print(keyboardHeight)
            
            if self.msgView.frame.origin.y != self.view.frame.size.height - 60{
                
                self.msgView.frame.origin.y += keyboardHeight
                self.chatTableView.frame.size.height += keyboardHeight
            }
            
        }
        
    }
    @objc func textFieldDidChange(_ textField: UITextField)
    {
        socket.emit("typing","")
        delayWithSeconds(1) {
            //Do something
            socket.emit("stop typing","")
        }
        
    }
  
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        print("textFieldShouldReturn")
        textField.resignFirstResponder();
        return true;
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    //MARK: URLSessionDownloadDelegate
    // 1
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL){
        print(location)
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentDirectoryPath:String = path[0]
        let fileManager = FileManager()
        let destinationURLForFile = URL(fileURLWithPath: documentDirectoryPath.appendingFormat("/\(fileName)"))
        
        if fileManager.fileExists(atPath: destinationURLForFile.path){
            showFileWithPath(path: destinationURLForFile.path)
        }
        else{
            do {
                try fileManager.moveItem(at: location, to: destinationURLForFile)
                // show file
                showFileWithPath(path: destinationURLForFile.path)
            }catch{
                print("An error occurred while moving file to destination url")
            }
        }
    }
    // 2
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64){
      //  progressView.setProgress(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite), animated: true)
    }
    
    //MARK: URLSessionTaskDelegate
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?){
        downloadTask = nil
      //  progressView.setProgress(0.0, animated: true)
        if (error != nil) {
            print(error!.localizedDescription)
        }else{
            SVProgressHUD.dismiss()
            print("The task finished transferring data successfully")
        }
    }
    
    func showFileWithPath(path: String){
        print(path)
        let isFileFound:Bool? = FileManager.default.fileExists(atPath: path)
//        if isFileFound == true{
            let viewer = UIDocumentInteractionController(url: URL(fileURLWithPath: path))
            viewer.delegate = self
            viewer.presentPreview(animated: true)
        
//        }
    }
    //MARK: UIDocumentInteractionControllerDelegate
    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController
    {
        return self
    }
    func documentInteractionControllerDidEndPreview(controller: UIDocumentInteractionController) {
        print("document preview ends")
        
    }

    //MARK: - Date picker func
    
    func datePickerTapped() {
        let currentDate = Date()
        var dateComponents = DateComponents()
        dateComponents.month = -3
        let threeMonthAgo = Calendar.current.date(byAdding: dateComponents, to: currentDate)
        var pickerTitle = String()
        pickerTitle = "Set Block Time"
        let datePicker = DatePickerDialog(textColor: .red,
                                          buttonColor: .red,
                                          font: UIFont.boldSystemFont(ofSize: 17),
                                          showCancelButton: true)
        datePicker.show(pickerTitle,
                        doneButtonTitle: "Done",
                        cancelButtonTitle: "Cancel",
                        minimumDate: currentDate,
                        //maximumDate: currentDate,
        datePickerMode: .dateAndTime) { (date) in
            if let dt = date {
                print(dt)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                dateFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone!
                self.endTimestamp = dateFormatter.string(from: dt)
                print(self.endTimestamp)
                self.APICallForBlockUser()
                
            }
        }
    }
    
    func convertLocalToUTC(localTime: String) -> String? {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-DD HH:MM:SS"
        dateFormatter.timeZone = NSTimeZone.local
        let timeLocal = dateFormatter.date(from: localTime)
        
        if timeLocal != nil {
            dateFormatter.timeZone = TimeZone.init(abbreviation: "UTC")
            
            let timeUTC = dateFormatter.string(from: timeLocal!)
            return timeUTC
        }
        return nil
    }
    
    func localToUTC(date:String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-DD HH:MM:SS"
        dateFormatter.calendar = NSCalendar.current
        dateFormatter.timeZone = TimeZone.current
        
        let dt = dateFormatter.date(from: date)
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "YYYY-MM-DD HH:MM:SS"
        
        return dateFormatter.string(from: dt!)
    }


}

extension String {
    var decodeEmoji: String{
        let data = self.data(using: String.Encoding.utf8);
        let decodedStr = NSString(data: data!, encoding: String.Encoding.nonLossyASCII.rawValue)
        if let str = decodedStr{
            return str as String
        }
        return self
    }
}
