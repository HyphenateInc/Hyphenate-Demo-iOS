//
//  EMChatViewController.swift
//  Hyphenate-Demo-Swift
//
//  Created by dujiepeng on 2017/6/16.
//  Copyright © 2017 dujiepeng. All rights reserved.
//

import UIKit
import Hyphenate
import MBProgressHUD
import MobileCoreServices
import Photos
import AssetsLibrary
import MediaPlayer

class EMChatViewController: UIViewController, EMChatToolBarDelegate, EMChatManagerDelegate, EMChatroomManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, EMLocationViewDelegate, EMChatBaseCellDelegate, UIActionSheetDelegate{
    
    
    @IBOutlet weak var tableView: UITableView!
    
    private var _chatToolBar: EMChatToolBar?
    private var _imagePickController: UIImagePickerController?
    private var _dataSource: Array<EMMessageModel>?
    private var _refresh: UIRefreshControl?
    private var _backButton: UIButton?
    private var _camButton: UIButton?
    private var _audioButton: UIButton?
    private var _detailButton: UIButton?
    private var _longPressIndexPath: IndexPath?
    
    private var _conversaiton: EMConversation?
    private var _pervAudioModel: EMMessageModel?
    
    public var _conversationId: String?
    
    init(_ conversationId: String, _ conversationType: EMConversationType) {
        super.init(nibName: nil, bundle: nil)
        _conversationId = conversationId
        _conversaiton = EMClient.shared().chatManager.getConversation(conversationId, type: conversationType, createIfNotExist: true)
        _conversaiton?.markAllMessages(asRead: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _setupInstanceUI()
        view.backgroundColor = UIColor.white
        edgesForExtendedLayout = UIRectEdge(rawValue: 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(endChat(withConversationIdNotification:)), name: NSNotification.Name(rawValue:KEM_END_CHAT), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deleteAllMessages(sender:)), name: NSNotification.Name(rawValue:KNOTIFICATIONNAME_DELETEALLMESSAGE), object: nil)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(keyboardHidden(tap:)))
        view.addGestureRecognizer(tap)
        
        tableView.tableFooterView = UIView()
        _refresh = refresh()
        tableView.addSubview(_refresh!)
        
        _chatToolBar!.delegate = self
        view.addSubview(_chatToolBar!)
        //        _chatToolBar?.setupInput(textInfo: "test")
        
        tableViewDidTriggerHeaderRefresh()
        
        EMClient.shared().chatManager.add(self, delegateQueue: nil)
        EMClient.shared().roomManager.add(self, delegateQueue: nil)
        
        _setupNavigationBar()
        _setupViewLayout()
        
//        NotificationCenter.default.addObserver(self, selector: #selector(remoteGroupNotification(noti:)), name: NSNotification.Name(rawValue:KEM_REMOVEGROUP_NOTIFICATION), object: nil) // oc demo in "viewDidAppear"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var unreadMessages = Array<EMMessage>()
        if _dataSource != nil {
            for model in _dataSource! {
                if _shouldSendHasReadAck(message: model.message!, false) {
                    unreadMessages.append(model.message!)
                }
            }
            
            if unreadMessages.count > 0 {
                _sendHasReadResponse(messages: unreadMessages, true)
            }
            
            _conversaiton?.markAllMessages(asRead: nil)
        }
    }
    
    private func _setupInstanceUI() {
        tableView.delegate = self
        tableView.dataSource = self
        _dataSource = Array<EMMessageModel>()
        _refresh = refresh()
        _chatToolBar = chatToolBar()
        _backButton = backButton()
        _camButton = camButton()
        _audioButton = audioButton()
        _detailButton = detailButton()
        _imagePickController = imagePickerController()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    deinit {
        print(" ----------------------------------------------- ChatViewController dealloc ---------------------------------------------------")
    }
    
    
    // MARK: - Private Layout Views
    private func _setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: _backButton!)
        if _conversaiton?.type == EMConversationTypeChat {
            navigationItem.rightBarButtonItems = [UIBarButtonItem.init(customView: _audioButton!), UIBarButtonItem.init(customView: _camButton!)]
            title = EMUserProfileManager.sharedInstance.getNickNameWithUsername(username: (_conversaiton?.conversationId!)!)
        } else if _conversaiton?.type == EMConversationTypeGroupChat {
            navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: _detailButton!)
            title = EMConversationModel.init(conversation: _conversaiton!).title()
        } else if _conversaiton?.type == EMConversationTypeChatRoom {
            navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: _detailButton!)
        }
    }
    
    private func _setupViewLayout() {
        tableView.width(width: kScreenWidth)
        tableView.height(height: kScreenHeight - (_chatToolBar?.height())! - 64)
        
        _chatToolBar?.width(width: kScreenWidth)
        _chatToolBar?.top(top: kScreenHeight - (_chatToolBar?.height())! - 64)
    }
    
    // MARK: - Getter
    func refresh() -> UIRefreshControl {
        let refresh = UIRefreshControl()
        refresh.tintColor = UIColor.lightGray
        refresh.addTarget(self, action: #selector(_loadMoreMessage), for: UIControlEvents.valueChanged)
        return refresh
    }
    
    func chatToolBar() -> EMChatToolBar {
        let toolBar = EMChatToolBar.instance()
        return toolBar
    }
    
    func backButton() -> UIButton {
        let btn = UIButton(type: UIButtonType.custom)
        btn.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        btn.imageView?.contentMode = UIViewContentMode.scaleAspectFit
        btn.addTarget(self, action: #selector(backAction), for: UIControlEvents.touchUpInside)
        btn.setImage(UIImage(named:"Icon_Back"), for: UIControlState.normal)
        return btn
    }
    
    func audioButton() -> UIButton {
        let btn = UIButton(type: UIButtonType.custom)
        btn.frame = CGRect(x: 0, y: 0, width: 25, height: 15)
        btn.setImage(UIImage(named:"iconCall"), for: UIControlState.normal)
        btn.addTarget(self, action: #selector(makeAudioCall), for: UIControlEvents.touchUpInside)
        return btn
    }
    
    func camButton() -> UIButton {
        let btn = UIButton(type: UIButtonType.custom)
        btn.frame = CGRect(x: 0, y: 0, width: 25, height: 15)
        btn.setImage(UIImage(named:"iconVideo"), for: UIControlState.normal)
        btn.addTarget(self, action: #selector(makeVideoCall), for: UIControlEvents.touchUpInside)
        return btn
    }
    
    func detailButton() -> UIButton {
        let btn = UIButton(type: UIButtonType.custom)
        btn.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        btn.setImage(UIImage(named:"icon_info"), for: UIControlState.normal)
        btn.addTarget(self, action: #selector(enterDetailView), for: UIControlEvents.touchUpInside)
        return btn
    }
    
    func imagePickerController() -> UIImagePickerController {
        let imgPickerC = UIImagePickerController()
        imgPickerC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        imgPickerC.allowsEditing = false
        imgPickerC.delegate = self
        
        return imgPickerC
    }
    
    // MARK: - Notification Method
    func remoteGroupNotification(noti: Notification) {
        navigationController?.popToViewController(self, animated: false)
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _dataSource?.count ?? 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = _dataSource![indexPath.row]
        let CellIdentifier = EMChatBaseCell.cellIdentifier(forMessageModel: model)
        var cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifier)
        if cell == nil {
            cell = EMChatBaseCell.chatBaseCell(withMessageModel: model)
            (cell as! EMChatBaseCell).delegate = self
        }
        
        (cell as! EMChatBaseCell).set(model: model)
        
        return cell!
    }
 
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let model = _dataSource![indexPath.row]
        return EMChatBaseCell.height(forMessageModel: model)
    }
    
    // MARK: - EMChatToolBarDelegate
    func chatToolBarDidChangeFrame(toHeight height: CGFloat) {
        weak var weakSelf = self
        UIView.animate(withDuration: 0.25) {
            weakSelf?.tableView.top(top: 0)
            weakSelf?.tableView.height(height: weakSelf!.view.height() - height)
        }
        
        _scrollViewToBottom(animated: false)
    }
    func didSendText(text:String) {
        let message = EMSDKHelper.createTextMessage(text, to:_conversaiton!.conversationId, _messageType(), nil)
        _sendMessage(message: message)
    }
    
    func didSendAudio(recordPath: String, duration:Int) {
        let message = EMSDKHelper.createVoiceMessage(recordPath, "audio.amr", duration, to: _conversaiton!.conversationId, _messageType(), nil)
        _sendMessage(message: message)
    }
    
    func didTakePhotos() {
        _chatToolBar?.endEditing(true)
        _imagePickController?.sourceType = UIImagePickerControllerSourceType.camera
        _imagePickController?.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
        present(_imagePickController!, animated: true, completion: nil)
    }
    
    func didSelectPhotos() {
        _chatToolBar?.endEditing(true)
        _imagePickController?.sourceType = UIImagePickerControllerSourceType.savedPhotosAlbum
        present(_imagePickController!, animated: true, completion: nil)
    }
    
    func didSelectLocation() {
        _chatToolBar?.endEditing(true)
        let locationViewController = EMLocationViewController.init(nibName: "EMLocationViewController", bundle: nil)
        locationViewController.delegate = self
        navigationController?.pushViewController(locationViewController, animated: true)
    }
    
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        weak var weakSelf = self
        let compressData:(UIImagePickerController, Dictionary<String, Any>) -> (EMMessage, UIImagePickerController) = { (imagePicker, selectInfo) -> (EMMessage, UIImagePickerController) in
            let type = selectInfo[UIImagePickerControllerMediaType] as! String
            if type == kUTTypeMovie as String {
                let videoURL = selectInfo[UIImagePickerControllerMediaURL] as! URL
                let mp4 = weakSelf?._convert2Mp4(movURL: videoURL)
                let fm = FileManager.default
                if fm.fileExists(atPath: videoURL.path) {
                    do { try fm.removeItem(at: videoURL)} catch {}
                }
                
                let message = EMSDKHelper.createVideoMessage((mp4?.path)!, "video.mp4", 0, to: (weakSelf?._conversaiton!.conversationId)!, (weakSelf?._messageType())!, nil)
                return (message, imagePicker)
            } else {
                let orgImage = selectInfo[UIImagePickerControllerOriginalImage] as! UIImage
                let message = EMSDKHelper.createImageMessage(orgImage, "image.jpg", to: (weakSelf?._conversaiton!.conversationId)!, (weakSelf?._messageType())!, nil)
                return (message, imagePicker)
            }
        }
        
        MBProgressHUD.showAdded(to: picker.view, animated: true)
        DispatchQueue.global().async {
            let (message, imagePicker) = compressData(picker, info)
            DispatchQueue.main.async {
                weakSelf?._sendMessage(message: message)
                imagePicker.dismiss(animated: true, completion: nil)
                MBProgressHUD.hide(for: imagePicker.view, animated: true)
            }
        }
    }
    
    // MARK: - EMLocationViewDelegate
    func sendLocation(_ latitude: Double, _ longitude: Double, _ address: String) {
        let message = EMSDKHelper.createLocationMessage(latitude, longitude, address, to: _conversaiton!.conversationId, _messageType(), nil)
        _sendMessage(message: message)
    }
    
    func didUpdateInputTextInfo(inputInfo: String) {
        
    }
    
    // MARK: - Actions
    func tableViewDidTriggerHeaderRefresh() {
        weak var weakSelf = self
        DispatchQueue.global().async {
            weakSelf?._conversaiton?.loadMessagesStart(fromId: nil, count: 20, searchDirection: EMMessageSearchDirectionUp, completion: { (messages, aError) in
                if aError == nil {
                    weakSelf?._dataSource!.removeAll()
                    for msg in messages! {
                        weakSelf?._addMessageToDatasource(message: msg as! EMMessage)
                    }
                    
                    weakSelf?.refresh().endRefreshing()
                    weakSelf?.tableView.reloadData()
                    weakSelf?._scrollViewToBottom(animated: false)
                }
            })
        }
    }
    
    func makeVideoCall() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:KNOTIFICATION_CALL), object: ["chatter":_conversaiton?.conversationId! as Any,"type":NSNumber.init(value: 1)])
    }
    
    func makeAudioCall() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:KNOTIFICATION_CALL), object: ["chatter":_conversaiton?.conversationId! as Any,"type":NSNumber.init(value: 0)])
    }
    
    func enterDetailView() {
        // TODO info
    }
    
    func backAction() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue:KNOTIFICATION_UPDATEUNREADCOUNT), object: nil);
        if _conversaiton!.type == EMConversationTypeChatRoom {
            showHub(inView: UIApplication.shared.keyWindow!, "Leaving the chatroom...")
            weak var weakSelf = self
            EMClient.shared().roomManager.leaveChatroom(_conversaiton?.conversationId, completion: { (error) in
                weakSelf?.hideHub()
                if error != nil {
                    // TODO
                }
                weakSelf?.navigationController?.popToViewController(weakSelf!, animated: true)
                weakSelf?.navigationController?.popViewController(animated: true)
            })
        }else {
            self.navigationController?.popToViewController(self, animated: true)
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func deleteAllMessages(sender: AnyObject) {
        if _dataSource!.count == 0 {
            return
        }
        
        if sender is Notification{
            let _sender = sender as! Notification
            let groupId = _sender.object as! String
            let isDelete = groupId == _conversaiton!.conversationId
            if _conversaiton?.type == EMConversationTypeChat && isDelete {
                _conversaiton!.deleteAllMessages(nil)
                _dataSource?.removeAll()
                tableView.reloadData()
            }
        }
    }
    
    func endChat(withConversationIdNotification notification: NSNotification) {
        let obj = notification.object
        if obj is String{
            let conversationId = obj as! String
            if conversationId.characters.count > 0 && conversationId == _conversaiton?.conversationId {
                backAction()
            }
        } else if obj is EMChatroom && _conversaiton?.type == EMConversationTypeChatRoom{
            let chatroom = obj as! EMChatroom
            if chatroom.chatroomId == _conversaiton?.conversationId {
                navigationController?.popToViewController(self, animated: true)
                navigationController?.popViewController(animated: true)
            }
        }
    }
    
    // MARK: - GestureRecognizer
    func keyboardHidden(tap: UITapGestureRecognizer) {
        if tap.state == UIGestureRecognizerState.ended {
            _chatToolBar?.endEditing(true)
        }
    }
    
    // MARK: - Private
    func _joinChatroom(chatroomId: String) {
        // TODO
        showHub(inView: view, "Joining the chatroom")
        weak var weakSelf = self
        EMClient.shared().roomManager.joinChatroom(chatroomId) { (chatroom, error) in
            weakSelf?.hideHub()
            if error != nil {
                if error?.code == EMErrorChatroomAlreadyJoined {
                    
                }
            }
        }
    }
    
    func _sendMessage(message: EMMessage) {
        _addMessageToDatasource(message: message)
        tableView.reloadData()
        weak var weakSelf = self
        DispatchQueue.global().async {
            EMClient.shared().chatManager.send(message, progress: nil) { (message, error) in
                DispatchQueue.main.async {
                    weakSelf?.tableView.reloadData()
                    weakSelf?._scrollViewToBottom(animated: true)
                }
            }
        }
    }
    
    func _addMessageToDatasource(message: EMMessage) {
        let model = EMMessageModel.init(withMesage: message)
        _dataSource?.append(model)
    }
    
    func _scrollViewToBottom(animated: Bool) {
        if tableView.contentSize.height > tableView.height() {
            let point = CGPoint(x: 0, y: tableView.contentSize.height - tableView.height())
            tableView.setContentOffset(point, animated: true)
        }
    }
    
    func _loadMoreMessage() {
        weak var weakSelf = self
        DispatchQueue.global().async {
            var messageId = ""
            if (weakSelf?._dataSource?.count)! > 0 {
                let model = weakSelf?._dataSource?[0]
                messageId = model!.message!.messageId
            }
            
            weakSelf?._conversaiton?.loadMessagesStart(fromId: messageId.characters.count > 0 ? messageId : nil, count: 20, searchDirection: EMMessageSearchDirectionUp, completion: { (messages, error) in
                if error == nil {
                    for message in messages as! Array<EMMessage> {
                        let model = EMMessageModel.init(withMesage: message)
                        self._dataSource?.insert(model, at: 0)
                    }
                }
                weakSelf?._refresh?.endRefreshing()
                weakSelf?.tableView.reloadData()
                
            })
        }
    }
    
    // TODO there is somethine woring.
    func _convert2Mp4(movURL: URL) -> URL {
        var mp4Url: URL? = nil
        let avAsset = AVURLAsset.init(url: movURL)
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: avAsset)
        if compatiblePresets.contains(AVAssetExportPresetHighestQuality) {
            let exportSession = AVAssetExportSession.init(asset: avAsset, presetName: AVAssetExportPresetHighestQuality)
            let dataPath = NSHomeDirectory() + "/Library/appdata/chatbuffer"
            let fm = FileManager.default
            if !fm.fileExists(atPath: dataPath) {
                do{ try fm.createDirectory(atPath: dataPath, withIntermediateDirectories: true, attributes: nil) } catch {}
            }
            
            let mp4Path = dataPath + "/" + "\(Date.timeIntervalBetween1970AndReferenceDate)" + "\(arc4random() % 100000)" + ".mp4"
            mp4Url = URL.init(fileURLWithPath: mp4Path)
            exportSession?.outputURL = mp4Url
            exportSession?.shouldOptimizeForNetworkUse = true
            exportSession?.outputFileType = AVFileTypeMPEG4
            
            let semaphore = DispatchSemaphore(value: 0)
            
            exportSession?.exportAsynchronously(completionHandler: {
                if exportSession?.status != AVAssetExportSessionStatus.completed {
                    print("something error")
                }
                semaphore.signal()
            })
            _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        }
        
        return mp4Url!
    }
    
    func _sendHasReadResponse(messages: Array<EMMessage>, _ isRead: Bool) {
        var unreadMessage = Array<EMMessage>()
        for message in messages {
            let isSend = _shouldSendHasReadAck(message: message, isRead)
            if isSend {
                unreadMessage.append(message)
            }
        }
        
        if unreadMessage.count > 0 {
            for message in unreadMessage {
                EMClient.shared().chatManager .sendMessageReadAck(message, completion: nil)
            }
        }
    }
    
    func _shouldSendHasReadAck(message: EMMessage,_ isRead: Bool) -> Bool {
        let account = EMClient.shared().currentUsername
        if message.chatType != EMChatTypeChat || message.isReadAcked || account == message.from || UIApplication.shared.applicationState == UIApplicationState.background {
            return false
        }
        
        let body = message.body
        switch body!.type {
        case EMMessageBodyTypeVideo, EMMessageBodyTypeVoice, EMMessageBodyTypeImage:
            if !isRead {
                return false
            }else {
                return true
            }
        default:
            return true
        }
    }
    
    func _shouldMarkMessageAsRead() -> Bool{
        var isMark = true
        if UIApplication.shared.applicationState == UIApplicationState.background {
            isMark = false
        }
        return isMark
    }
    
    func _messageType() -> EMChatType {
        var type = EMChatTypeChat
        switch _conversaiton!.type {
        case EMConversationTypeChat:
            type = EMChatTypeChat
            break
        case EMConversationTypeGroupChat:
            type = EMChatTypeGroupChat
            break
        case EMConversationTypeChatRoom:
            type = EMChatTypeChatRoom
            break
        default: break
        }
        
        return type
    }
    
    // MARK: - EMChatManagerDelegate
    
    func messagesDidReceive(_ aMessages: [Any]!) {
        for var message in aMessages {
            message = message as! EMMessage
            if _conversaiton?.conversationId == (message as AnyObject).conversationId {
                _addMessageToDatasource(message: message as! EMMessage)
                _sendHasReadResponse(messages: [message as! EMMessage], false)
                if _shouldMarkMessageAsRead() {
                    _conversaiton!.markMessageAsRead(withId: (message as AnyObject).messageId, error: nil)
                }
            }
        }
        
        tableView.reloadData()
        _scrollViewToBottom(animated: true)
    }
    
    func messageAttachmentStatusDidChange(_ aMessage: EMMessage!, error aError: EMError!) {
        if _conversaiton?.conversationId == aMessage.conversationId {
            tableView.reloadData()
        }
    }
    
    func messagesDidRead(_ aMessages: [Any]!) {
        for var message in aMessages {
            message = message as! EMMessage
            if _conversaiton?.conversationId == (message as AnyObject).conversationId {
                tableView.reloadData()
                break
            }
        }
    }
    
    // MARK: - EMChatManagerChatroomDelegate
    func userDidJoin(_ aChatroom: EMChatroom!, user aUsername: String!) {
        show(aUsername + " join chatroom " + aChatroom.chatroomId)
    }
    
    func userDidLeave(_ aChatroom: EMChatroom!, user aUsername: String!) {
        show(aUsername + " leave chatroom " + aChatroom.chatroomId)
    }
    
    func didDismiss(from aChatroom: EMChatroom!, reason aReason: EMChatroomBeKickedReason) {
        if _conversaiton?.conversationId == aChatroom.chatroomId {
            show("be removed from chatroom " + aChatroom.chatroomId)
            navigationController?.popToViewController(self, animated: false)
            navigationController?.popViewController(animated: true)
        }
    }
    
    // MARK: - EMChatBaseCellDelegate
    func didHeadImagePressed(model: EMMessageModel) {
        
    }
    
    func didTextCellPressed(model: EMMessageModel) {
        
    }
    
    func didImageCellPressed(model: EMMessageModel) {
        if _shouldSendHasReadAck(message: model.message!, true) {
            _sendHasReadResponse(messages: [model.message!], true)
        }
        
        let body = model.message!.body as! EMImageMessageBody
        if model.message?.direction == EMMessageDirectionSend && body.localPath != nil {
            let image = UIImage.init(contentsOfFile: body.localPath)
            readManager.showBrower([image!])
        }else {
            readManager.showBrower([URL(string: body.remotePath)!])
        }
        
    }
    
    func didAudioCellPressed(model: EMMessageModel) {
        let body = model.message?.body as! EMVoiceMessageBody
        let downloadStatus = body.downloadStatus
        if downloadStatus == EMDownloadStatusDownloading { return }
        else if (downloadStatus == EMDownloadStatusFailed) {
            EMClient.shared().chatManager .downloadMessageAttachment(model.message, progress: nil, completion: nil)
            return
        }
        
        if body.type == EMMessageBodyTypeVoice {
            if _shouldSendHasReadAck(message: model.message!, true) {
                _sendHasReadResponse(messages: [model.message!], true)
            }
            
            var isPerpare = true
            if _pervAudioModel == nil {
                _pervAudioModel = model
                model.isPlaying = true
            } else if _pervAudioModel == model {
                model.isPlaying = false
                _pervAudioModel = nil
                isPerpare = false
            }else {
                _pervAudioModel?.isPlaying = false
                model.isPlaying = true
            }
            
            tableView.reloadData()
            if isPerpare {
                _pervAudioModel = model
                weak var weakSelf = self
                EMCDDeviceManager.sharedInstance().enableProximitySensor()
                EMCDDeviceManager.sharedInstance().asyncPlaying(withPath: body.localPath, completion: { (error) in
                    weakSelf?.tableView.reloadData()
                    EMCDDeviceManager.sharedInstance().disableProximitySensor()
                    model.isPlaying = false
                })
            } else {
                EMCDDeviceManager.sharedInstance().disableProximitySensor()
            }
        }
    }
    
    func didVideoCellPressed(model: EMMessageModel) {
        let body = model.message?.body as! EMVideoMessageBody
        if body.downloadStatus == EMDownloadStatusSuccessed {
            if _shouldSendHasReadAck(message: model.message!, true) {
                _sendHasReadResponse(messages: [model.message!], true)
            }
            let videoUrl = URL.init(fileURLWithPath: body.localPath)
            let movePlayController = MPMoviePlayerViewController.init(contentURL: videoUrl)
            movePlayController?.moviePlayer.movieSourceType = MPMovieSourceType.file
            present(movePlayController!, animated: true, completion: nil)
        }else {
            EMClient.shared().chatManager.downloadMessageAttachment(model.message!, progress: nil, completion: nil)
        }
    }
    
    func didLocationCellPressed(model: EMMessageModel) {
        let body = model.message?.body as! EMLocationMessageBody
        let locationController = EMLocationViewController.init(location: CLLocationCoordinate2DMake(body.latitude, body.longitude))
        navigationController?.pushViewController(locationController, animated: true)
    }
    
    func didCellLongPressed(cell: EMChatBaseCell) {
        let index = tableView.indexPath(for: cell)
        let model = _dataSource![index!.row]
        if model.message?.body.type == EMMessageBodyTypeText {
            let sheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Copy", "Delete")
            sheet.tag = 1000
            sheet.show(in: view)
            _longPressIndexPath = index
        }else {
            let sheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Delete")
            sheet.tag = 1001
            sheet.show(in: view)
            _longPressIndexPath = index
        }
    }
    
    func didResendButtonPressed(model: EMMessageModel) {
        weak var weakSelf = self
        tableView.reloadData()
        EMClient.shared().chatManager .resend(model.message, progress: nil) { (message, error) in
            weakSelf?.tableView.reloadData()
        }
    }
    
    // MARK: - UIActionSheetDelegate
    func actionSheet(_ actionSheet: UIActionSheet, clickedButtonAt buttonIndex: Int) {
        if buttonIndex == 0 {
            _longPressIndexPath = nil
            return
        }
        if _longPressIndexPath != nil {
            let model = _dataSource![_longPressIndexPath!.row]
            if actionSheet.tag == 1000 {
                if buttonIndex == 1 {
                    let pasteboard = UIPasteboard()
                    if model.message!.body.type == EMMessageBodyTypeText {
                        let body = model.message!.body as! EMTextMessageBody
                        pasteboard.string = body.text
                    }
                } else if buttonIndex == 2 {
                    _conversaiton?.deleteMessage(withId: model.message?.messageId!, error: nil)
                    _dataSource?.remove(at: _longPressIndexPath!.row)
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [_longPressIndexPath!], with: UITableViewRowAnimation.fade)
                    tableView.endUpdates()
                }
            }else if actionSheet.tag == 1001 {
                _conversaiton?.deleteMessage(withId: model.message?.messageId!, error: nil)
                _dataSource?.remove(at: _longPressIndexPath!.row)
                tableView.beginUpdates()
                tableView.deleteRows(at: [_longPressIndexPath!], with: UITableViewRowAnimation.fade)
                tableView.endUpdates()
            }
        }
    }
    
    func actionSheetCancel(_ actionSheet: UIActionSheet) {
        _longPressIndexPath = nil
    }
}
