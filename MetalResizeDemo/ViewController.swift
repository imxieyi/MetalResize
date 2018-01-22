//
//  ViewController.swift
//  MetalResizeDemo
//
//  Created by 谢宜 on 2018/1/22.
//  Copyright © 2018年 谢宜. All rights reserved.
//

import UIKit
import MetalResize

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var inView: UIImageView!
    @IBOutlet weak var outView: UIImageView!
    @IBOutlet weak var status: UILabel!
    @IBOutlet weak var pickBtn: UIButton!
    @IBOutlet weak var processBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    
    var inImage: UIImage!
    var outImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    let pickController = UIImagePickerController()
    
    @IBAction func pick(_ sender: Any) {
        pickController.delegate = self
        pickController.sourceType = .photoLibrary
        present(pickController, animated: true, completion: nil)
    }
    
    func work(_ type: InterpolationType) {
        // Reference: https://stackoverflow.com/questions/24755558/measure-elapsed-time-in-swift
        let start = DispatchTime.now()
        let background = DispatchQueue(label: "background")
        status.text = "Resizing..."
        pickBtn.isEnabled = false
        processBtn.isEnabled = false
        saveBtn.isEnabled = false
        background.async {
            do {
                let mr = try MetalResize()
                self.outImage = mr.resize(self.inImage, 2.0, type)
                let end = DispatchTime.now()
                let nanotime = end.uptimeNanoseconds - start.uptimeNanoseconds
                let timeInterval = Double(nanotime) / 1_000_000_000
                DispatchQueue.main.async {
                    self.status.text = "Time elapsed: \(timeInterval)"
                    self.outView.image = self.outImage
                    self.pickBtn.isEnabled = true
                    self.processBtn.isEnabled = true
                    self.saveBtn.isEnabled = true
                }
            } catch let error {
                DispatchQueue.main.async {
                    self.status.text = error.localizedDescription
                    self.outView.image = nil
                    self.pickBtn.isEnabled = true
                    self.processBtn.isEnabled = true
                    self.saveBtn.isEnabled = true
                }
            }
        }
    }
    
    @IBAction func process(_ sender: Any) {
        guard inImage != nil else {
            return
        }
        let actionsheet = UIAlertController(title: "Interpolation method", message: nil, preferredStyle: .actionSheet)
        actionsheet.addAction(UIAlertAction(title: "Nearest-neighbor", style: .default, handler: { _ in
            self.work(.nearest)
        }))
        actionsheet.addAction(UIAlertAction(title: "Bilinear", style: .default, handler: { _ in
            self.work(.bilinear)
        }))
        actionsheet.addAction(UIAlertAction(title: "Bicubic", style: .default, handler: { _ in
            self.work(.bicubic)
        }))
        actionsheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionsheet.popoverPresentationController?.sourceView = processBtn
        actionsheet.popoverPresentationController?.sourceRect = processBtn.bounds
        present(actionsheet, animated: true, completion: nil)
    }
    
    @IBAction func save(_ sender: Any) {
        guard let image = outView.image else {
            let alert = UIAlertController(title: "Error", message: "You should process the image first!", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Close", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        inImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        inView.image = inImage
        pickController.dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

