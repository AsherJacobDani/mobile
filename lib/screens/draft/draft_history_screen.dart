import 'package:flutter/material.dart';

import '../../models/draft.dart';
import '../../services/draft_service.dart';
import 'draft_detail_screen.dart';

class DraftHistoryScreen extends StatefulWidget {
  const DraftHistoryScreen({super.key});

  @override
  State<DraftHistoryScreen> createState() =>
      _DraftHistoryScreenState();
}

class _DraftHistoryScreenState
    extends State<DraftHistoryScreen> {
  List<Draft> drafts = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadDrafts();
  }

  Future<void> loadDrafts() async {
    setState(() {
      loading = true;
    });

    try {
      drafts = await DraftService().getDrafts();
    } catch (e) {
      debugPrint(e.toString());
    }

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  Future<bool> confirmDelete() async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Delete Draft"),
            content: const Text(
              "Are you sure you want to delete this draft?",
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(context, false),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pop(context, true),
                child: const Text("Delete"),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> deleteDraft(
    int index,
    Draft draft,
  ) async {
    await DraftService().deleteDraft(
      draft.id,
    );

    if (!mounted) return;

    setState(() {
      drafts.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          "Draft deleted successfully",
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Saved Drafts"),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : drafts.isEmpty
              ? const Center(
                  child: Text(
                    "No Drafts Found",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadDrafts,
                  child: ListView.builder(
                    itemCount: drafts.length,
                    itemBuilder: (context, index) {
                      final draft = drafts[index];

                      return Dismissible(
                        key: Key(
                          draft.id.toString(),
                        ),
                        direction:
                            DismissDirection.endToStart,
                        confirmDismiss:
                            (_) => confirmDelete(),
                        onDismissed: (_) async {
                          await deleteDraft(
                            index,
                            draft,
                          );
                        },
                        background: Container(
                          color: Colors.red,
                          alignment:
                              Alignment.centerRight,
                          padding:
                              const EdgeInsets.only(
                            right: 25,
                          ),
                          child: const Icon(
                            Icons.delete,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                        child: Card(
                          margin:
                              const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          elevation: 3,
                          child: ListTile(
                            leading: draft.imagePaths.isEmpty
                                ? const Icon(
                                    Icons.image,
                                    size: 55,
                                  )
                                : ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(
                                      8,
                                    ),
                                    child: Image.network(
                                      draft.imagePaths.first,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,

                                      loadingBuilder: (
                                        context,
                                        child,
                                        loadingProgress,
                                      ) {
                                        if (loadingProgress ==
                                            null) {
                                          return child;
                                        }

                                        return const SizedBox(
                                          width: 70,
                                          height: 70,
                                          child: Center(
                                            child:
                                                CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      },

                                      errorBuilder: (
                                        context,
                                        error,
                                        stackTrace,
                                      ) {
                                        return Container(
                                          width: 70,
                                          height: 70,
                                          color: Colors.grey.shade300,
                                          child: const Icon(
                                            Icons.broken_image,
                                            size: 40,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    draft.category,
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Chip(
                                  backgroundColor:
                                      draft.status ==
                                              "Published"
                                          ? Colors.green
                                              .shade100
                                          : Colors.orange
                                              .shade100,
                                  label: Text(
                                    draft.status,
                                    style: TextStyle(
                                      color: draft.status ==
                                              "Published"
                                          ? Colors.green
                                          : Colors.orange,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  draft.caption,
                                  maxLines: 2,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  draft.hashtags.join(
                                    " ",
                                  ),
                                  maxLines: 1,
                                  overflow:
                                      TextOverflow
                                          .ellipsis,
                                  style:
                                      const TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                            ),
                            onTap: () async {
                              final updated =
                                  await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      DraftDetailScreen(
                                    draft: draft,
                                  ),
                                ),
                              );

                              if (updated == true) {
                                loadDrafts();
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}