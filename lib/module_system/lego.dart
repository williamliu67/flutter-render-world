import 'package:flutter_render_world/module_system/router.dart';

/// 用来处理模块化
///负责各个模块的启动
///1、路由模块
///     a.页面跳转
///     b.页面堆栈的维护
///     c.页面状态的保存与恢复
///     d.页面跳转动画
///2、App状态管理
///     a.状态的生命周期管理  注册、取消注册、
///     b.状态数据的管理 注册数据，监听数据调用
///     c.状态持久化
///3、网络管理
///     a.文件上传、下载
///     b.发送get、post请求,此处通过服务端生成请求文件，从而导入Api文件来实现请求代码自动生成
///4、Setting数据管理
///     a.数据的存取与清除
///5、文件操作
///     a.App存储（随着App删除而删除）、SD卡操作
///         1）创建文件夹
///         2) 查找文件夹列表
///         3）（批量）删除文件夹
///         4）修改文件夹名字（是否覆盖重名）
///         5）创建文件
///         6）修改文件
///         7）读取文件（分页读取）
///         8）删除文件
///6、数据库操作
///     a.创建数据库
///     b.数据库升级
///     c.清除数据库
///     d.创建表（申明表结构）
///     e.查询表
///     f.更新表
///     d.删除表

class Context with RouterContext{
}