//
// Copyright 2020-2021 Picovoice Inc.
//
// You may not use this file except in compliance with the license. A copy of the license is located in the "LICENSE"
// file accompanying this source.
//
// Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
// an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//

import Porcupine

@objc(PvPorcupine)
class PvPorcupine: NSObject {
    private var porcupinePool:Dictionary<String, Porcupine> = [:]

    @objc(fromBuiltInKeywords:modelPath:keywords:sensitivities:resolver:rejecter:)
    func fromBuiltInKeywords(accessKey: String, modelPath: String, keywords: [String], sensitivities: [Float32],
        resolver resolve:RCTPromiseResolveBlock, rejecter reject:RCTPromiseRejectBlock) -> Void {
        do {
            var keywordValues: [Porcupine.BuiltInKeyword] = []
            for keyword in keywords {
                if let builtIn = Porcupine.BuiltInKeyword(rawValue: keyword.capitalized) {
                    keywordValues.append(builtIn)
                } else {
                    let (code, message) = errorToCodeAndMessage(PorcupineInvalidArgumentError("'\(keyword.lowercased())' is not a built in keyword"))
                    reject(code, message, nil)
                    return
                }
            }
            
            let porcupine = try Porcupine(
                accessKey: accessKey,
                keywords: keywordValues,
                modelPath: modelPath.isEmpty ? nil : try getResourcePath(modelPath),
                sensitivities: sensitivities.isEmpty ? nil : sensitivities)
            
            let handle: String = String(describing: porcupine)
            porcupinePool[handle] = porcupine
            
            var param: [String: Any] = [:]
            param["handle"] = handle
            param["frameLength"] = Porcupine.frameLength
            param["sampleRate"] = Porcupine.sampleRate
            param["version"] = Porcupine.version
            
            resolve(param)
        } catch let error as PorcupineError {
            let (code, message) = errorToCodeAndMessage(error)
            reject(code, message, nil)
        } catch {
            let (code, message) = errorToCodeAndMessage(PorcupineError(error.localizedDescription))
            reject(code, message, nil)
        }
    }

    @objc(fromKeywordPaths:modelPath:keywordPaths:sensitivities:resolver:rejecter:)
    func fromKeywordPaths(accessKey: String, modelPath: String, keywordPaths: [String], sensitivities: [Float32],
        resolver resolve:RCTPromiseResolveBlock, rejecter reject:RCTPromiseRejectBlock) -> Void {
        var keywordPaths = keywordPaths
        
        do {
            for i in 0..<keywordPaths.count {
                keywordPaths[i] = try getResourcePath(keywordPaths[i])
            }
        } catch let error as PorcupineError {
            let (code, message) = errorToCodeAndMessage(error)
            reject(code, message, nil)
            return
        } catch {
            let (code, message) = errorToCodeAndMessage(PorcupineError(error.localizedDescription))
            reject(code, message, nil)
            return
        }
        
        do {
            let porcupine = try Porcupine(
                accessKey: accessKey,
                keywordPaths: keywordPaths,
                modelPath: modelPath.isEmpty ? nil : try getResourcePath(modelPath),
                sensitivities: sensitivities.isEmpty ? nil : sensitivities)
            
            let handle: String = String(describing: porcupine)
            porcupinePool[handle] = porcupine
            
            var param: [String: Any] = [:]
            param["handle"] = handle
            param["frameLength"] = Porcupine.frameLength
            param["sampleRate"] = Porcupine.sampleRate
            param["version"] = Porcupine.version
            
            resolve(param)
        } catch let error as PorcupineError {
            let (code, message) = errorToCodeAndMessage(error)
            reject(code, message, nil)
        } catch {
            let (code, message) = errorToCodeAndMessage(PorcupineError(error.localizedDescription))
            reject(code, message, nil)
        }
    }
    
    @objc(delete:)
    func delete(handle:String) -> Void {        
        if let porcupine = porcupinePool.removeValue(forKey: handle) {
            porcupine.delete()
        }
    }
    
    @objc(process:pcm:resolver:rejecter:)
    func process(handle:String, pcm:[Int16], 
        resolver resolve:RCTPromiseResolveBlock, rejecter reject:RCTPromiseRejectBlock) -> Void {
        do {
            if let porcupine = porcupinePool[handle] {
                let keywordIndex = try porcupine.process(pcm: pcm)
                resolve(keywordIndex)
            } else {
                let (code, message) = errorToCodeAndMessage(PorcupineRuntimeError("Invalid handle provided to Porcupine 'process'"))
                reject(code, message, nil)
            }
        } catch let error as PorcupineError {
            let (code, message) = errorToCodeAndMessage(error)
            reject(code, message, nil)
        } catch {
            let (code, message) = errorToCodeAndMessage(PorcupineError(error.localizedDescription))
            reject(code, message, nil)
        }
    }

    private func getResourcePath(_ filePath: String) throws -> String {
        if (!FileManager.default.fileExists(atPath: filePath)) {
            if let resourcePath = Bundle(for: type(of: self)).resourceURL?.appendingPathComponent(filePath).path {
                if (FileManager.default.fileExists(atPath: resourcePath)) {
                    return resourcePath
                }
            }
            
            throw PorcupineIOError("Could not find file at path '\(filePath)'. If this is a packaged asset, ensure you have added it to your xcode project.")
        }
        
        return filePath
    }
    
    private func errorToCodeAndMessage(_ error: PorcupineError) -> (String, String) {
        return (error.name.replacingOccurrences(of: "Error", with: "Exception"), error.localizedDescription)
    }
}
