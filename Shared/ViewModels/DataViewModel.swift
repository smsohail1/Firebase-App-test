//
//  DataViewModel.swift
//  Firebase App (iOS)
//
//  Created by Nanosoft on 2022-08-18.
//

import Foundation
import Firebase


class DataViewModel : ObservableObject{
    
//    @Published var dataList = ["item"]
    @Published var dataList = [DataItemModel]()
    
    
    init(){
        getDataList()
    }
    
    
    func updateData(todoToUpdate: DataItemModel){
    // Get a reference to the database
    let db = Firestore.firestore()
    // Set the data to update
        
        db.collection("todos").document(todoToUpdate.id).setData(["name": "updated \(todoToUpdate.name)"],merge:  true) { error in
            if error == nil{
                
                // No errors
                
                self.getDataList()
                
            }else{
                
            }
        }
        
    }
    
    func deleteData(todoToDelete: DataItemModel) {
    // Get a reference to the database
    let db = Firestore.firestore()
    // Specify the document to delete
        db.collection("todos").document(todoToDelete.id).delete { error in
        
            if error == nil{
                
                // No errors
                
                DispatchQueue.main.async {
                    self.dataList.removeAll { todo in
                        return todo.id == todoToDelete.id
                    }
                    
                }
            }else{
                
            }
        }
        
  
    }
    
    func addData(name: String, notes: String) {
    // Get a reference to the database
    let db = Firestore.firestore()
    // Add a document to a collection
        
        db.collection("todos").addDocument(data: ["name" : name,"notes":notes]) { error in
        
            
            if error == nil{
                
                // No errors
                
                self.getDataList()
                
            }else{
                
            }
            
        }
        
        
    
    }
    

    
    func getDataList(){
        
        //Get a reference to database
        let db = Firestore.firestore()
          
        //Read the document on specific path
        db.collection("todos").getDocuments { snapshot, error in
            
            if error == nil{
                
                // No errors
                
                if let snapshot = snapshot {
                    
                    DispatchQueue.main.async {
               
                        // Get all the documents and create Todos
                            self.dataList = snapshot.documents.map{ d in
                                return DataItemModel(id: d.documentID, name: d["name"] as?  String ?? "", notes: d["notes"] as?  String ?? "")
                                
                            }
                        
                    }
               
                    
                }
                
                
            }else{
                
            }
        }
    }

}
