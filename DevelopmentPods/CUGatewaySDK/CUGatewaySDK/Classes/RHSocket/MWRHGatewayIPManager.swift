//
//  MWRHGatewayIPManager.swift
//  CUGatewaySDK
//
//  Created by 夏明伟 on 2020/12/4.
//

import Foundation
import SwiftyJSON
public typealias BindSearchHandler = (_ sucess: Bool, _ ip: String? , _ response: Any? ) -> Void

class IpTrackReponseItem: NSObject {
    var ip: String
    var reponse: Any
    
    init(newIp: String, res: Any) {
        self.ip = newIp
        self.reponse = res
    }
    
}

open class MWRHGatewayIPManager: NSObject {
    
    @objc public static func findGateway(complete: BindSearchHandler? = nil) {
        PNUdpTraceroute.start("114.114.114.114", maxTtl: 6, completeIparr: { ipArr in
            guard let ipArr = ipArr as? [String] else {
                log.error("ipArr 是空的")
                complete?(false, nil, nil)
                return
            }
            log.info("原始ip数组：\(ipArr)")
            var ips = [String]()
            var sameIp = ""
            
            for ip in ipArr {
                if MWRHGatewayIPManager.isLocalIpAdress(ip: ip) {
                    if !sameIp.elementsEqual(ip) {
                        ips.append(ip)
                        sameIp = ip
                    }
                }
            }
            log.info("处理后的ip数组：\(ips)")
            // 开始探测
            MWRHGatewayIPManager.loopSearch(ipArr: ips ){ sucess, ip, response in
                complete?(true, ip, response)
            }
        })
    }
    
    
}
extension MWRHGatewayIPManager {
    @objc public static func isLocalIpAdress(ip: String) -> Bool {
        let pattern = "^(192).(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5]).(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5]).(\\d{1,2}|1\\d\\d|2[0-4]\\d|25[0-5])$"
        
        return isText(text: ip, pattern: pattern)
        
    }
    @objc public static func isText(text: String, pattern: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: text)
    }
}

extension MWRHGatewayIPManager {
    
    @objc public static func loopSearch(ipArr: Array<String>?, comeplete: BindSearchHandler? = nil) -> () {
        guard let ipArr = ipArr else {
            log.error("数组为空")
            comeplete?(false,nil,nil)
            return
        }
        let queue = DispatchQueue(label: "ipTrackHandler")
        let group = DispatchGroup()
        
        var sucessIps = [IpTrackReponseItem]()
        // weak var weakSelf =  self
        for ip in ipArr {
            queue.async(group: group) {
                let sema = DispatchSemaphore(value: 0)
                self.bindSearch(host: ip) { (sucess, host,response) in
                    if sucess {
                        let sucess = IpTrackReponseItem(newIp: host, res: response ?? "")
                        sucessIps.append(sucess)
                    }
                    sema.signal()
                }
                // 异步调用返回前，就会一直阻塞在这
                sema.wait()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            if sucessIps.count > 0 {
                // 在原数组中，找到下标最小的成`功ip，即：有多个成功ip的情况下，默认使用tranceRouter 跳数最小的网关
                var item = sucessIps[0]
                var min = ipArr.firstIndex(of: item.ip)!
                for index in 1..<sucessIps.count {
                    func searchMinIndex (ipItem: IpTrackReponseItem, ie: Int) -> (Int, IpTrackReponseItem) {
                        let i = ipArr.firstIndex(of: ipItem.ip)
                        var minX = ie
                        if let safeIndex = i {
                            minX = minX <= safeIndex ? minX: safeIndex
                        }
                        return (minX, ipItem)
                    }
                    // 返回在原IP数组(ipArr)中的index
                    let result = searchMinIndex(ipItem: sucessIps[index], ie: min)
                    min = result.0
                    item = result.1
                }
                let gwip = ipArr[min]
                log.info("执行结束,网关ip为：\(gwip), 返回数据为：\(item.reponse)")
                comeplete?(true, gwip, item.reponse)
            } else {
                log.info("执行结束,没有网关ip")
                comeplete?(false, nil, nil)
            }
        }
    }
    
    
    @objc public static func bindSearch(host: String, complete:@escaping (_ sucess:Bool, _ ip: String, _ response:Any? )->Void){
        // 获取探测数据
        let data = MWRHRequestManager.localDataEx(cmdType: MWCmdType.BindSearch())
        
        // 开始探测
        MWRHRequestManager.send(host: host, param: data) {(reponse) in
            log.info("成功ip:\(host)->\(reponse ?? "")")
            complete(true, host, reponse)
        } fail: {(error) in
            log.info("失败ip:\(host)->\(error?.localizedDescription ?? "")")
            complete(false, host, error)
        }
    }
}
