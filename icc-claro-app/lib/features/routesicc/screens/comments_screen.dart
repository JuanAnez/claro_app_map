// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:icc_claro_app/core/utils/buttons/alert_button.dart';
import 'package:icc_claro_app/core/widgets/loading_progress.dart';
import 'package:icc_claro_app/features/authentication/users/user_provider.dart';
import 'package:icc_claro_app/features/routesicc/services/route_service.dart';
import 'package:provider/provider.dart';

class CommentsScreen extends StatefulWidget {
  final int routeId;
  final int location;

  const CommentsScreen({
    super.key,
    required this.routeId,
    required this.location,
  });

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;
  late BuildContext _scaffoldContext;

  Future<void> _submitComment() async {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) return;

    Navigator.of(context).pop();

    setState(() {
      _isLoading = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userName = userProvider.getUser()?.username ?? 'Invitado';

      await RouteService().insertRouteComment(
        context: context,
        comment: comment,
        location: widget.location,
        routeId: widget.routeId,
        userName: userName,
      );

      print(  'Comentario enviado: $comment');
      print(  'Ruta ID: ${widget.routeId}, Locación: ${widget.location}, Usuario: $userName');

      if (!mounted) return;

      _commentController.clear();

      ScaffoldMessenger.of(_scaffoldContext).showSnackBar(
        const SnackBar(content: Text('Comentario agregado con éxito')),
      );

      setState(() {});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(_scaffoldContext).showSnackBar(
        SnackBar(content: Text('Error al enviar comentario: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _editComment(int commentId, String originalComment) async {
    final TextEditingController _editController =
        TextEditingController(text: originalComment);

    await showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Center(
                  child: Text(
                    'Editar Comentario',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _editController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Comentario',
                    labelStyle: TextStyle(color: Colors.white),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    AlertButton(
                      text: 'Cancelar',
                      color: const Color(0xFFb60000),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    AlertButton(
                      text: 'Actualizar',
                      color: const Color(0xFF449D44),
                      onPressed: () async {
                        final newComment = _editController.text.trim();
                        if (newComment.isNotEmpty) {
                          final userProvider =
                              Provider.of<UserProvider>(context, listen: false);
                          final userName =
                              userProvider.getUser()?.username ?? 'Invitado';
                          await RouteService().updateRouteComment(
                            context: context,
                            commentId: commentId,
                            newComment: newComment,
                            userName: userName,
                          );
                          Navigator.of(context).pop();
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (BuildContext scaffoldContext) {
      _scaffoldContext = scaffoldContext;
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.blueGrey[900],
          title: Text(
            "Comentarios de Recorrido - ${widget.routeId}",
            style: const TextStyle(color: Colors.white),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: _isLoading
            ? const Center(child: LoadingProgress())
            : FutureBuilder<List<dynamic>>(
                future: RouteService()
                    .fetchComments(context: context, routeId: widget.routeId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: LoadingProgress());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final comments = snapshot.data ?? [];

                    if (comments.isEmpty) {
                      return const Center(
                        child: Text(
                          'No hay comentarios para mostrar',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: DataTable(
                          headingRowColor: WidgetStateProperty.resolveWith(
                            (states) => Colors.grey[800],
                          ),
                          dataRowColor: WidgetStateProperty.resolveWith(
                            (states) => Colors.black,
                          ),
                          headingTextStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          dataTextStyle: const TextStyle(color: Colors.white),
                          columns: const [
                            DataColumn(label: Text('Comentario')),
                            DataColumn(label: Text('Creado')),
                            DataColumn(label: Text('Creado Por')),
                          ],
                          rows: comments.map((comment) {
                            final comentario =
                                comment['routeComment'] ?? 'Sin comentario';
                            final fecha =
                                comment['creationDate'] ?? 'Sin fecha';
                            final creadoPor =
                                comment['createdBy'] ?? 'Desconocido';
                            final commentId =
                                comment['posLocRouteCommentId'] ?? 0;

                            return DataRow(
                              cells: [
                                DataCell(
                                  InkWell(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => Center(
                                          child: Material(
                                            color: Colors.transparent,
                                            child: Container(
                                              width: 300,
                                              padding: const EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.6),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text(
                                                    'Eliminar comentario',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    comentario,
                                                    style: const TextStyle(
                                                        color: Colors.white70),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 24),
                                                  const Text(
                                                    '¿Estás seguro de que deseas eliminar este comentario?',
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 24),
                                                  Wrap(
                                                    alignment:
                                                        WrapAlignment.center,
                                                    spacing: 8,
                                                    runSpacing: 8,
                                                    children: [
                                                      AlertButton(
                                                        text: 'Cancelar',
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        color: const Color(
                                                            0xFFb60000),
                                                      ),
                                                      AlertButton(
                                                          text: 'Editar',
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            _editComment(
                                                                commentId,
                                                                comentario);
                                                          },
                                                          color: const Color(
                                                              0xFFC47D1B)),
                                                      AlertButton(
                                                        text: 'Eliminar',
                                                        onPressed: () async {
                                                          setState(() {
                                                            _isLoading = true;
                                                          });

                                                          Navigator.of(context)
                                                              .pop();
                                                          try {
                                                            await RouteService()
                                                                .deleteComment(
                                                              context:
                                                                  _scaffoldContext,
                                                              commentId:
                                                                  commentId,
                                                            );

                                                            if (!mounted)
                                                              return;

                                                            ScaffoldMessenger.of(
                                                                    _scaffoldContext)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                  content: Text(
                                                                      'Comentario eliminado')),
                                                            );
                                                          } catch (e) {
                                                            if (!mounted)
                                                              return;
                                                            ScaffoldMessenger.of(
                                                                    _scaffoldContext)
                                                                .showSnackBar(
                                                              SnackBar(
                                                                  content: Text(
                                                                      'Error al eliminar: $e')),
                                                            );
                                                          } finally {
                                                            if (mounted) {
                                                              setState(() {
                                                                _isLoading =
                                                                    false;
                                                              });
                                                            }
                                                          }
                                                        },
                                                        color: const Color(
                                                            0xFF449D44),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                    child: Text(comentario),
                                  ),
                                ),
                                DataCell(Text(fecha)),
                                DataCell(Text(creadoPor)),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  }
                },
              ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Center(
                          child: Text(
                            'Agregar Comentario',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _commentController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Comentario',
                            labelStyle: TextStyle(color: Colors.white),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.red),
                            ),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            AlertButton(
                              text: 'Cancelar',
                              color: const Color(0xFFb60000),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                            AlertButton(
                              text: 'Enviar',
                              color: const Color(0xFF449D44),
                              onPressed: _submitComment,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          backgroundColor: const Color(0xFFb60000),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      );
    });
  }
}
