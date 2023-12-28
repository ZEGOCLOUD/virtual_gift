part of '../manager.dart';

mixin Cache {
  final _cacheImpl = CacheImpl();

  CacheImpl get cache => _cacheImpl;
}

class CacheImpl {
  void cache(List<ZegoGiftItem> cacheList) {
    for (var itemData in cacheList) {
      debugPrint('${DateTime.now()} try cache ${itemData.sourceURL}');
      switch (itemData.source) {
        case ZegoGiftSource.url:
          readFromURL(url: itemData.sourceURL).then((value) {
            debugPrint('${DateTime.now()} cache done: ${itemData.sourceURL} ');
          });
          break;
        case ZegoGiftSource.asset:
          // readFromAsset(itemData.sourceURL).then((value) {
          //   debugPrint('${DateTime.now()} cache done: ${itemData.sourceURL} ');
          // });
          break;
      }
    }
  }

  Future<List<int>> readFromURL({required String url}) async {
    List<int> result = kTransparentImage.toList();
    final FileInfo? info = await DefaultCacheManager().getFileFromCache(
      url,
      // ignoreMemCache: true,
    );
    if (info == null) {
      try {
        final Uri uri = Uri.parse(url);
        final http.Response response = await http.get(uri);
        if (response.statusCode == HttpStatus.ok) {
          result = response.bodyBytes.toList();
          await DefaultCacheManager().putFile(url, response.bodyBytes);
          print("cache download done:$url");
        } else {}
      } on Exception catch (e, s) {
        print("cache read Exception: $e $s, url:$url");
      }
    } else {
      result = info.file.readAsBytesSync().toList();
    }

    return Future<List<int>>.value(result);
  }

  Future<List<int>> readFromAsset(String assetPath) async {
    List<int> result = kTransparentImage.toList();
    final FileInfo? info = await DefaultCacheManager().getFileFromCache(
      assetPath,
      // ignoreMemCache: true,
    );
    if (info == null) {
      await loadAssetData(assetPath).then((bytesData) async {
        result = bytesData;
        await DefaultCacheManager().putFile(assetPath, bytesData);
      });
    } else {
      result = info.file.readAsBytesSync().toList();
    }

    return Future<List<int>>.value(result);
  }

  Future<Uint8List> loadAssetData(String assetPath) async {
    ByteData assetData = await rootBundle.load(assetPath);
    Uint8List data = assetData.buffer.asUint8List();
    return data;
  }
}
