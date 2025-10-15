// --- Importaciones necesarias ---
import 'package:flutter/material.dart'; 
// Importa el paquete principal de Flutter, que contiene los widgets y componentes visuales básicos.

import 'package:firebase_core/firebase_core.dart'; 
// Permite inicializar y conectar la app con Firebase.

import 'firebase_options.dart'; 
// Archivo generado automáticamente por FlutterFire CLI. Contiene las configuraciones de Firebase específicas para cada plataforma (Android, iOS, Web).

import 'instancia_bd.dart'; 
// Archivo propio donde se encuentran las funciones de conexión y manipulación de datos en Firebase (obtenerUsuarios, agregarUsuario, actualizarUsuario, eliminarUsuario).

// --- Función principal de la aplicación ---
void main() async {
  // Asegura que los widgets de Flutter estén inicializados antes de realizar operaciones asíncronas (como iniciar Firebase).
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase en la aplicación con la configuración correspondiente a la plataforma actual.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Ejecuta la aplicación, iniciando con el widget principal MyApp.
  runApp(const MyApp());
}

// --- Clase principal de la aplicación ---
class MyApp extends StatelessWidget {
  const MyApp({super.key}); 
  // Constructor de la clase. Se usa const porque este widget no cambia.

  @override
  Widget build(BuildContext context) {
    // Método que construye la interfaz de usuario principal.
    return MaterialApp(
      title: 'CRUD Firebase', 
      // Título de la aplicación que puede aparecer en la barra superior o en el conmutador de tareas del dispositivo.

      theme: ThemeData(
        primarySwatch: Colors.deepPurple, 
        // Define el color principal del tema de la aplicación.
        useMaterial3: true, 
        // Usa el nuevo sistema de diseño Material 3.
      ),

      home: const HomePage(), 
      // Indica que la pantalla principal será la clase HomePage.
    );
  }
}

// --- Página principal de la aplicación ---
class HomePage extends StatefulWidget {
  const HomePage({super.key}); 
  // Constructor de la clase. StatefulWidget permite que el contenido cambie dinámicamente.

  @override
  State<HomePage> createState() => _HomePageState(); 
  // Crea el estado asociado a este widget.
}

// --- Clase que maneja el estado de HomePage ---
class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    // Construye la interfaz principal de la página.
    return Scaffold(
      // Estructura base visual con AppBar, cuerpo y botón flotante.
      appBar: AppBar(
        title: const Text('Usuarios con Firebase 🔥'), 
        // Título que aparece en la barra superior de la app.
        backgroundColor: Colors.deepPurple[100], 
        // Color de fondo del AppBar.
      ),

      // --- Cuerpo principal de la aplicación ---
      // Muestra los usuarios almacenados en Firebase en tiempo real.
      body: StreamBuilder(
        stream: obtenerUsuarios(), 
        // Escucha constantemente los cambios en la base de datos (colección de usuarios en Firebase).

        builder: (context, snapshot) {
          // snapshot contiene los datos obtenidos del stream.
          
          // Si el stream tiene datos (usuarios), los mostramos en una lista.
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data?.docs.length, 
              // Indica cuántos documentos (usuarios) hay en la colección.

              itemBuilder: (context, index) {
                // Construye cada elemento (usuario) de la lista.
                final userDoc = snapshot.data!.docs[index]; 
                // Obtiene el documento individual por su índice.

                final userId = userDoc.id; 
                // Guarda el ID del documento, necesario para editar o eliminar.

                final userData = userDoc.data() as Map<String, dynamic>; 
                // Convierte los datos del documento a un mapa para poder acceder a los campos.

                final userName = userData['nombre'] ?? 'Sin nombre'; 
                // Obtiene el nombre del usuario, o muestra “Sin nombre” si está vacío.

                final userDni = userData['dni'] ?? 'Sin DNI'; 
                // Obtiene el DNI del usuario, o “Sin DNI” si no existe.

                // --- Cada usuario se representa como un ListTile ---
                return ListTile(
                  title: Text(userName), 
                  // Muestra el nombre del usuario.
                  subtitle: Text('DNI: $userDni'), 
                  // Muestra el DNI debajo del nombre.

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min, 
                    // Ajusta el tamaño del Row al contenido (los íconos).

                    children: [
                      // --- Botón para editar usuario ---
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue), 
                        // Ícono azul con forma de lápiz.
                        onPressed: () => _mostrarDialogoEditar(context, userId, userName), 
                        // Al presionar, se abre un diálogo para editar el nombre del usuario.
                      ),

                      // --- Botón para eliminar usuario ---
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red), 
                        // Ícono rojo con forma de papelera.
                        onPressed: () => eliminarUsuario(userId), 
                        // Llama a la función que elimina el usuario de Firebase.
                      ),
                    ],
                  ),
                );
              },
            );
          }

          // Si los datos aún no llegan, se muestra un círculo de carga.
          return const Center(child: CircularProgressIndicator());
        },
      ),

      // --- Botón flotante para agregar nuevos usuarios ---
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoAgregar(context), 
        // Al presionar, abre el cuadro de diálogo para agregar un nuevo usuario.
        child: const Icon(Icons.add), 
        // Ícono de “+” en el botón flotante.
      ),
    );
  }

  // --- FUNCIÓN PARA MOSTRAR EL DIÁLOGO DE AGREGAR USUARIO ---
  void _mostrarDialogoAgregar(BuildContext context) {
    final TextEditingController dniController = TextEditingController();
    final TextEditingController nombreController = TextEditingController();
    // Controladores para obtener los valores ingresados por el usuario.

    showDialog(
      context: context, 
      // Muestra un cuadro de diálogo emergente sobre la pantalla.
      builder: (context) {
        return AlertDialog(
          title: const Text("Agregar Nuevo Usuario"), 
          // Título del cuadro de diálogo.

          content: Column(
            mainAxisSize: MainAxisSize.min, 
            // Ajusta la altura del cuadro de acuerdo al contenido.
            children: [
              TextField(
                controller: dniController, 
                // Campo para ingresar el DNI del usuario.
                decoration: const InputDecoration(labelText: "DNI"),
              ),
              TextField(
                controller: nombreController, 
                // Campo para ingresar el nombre del usuario.
                decoration: const InputDecoration(labelText: "Nombre"),
              ),
            ],
          ),

          actions: [
            // --- Botón Cancelar ---
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.of(context).pop(), 
              // Cierra el cuadro de diálogo sin hacer nada.
            ),

            // --- Botón Guardar ---
            ElevatedButton(
              child: const Text("Guardar"),
              onPressed: () {
                // Llama a la función que agrega el usuario a Firebase con los datos escritos.
                agregarUsuario(dniController.text, nombreController.text);
                Navigator.of(context).pop(); 
                // Cierra el cuadro de diálogo después de guardar.
              },
            ),
          ],
        );
      },
    );
  }

  // --- FUNCIÓN PARA MOSTRAR EL DIÁLOGO DE EDITAR USUARIO ---
  void _mostrarDialogoEditar(BuildContext context, String uid, String nombreActual) {
    final TextEditingController nombreController = TextEditingController(text: nombreActual);
    // Controlador con el nombre actual precargado para editarlo.

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar Nombre"), 
          // Título del cuadro de diálogo.
          content: TextField(
            controller: nombreController, 
            // Campo de texto con el nombre actual del usuario.
            decoration: const InputDecoration(labelText: "Nuevo Nombre"), 
            // Etiqueta del campo.
          ),

          actions: [
            // --- Botón Cancelar ---
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.of(context).pop(), 
              // Cierra el diálogo sin guardar cambios.
            ),

            // --- Botón Actualizar ---
            ElevatedButton(
              child: const Text("Actualizar"),
              onPressed: () {
                // Llama a la función que actualiza el usuario en Firebase.
                actualizarUsuario(uid, nombreController.text);
                Navigator.of(context).pop(); 
                // Cierra el cuadro de diálogo después de actualizar.
              },
            ),
          ],
        );
      },
    );
  }
}
