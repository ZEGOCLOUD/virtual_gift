import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

class Mp4PlayerManager with ZegoUIKitMediaEventInterface {
  static final Mp4PlayerManager _instance = Mp4PlayerManager._internal();

  factory Mp4PlayerManager() {
    return _instance;
  }

  Mp4PlayerManager._internal();

  bool _registerToUIKit = false;

  Widget? _mediaPlayerWidget;
  ZegoMediaPlayer? _mediaPlayer;
  int _mediaPlayerViewID = -1;

  /// callbacks
  void Function(ZegoMediaPlayerState state, int errorCode)?
      _onMediaPlayerStateUpdate;
  void Function(ZegoMediaPlayerFirstFrameEvent event)?
      _onMediaPlayerFirstFrameEvent;

  void registerCallbacks({
    Function(ZegoMediaPlayerState state, int errorCode)?
        onMediaPlayerStateUpdate,
    Function(ZegoMediaPlayerFirstFrameEvent event)?
        onMediaPlayerFirstFrameEvent,
  }) {
    if (!_registerToUIKit) {
      ZegoUIKit().registerMediaEvent(_instance);
      _registerToUIKit = true;
    }

    _onMediaPlayerStateUpdate = onMediaPlayerStateUpdate;
    _onMediaPlayerFirstFrameEvent = onMediaPlayerFirstFrameEvent;
  }

  void unregisterCallbacks() {
    _onMediaPlayerStateUpdate = null;
    _onMediaPlayerFirstFrameEvent = null;
  }

  /// create media player
  Future<Widget?> createMediaPlayer({bool reusePlayerView = false}) async {
    _mediaPlayer ??= await ZegoExpressEngine.instance.createMediaPlayer();

    if (!reusePlayerView) {
      destroyPlayerView();
    }
    // create or reuse old widget
    if (_mediaPlayerViewID == -1) {
      _mediaPlayerWidget =
          await ZegoExpressEngine.instance.createCanvasView((viewID) {
        _mediaPlayerViewID = viewID;
        _mediaPlayer?.setPlayerCanvas(ZegoCanvas(viewID, alphaBlend: true));
      });
    }
    return _mediaPlayerWidget;
  }

  @override
  void onMediaPlayerStateUpdate(mediaPlayer, state, errorCode) {
    _onMediaPlayerStateUpdate?.call(state, errorCode);
  }

  @override
  void onMediaPlayerFirstFrameEvent(mediaPlayer, event) {
    _onMediaPlayerFirstFrameEvent?.call(event);
  }

  void destroyMediaPlayer() {
    if (_mediaPlayer != null) {
      ZegoExpressEngine.instance.destroyMediaPlayer(_mediaPlayer!);
      _mediaPlayer = null;
    }
    destroyPlayerView();
  }

  void destroyPlayerView() {
    if (_mediaPlayerViewID != -1) {
      ZegoExpressEngine.instance.destroyCanvasView(_mediaPlayerViewID);
      _mediaPlayerViewID = -1;
    }
  }

  void clearView() {
    _mediaPlayer?.clearView();
  }

  Future<int> loadResource(String url,
      {ZegoAlphaLayoutType layoutType = ZegoAlphaLayoutType.Left}) async {
    debugPrint('Mp4 Player loadResource: $url');
    int ret = -1;
    if (_mediaPlayer != null) {
      ZegoMediaPlayerResource source = ZegoMediaPlayerResource.defaultConfig();
      source.filePath = url;
      source.loadType = ZegoMultimediaLoadType.FilePath;
      source.alphaLayout = layoutType;
      var result = await _mediaPlayer!.loadResourceWithConfig(source);
      ret = result.errorCode;
    }
    return ret;
  }

  void startMediaPlayer() {
    if (_mediaPlayer != null) {
      _mediaPlayer!.start();
    }
  }

  void pauseMediaPlayer() {
    if (_mediaPlayer != null) {
      _mediaPlayer!.pause();
    }
  }

  void resumeMediaPlayer() {
    if (_mediaPlayer != null) {
      _mediaPlayer!.resume();
    }
  }

  void stopMediaPlayer() {
    if (_mediaPlayer != null) {
      _mediaPlayer!.stop();
    }
  }
}
