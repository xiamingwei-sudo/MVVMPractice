//
//  MWRHRequestManager.swift
//  first
//
//  Created by 夏明伟 on 2020/11/27.
//

import Foundation
import RHSocketKit


public typealias sucessHandler = (_ reponse: Any?) -> Void
public typealias failHandler = (_ error: Error?) -> Void

enum MWCmdType {
    case BindSearch(content:String = "BIND_SEARCH")
    case CheckPasswdParam(content:String = "CHECK_PASSWD_PARAM")
    case Other(content:String)
}

open class MWRHRequestManager: NSObject {
    
    @objc public static func sendWihtoutHost(
        param: Data?,
        sucess: sucessHandler? = nil,
        fail: failHandler? = nil) {
        
        MWRHRequestManager.send(host: "192.168.1.1", param: param, sucess: sucess, fail: fail)
    }

    @objc public static func send(
        host: String,
        port: Int32 = Int32(17999),
        param: Data?,
        timeInterval: Double = Double(20),
        sucess: sucessHandler? = nil,
        fail: failHandler? = nil) {
        
        guard let safeParam = param  else {
            log.error("发送数据为空")
            return
        }
        
        let request = MWRHRequestManager()

        // 开始连接网关
        request.start(host: host, port: port, param: safeParam, timeInterval: timeInterval, sucess: sucess, fail: fail)
    }
    
}

extension MWRHRequestManager {
    fileprivate func start(
        host: String,
        port: Int32,
        param: Data?,
        timeInterval: Double,
        sucess: sucessHandler? = nil,
        fail: failHandler? = nil) {
        MWRHSocketClient.shared.startConnet(host: host, port: port) {
            (aCallReply:RHSocketCallReplyProtocol?, reponst:RHDownstreamPacket?) in
            
            self.sendData(data: param, timeInterval: timeInterval, sucess: sucess,fail: fail)
        } fail: {(aCallReply:RHSocketCallReplyProtocol?, error:Error?) in
//            log.info("引用计数：\(CFGetRetainCount(self))")
            fail?(error)
        }
    }
    
    fileprivate func sendData(
        data: Data!,
        timeInterval: Double,
        sucess: sucessHandler? = nil,
        fail: failHandler? = nil) {
        MWRHSocketClient.shared.sendMessage(paramData: data, timeInterval: timeInterval) {
            (bCallReply:RHSocketCallReplyProtocol?, bReponse:RHDownstreamPacket?) in
            let reponseData = MWRHSocketClient.localDataToString(reponse: bReponse?.object)
            log.info(reponseData)
            sucess?(reponseData)
        } fail: {
            (bCallReply:RHSocketCallReplyProtocol?, error:Error?) in
            fail?(error)
        }
    }
}


extension MWRHRequestManager {
    static func localDataEx(cmdType: MWCmdType?, mac:String = "", token: String = "", dataDic: Any? = nil) -> Data?{
        
        guard let type = cmdType else {
            log.error("cmdType,不能为空")
            return nil
        }
        
        var paramDic = ["Version":"1.0", "RPCMethod":"Post1", "PluginName":"Plugin_ID"]
        paramDic["SequenceId"] = "0x00000001"
        paramDic["ID"] = "123"
        if token.count > 0 {
            paramDic["Token"] = token
        }
        if mac.count > 0 {
            paramDic["Identify"] = mac
        }
        
        var jsonStr = ""
        switch type {
        case .BindSearch(let content), .CheckPasswdParam(let content):
            paramDic["CmdType"] = content
            jsonStr = MWRHSocketClient.dictionnaryObjectToString(paramDic: paramDic)
            break
        case .Other (let content):
            paramDic["CmdType"] = content
            if var safeDataDic = dataDic as? Dictionary<String, Any> {
                safeDataDic["SequenceId"] = "0x00000001"
                jsonStr = MWRHSocketClient.dictionnaryObjectToString(paramDic: safeDataDic)
            }
            break
        }
        
        let jsonData  = jsonStr.data(using: .utf8)
        let encodeStr = jsonData?.base64EncodedString(options: Data.Base64EncodingOptions(rawValue: 0))
        paramDic["Parameter"] = encodeStr
        let dataStr = MWRHSocketClient.dictionnaryObjectToString(paramDic: paramDic)
        
        log.info(dataStr)
        return dataStr.data(using: .utf8)
        
    }
}
