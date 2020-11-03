//
//  PreviewController.swift
//  GIFfit
//
//  Created by kishore Kumar on 01/11/20.
//

import UIKit
import SwiftyGif

class PreviewController: UIViewController {

    private let imageView:UIImageView!
//    private var viewModel:GifCellViewModel

    override func loadView() {
        super.loadView()
        view = imageView
//        guard let url = viewModel.url else {
//            return
//        }
//        imageView = UIImageView(gifURL: url)
//        view.addSubview(imageView)
//        imageView?.bindFrameToSuperviewBounds()
//
//        // Set up our image view and display the gif
//        imageView?.clipsToBounds = true
//        imageView?.contentMode = .scaleAspectFit
//        imageView?.displaying = true

    }
    

    init(viewModel: GifCellViewModel) {
        guard let url = viewModel.url else {
            imageView = nil
            super.init(nibName: nil, bundle: nil)
            return
        }
        imageView = UIImageView(gifURL: url)

        super.init(nibName: nil, bundle: nil)

        // Set up our image view and display the gif
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.displaying = true
        imageView.backgroundColor = .systemBackground
        
//        imageView.setGifFromURL(url)
        // By setting the preferredContentSize to the image size,
        // the preview will have the same aspect ratio as the image
        preferredContentSize = viewModel.size ?? .zero
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//extension PreviewController : SwiftyGifDelegate {
//
//    func gifURLDidFinish(sender: UIImageView) {
//        print("gifURLDidFinish")
//        imageView?.startAnimatingGif()
//    }
//
//    func gifURLDidFail(sender: UIImageView) {
//        print("gifURLDidFail")
//    }
//
//    func gifDidStart(sender: UIImageView) {
//        print("gifDidStart")
//    }
//
//    func gifDidLoop(sender: UIImageView) {
//        print("gifDidLoop")
//    }
//
//    func gifDidStop(sender: UIImageView) {
//        print("gifDidStop")
//    }
//}

