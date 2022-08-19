//
//  ContentView.swift
//  Shared
//
//  Created by Nanosoft on 2022-08-16.
//

import SwiftUI
import FirebaseStorage

struct ContentView: View {
    
    @ObservedObject var DVmodel = DataViewModel()
    @State var name = ""
    @State var notes = ""
    
    
    @State private var selectedImg: UIImage? = UIImage(named: "photo")
    @State private var shouldPresentImagePicker = false
    @State private var shouldPresentActionScheet = false
    @State private var shouldPresentCamera = false
    @State  private var imageURL: String? = nil
    var i = 0;
    
    var body: some View {
        
        
//        List(DVmodel.dataList) { item in
//
//            Text(item.name)
//
//        }
        
        VStack{
            
            ScrollView(.vertical,showsIndicators: false){
                
            VStack{
                
                ForEach(DVmodel.dataList){ data in

                    getRowNameView(name: data.name,item : data)

                }
            
            }
            }
            
                    Image(uiImage: self.selectedImg!)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.white, lineWidth: 4))
                                .shadow(radius: 10)
                                .onTapGesture { self.shouldPresentActionScheet = true }
                                .sheet(isPresented: $shouldPresentImagePicker) {
                                    SUImagePickerView(sourceType: self.shouldPresentCamera ? .camera : .photoLibrary, image: self.$selectedImg, isPresented: self.$shouldPresentImagePicker)
                            }.actionSheet(isPresented: $shouldPresentActionScheet) { () -> ActionSheet in
                                ActionSheet(title: Text("Choose mode"), message: Text("Please choose your preferred mode to set your profile image"), buttons: [ActionSheet.Button.default(Text("Camera"), action: {
                                    self.shouldPresentImagePicker = true
                                    self.shouldPresentCamera = true
                                }), ActionSheet.Button.default(Text("Photo Library"), action: {
                                    self.shouldPresentImagePicker = true
                                    self.shouldPresentCamera = false
                                }), ActionSheet.Button.cancel()])
                            }
            
            
            
            if imageURL != nil {
            AsyncImage(url: URL(string: imageURL!)) { image in
                        image.resizable()
                    } placeholder: {
                      //  Color.red
               // or use this
                        ProgressView()
                    }
                    .frame(width: 128, height: 128)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
            }
            
            if selectedImg != nil {
                Button {
                    uploadPhoto()
                } label: {
                    Text("Upload image")
                }
            
            }
            
            Divider()
            
            VStack(spacing: 10){
            TextField("Name", text: $name)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Notes", text: $notes)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            
                Button {
                    DVmodel.addData(name: name, notes: notes)
                } label: {
                    Text("Add todo item")
                }
            
        }
            
        }
      
    }
    
    
    private func getRowNameView(name: String,item : DataItemModel ) -> some View {
        
        VStack(spacing: 20) {
            
            HStack{
                
                
        Text(name)
        .foregroundColor(.white)
        .padding()
    //    .background(RoundedRectangle(cornerRadius: 5) .fill(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing)))
        .shadow(color: Color.white.opacity(0.1), radius: 2, x: -2, y: -2)
        .shadow(color: Color.black.opacity(0.2) , radius: 2, x: 2, y: 2)

                Spacer()
                Button {
                    DVmodel.updateData(todoToUpdate: item)
                } label: {

                    Image("editing").resizable().frame(width: 20, height: 20).padding(.trailing,10)
                }
                
                Button {
                    DVmodel.deleteData(todoToDelete: item)
                } label: {

                    Image("delete").resizable().frame(width: 20, height: 20).padding(.trailing,10)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 5) .fill(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing)))
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 5, trailing: 20))

    }
    
    func uploadPhoto(){
        
        // Make sure that the selected image property isn't nil
        guard selectedImg != nil else{
        return
        }
        // Create storage reference
        let storageRef = Storage.storage().reference()
        // Turn our image into data
        let imageData = selectedImg!.jpegData(compressionQuality: 0.8)
        guard imageData != nil else {
            return
            
        }
        // Specify the file path and name
        let fileRef = storageRef.child("images/\(UUID().uuidString).jpg")
        
        let uploadTask = fileRef.putData(imageData!, metadata: nil) { metadata, error in
        
            // Check for errors
            if error == nil && metadata != nil {
            // TODO: Save a reference to the file in Firestore DB
                

                
                fileRef.downloadURL(completion: { url, error in
                        guard let url = url, error == nil else {
                            return
                        }
                   imageURL = url.absoluteString
                    })
                
             
                
            }
        }
    }
    

    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()

    }
}
