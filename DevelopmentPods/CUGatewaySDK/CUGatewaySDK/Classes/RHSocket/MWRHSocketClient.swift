//
//  MWRHSocketClient.swift
//  first
//
//  Created by 夏明伟 on 2020/11/27.
//

import Foundation
import RHSocketKit
import SwiftyJSON

typealias sucessCallReply = (_ aCallReply:RHSocketCallReplyProtocol?, _ reponse:RHDownstreamPacket?) -> Void
typealias failCallReply = (_ aCallReply:RHSocketCallReplyProtocol?, _ error:Error?) -> Void

class MWRHSocketClient: NSObject {
    
    
    static let shared = MWRHSocketClient()
    
    private override init() {
        super.init()
    }
}

extension MWRHSocketClient{
    func startConnet(host: String, port: Int32, sucess:@escaping sucessCallReply, fail:@escaping failCallReply ) {
        let encoder = RHSocketVariableLengthEncoder()
        encoder.countOfLengthByte = 4
        
        let decoder = RHSocketVariableLengthDecoder()
        decoder.countOfLengthByte = 4
        
        RHSocketChannelProxy.sharedInstance()!.encoder = encoder
        RHSocketChannelProxy.sharedInstance()!.decoder = decoder
        
        let callReply = RHConnectCallReply()
        callReply.host = host
        callReply.port = port
        
        callReply.setSuccessBlock {(aCallReply:RHSocketCallReplyProtocol?, reponse:RHDownstreamPacket?) in
            log.debug("连接成功")
            sucess(aCallReply, reponse)
        }
        callReply.setFailureBlock {(aCallReply:RHSocketCallReplyProtocol?, error: Error?) in
            log.error(error?.localizedDescription)
            fail(aCallReply, error)
        }
        // 连接前先断开原有连接
        RHSocketChannelProxy.sharedInstance()?.disconnect()
        
        // 开始连接
        RHSocketChannelProxy.sharedInstance()?.asyncConnect(callReply)
    }
    
    func sendMessage(paramData: Data?, timeInterval: Double, sucess:@escaping sucessCallReply, fail:@escaping failCallReply) {
        let request = RHSocketPacketRequest.init()
        request.object = paramData!
        request.timeout = timeInterval
        
        let callReply = RHSocketCallReply()
        callReply.request = request
        log.debug("发送数据：\(String(describing: paramData))")
        callReply.setSuccessBlock {(aCallReply:RHSocketCallReplyProtocol?, reponse:RHDownstreamPacket?) in
            RHSocketChannelProxy.sharedInstance()?.disconnect()
            sucess(aCallReply, reponse)
        }
        callReply.setFailureBlock { (aCallReply:RHSocketCallReplyProtocol?, error:Error?) in
            log.error(error?.localizedDescription)
            fail(aCallReply, error)
        }
        
        RHSocketChannelProxy.sharedInstance()?.asyncCallReply(callReply)
    }
}

extension MWRHSocketClient {
    static func localDataToString(reponse: Any?) -> Any? {
         let rootDic = JSON(reponse ?? "").object
         guard var safeDic = rootDic as? Dictionary<String,Any> else {
             return nil
         }
         
         guard let result = safeDic["Result"] else {
             safeDic["Result"] = "1111"
            return safeDic
         }
         safeDic["Result"] = result
         let return_Parameter = safeDic["return_Parameter"]
         let paramData = Data(base64Encoded: return_Parameter as! String)
         let decodStr = String(data: paramData!, encoding: .utf8)?.replacingOccurrences(of: "(null)", with: "")
         let paramDic = JSON(decodStr ?? "").object
         safeDic["return_Parameter"] = paramDic
        return safeDic
     }
     
    static func dictionnaryObjectToString(paramDic: Dictionary<String, Any>) -> String {
         do {
             let data = try JSONSerialization.data(withJSONObject: paramDic, options: JSONSerialization.WritingOptions(rawValue: 0))
             var jsonString = String(data: data, encoding: .utf8)
             jsonString = jsonString?.replacingOccurrences(of: "\\/", with: "/")
             jsonString = jsonString?.replacingOccurrences(of: "(null)", with: "")
             return jsonString!
         } catch {
             log.error(error.localizedDescription)
             return ""
         }
     }
}

