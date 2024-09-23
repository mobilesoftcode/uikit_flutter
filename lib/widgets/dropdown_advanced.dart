import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uikit_flutter/widgets/flutter_search_bar.dart';
import 'package:uikit_flutter/widgets/loader/loader.dart';

import '../src/utils/colors.dart';

class DropdownAdvanced<S, T> extends StatefulWidget {
  const DropdownAdvanced({
    super.key,
    required this.enabled,
    required this.noContentLabel,
    required this.strategy,
    required this.content,
    this.selectedItems,
    required this.mainLabel,
    this.onItemOverview,
    this.itemOverviewIconBuilder,
    this.searchBox,
    Size? searchBoxSize,
    int? initialPage,
    this.debouncingWindow,
  })  : searchBoxSize = searchBoxSize ?? const Size(200.0, 40.0),
        initialPage = initialPage ?? 0;

  final bool enabled;
  final String noContentLabel;
  final DropdownSelectorStrategy<T> strategy;
  final DropdownSelectorContent<S, T> content;
  final Set<T>? selectedItems;
  final String mainLabel;
  final void Function(T)? onItemOverview;
  final Widget Function(T)? itemOverviewIconBuilder;
  final Size searchBoxSize;
  final Widget? searchBox;
  final int initialPage;
  final Duration? debouncingWindow;

  @override
  State<DropdownAdvanced<S, T>> createState() => _DropdownAdvancedState<S, T>();
}

class _DropdownAdvancedState<S, T> extends State<DropdownAdvanced<S, T>> {
  late final ScrollController _scrollController;
  late final bool _allowMultiSelection;
  List<DropdownMultiItem<S, T>> _items = [];
  List<DropdownMultiItem<S, T>> _filteredItems = [];
  late Set<T> _selectedItems;
  late final String Function(S) _headLabelBuilder;
  void Function(T) _onSingleItemSelected = (_) {};
  void Function(List<T>)? _onMultiItemsSelected;
  void Function(String)? _filterFunction;
  String? _confirmLabel;
  bool _isLoading = true;
  late int _currentPage = widget.initialPage;
  String _keyword = "";
  late final _Debouncer _debouncer = _Debouncer(
      duration: widget.debouncingWindow ?? const Duration(milliseconds: 500));
  void Function()? _onConfirm;
  void Function(List<T>)? _onItemsSelected;
  late void Function(void Function()) _innerSetState = setState;

  void _simpleListener() async {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      _innerSetState(() {
        _isLoading = true;
      });
      _currentPage++;
      final content = widget.content as _Simple<S, T>;
      final (newItems, isLastPage) = await content.itemsBuilder(_currentPage);
      if (isLastPage) {
        _scrollController.removeListener(_simpleListener);
      }
      _items.addAll(newItems.map((it) => DropdownMultiItem<S, T>.single(it)));
      final filter = content.filter;
      if (filter == null) {
        _filteredItems = _items;
      } else {
        final filteredList = (await Stream.fromIterable(_items)
                .asyncMap((it) => filter((it as _Single).item, _keyword))
                .toList())
            .whereType<T>();
        _filteredItems = filteredList
            .map((it) => DropdownMultiItem<S, T>.single(it))
            .toList(growable: false);
      }
      _innerSetState(() {
        _isLoading = false;
      });
    }
  }

  void _groupListener() async {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      _innerSetState(() {
        _isLoading = true;
      });
      _currentPage++;
      final content = widget.content as _ContentGroup<S, T>;
      final (newItems, isLastPage) = await content.itemsBuilder(_currentPage);
      if (isLastPage) {
        _scrollController.removeListener(_groupListener);
      }
      _items.addAll(newItems);
      final filter = content.filter;
      if (filter == null) {
        _filteredItems = _items;
      } else {
        final stream = Stream.fromIterable(_items).asyncMap((it) async {
          switch (it) {
            case _Single<S, T>():
              final newValue = await filter(it.item, _keyword);
              if (newValue == null) {
                return null;
              } else {
                return it;
              }
            case _Group<S, T>():
              final newList = (await Stream.fromIterable(it.content)
                      .asyncMap((e) => filter(e, _keyword))
                      .toList())
                  .whereType<T>()
                  .toList();
              if (newList.isEmpty) {
                return null;
              }
              return _Group<S, T>(
                it.head,
                newList,
              );
          }
        });

        _filteredItems = (await stream.toList())
            .whereType<DropdownMultiItem<S, T>>()
            .toList(growable: false);
      }
      _innerSetState(() {
        _isLoading = false;
      });
    }
  }

  void _futureFilterSimpleListener() async {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      _innerSetState(() {
        _isLoading = true;
      });
      _currentPage++;
      final content = widget.content as _FutureFilterSimple<S, T>;
      final (newItems, isLastPage) =
          await content.itemsBuilder(_currentPage, _keyword);
      if (isLastPage) {
        _scrollController.removeListener(_simpleListener);
      }
      _items.addAll(newItems.map((it) => DropdownMultiItem<S, T>.single(it)));
      _filteredItems = _items;
      _innerSetState(() {
        _isLoading = false;
      });
    }
  }

  void _futureFilterGroupListener() async {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      _innerSetState(() {
        _isLoading = true;
      });
      _currentPage++;
      final content = widget.content as _FutureFilterGroup<S, T>;
      final (newItems, isLastPage) =
          await content.itemsBuilder(_currentPage, _keyword);
      if (isLastPage) {
        _scrollController.removeListener(_groupListener);
      }
      _items.addAll(newItems);
      _filteredItems = _items;
      _innerSetState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _selectedItems = widget.selectedItems ?? <T>{};
    final strategy = widget.strategy;
    switch (strategy) {
      case _SingleStrategy():
        _allowMultiSelection = false;
        _onSingleItemSelected = strategy.onItemSelected;
      case _MultiStrategy():
        _allowMultiSelection = true;
        _onMultiItemsSelected = strategy.onItemsSelected;
        _confirmLabel = strategy.confirmLabel;
    }
    final content = widget.content;
    switch (content) {
      case _Simple():
        _headLabelBuilder = (_) => "";
        final filter = content.filter;
        if (filter == null) {
          _filterFunction = null;
        } else {
          _filterFunction = (keyword) {
            _debouncer.run(() async {
              _keyword = keyword;
              _filteredItems =
                  (await Stream<DropdownMultiItem<S, T>>.fromIterable(_items)
                          .asyncMap(
                              (it) => filter((it as _Single).item, keyword))
                          .toList())
                      .whereType<T>()
                      .map((it) => DropdownMultiItem<S, T>.single(it))
                      .toList(growable: false);
              _innerSetState(() {});
            });
          };
        }
        Future<(List<T>, bool)>(() async {
          return await content.itemsBuilder(0);
        }).then((value) async {
          final (list, isLastPage) = value;
          final mappedList = list
              .map((it) => DropdownMultiItem<S, T>.single(it))
              .toList(growable: !isLastPage);
          _items = mappedList;
          _filteredItems = _items;
          if (!isLastPage) {
            _scrollController.addListener(_simpleListener);
          }
          _innerSetState(() {
            _isLoading = false;
          });
        });
        break;
      case _ContentGroup():
        _headLabelBuilder = content.headLabelBuilder;
        final filter = content.filter;
        if (filter == null) {
          _filterFunction = null;
        } else {
          _filterFunction = (keyword) {
            _debouncer.run(() async {
              _keyword = keyword;
              final stream = Stream.fromIterable(_items).asyncMap((it) async {
                switch (it) {
                  case _Single<S, T>():
                    final newValue = await filter(it.item, keyword);
                    if (newValue == null) {
                      return null;
                    } else {
                      return it;
                    }
                  case _Group<S, T>():
                    final newList = (await Stream.fromIterable(it.content)
                            .asyncMap((e) => filter(e, keyword))
                            .toList())
                        .whereType<T>()
                        .toList();
                    if (newList.isEmpty) {
                      return null;
                    }
                    return _Group<S, T>(
                      it.head,
                      newList,
                    );
                }
              });

              _filteredItems = (await stream.toList())
                  .whereType<DropdownMultiItem<S, T>>()
                  .toList(growable: false);
              _innerSetState(() {});
            });
          };
        }
        Future<(List<T>, bool)>(() async {
          final result = await content.itemsBuilder(0);
          return result as (List<T>, bool);
        }).then((value) async {
          final (list, isLastPage) = value;
          final mappedList = list
              .map((it) => DropdownMultiItem<S, T>.single(it))
              .toList(growable: !isLastPage);
          _items = mappedList;
          _filteredItems = _items;
          if (!isLastPage) {
            _scrollController.addListener(_groupListener);
          }
          _innerSetState(() {
            _isLoading = false;
          });
        });
        break;
      case _FutureFilterSimple():
        _headLabelBuilder = (_) => "";
        _filterFunction = (keyword) {
          _debouncer.run(() async {
            _items = [];
            _filteredItems = _items;
            _scrollController.removeListener(_futureFilterSimpleListener);
            _innerSetState(() {
              _isLoading = true;
            });
            _keyword = keyword;
            _currentPage = 0;
            var (items, isLastPage) =
                await content.itemsBuilder(_currentPage, keyword);
            _items = items
                .map((it) => DropdownMultiItem<S, T>.single(it))
                .toList(growable: !isLastPage);
            _filteredItems = _items;
            if (!isLastPage) {
              _scrollController.addListener(_futureFilterSimpleListener);
            }
          });
          _innerSetState(() {
            _isLoading = false;
          });
        };
        Future<(List<T>, bool)>(() async {
          return await content.itemsBuilder(0, "");
        }).then((value) async {
          final (list, isLastPage) = value;
          final mappedList = list
              .map((it) => DropdownMultiItem<S, T>.single(it))
              .toList(growable: !isLastPage);
          _items = mappedList;
          _filteredItems = _items;
          if (!isLastPage) {
            _scrollController.addListener(_futureFilterSimpleListener);
          }
          _innerSetState(() {
            _isLoading = false;
          });
        });
        break;
      case _FutureFilterGroup():
        _headLabelBuilder = content.headLabelBuilder;
        _filterFunction = (keyword) {
          _debouncer.run(() async {
            _items = [];
            _filteredItems = _items;
            _scrollController.removeListener(_futureFilterSimpleListener);
            _innerSetState(() {
              _isLoading = true;
            });
            _keyword = keyword;
            _currentPage = 0;
            var (items, isLastPage) =
                await content.itemsBuilder(_currentPage, keyword);
            _items = items.toList(growable: !isLastPage);
            _filteredItems = _items;
            if (!isLastPage) {
              _scrollController.addListener(_futureFilterSimpleListener);
            }
            _innerSetState(() {
              _isLoading = false;
            });
          });
        };
        Future<(List<DropdownMultiItem<S, T>>, bool)>(() async {
          return await content.itemsBuilder(0, "");
        }).then((value) async {
          final (list, isLastPage) = value;
          final mappedList = list.toList(growable: !isLastPage);
          _items = mappedList;
          _filteredItems = _items;
          if (!isLastPage) {
            _scrollController.addListener(_futureFilterGroupListener);
          }
          _innerSetState(() {
            _isLoading = false;
          });
        });
        break;
    }
    _onConfirm = _onMultiItemsSelected != null
        ? () {
            _onMultiItemsSelected!(_selectedItems.toList());
            Navigator.of(context).pop();
          }
        : null;
    _onItemsSelected = _allowMultiSelection
        ? (i) => _innerSetState(() {
              for (var e in i) {
                if (!_selectedItems.add(e)) {
                  _selectedItems.remove(e);
                }
              }
            })
        : (i) {
            _onSingleItemSelected(i.first);
            Navigator.of(context).pop();
          };
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
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
              color: Theme.of(context).colorScheme.surface,
              elevation: 20,
              enabled: widget.enabled,
              tooltip: widget.mainLabel,
              offset: const Offset(0, 40),
              itemBuilder: (context) => [
                PopupMenuItem(
                  enabled: false,
                  padding: EdgeInsets.zero,
                  child: StatefulBuilder(builder: (context, setState) {
                    _innerSetState = setState;
                    return Column(
                      children: [
                        if (_filterFunction != null)
                          FlutterSearchBar(onChangeText: (value) {
                            _filterFunction!(value);
                          }),
                        if (_filterFunction != null)
                          const Divider(
                            height: 1,
                          ),
                        SizedBox(
                          height: 300,
                          width: 300,
                          child: _filteredItems.isEmpty
                              ? _EmptyList(widget.noContentLabel, _isLoading)
                              : _PopulatedList<S, T>(
                                  scrollController: _scrollController,
                                  isLoading: _isLoading,
                                  items: _filteredItems,
                                  selectedItems: _selectedItems,
                                  onItemsSelected: _onItemsSelected,
                                  headLabelBuilder: _headLabelBuilder,
                                  itemLabelBuilder:
                                      widget.content.itemLabelBuilder,
                                  allowMultiSelection: _allowMultiSelection,
                                  onItemOverview: widget.onItemOverview,
                                  itemOverviewIconBuilder:
                                      widget.itemOverviewIconBuilder,
                                ),
                        ),
                        if (_onConfirm != null)
                          Align(
                            alignment: Alignment.bottomRight,
                            child: TextButton(
                              onPressed:
                                  _selectedItems.isEmpty ? null : _onConfirm,
                              child: Text(_confirmLabel ?? ""),
                            ),
                          )
                      ],
                    );
                  }),
                ),
              ],
              child: widget.searchBox ??
                  _SearchBox(
                    searchBoxSize: widget.searchBoxSize,
                    mainLabel: widget.mainLabel,
                    onItemsSelected: _onItemsSelected,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchBox<T> extends StatelessWidget {
  final Size searchBoxSize;
  final String mainLabel;
  final void Function(List<T>)? onItemsSelected;

  const _SearchBox({
    required this.searchBoxSize,
    required this.mainLabel,
    required this.onItemsSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: searchBoxSize.height,
      width: searchBoxSize.width,
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
            mainLabel,
            style: Theme.of(context).textTheme.bodyLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(
          width: 8,
        ),
        if (onItemsSelected != null)
          const Icon(Icons.keyboard_arrow_down,
              color: ColorsPalette.primaryGrey),
        const SizedBox(
          width: 8,
        ),
      ]),
    );
  }
}

class _EmptyList extends StatelessWidget {
  const _EmptyList(this.noContentLabel, this.isLoading);
  final String noContentLabel;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
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
                  child: isLoading
                      ? const Loader()
                      : Text(
                          noContentLabel,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        )),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _PopulatedList<S, T> extends StatelessWidget {
  const _PopulatedList({
    super.key,
    required this.scrollController,
    required this.isLoading,
    required this.items,
    required this.selectedItems,
    required this.onItemsSelected,
    required this.headLabelBuilder,
    required this.itemLabelBuilder,
    required this.allowMultiSelection,
    required this.onItemOverview,
    required this.itemOverviewIconBuilder,
  });

  final ScrollController scrollController;
  final bool isLoading;
  final List<DropdownMultiItem<S, T>> items;
  final Set<T> selectedItems;
  final void Function(List<T>)? onItemsSelected;
  final String Function(S) headLabelBuilder;
  final String Function(T) itemLabelBuilder;
  final bool allowMultiSelection;
  final void Function(T)? onItemOverview;
  final Widget Function(T)? itemOverviewIconBuilder;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.zero,
      itemCount: items.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == items.length) {
          return const Center(child: Loader());
        }
        final content = items[index];
        switch (content) {
          case _Single<S, T>():
            return _SingleItem(
              item: content.item,
              selectedItems: selectedItems,
              itemLabelBuilder: itemLabelBuilder,
              allowMultiSelection: allowMultiSelection,
              onItemsSelected: onItemsSelected,
              onItemOverview: onItemOverview,
              itemOverviewIconBuilder: itemOverviewIconBuilder,
              extraSpace: false,
            );
          case _Group<S, T>():
            return _MultiItem(
              group: content,
              selectedItems: selectedItems,
              onItemsSelected: onItemsSelected,
              headLabelBuilder: headLabelBuilder,
              itemLabelBuilder: itemLabelBuilder,
              allowMultiSelection: allowMultiSelection,
              onItemOverview: onItemOverview,
              itemOverviewIconBuilder: itemOverviewIconBuilder,
            );
        }
      },
    );
  }
}

class _SingleItem<S, T> extends StatelessWidget {
  final T item;
  final Set<T> selectedItems;
  final void Function(List<T>)? onItemsSelected;
  final String Function(T) itemLabelBuilder;
  final bool allowMultiSelection;
  final void Function(T)? onItemOverview;
  final Widget Function(T)? itemOverviewIconBuilder;
  final bool extraSpace;

  const _SingleItem({
    super.key,
    required this.item,
    required this.selectedItems,
    required this.onItemsSelected,
    required this.itemLabelBuilder,
    required this.allowMultiSelection,
    required this.onItemOverview,
    required this.itemOverviewIconBuilder,
    required this.extraSpace,
  });

  @override
  Widget build(BuildContext context) {
    var selected = selectedItems.contains(item);
    return ListTile(
      minLeadingWidth: 10,
      onTap: onItemsSelected != null
          ? () {
              if (item == null) {
                return;
              }
              onItemsSelected!([item]);
            }
          : null,
      title: Text(
        itemLabelBuilder(item),
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      leading: allowMultiSelection
          ? Row(
              children: [
                if (extraSpace)
                  const SizedBox(
                    width: 15,
                  ),
                Icon(
                  selected
                      ? Icons.check_box_outlined
                      : Icons.check_box_outline_blank,
                  color: selected
                      ? Theme.of(context).primaryColor
                      : ColorsPalette.primaryGrey,
                  size: 15,
                ),
              ],
            )
          : const SizedBox(
              width: 10,
            ),
      trailing: onItemOverview != null
          ? IconButton(
              onPressed: () {
                onItemOverview!(item);
              },
              icon: itemOverviewIconBuilder?.call(item) ??
                  const Icon(
                    Icons.more_vert,
                    color: ColorsPalette.primaryGrey,
                  ),
            )
          : null,
    );
  }
}

class _MultiItem<S, T> extends StatefulWidget {
  final _Group<S, T> group;
  final Set<T> selectedItems;
  final void Function(List<T>)? onItemsSelected;
  final String Function(S) headLabelBuilder;
  final String Function(T) itemLabelBuilder;
  final bool allowMultiSelection;
  final void Function(T)? onItemOverview;
  final Widget Function(T)? itemOverviewIconBuilder;
  const _MultiItem({
    required this.group,
    required this.selectedItems,
    required this.onItemsSelected,
    required this.headLabelBuilder,
    required this.itemLabelBuilder,
    required this.allowMultiSelection,
    required this.onItemOverview,
    required this.itemOverviewIconBuilder,
  });

  @override
  State<_MultiItem> createState() => _MultiItemState();
}

class _MultiItemState extends State<_MultiItem> with TickerProviderStateMixin {
  late bool _showChild = false;

  /// The controller of the rotating animation of chevron when tapped
  late final AnimationController _rotationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
    upperBound: 0.5,
  );

  /// The controller of expandable child widget when chevron is tapped
  late final AnimationController _expandController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 200));

  @override
  void dispose() {
    _rotationController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  void _changeTileView() {
    if (_showChild) {
      _rotationController.reverse(from: 0.5);
      _expandController.reverse();
    } else {
      _rotationController.forward(from: 0.0);
      _expandController.forward();
    }
    setState(() {
      _showChild = !_showChild;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selectedItems.containsAll(widget.group.content);

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            minLeadingWidth: 10,
            onTap: widget.allowMultiSelection && widget.onItemsSelected != null
                ? () => widget.onItemsSelected!(widget.group.content)
                : null,
            title: Text(
              widget.headLabelBuilder(widget.group.head),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            leading: widget.allowMultiSelection
                ? Icon(
                    selected
                        ? Icons.check_box_outlined
                        : Icons.check_box_outline_blank,
                    color: selected
                        ? Theme.of(context).primaryColor
                        : ColorsPalette.primaryGrey,
                    size: 15,
                  )
                : const SizedBox(
                    width: 10,
                  ),
            trailing: IconButton(
              icon: RotationTransition(
                turns: Tween(begin: 0.0, end: 1.0).animate(_rotationController),
                child: const Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                ),
              ),
              onPressed: () {
                _changeTileView();
              },
            ),
          ),
          FocusScope(
            child: SizeTransition(
              axisAlignment: 1.0,
              sizeFactor: CurvedAnimation(
                parent: _expandController,
                curve: Curves.fastOutSlowIn,
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  for (final item in widget.group.content)
                    _SingleItem(
                      item: item,
                      selectedItems: widget.selectedItems,
                      itemLabelBuilder: widget.itemLabelBuilder,
                      allowMultiSelection: widget.allowMultiSelection,
                      onItemsSelected: widget.onItemsSelected,
                      onItemOverview: widget.onItemOverview,
                      itemOverviewIconBuilder: widget.itemOverviewIconBuilder,
                      extraSpace: true,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

sealed class DropdownMultiItem<S, T> {
  const DropdownMultiItem._();

  factory DropdownMultiItem.single(T item) => _Single(item);
  factory DropdownMultiItem.group(S head, List<T> group) => _Group(head, group);
}

class _Single<S, T> extends DropdownMultiItem<S, T> {
  const _Single(this.item) : super._();
  final T item;
}

class _Group<S, T> extends DropdownMultiItem<S, T> {
  const _Group(this.head, this.content) : super._();
  final S head;
  final List<T> content;
}

sealed class DropdownSelectorStrategy<T> {
  const DropdownSelectorStrategy._();

  factory DropdownSelectorStrategy.single({
    required final void Function(T) onItemSelected,
  }) =>
      _SingleStrategy(onItemSelected: onItemSelected);

  factory DropdownSelectorStrategy.multi({
    required final String confirmLabel,
    required final void Function(List<T>) onItemsSelected,
  }) =>
      _MultiStrategy(
        confirmLabel: confirmLabel,
        onItemsSelected: onItemsSelected,
      );
}

class _SingleStrategy<T> extends DropdownSelectorStrategy<T> {
  const _SingleStrategy({
    required this.onItemSelected,
  }) : super._();
  final void Function(T) onItemSelected;
}

class _MultiStrategy<T> extends DropdownSelectorStrategy<T> {
  const _MultiStrategy({
    required this.confirmLabel,
    required this.onItemsSelected,
  }) : super._();
  final String confirmLabel;
  final void Function(List<T>) onItemsSelected;
}

sealed class DropdownSelectorContent<S, T> {
  const DropdownSelectorContent._(this.itemLabelBuilder);

  final String Function(T) itemLabelBuilder;

  factory DropdownSelectorContent.simple({
    required final FutureOr<(List<T> list, bool isLastPage)> Function(int page)
        itemsBuilder,
    required final FutureOr<T?> Function(T, String keyword)? filter,
    required final String Function(T) itemLabelBuilder,
  }) =>
      _Simple(
        itemsBuilder: itemsBuilder,
        filter: filter,
        itemLabelBuilder: itemLabelBuilder,
      );

  factory DropdownSelectorContent.group({
    required final FutureOr<
                (List<DropdownMultiItem<S, T>> list, bool isLastPage)>
            Function(int page)
        itemsBuilder,
    required final FutureOr<T> Function(T original, String keyword)? filter,
    required final String Function(S) headLabelBuilder,
    required final String Function(T) itemLabelBuilder,
  }) =>
      _ContentGroup(
        itemsBuilder: itemsBuilder,
        filter: filter,
        headLabelBuilder: headLabelBuilder,
        itemLabelBuilder: itemLabelBuilder,
      );

  factory DropdownSelectorContent.futureFilter({
    required final FutureOr<(List<T> list, bool isLastPage)> Function(
            int page, String keyword)
        itemsBuilder,
    required final String Function(T) itemLabelBuilder,
  }) =>
      _FutureFilterSimple(
        itemsBuilder: itemsBuilder,
        itemLabelBuilder: itemLabelBuilder,
      );

  factory DropdownSelectorContent.futureFilterGroup({
    required final FutureOr<
            (List<DropdownMultiItem<S, T>> list, bool isLastPage)>
        Function(
      int page,
      String keyword,
    ) itemsBuilder,
    required final String Function(S) headLabelBuilder,
    required final String Function(T) itemLabelBuilder,
  }) =>
      _FutureFilterGroup(
        itemsBuilder: itemsBuilder,
        headLabelBuilder: headLabelBuilder,
        itemLabelBuilder: itemLabelBuilder,
      );
}

class _Simple<S, T> extends DropdownSelectorContent<S, T> {
  const _Simple({
    required this.itemsBuilder,
    required this.filter,
    required String Function(T) itemLabelBuilder,
  }) : super._(itemLabelBuilder);
  final FutureOr<(List<T>, bool)> Function(int page) itemsBuilder;
  final FutureOr<T?> Function(T original, String keyword)? filter;
}

class _ContentGroup<S, T> extends DropdownSelectorContent<S, T> {
  const _ContentGroup({
    required this.itemsBuilder,
    required this.filter,
    required this.headLabelBuilder,
    required String Function(T) itemLabelBuilder,
  }) : super._(itemLabelBuilder);
  final FutureOr<(List<DropdownMultiItem<S, T>>, bool)> Function(int page)
      itemsBuilder;
  final FutureOr<T?> Function(T original, String keyword)? filter;
  final String Function(S) headLabelBuilder;
}

class _FutureFilterSimple<S, T> extends DropdownSelectorContent<S, T> {
  const _FutureFilterSimple({
    required this.itemsBuilder,
    required String Function(T) itemLabelBuilder,
  }) : super._(itemLabelBuilder);
  final FutureOr<(List<T>, bool)> Function(int page, String keyword)
      itemsBuilder;
}

class _FutureFilterGroup<S, T> extends DropdownSelectorContent<S, T> {
  const _FutureFilterGroup({
    required this.itemsBuilder,
    required this.headLabelBuilder,
    required String Function(T) itemLabelBuilder,
  }) : super._(itemLabelBuilder);
  final FutureOr<(List<DropdownMultiItem<S, T>>, bool)> Function(
      int page, String keyword) itemsBuilder;
  final String Function(S) headLabelBuilder;
}

class _Debouncer {
  final Duration duration;
  Timer? _timer;

  _Debouncer({required this.duration});

  void run(VoidCallback action) {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer(duration, action);
  }
}
