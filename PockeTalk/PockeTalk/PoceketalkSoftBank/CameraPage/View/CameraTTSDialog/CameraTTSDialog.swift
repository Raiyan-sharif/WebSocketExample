//  CameraTTSDialog.swift
//  PockeTalk
//

import UIKit
import MarqueeLabel

protocol CameraTTSDialogProtocol: AnyObject {
    func cameraTTSDialogToPlaybutton()
    func cameraTTSDialogFromPlaybutton()
    func cameraTTSDialogShowContextMenu()
}

class CameraTTSDialog: UIView {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var placeHolderView: UIView!
    @IBOutlet weak var backgroundTextureImageView: UIImageView!

    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var fromLanguageLabel: UILabel!
    @IBOutlet weak var toLanguageLabel: UILabel!

    @IBOutlet weak var fromTranslateLabel: MarqueeLabel!
    @IBOutlet weak var toTranslateLabel: MarqueeLabel!

    weak var delegate: CameraTTSDialogProtocol?


    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        styleViewWithAttributes()
        setUpFontAttribute()
        setUpDataInput()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
        styleViewWithAttributes()
        setUpFontAttribute()
        setUpDataInput()
    }

       func commonInit() {
           Bundle.main.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
           containerView.translatesAutoresizingMaskIntoConstraints = false
           addSubview(containerView)
           NSLayoutConstraint.activate([
               self.topAnchor.constraint(equalTo: containerView.topAnchor),
               self.bottomAnchor.constraint(equalTo:containerView.bottomAnchor),
               self.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
               self.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
           ])
       }

    func styleViewWithAttributes() {

        //Set color
        self.containerView.backgroundColor = .black
        self.placeHolderView.backgroundColor = .clear
        self.toLanguageLabel.textColor = .black
        self.fromLanguageLabel.textColor = .lightGray
        self.toTranslateLabel.textColor = UIColor(red: 57, green: 142, blue: 224)
        self.fromTranslateLabel.textColor = UIColor(red: 57, green: 142, blue: 224)


        //set Corner Radius
        backgroundTextureImageView.layer.cornerRadius = DIALOG_CORNER_RADIUS
        backgroundTextureImageView.layer.masksToBounds = true
    }

    //Set UI font and Update if needed
    func setUpFontAttribute() {
        self.toLanguageLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        self.fromLanguageLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        self.toTranslateLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        self.fromTranslateLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
    }



    func setUpDataInput() {
        self.toLanguageLabel.text = "কমিশন চায় ডিভাইস থেকে চার্জার বিক্রয় বন্ধ করা হোক, এবং একটি সুরেলা চার্জিং পোর্টের প্রস্তাবও দেওয়া হোক।অ্যাপল, যার আইফোনগুলি তার লাইটনিং ক্যাবল থেকে চার্জ করা হয়েছে, বলেছে যে সংযোগকারীদের এক ধরণের মেনে চলতে বাধ্য করার নিয়মগুলি উদ্ভাবনকে বাধা দিতে পারে, ইলেকট্রনিক বর্জ্য এবং বিরক্তিকর ভোক্তাদের পাহাড় তৈরি করতে পারে।প্রতিদ্বন্দ্বী অ্যান্ড্রয়েড-ভিত্তিক ডিভাইসগুলি ইউএসবি-সি সংযোগকারী ব্যবহার করে চার্জ করা হয়। ২০১ Commission সালে মোবাইল ফোনের সাথে বিক্রিত অর্ধেক চার্জারের একটি ইউএসবি মাইক্রো-বি কানেক্টর ছিল, যখন ২%% এর একটি ইউএসবি-সি কানেক্টর এবং ২১% একটি লাইটনিং কানেক্টর ছিল।"
        self.toTranslateLabel.text = "Benagali (বাংলা) Benagali (বাংলা)"

        self.fromLanguageLabel.text = "The Commission wants the sale of chargers to be decoupled from devices, and also propose a harmonised charging port, the person said.Apple, whose iPhones are charged from its Lightning cable, has said rules forcing connectors to conform to one type could deter innovation, create a mountain of electronic waste and irk consumers.Rival Android-based devices are charged using USB-C connectors. Half the chargers sold with mobile phones in 2018 had a USB micro-B connector, while 29% had a USB-C connector and 21% a Lightning connector, according to a 2019 Commission study."
        self.fromTranslateLabel.text = "English US"
    }

    func dismissDialog() {
        self.removeFromSuperview()
    }

    @IBAction func didTapOnDismissButton(_ sender: UIButton) {
        dismissDialog()
    }


    @IBAction func didTapOnToPlayButton(_ sender: UIButton) {
        self.delegate?.cameraTTSDialogToPlaybutton()
    }

    @IBAction func didTapOnFromPlayButton(_ sender: UIButton) {
        self.delegate?.cameraTTSDialogFromPlaybutton()
    }

    @IBAction func didTapOnMenuButton(_ sender: UIButton) {
        self.delegate?.cameraTTSDialogShowContextMenu()
    }
}

