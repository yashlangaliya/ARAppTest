//
//  ViewController.swift
//  ARApp
//
//  Created by yash-mac on 16/10/23.
//

import UIKit
import SceneKit
import ARKit
import AVKit
import ARVideoKit

class CameraViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, RecordARDelegate {
    @IBOutlet var sceneView: ARSCNView!
    var recorder:RecordAR?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard ARFaceTrackingConfiguration.isSupported else { fatalError() }
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.showsStatistics = false
        recorder = RecordAR(ARSceneKit: sceneView)
        recorder?.inputViewOrientations = [.portrait]
        recorder?.contentMode = .aspectFill
        recorder?.onlyRenderWhileRecording = true
        recorder?.deleteCacheWhenExported = false
        recorder?.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARFaceTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
        recorder?.prepare(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
        recorder?.rest()
    }
    
    @IBAction func toggleRecording(_ sender: UIButton) {
        sender.isSelected.toggle()
        if sender.isSelected {
            recorder?.record()
        } else {
            recorder?.stop({ videoPath in
                
                var newPath = videoPath
                var rv = URLResourceValues()
                
                rv.name = Date().string(format: "ddMMyyhhmmss") + ".mp4"
                rv.fileSecurity = .none
                try? newPath.setResourceValues(rv)
                newPath.deleteLastPathComponent()
                newPath = newPath.appendingPathComponent("\(Date().string(format: "ddMMyyhhmmss"))", conformingTo: .mpeg4Movie)
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "File saved", message: "add tag", preferredStyle: .alert)
                    alert.addTextField { (textField) in
                        textField.text = ""
                    }
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
                        if let tag = alert?.textFields?[0].text {
                            let video = VideoModel()
                            video.videoURLString = newPath.lastPathComponent
                            video.tag = tag
                            video.duration = newPath.getVideoDuration()
                            VideoDB().saveVideo(video)
                        }
                    }))
                    
                    self.present(alert, animated: true, completion: nil)
                }
                
            })
        }
    }
    
    
    @IBAction func userTapedSeene(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        let results = sceneView.hitTest(location, options: nil)
        if let result = results.first,
           let node = result.node as? MustacheNode {
            node.next()
        }
        
        
    }
}

extension CameraViewController {
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let device = sceneView.device else {
            return nil
        }
        guard let faceAnchor = anchor as? ARFaceAnchor else { return nil }
        let faceGeometry = ARSCNFaceGeometry(device: device)
        let faceNode = SCNNode(geometry: faceGeometry)
        faceNode.geometry?.firstMaterial?.fillMode = .lines
        faceNode.geometry?.firstMaterial?.transparency = 0
        
        let mNode = MustacheNode(with: [#imageLiteral(resourceName: "mustache_1"), #imageLiteral(resourceName: "mustache_3"), #imageLiteral(resourceName: "mustache_2.png")]);
        mNode.name = "mustache"
        faceNode.addChildNode(mNode)
        updateFeatures(for: mNode, using: faceAnchor)
        return faceNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        guard let faceGeometry = node.geometry as? ARSCNFaceGeometry else { return }
        updateFeatures(for: node, using: faceAnchor)
        faceGeometry.update(from: faceAnchor.geometry)
    }
    
    func updateFeatures(for node: SCNNode, using anchor: ARFaceAnchor) {
      let child = node.childNode(withName: "mustache", recursively: false) as? MustacheNode
      let vertices = [anchor.geometry.vertices[0]]
      child?.updatePosition(for: vertices)
    }
    
    func recorder(willEnterBackground status: ARVideoKit.RecordARStatus) {
        if recorder?.status == .recording {
            recorder?.stop()
        }
    }
    func recorder(didEndRecording path: URL, with noError: Bool) {
        
    }
    
    func recorder(didFailRecording error: Error?, and status: String) {
        
    }

    
}
