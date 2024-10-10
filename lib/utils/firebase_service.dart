import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get a specific collection
  CollectionReference getCollection(String collectionName) {
    return _firestore.collection(collectionName);
  }
  

  // Add a document to a collection
  Future<void> addDocument(String collectionName, Map<String, dynamic> data) {
    return _firestore.collection(collectionName).add(data);
  }

  // Update a document in a collection
  Future<void> updateDocument(String collectionName, String documentId, Map<String, dynamic> newData) {
    return _firestore.collection(collectionName).doc(documentId).update(newData);
  }

  // Delete a document from a collection
  Future<void> deleteDocument(String collectionName, String documentId) {
    return _firestore.collection(collectionName).doc(documentId).delete();
  }

  // Fetch all documents from a collection
  Future<QuerySnapshot> fetchAllDocuments(String collectionName) {
    return _firestore.collection(collectionName).get();
  }
}
