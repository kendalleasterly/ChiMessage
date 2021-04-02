//
//  PhotoView.swift
//  ChiMessage
//
//  Created by Kendall Easterly on 11/13/20.
//

import SwiftUI

struct PhotoView: View {
    
    @ObservedObject var imagesModel = StorageModel()
    @State var ispresentingPickImage = false
    
    var body: some View {
        
        VStack {
        imagesModel.userImage
           
            Button {
                self.ispresentingPickImage = true
            } label: {
                Text("o h  w o w")
            }

        
        } .onAppear {
            
            imagesModel.getActivityImage()
            
        } .sheet(isPresented: $ispresentingPickImage) {
            ImagePicker(model: imagesModel)
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    
    var model: StorageModel
    @Environment (\.presentationMode) private var presentationMode

    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
 
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
 
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }
 
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
 
    }
    
    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
     
        var parent: ImagePicker
     
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
     
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
     
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                
                parent.model.uploadImage(image: image)
                
            } else {
                print("couldn't make uiimage")
            }
     
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
