import 'package:flutter/material.dart';

import 'package:uikit_flutter/src/utils/colors.dart';
import 'package:uikit_flutter/widgets/flutter_search_bar.dart';
import 'package:uikit_flutter/widgets/loader/loader.dart';

class DropdownSectionTile<T> {
  final String name;
  List<DropdownRowTile<T>> rows;
  DropdownSectionTile({
    required this.name,
    required this.rows,
  });

  static Future<List<DropdownSectionTile<T>>> onlyItems<T>(
      List<DropdownRowTile<T>> items) async {
    return [DropdownSectionTile(name: "", rows: items)];
  }
}

class DropdownRowTile<T> {
  /// The value of the row tile item
  final T item;

  /// The label to show for each item of the dropdown. If `itemBuilder` is not _null_,
  /// it will be used instead
  final String Function(T item) labelBuilder;

  /// The widget to show for each item of the dropdown.
  /// If _null_, `labelBuilder` will be used instead
  final Widget Function(T item)? itemBuilder;

  /// The action to take when the user selects an item. If it's _null_, the dropdown
  /// is only in view-mode and items cannot be selected.
  final void Function(T item)? onSelectItem;

  /// If this method is not _null_, a "detail" icon is shown on the right side of
  /// each dropdown item tile, to eventually do something such as opening a modal detail.
  final void Function(T item)? onSelectItemOverview;

  /// If _true_ and multiselection is enabled, shows a flagged chackbox
  final bool isSelected;
  DropdownRowTile({
    required this.item,
    required this.labelBuilder,
    this.itemBuilder,
    this.onSelectItem,
    this.onSelectItemOverview,
    this.isSelected = false,
  });
}

/// A widget that behaves like a dropdown menu, allowing
/// only view-mode, single and multi-selection and much more.
class DropdownAdvanced<T> extends StatefulWidget {
  /// The label to show in the default dropdown box when the dropdown is closed.
  /// Defautls to "Seleziona".
  final String dropdownLabel;

  /// The list of items to show in the dropdown. It's a [Future], so that the dropdown
  /// itself is responsbile of waiting the result while loading data.
  final Future<List<DropdownSectionTile<T>>> Function() sections;

  /// If _true_, checkboxes are shown in the dropdown to allow multiselection.
  /// Note that the _onSelectItem_ callback is called every time the user flags a checkbox,
  /// so it's developer responsability to manage selected items lists (i.e. select/deselect items)
  final bool allowMultiselection;

  /// If not _null_, a searchbar is shown in the dropdown to filter items by text.
  /// It takes the original items list and the searchbar text to filter, and should return
  /// the filtered items list
  final List<DropdownRowTile<T>> Function(
      List<DropdownRowTile<T>> items, String text)? filter;

  /// If _false_, the dropdown does not open
  final bool enabled;

  /// By default, the [DropdownAdvanced] shows a custom widget to tap to open the dropdown.
  /// This widget can be overwritten by passing a custom `child`
  final Widget? child;

  /// Use this [ScrollController] i.e. to manage pagination for API call
  final ScrollController? scrollController;

  /// Creates a widget that behaves like a dropdown menu, allowing
  /// only view-mode, single and multi-selection and much more.
  const DropdownAdvanced({
    Key? key,
    required this.sections,
    this.dropdownLabel = "Seleziona",
    this.allowMultiselection = false,
    this.filter,
    this.enabled = true,
    this.child,
    this.scrollController,
  }) : super(key: key);

  @override
  State<DropdownAdvanced<T>> createState() => _DropdownAdvancedState<T>();
}

class _DropdownAdvancedState<T> extends State<DropdownAdvanced<T>> {
  final List<T> _selectedItems = [];
  String? selectedItemsLabel;

  String? _getSelectedItemsLabel(DropdownRowTile<T> row) {
    if (_selectedItems.isEmpty) {
      return null;
    }
    if (!widget.allowMultiselection) {
      return row.labelBuilder(row.item);
    }

    var label = "";
    for (var element in _selectedItems) {
      if (label.isEmpty) {
        label = row.labelBuilder(element);
      } else {
        label = "$label, ${row.labelBuilder(element)}";
      }
    }

    return label;
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !widget.enabled,
      child: Opacity(
        opacity: widget.enabled ? 1 : 0.5,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Material(
            // color: Theme.of(context).backgroundColor,
            child: PopupMenuButton(
              onCanceled: () {
                Future.delayed(const Duration(milliseconds: 10), () {
                  FocusManager.instance.primaryFocus?.unfocus();
                });
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              color: Theme.of(context).colorScheme.background,
              elevation: 20,
              enabled: widget.enabled,
              tooltip: widget.enabled ? widget.dropdownLabel : "",
              offset: const Offset(0, 40),
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: false,
                  padding: EdgeInsets.zero,
                  child: FutureBuilder(
                    future: widget.sections(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Loader();
                      }

                      var data = snapshot.data ?? [];
                      if (!snapshot.hasData || data.isEmpty) {
                        return _emptyStateBox();
                      }

                      return StatefulBuilder(builder: (context, setState) {
                        return Column(
                          children: [
                            if (widget.filter != null)
                              _dropdownSearchBar(
                                data: data,
                                setState: setState,
                              ),
                            SizedBox(
                              height: 300,
                              width: 300,
                              child: _sectionsList(data),
                            ),
                          ],
                        );
                      });
                    },
                  ),
                ),
              ],
              child: widget.child ?? _dropdownBox(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _dropdownSearchBar({
    required List<DropdownSectionTile<T>> data,
    required void Function(void Function()) setState,
  }) {
    return Column(
      children: [
        FlutterSearchBar(onChangeText: (value) {
          for (var e in data) {
            e.rows = widget.filter!(List.of(e.rows), value);
          }
          setState(() {});
        }),
        const Divider(
          height: 1,
        ),
      ],
    );
  }

  Widget _sectionsList(List<DropdownSectionTile<T>> data) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: data.length,
      itemBuilder: (context, index) {
        final section = data[index];
        return Column(
          children: [
            if (section.name.isNotEmpty) Text(section.name),
            _rowsList(section.rows),
          ],
        );
      },
    );
  }

  Widget _rowsList(List<DropdownRowTile<T>> rows) {
    return ListView.builder(
        shrinkWrap: true,
        itemCount: rows.length,
        itemBuilder: (context, index) {
          return _rowTile(rows[index]);
        });
  }

  Widget _rowTile(DropdownRowTile<T> row) {
    final item = row.item;
    return StatefulBuilder(builder: (context, setState) {
      return ListTile(
        onTap: row.onSelectItem == null
            ? null
            : () {
                row.onSelectItem!(item);
                if (widget.allowMultiselection) {
                  if (_selectedItems.contains(item)) {
                    _selectedItems.remove(item);
                  } else {
                    _selectedItems.add(item);
                  }
                } else {
                  _selectedItems.clear();
                  _selectedItems.add(item);
                  Navigator.pop(context);
                }

                selectedItemsLabel = _getSelectedItemsLabel(row);

                setState(() {});
              },
        title: row.itemBuilder?.call(item) ??
            Text(
              row.labelBuilder(item),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
        leading: widget.allowMultiselection
            ? Icon(
                _selectedItems.contains(item)
                    ? Icons.check_box_outlined
                    : Icons.check_box_outline_blank,
                color: _selectedItems.contains(item)
                    ? Theme.of(context).primaryColor
                    : ColorsPalette.primaryGrey,
                size: 15,
              )
            : const SizedBox.shrink(),
        trailing: row.onSelectItemOverview != null
            ? IconButton(
                onPressed: () {
                  row.onSelectItemOverview?.call(item);
                },
                icon: const Icon(
                  Icons.more_vert,
                  color: ColorsPalette.primaryGrey,
                ),
              )
            : null,
      );
    });
  }

  Widget _dropdownBox() {
    var searchBoxText = selectedItemsLabel ?? widget.dropdownLabel;

    return Builder(builder: (context) {
      return Container(
        height: 40,
        width: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          // color: Theme.of(context).backgroundColor,
          border: Border.all(color: ColorsPalette.primaryGrey),
        ),
        child: Row(children: [
          const SizedBox(
            width: 8,
          ),
          Expanded(
            child: Text(
              searchBoxText,
              style: Theme.of(context).textTheme.bodyLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          const Icon(Icons.keyboard_arrow_down,
              color: ColorsPalette.primaryGrey),
          const SizedBox(
            width: 8,
          ),
        ]),
      );
    });
  }

  Widget _emptyStateBox() {
    return Builder(builder: (context) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10)),
          child: Center(
              child: Text("Nessun contenuto trovato",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge)),
        ),
      );
    });
  }
}
