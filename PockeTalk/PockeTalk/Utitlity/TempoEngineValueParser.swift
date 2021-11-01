//
//  TempoEngineValueParser
//  PockeTalk
//

import UIKit

public class TempoEngineValueParser{
    public static let shared: TempoEngineValueParser = TempoEngineValueParser()
    let fileName = "engine-tempo-value"
    let TAG = "\(TempoEngineValueParser.self)"
    var engineValues: [EngineValue]?


    private init() {
        self.getData()
    }
    
    func getData(){
        do {
            if let bundlePath = Bundle.main.path(forResource: fileName,
                                                     ofType: "json"),
            let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                let engineTempoValue = try JSONDecoder().decode(EngineTempoValue.self,
                                                                   from: jsonData)
                engineValues = engineTempoValue.engine_value
            }
            
        } catch {
            PrintUtility.printLog(tag: TAG, text: "\(error)")
        }
    }
    
    func getEngineTempoValue(engineName: String, type: TempoControlSpeedType) -> (String) {
        
        let engineValue = engineValues?.first{ $0.engine_name == engineName}
        var tempoRate = ""
        switch type {
            case .standard:
                tempoRate =  engineValue?.normal.tempo_rate ?? ""
                break
            case .slow:
                tempoRate =  engineValue?.slow.tempo_rate ?? ""
                break
            case .verySlow:
                tempoRate =  engineValue?.verySlow.tempo_rate ?? ""
                break
            default:
                tempoRate =  engineValue?.normal.tempo_rate ?? ""
                break
        }
        return tempoRate
    }
}
