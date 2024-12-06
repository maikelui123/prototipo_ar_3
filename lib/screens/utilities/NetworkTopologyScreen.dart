import 'package:flutter/material.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';

// Definición del modelo Node
class Node {
  IconData icon;
  String label;
  bool inUse;

  Node({required this.icon, required this.label, this.inUse = false});
}

class NetworkTopologyScreen extends StatefulWidget {
  @override
  _NetworkTopologyScreenState createState() => _NetworkTopologyScreenState();
}

class _NetworkTopologyScreenState extends State<NetworkTopologyScreen> {
  List<DragAndDropList> networkLists = [];
  List<Node> availableNodes = [
    Node(icon: Icons.router, label: "Router"),
    Node(icon: Icons.computer, label: "PC"),
    Node(icon: Icons.dns, label: "Servidor"),
  ];

  @override
  void initState() {
    super.initState();
    _initializeNetworkLists();
  }

  void _initializeNetworkLists() {
    networkLists = [
      DragAndDropList(
        header: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Nodos disponibles",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        children: availableNodes.where((node) => !node.inUse).map(_createNodeItem).toList(),
      ),
      DragAndDropList(
        header: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Diseño de red",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        children: [],
      ),
    ];
  }

  DragAndDropItem _createNodeItem(Node node) {
    return DragAndDropItem(
      child: Card(
        color: node.inUse ? Colors.grey.shade300 : Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          leading: Icon(node.icon, size: 40, color: Colors.blue),
          title: Text(
            node.label,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: node.inUse ? Colors.grey : Colors.black,
            ),
          ),
          onTap: !node.inUse ? () => _editNode(node) : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Organización de Redes",
          style: TextStyle(
            color: Colors.lightBlue,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: Color(0xFF42F5EC),
      ),
      body: DragAndDropLists(
        children: networkLists,
        onItemReorder: _onReorderItem,
        onListReorder: _onReorderList,
        listPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        itemDecorationWhileDragging: BoxDecoration(
          color: Colors.blue.shade100,
          boxShadow: [
            BoxShadow(
              color: Colors.grey,
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  void _onReorderItem(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      if (oldListIndex == 0 && newListIndex == 1) {
        // Mover de "Nodos disponibles" a "Diseño de red"
        var originalNode = availableNodes[oldItemIndex];
        if (!originalNode.inUse) {
          // Marcar como en uso
          originalNode.inUse = true;
          // Crear una copia del nodo para agregarlo a "Diseño de red"
          var newNode = Node(icon: originalNode.icon, label: originalNode.label, inUse: true);
          networkLists[newListIndex].children.insert(newItemIndex, _createNodeItem(newNode));
        }
      } else if (oldListIndex == 1 && newListIndex == 0) {
        // Mover de "Diseño de red" a "Nodos disponibles"
        var movedItem = networkLists[oldListIndex].children.removeAt(oldItemIndex);
        var movedNode = _getNodeFromItem(movedItem);
        // Encontrar el nodo original en availableNodes y restablecer su estado
        var originalNode = availableNodes.firstWhere((node) => node.label == movedNode.label, orElse: () => Node(icon: Icons.device_unknown, label: "Unknown"));
        originalNode.inUse = false;
        // Reagregar a "Nodos disponibles"
        networkLists[newListIndex].children.insert(newItemIndex, _createNodeItem(originalNode));
      } else {
        // Reorganizar dentro de la misma lista
        var movedItem = networkLists[oldListIndex].children.removeAt(oldItemIndex);
        networkLists[newListIndex].children.insert(newItemIndex, movedItem);
      }
    });
  }

  void _onReorderList(int oldListIndex, int newListIndex) {
    setState(() {
      var movedList = networkLists.removeAt(oldListIndex);
      networkLists.insert(newListIndex, movedList);
    });
  }

  // Obtener el Node asociado a un DragAndDropItem
  Node _getNodeFromItem(DragAndDropItem item) {
    ListTile tile = (item.child as Card).child as ListTile;
    return availableNodes.firstWhere((node) => node.label == tile.title.toString().split("'")[1], orElse: () => Node(icon: Icons.device_unknown, label: "Unknown"));
  }

  void _editNode(Node node) {
    TextEditingController labelController = TextEditingController(text: node.label);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Editar Nodo"),
          content: TextField(
            controller: labelController,
            decoration: InputDecoration(labelText: "Nombre del Nodo"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  node.label = labelController.text;
                });
                Navigator.of(context).pop();
              },
              child: Text("Guardar"),
            ),
          ],
        );
      },
    );
  }
}
