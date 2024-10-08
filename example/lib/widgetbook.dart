// Widgetbook file: widgetbook.dart
import 'package:flutter/material.dart';
import 'package:uikit_flutter/theme/src/themes.dart';
import 'package:uikit_flutter/widgets/accordion.dart';
import 'package:uikit_flutter/widgets/dropdown_selector.dart';
import 'package:uikit_flutter/widgets/expandable_floating_container.dart';
import 'package:uikit_flutter/widgets/expandable_text.dart';
import 'package:uikit_flutter/widgets/flutter_search_bar.dart';
import 'package:uikit_flutter/widgets/loader/loader.dart';
import 'package:uikit_flutter/widgets/page_skeleton.dart';
import 'package:uikit_flutter/widgets/shadow_box.dart';
import 'package:widgetbook/widgetbook.dart';

class HotReload extends StatelessWidget {
  const HotReload({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      addons: [
        _themeAddOn(),
        _deviceFrameAddOn(),
      ],
      directories: [
        WidgetbookComponent(
          name: 'ShadowBox',
          useCases: [
            WidgetbookUseCase(
              name: 'plain',
              builder: (context) => ShadowBox(
                removeMargin: context.knobs.boolean(label: "Remove margin"),
                child: Text(context.knobs.string(label: "Text content")),
              ),
            ),
            WidgetbookUseCase(
              name: 'with title',
              builder: (context) => ShadowBoxWithTitle(
                title: Text(
                  context.knobs.string(label: "Text title"),
                ),
                removeMargin: context.knobs.boolean(label: "Remove margin"),
                removeInnerPadding:
                    context.knobs.boolean(label: "Remove inner padding"),
                shouldAllowHiding:
                    context.knobs.boolean(label: "Should allow hiding"),
                initiallyShowChild:
                    context.knobs.boolean(label: "Initially show child"),
                child: Text(context.knobs.string(label: "Text content")),
              ),
            ),
          ],
        ),
        WidgetbookComponent(
          name: 'PageSkeleton',
          useCases: [
            WidgetbookUseCase(
              name: 'plain',
              builder: (context) => PageSkeleton(
                removePadding: context.knobs.boolean(label: "Remove padding"),
                body: Text(context.knobs.string(label: "Scaffold content")),
              ),
            ),
            WidgetbookUseCase(
              name: 'with appbar',
              builder: (context) => PageSkeleton(
                removePadding: context.knobs.boolean(label: "Remove padding"),
                appBar: AppBar(
                  title: Text(
                    context.knobs.string(label: "Appbar content"),
                  ),
                ),
                body: Text(context.knobs.string(label: "Scaffold content")),
              ),
            ),
            WidgetbookUseCase(
              name: 'with FAB',
              builder: (context) => PageSkeleton(
                removePadding: context.knobs.boolean(label: "Remove padding"),
                floatingActionButton: IconButton.filled(
                    onPressed: () {}, icon: const Icon(Icons.add)),
                body: Text(context.knobs.string(label: "Scaffold content")),
              ),
            ),
            WidgetbookUseCase(
              name: 'wuth top widget',
              builder: (context) => PageSkeleton(
                removePadding: context.knobs.boolean(label: "Remove padding"),
                topWidget: Text(
                  context.knobs.string(label: "Top widget content"),
                ),
                appBar: context.knobs.boolean(label: "Show app bar")
                    ? AppBar(
                        title: const Text("Appbar"),
                      )
                    : null,
                body: Text(context.knobs.string(label: "Scaffold content")),
              ),
            ),
          ],
        ),
        WidgetbookComponent(
          name: 'SearchBar',
          useCases: [
            WidgetbookUseCase(
              name: 'plain',
              builder: (context) => FlutterSearchBar(
                onChangeText: (value) {},
                onFilterTap: context.knobs.boolean(label: "Show filter button")
                    ? () {}
                    : null,
                onOrderArrowTap:
                    context.knobs.boolean(label: "Show sort button")
                        ? (order) {}
                        : null,
                searchBarColor: context.knobs.color(
                    label: "Bar color",
                    initialValue: Theme.of(context).cardColor),
              ),
            ),
          ],
        ),
        WidgetbookComponent(
          name: 'ExpandableText',
          useCases: [
            WidgetbookUseCase(
              name: 'plain',
              builder: (context) => ExpandableText(
                textSpan: TextSpan(
                  text: context.knobs.string(label: "Text so truncate"),
                ),
                maxLines: context.knobs.double
                    .input(
                        label: "Max number of lines to truncate text",
                        initialValue: 1)
                    .toInt(),
              ),
            ),
          ],
        ),
        WidgetbookComponent(
          name: 'DropdownSelector',
          useCases: [
            WidgetbookUseCase(
                name: 'plain',
                builder: (context) => DropdownSelector(
                      items: () async => ["Item1", "Item2"],
                      labelItemBuilder: (item) => item,
                    )),
          ],
        ),
        WidgetbookComponent(
          name: 'Accordion',
          useCases: [
            WidgetbookUseCase(
              name: 'plain',
              builder: (context) => Accordion(
                title: context.knobs.string(label: "Title"),
                child: Container(
                    color: Colors.white,
                    child: Text(context.knobs.string(label: "Text content"))),
              ),
            ),
          ],
        ),
        WidgetbookComponent(
          name: 'Expandable Floating Container',
          useCases: [
            WidgetbookUseCase(
              name: 'plain',
              builder: (context) => SafeArea(child: Stack(
                children: [
                  Positioned(
                    top: 16,
                    right: 16,
                    child: ExpandableFloatingContainer(
                    icon: (isExpanded) => Icon(context.knobs.list(label: "Icon", options: [Icons.gps_off, Icons.tv_off])),
                    title: Text(context.knobs.string(label: "Title", initialValue: "Example Title")),
                    backgroundColor: context.knobs.color(label: "Background Color", initialValue: Colors.white),
                    
                    child: Flexible(
                      child: SizedBox(
                        height: 200,
                        child: Container(
                            color: Colors.red,
                            ),
                      ),
                    ),
                                    ),
                  ),
          ])),
            ),
          ],
        ),
        WidgetbookComponent(
          name: 'Loader',
          useCases: [
            WidgetbookUseCase(
                name: 'plain', builder: (context) => const Loader()),
          ],
        ),
      ],
    );
  }

  _themeAddOn() {
    return ThemeAddon(
      themes: [
        WidgetbookTheme(
          name: 'Light',
          data: Themes.lightTheme,
        ),
        WidgetbookTheme(
          name: 'Dark',
          data: Themes.darkTheme,
        ),
      ],
      themeBuilder: (context, theme, child) {
        return Theme(
          data: theme,
          child: child,
        );
      },
    );
  }

  _deviceFrameAddOn() {
    return DeviceFrameAddon(
      devices: [
        Devices.ios.iPhoneSE,
        Devices.ios.iPhone13,
        Devices.android.samsungGalaxyS20,
        Devices.android.smallPhone,
      ],
      initialDevice: Devices.ios.iPhone13,
    );
  }
}
