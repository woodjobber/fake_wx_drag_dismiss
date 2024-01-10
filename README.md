<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

TODO: Put a short description of the package here that helps potential users
know whether this package might be useful for them.

## Features

Imitation of WeChat Moments to view video interaction.

## Usage

```dart
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      title: Text('Fake demo'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  fullscreenDialog: true,
                  opaque: false,
                  pageBuilder: (ctx, begin, end) {
                    return DragTransitionPage(builder: (ctx) {
                      return const HeroWxPage(
                        tag: 'HeroWxPage',
                      );
                    });
                  },
                  transitionsBuilder: (ctx, _, __, child) {
                    return defaultTransitionsBuilder(context, child);
                  },
                  transitionDuration: dragDefaultTransitionDuration,
                  reverseTransitionDuration: dragDefaultTransitionDuration,
                ),
              );
            },
            child: Hero(
              tag: 'HeroWxPage',
              child: Container(
                height: 100,
                width: 100,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Image.network(
                  'https://source.unsplash.com/1900x3600/?camera,paper',
                  width: 100,
                  height: 100,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
          // const JankWidget(),
        ],
      ),
    ), // This trailing comma makes auto-formatting nicer for build methods.
  );
}
```

`HeroWxPage`

```dart
class HeroWxPage extends StatelessWidget {
  const HeroWxPage({
    super.key,
    required this.tag,
  });
  final String tag;
  @override
  Widget build(BuildContext context) {
    return HeroAnimationWidget(
      tag: tag,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Image.network(
          'https://source.unsplash.com/1900x3600/?camera,paper',
          fit: BoxFit.fill,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
        ),
      ),
    );
  }
}
```

## Thanks

Thank you `EchoPuda` https://github.com/EchoPuda/wx_video_player.git.
