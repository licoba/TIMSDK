//
//  JoinCallViewManager.swift
//  Pods
//
//  Created by vincepzhang on 2025/3/3.
//

import UIKit
import RTCRoomEngine
import ImSDK_Plus
import TUICore
import RTCCommon

class JoinCallViewManager: NSObject, V2TIMGroupListener, JoinCallViewDelegate {
    static let shared = JoinCallViewManager()
    
    private let callStatusObserver = Observer()
    private var joinGroupCallView = JoinCallView()
    private var roomId = TUIRoomId()
    private var groupId: String = ""
    private var callId: String = ""
    private var callMediaType: TUICallMediaType = .unknown
    private var recordExpansionStatus: Bool = false
    
    private override init() {
        super.init()
        V2TIMManager.sharedInstance().addGroupListener(listener: self)
        registerCallStatusObserver()
    }
    
    deinit {
        CallManager.shared.userState.selfUser.callStatus.removeObserver(callStatusObserver)
    }
    
    func getGroupAttributes(_ groupID: String) {
        groupId = groupID
        recordExpansionStatus = false
        guard CallManager.shared.userState.selfUser.callStatus.value == .none else {
            return
        }
        V2TIMManager.sharedInstance().getGroupAttributes(groupID, keys: nil) { [weak self] groupAttributeList in
            guard let self = self, let attributeList = groupAttributeList as? [String : String] else {
                return
            }
            self.processGroupAttributeData(attributeList)
        } fail: { code, message in
        }
    }
    
    func setJoinGroupCallView(_ view: JoinCallView) {
        joinGroupCallView = view
        joinGroupCallView.delegate = self
        joinGroupCallView.isHidden = true
    }
    
    func registerCallStatusObserver() {
        CallManager.shared.userState.selfUser.callStatus.addObserver(callStatusObserver, closure: { [weak self] newValue, _ in
            guard let self = self else { return }
            if newValue == .none && !self.groupId.isEmpty && self.groupId.count > 0 {
                self.getGroupAttributes(self.groupId)
            }
        })
    }
    
    // MARK: - Private Method
    private func processGroupAttributeData(_ groupAttributeList: [String: String]) {
        guard let jsonStr = groupAttributeList["inner_attr_kit_info"], jsonStr.count > 0,
              let jsonData = jsonStr.data(using: .utf8),
              let groupAttributeDic = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any],
              checkBusinessType(groupAttributeDic) else {
            hiddenJoinGroupCallView()
            return
        }
        
        handleRoomId(groupAttributeDic)
        handleCallMediaType(groupAttributeDic)
        handleCallId(groupAttributeDic)
        
        guard let userIdList = getUserIdList(groupAttributeDic), userIdList.count > 0 else {
            hiddenJoinGroupCallView()
            return
        }
        
        if userIdList.contains(CallManager.shared.userState.selfUser.id.value) {
            hiddenJoinGroupCallView()
            return
        }
        
        handleUsersInfo(userIdList)
    }
    
    private func checkBusinessType(_ groupAttributeValue: [String: Any]) -> Bool {
        guard let businessType = groupAttributeValue["business_type"] as? String else {
            return false
        }
        return businessType == "callkit"
    }
    
    private func handleRoomId(_ groupAttributeValue: [String: Any]) {
        guard let strRoomId = groupAttributeValue["room_id"] as? String, strRoomId.count > 0 else {
            return
        }
        
        if groupAttributeValue["room_id_type"] as? Int == 2 {
            roomId.strRoomId = strRoomId
            return
        }
        
        if let intRoomId = UInt32(strRoomId) {
            roomId.intRoomId = intRoomId
        } else {
            roomId.strRoomId = strRoomId
        }
    }
    
    private func handleCallMediaType(_ groupAttributeValue: [String: Any]) {
        guard let callMediaType = groupAttributeValue["call_media_type"] as? String, callMediaType.count > 0 else {
            return
        }
        
        if callMediaType == "audio" {
            self.callMediaType = TUICallMediaType.audio
        } else if callMediaType == "video" {
            self.callMediaType = TUICallMediaType.video
        }
    }
    
    private func handleCallId(_ groupAttributeValue: [String: Any]) {
        guard let callId = groupAttributeValue["call_id"] as? String else {
            return
        }
        self.callId = callId
    }
    
    private func getUserIdList(_ groupAttributeValue: [String: Any]) -> [String]? {
        guard let userInfoList = groupAttributeValue["user_list"] as? [[String: Any]] else {
            return nil
        }
        
        var userIdList = [String]()
        for userInfoDic in userInfoList {
            guard let userId = userInfoDic["userid"] as? String else {
                break
            }
            userIdList.append(userId)
        }
        
        return userIdList
    }
    
    private func handleUsersInfo(_ userIdList: [String]) {
        V2TIMManager.sharedInstance().getUsersInfo(userIdList) { [weak self] infoList in
            guard let self = self, let userInfoList = infoList else { return }
            
            var userModelList: [User] = Array()
            
            for userInfo in userInfoList {
                let userModel = User()
                userModel.id.value = userInfo.userID ?? ""
                userModel.avatar.value = userInfo.faceURL ?? ""
                userModelList.append(userModel)
            }
            
            if userModelList.count > 1 {
                self.showJoinGroupCallView()
                self.joinGroupCallView.updateView(with: userModelList, callMediaType:self.callMediaType)
            } else {
                self.hiddenJoinGroupCallView()
            }
        } fail: { code, message in
        }
    }
    
    private func showJoinGroupCallView() {
        joinGroupCallView.isHidden = false
        updatePageContent()
        postUpdateNotification()
    }
    
    func hiddenJoinGroupCallView() {
        joinGroupCallView.isHidden = true
        if let parentView = joinGroupCallView.superview {
            parentView.frame = CGRect(x: 0, y: 0, width: parentView.bounds.size.width, height: 0)
            postUpdateNotification()
        }
    }
    
    func updatePageContent() {
        DispatchQueue.main.async {
            let joinGroupCallViewHeight = self.recordExpansionStatus ? kJoinGroupCallViewExpandHeight : kJoinGroupCallViewDefaultHeight
            self.joinGroupCallView.frame = CGRect(x: self.joinGroupCallView.frame.origin.x,
                                                  y: self.joinGroupCallView.frame.origin.y,
                                                  width: self.joinGroupCallView.bounds.size.width,
                                                  height: joinGroupCallViewHeight)
            if let parentView = self.joinGroupCallView.superview {
                parentView.frame = CGRect(x: 0,
                                          y: 0,
                                          width: parentView.bounds.size.width,
                                          height: self.joinGroupCallView.bounds.size.height)
            }
        }
    }
    
    func postUpdateNotification() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(TUICore_TUIChatExtension_ChatViewTopArea_ChangedNotification), object: nil)
        }
    }
    
    // MARK: - TUICallKitJoinGroupCallViewDelegate
    func updatePageContent(isExpand: Bool) {
        if recordExpansionStatus != isExpand {
            recordExpansionStatus = isExpand
        }
        updatePageContent()
        postUpdateNotification()
    }
    
    func joinCall() {
        hiddenJoinGroupCallView()
        
        if CallManager.shared.globalState.enableForceUseV2API {
            TUICallKit.createInstance().joinInGroupCall(roomId: roomId, groupId: groupId, callMediaType: callMediaType)
            return
        }
        
        guard !callId.isEmpty else { return }
        TUICallKit.createInstance().join(callId: callId)
    }
    
    // MARK: - V2TIMGroupListener
    func onGroupAttributeChanged(_ groupID: String!, attributes: NSMutableDictionary!) {
        guard let attributes = attributes as? [String: String],
              groupId == groupID else {
            return
        }
        
        if CallManager.shared.userState.selfUser.callStatus.value != .none {
            self.hiddenJoinGroupCallView()
            return
        }
        processGroupAttributeData(attributes)
    }
}
