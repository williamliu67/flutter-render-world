import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_render_world/label/layout.dart';
import 'package:flutter_render_world/label/layout_compat.dart';
import 'package:flutter_render_world/label/view.dart';
import 'package:flutter_render_world/module_system/lego.dart';
import 'package:flutter_render_world/module_system/router.dart';
import 'package:flutter_render_world/page/page.dart';
import 'package:flutter_render_world/page/page_view.dart';

///1.GestureBinding 负责接收点击事件 关键代码在window.onPointerDataPacket这个方法
///2.ServicesBinding 用来接收平台消息 关键代码在window.onPlatformMessage = defaultBinaryMessenger.handlePlatformMessage;
///3.SchedulerBinding 用来处理Vsync信号的相关回调信息以及当前应用的是否位于活跃状态等
///4.PaintingBinding 用来处理图片缓存以及开屏页，如果自定义图片加载器，可以忽略其中的ImageCache
///5.SemanticsBinding 主要用来处理各个平台的差异化内容
///6.RendererBinding 整个Flutter的渲染模型，处理了测量，布局，绘制等关键内容，与SchedulerBinding配合达到渲染屏幕的目的
///7.Context 模块化相关的内容，包括RouterContext，StorageContext等

abstract class Application extends BindingBase
    with
        GestureBinding,
        ServicesBinding,
        SchedulerBinding,
        PaintingBinding,
        SemanticsBinding,
        RendererBinding {
  Context _context;
  static const ROOT_CONTAINER = "application_root_container";

  Application() {
    _context = Context();
    // 初始化RouterContext
    RouterContainer routerContainer =
        RouterContainer(SizeSpec.matchParent(), SizeSpec.matchParent());
    routerContainer
      ..background = Colors.white
      ..id = ID(ROOT_CONTAINER)
      ..padding = EdgeInsets.only(top: 0);
    renderView.child = routerContainer.renderVue;
    _context.bindRouterContainer(routerContainer);
    _context.configRouters(RouterConfig(10, routers));
    onCreate();
    scheduleFrame();
  }

  void onCreate() {}

  onDestroy() {
    ///销毁所有页面
    _context.destroy();
  }

  List<PageRouter> get routers;

  @override
  Future<void> performReassemble() {
    ///TODO 当前架构无法hot reload
    print("hot reload will through here!");
    return super.performReassemble();
  }
}

class MyApplication extends Application {
  @override
  void onCreate() {
    super.onCreate();
    PageIntent intent = PageIntent();
    intent.router = routers[0]?.path;
    intent.routerFlag = RouterFlag.standard;
    _context.start(intent);
  }

  @override
  List<PageRouter> get routers => [
        PageRouter('login', () => LoginPage()),
        PageRouter('main', () => MainPage())
      ];
}
