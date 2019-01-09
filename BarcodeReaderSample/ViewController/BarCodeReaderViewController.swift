//
//  BarCodeReaderViewController.swift
//  BarcodeReaderSample
//
//  Created by 南京兵 on 2019/01/09.
//  Copyright © 2019 kyohei.minami. All rights reserved.
//

import UIKit
import AVFoundation

class BarCodeReaderViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
  
  // カメラやマイクの入出力を管理するオブジェクトを生成
  private let session = AVCaptureSession()
  /// カメラ領域
  @IBOutlet weak var cameraView: UIView!

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // カメラやマイクのデバイスそのものを管理するオブジェクトを生成（ここではワイドアングルカメラ・ビデオ・背面カメラを指定）
    let discoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera],
                                                            mediaType: .video,
                                                            position: .back)
    
    // ワイドアングルカメラ・ビデオ・背面カメラに該当するデバイスを取得
    let devices = discoverySession.devices
    
    //　該当するデバイスのうち最初に取得したものを利用する
    if let backCamera = devices.first {
      do {
        // QRコードの読み取りに背面カメラの映像を利用するための設定
        let deviceInput = try AVCaptureDeviceInput(device: backCamera)
        if self.session.canAddInput(deviceInput) {
          self.session.addInput(deviceInput)
          
          // 背面カメラの映像からQRコードを検出するための設定
          let metadataOutput = AVCaptureMetadataOutput()
          if self.session.canAddOutput(metadataOutput) {
            self.session.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            // 読み取りたいバーコードの種類を指定
            // .ean13 は本の書籍などに使用されるバーコード
            // .qr はQRコード、などなど
            metadataOutput.metadataObjectTypes = [.ean13]
            
            // 読み取り可能エリアの設定を行う
            // 画面の横、縦に対して、左が10%、上が40%のところに、横幅80%、縦幅20%を読み取りエリアに設定
            let x: CGFloat = 0.1
            let y: CGFloat = 0.4
            let width: CGFloat = 0.8
            let height: CGFloat = 0.2
            metadataOutput.rectOfInterest = CGRect(x: y, y: 1 - x - width, width: height, height: width)
            
            // 背面カメラの映像を画面に表示するためのレイヤーを生成
            let previewLayer = AVCaptureVideoPreviewLayer(session: self.session)
            previewLayer.frame = cameraView.bounds
            previewLayer.videoGravity = .resizeAspectFill
            cameraView.layer.addSublayer(previewLayer)
            
            // 読み取り可能エリアに枠を追加する
            let detectionArea = UIView()
            detectionArea.frame = CGRect(x: view.frame.size.width * x, y: view.frame.size.height * y, width: view.frame.size.width * width, height: view.frame.size.height * height)
            detectionArea.layer.borderColor = UIColor.white.cgColor
            detectionArea.layer.borderWidth = 1
            cameraView.addSubview(detectionArea)

            // 読み取り開始
            self.session.startRunning()
          }
        }
      } catch {
        print("Error occured while creating video device input: \(error)")
      }
    }
  }
  
  /// サンプルボタン押下時処理
  @IBAction func sampleButtonTapped(_ sender: Any) {
    let alert = UIAlertController(title: "サンプル", message: "ボタンを押下しました", preferredStyle: .alert)
    // 表示して一定時間で閉じる
    present(alert, animated: true, completion: {
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
        alert.dismiss(animated: true, completion: nil)
      })
      
    })
  }
  
  func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
    for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
      // バーコードの内容が空かどうかの確認
      if metadata.stringValue == nil { continue }
      
      // 取得したデータの処理を行う
      let alert: UIAlertController = UIAlertController(title: "バーコードの中身", message: metadata.stringValue, preferredStyle: UIAlertController.Style.alert)
      let cancel: UIAlertAction = UIAlertAction(title: "キャンセル", style: UIAlertAction.Style.cancel, handler:nil)
      alert.addAction(cancel)
      present(alert, animated: true, completion: nil)
    }
  }
  
}
