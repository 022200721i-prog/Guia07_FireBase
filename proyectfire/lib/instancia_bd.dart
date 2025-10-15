import 'package:cloud_firestore/cloud_firestore.dart';

// Se crea una instancia de Cloud Firestore.
FirebaseFirestore db = FirebaseFirestore.instance;

// --- LEER DATOS ---
// Función para obtener todos los usuarios de la colección 'usuarios'.
// Devuelve un Stream que se actualizará en tiempo real.
Stream<QuerySnapshot> obtenerUsuarios() {
  return db.collection('usuarios').snapshots();
}

// --- CREAR DATOS ---
// Función asíncrona para agregar un nuevo usuario.
Future<void> agregarUsuario(String dni, String nombre) async {
  // 'add' crea un documento con un ID generado automáticamente.
  await db.collection("usuarios").add({
    "dni": dni,
    "nombre": nombre,
  });
}

// --- ACTUALIZAR DATOS ---
// Función asíncrona para actualizar el nombre de un usuario existente.
Future<void> actualizarUsuario(String uid, String nuevoNombre) async {
  // 'doc(uid)' apunta al documento específico y 'update' modifica sus campos.
  await db.collection("usuarios").doc(uid).update({"nombre": nuevoNombre});
}

// --- ELIMINAR DATOS ---
// Función asíncrona para eliminar un usuario.
Future<void> eliminarUsuario(String uid) async {
  // 'doc(uid)' apunta al documento específico y 'delete' lo elimina.
  await db.collection("usuarios").doc(uid).delete();
}







