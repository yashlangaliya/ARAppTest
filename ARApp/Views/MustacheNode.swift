//
//  MustacheNode.swift
//  ARApp
//
//  Created by yash-mac on 17/10/23.
//

import Foundation
import SceneKit

class MustacheNode: SCNNode {
    
    var options: [UIImage]
    var index = 0
    
    init(with options: [UIImage]) {
        self.options = options
        
        super.init()
        let size = getPlaneSizeFor(image: options.first!)
        let plane = SCNPlane(width: size.width, height: size.height)
        plane.firstMaterial?.diffuse.contents = options.first
        plane.firstMaterial?.isDoubleSided = true
        geometry = plane
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MustacheNode {
    
    func getPlaneSizeFor(image: UIImage) -> CGSize {
        let oldWidth = image.size.width;
        let scaleF = 0.1 / oldWidth
        return CGSize(width: image.size.width * scaleF, height: image.size.height * scaleF)
    }
    
    
    func updatePosition(for vectors: [vector_float3]) {
        let newPos = vectors.reduce(vector_float3(), +) / Float(vectors.count)
        position = SCNVector3(newPos)
    }
    
    func next() {
        index = (index + 1) % options.count
        if let plane = geometry as? SCNPlane {
            let size = getPlaneSizeFor(image: options[index])
            plane.width = size.width
            plane.height = size.height
            plane.firstMaterial?.diffuse.contents = options[index]
            plane.firstMaterial?.isDoubleSided = true
        }
    }
}
