import 'package:flutter/material.dart';
import 'package:uikit_flutter/src/utils/colors.dart';
import 'package:uikit_flutter/widgets/loader/loader.dart';
import 'package:uikit_flutter/widgets/flutter_search_bar.dart';

/// A widget that behaves like a dropdown menu, allowing
/// only view-mode, single and multi-selection and much more.
class DropdownSelector<T> extends StatelessWidget {
  /// This list is used when `allowMultiselection` is _true_, to pass a list
  /// of pre-selected items when opening the dropdown.
  final List<T>? selectedItems;

  /// The label to show in the default dropdown box when the dropdown is closed.
  /// Defautls to "Seleziona". It should be updated every time the user selects an item,
  /// eventually with a `setState`, so that the label reflects the user choice.
  final String? selectedItemLabel;

  /// The action to take when the user selects an item. If it's _null_, the dropdown
  /// is only in view-mode and items cannot be selected.
  final void Function(T item)? onSelectItem;

  /// If this method is not _null_, a "detail" icon is shown on the right side of
  /// each dropdown item tile, to eventually do something such as opening a modal detail.
  final void Function(T item)? onSelectItemOverview;

  /// The list of items to show in the dropdown. It's a [Future], so that the dropdown
  /// itself is responsbile of waiting the result while loading data.
  final Future<List<T>> Function() items;

  /// If _true_, checkboxes are shown in the dropdown to allow multiselection.
  /// Note that the _onSelectItem_ callback is called every time the user flags a checkbox,
  /// so it's developer responsability to manage selected items lists (i.e. select/deselect items)
  final bool allowMultiselection;

  /// If not _null_, a searchbar is shown in the dropdown to filter items by text.
  /// It takes the original items list and the searchbar text to filter, and should return
  /// the filtered items list
  final List<T> Function(List<T> items, String text)? filter;

  /// The label to show for each item of the dropdown
  final String Function(T item) labelItemBuilder;

  /// If _false_, the dropdown does not open
  final bool enabled;

  /// By default, the [DropdownSelector] shows a custom widget to tap to open the dropdown.
  /// This widget can be overwritten by passing a custom `child`
  final Widget? child;

  /// The size of the default searchbox widget shown to allow opening the dropdown.
  final Size? searchBoxSize;

  /// Creates a widget that behaves like a dropdown menu, allowing
  /// only view-mode, single and multi-selection and much more.
  const DropdownSelector({
    Key? key,
    this.selectedItems,
    this.selectedItemLabel,
    this.onSelectItem,
    this.onSelectItemOverview,
    required this.items,
    this.allowMultiselection = false,
    this.filter,
    required this.labelItemBuilder,
    this.enabled = true,
    this.child,
    this.searchBoxSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<T> _selectedItems = List.from(selectedItems ?? []);

    return IgnorePointer(
      ignoring: !enabled,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
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
              enabled: enabled,
              tooltip: onSelectItem != null ? "Seleziona" : "",
              offset: const Offset(0, 40),
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: false,
                  padding: EdgeInsets.zero,
                  child: FutureBuilder(
                    future: items(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData &&
                            snapshot.data is List<T> &&
                            (snapshot.data as List).isNotEmpty) {
                          var res = snapshot.data as List<T>;

                          return StatefulBuilder(builder: (context, setState) {
                            return Column(
                              children: [
                                if (filter != null)
                                  FlutterSearchBar(onChangeText: (value) {
                                    res =
                                        filter!(List.of(snapshot.data), value);
                                    setState(() {});
                                  }),
                                if (filter != null)
                                  const Divider(
                                    height: 1,
                                  ),
                                SizedBox(
                                  height: 300,
                                  width: 300,
                                  child: ListView.builder(
                                    padding: EdgeInsets.zero,
                                    itemCount: res.length,
                                    itemBuilder: (context, index) {
                                      var selected =
                                          _selectedItems.contains(res[index]);
                                      return ListTile(
                                        onTap: onSelectItem != null
                                            ? () {
                                                T item = res[index];
                                                if (item == null) {
                                                  return;
                                                }

                                                onSelectItem!(item);
                                                if (allowMultiselection) {
                                                  if (_selectedItems
                                                      .contains(item)) {
                                                    _selectedItems.remove(item);
                                                  } else {
                                                    _selectedItems.add(item);
                                                  }
                                                  setState(() {});
                                                } else {
                                                  Navigator.pop(context);
                                                }
                                              }
                                            : null,
                                        title: Text(
                                          labelItemBuilder(res[index]),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge,
                                        ),
                                        leading: allowMultiselection
                                            ? Icon(
                                                selected
                                                    ? Icons.check_box_outlined
                                                    : Icons
                                                        .check_box_outline_blank,
                                                color: selected
                                                    ? Theme.of(context)
                                                        .primaryColor
                                                    : ColorsPalette.primaryGrey,
                                 
                                                size: 15,
                                              )
                                            : null,
                                        trailing: onSelectItemOverview != null
                                            ? IconButton(
                                                onPressed: () {
                                                  onSelectItemOverview!(
                                                      res[index]);
                                                },
                                                icon: const Icon(
                                                  Icons.more_vert,
                                                  color:
                                                      ColorsPalette
                                                      .primaryGrey,
                                                ),
                                              )
                                            : null,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            );
                          });
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: const EdgeInsets.all(10),
                                  padding: const EdgeInsets.all(10),
                                  height: 100,
                                  width: 200,
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).cardColor,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Center(
                                      child: Text("Nessun contenuto trovato",
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge)),
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const Loader();
                    },
                  ),
                ),
              ],
              child: child ?? _searchBox(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchBox() {
    var searchBoxText = "";
    if (onSelectItem != null) {
      searchBoxText = "Seleziona";
    }
    if (selectedItemLabel != null) {
      searchBoxText = selectedItemLabel!;
    }
    return Builder(builder: (context) {
      return Container(
        height: searchBoxSize?.height ?? 40,
        width: searchBoxSize?.width ?? 200,
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
          if (onSelectItem != null)
            const Icon(Icons.keyboard_arrow_down,
                color: ColorsPalette.primaryGrey),
          const SizedBox(
            width: 8,
          ),
        ]),
      );
    });
  }
}
