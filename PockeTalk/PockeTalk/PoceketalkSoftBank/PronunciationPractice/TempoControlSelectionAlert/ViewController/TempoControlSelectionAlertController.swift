//
//  TempoControlSelectionAlertController.swift
//  PockeTalk
//

import UIKit

protocol TempoControlSelectionDelegate {
    func onStandardSelection()
    func onSlowSelection()
    func onVerySlowSelection()
}

class TempoControlSelectionAlertController: BaseViewController {
    static var nib: UINib =  UINib.init(nibName: KAlertTempoControlSelectionAlert, bundle: nil)
    
    @IBOutlet weak var viewRoot: UIView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var viewContainerStandard: UIView!
    @IBOutlet weak var labelStandard: UILabel!
    @IBOutlet weak var ivStandard: UIImageView!
    @IBOutlet weak var viewContainerSlow: UIView!
    @IBOutlet weak var labelSlow: UILabel!
    @IBOutlet weak var ivSlow: UIImageView!
    @IBOutlet weak var viewContainerVerySlow: UIView!
    @IBOutlet weak var labelVerySlow: UILabel!
    @IBOutlet weak var ivVerySlow: UIImageView!
    var delegate: TempoControlSelectionDelegate?
    var talkButtonImageView: UIImageView!
    let window = UIApplication.shared.keyWindow!
    var flagTalkButton = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        talkButtonImageView = window.viewWithTag(109) as! UIImageView
        flagTalkButton = talkButtonImageView.isHidden
        if(!flagTalkButton){
            talkButtonImageView.isHidden = true
            HomeViewController.dummyTalkBtnImgView.isHidden = false
        }
    }
    
    deinit {
        if(!flagTalkButton){
            talkButtonImageView.isHidden = false
            HomeViewController.dummyTalkBtnImgView.isHidden = true
        }
    }
    func setUpUI(){
        self.view.backgroundColor = UIColor._blackColor().withAlphaComponent(0.5)
        self.viewRoot.layer.cornerRadius = 20
        self.viewRoot.layer.masksToBounds = true
        
        labelTitle.text = "Playback Speed".localiz()
        labelStandard.text = "Standard".localiz()
        labelSlow.text = "Slowly".localiz()
        labelVerySlow.text = "Very Slowly".localiz()
        
        let tapForStandard = UITapGestureRecognizer(target: self, action: #selector(self.actionSelectStandard(sender:)))
        viewContainerStandard.isUserInteractionEnabled = true
        viewContainerStandard.addGestureRecognizer(tapForStandard)
        
        let tapForSlow = UITapGestureRecognizer(target: self, action: #selector(self.actionSelectSlow(sender:)))
        viewContainerSlow.isUserInteractionEnabled = true
        viewContainerSlow.addGestureRecognizer(tapForSlow)
        
        let tapForVerySlow = UITapGestureRecognizer(target: self, action: #selector(self.actionSelectVerySlow(sender:)))
        viewContainerVerySlow.isUserInteractionEnabled = true
        viewContainerVerySlow.addGestureRecognizer(tapForVerySlow)
        
        let selectedValue = UserDefaultsProperty<String>(kTempoControlSpeed).value
        if selectedValue == TempoControlSpeedType.verySlow.rawValue{
            self.selectVerySlow()
        }else if(selectedValue == TempoControlSpeedType.slow.rawValue){
            self.selectSlow()
        }else {
            self.selectStandard()
        }
        
    }
    
    @objc func actionSelectStandard(sender:UITapGestureRecognizer) {
        print("actionSelectStandard")
        self.selectStandard()
        self.delegate?.onStandardSelection()
        self.dismiss(animated: true)
    }
    func selectStandard(){
        viewContainerSlow.backgroundColor = .white
        ivSlow.isHidden = true
        viewContainerVerySlow.backgroundColor = .white
        ivVerySlow.isHidden = true
        viewContainerStandard.backgroundColor = UIColor(hex: "#008FE8")
        ivStandard.isHidden = false
        UserDefaultsProperty<String>(kTempoControlSpeed).value = TempoControlSpeedType.standard.rawValue
    }
    @objc func actionSelectSlow(sender:UITapGestureRecognizer) {
        print("actionSelectSlow")
        self.selectSlow()
        self.delegate?.onSlowSelection()
        self.dismiss(animated: true)
    }
    func selectSlow(){
        viewContainerSlow.backgroundColor = UIColor(hex: "#008FE8")
        ivSlow.isHidden = false
        viewContainerVerySlow.backgroundColor = .white
        ivVerySlow.isHidden = true
        viewContainerStandard.backgroundColor = .white
        ivStandard.isHidden = true
        UserDefaultsProperty<String>(kTempoControlSpeed).value = TempoControlSpeedType.slow.rawValue
    }
    @objc func actionSelectVerySlow(sender:UITapGestureRecognizer) {
        print("actionSelectVerySlow")
        self.selectVerySlow()
        self.delegate?.onVerySlowSelection()
        self.dismiss(animated: true)
    }
    func selectVerySlow(){
        viewContainerSlow.backgroundColor = .white
        ivSlow.isHidden = true
        viewContainerVerySlow.backgroundColor = UIColor(hex: "#008FE8")
        ivVerySlow.isHidden = false
        viewContainerStandard.backgroundColor = .white
        ivStandard.isHidden = true
        UserDefaultsProperty<String>(kTempoControlSpeed).value = TempoControlSpeedType.verySlow.rawValue
    }
}
