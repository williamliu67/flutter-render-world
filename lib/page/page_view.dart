import 'dart:async';

import 'package:flutter/material.dart' hide Page;
import 'package:flutter_render_world/label/layout.dart';
import 'package:flutter_render_world/label/layout_compat.dart';
import 'package:flutter_render_world/label/view.dart';
import 'package:flutter_render_world/label/widgets.dart';
import 'package:flutter_render_world/page/page.dart';

class LoginPage extends Page {
	final String tag = "LoginPage";
	TextView _textView;

	@override
	void onCreate() {
		super.onCreate();
		print("$tag:onCreate");
		setContentView(getContentView());

		_textView = findViewById(ID('loginBtn'));
		_textView?.clickListener = (v) {
			_textView.setText("登陆...");
			Timer(Duration(seconds: 2), (){
				PageIntent intent = PageIntent()
					..router = 'main'
					..routerFlag = RouterFlag.standard;

				start(intent);
				finish();
			});
		};
	}

	View getContentView() => FrameLayout(SizeSpec.matchParent(), SizeSpec.matchParent())
		..background = Colors.blue
		..children = [
			TextView(SizeSpec(50), SizeSpec.wrapContent())
				..id = ID('loginBtn')
				..padding = EdgeInsets.fromLTRB(10, 5, 10, 5)
				..background = Colors.white
				..margin = EdgeInsets.only(top: 50)
				..message = "登陆"
				..style = TextStyle(color: Colors.yellow, fontSize: 15)
				..layoutParams = FrameLayoutParams(xGravity: Gravity.center)
		];

	@override
	void onStart() {
		super.onStart();
		print("$tag:onStart");
	}

	@override
	void onResume() {
		super.onResume();
		print("$tag:onResume");
	}

	@override
	void onPause() {
		super.onPause();
		print("$tag:onPause");
	}

	@override
	void onStop() {
		super.onStop();
		print("$tag:onStop");
	}

	@override
	void onDestroy() {
		super.onDestroy();
		print("$tag:onDestroy");
	}
}

class MainPage extends Page {
	final String tag = "MainPage";

	@override
	void onCreate() {
		super.onCreate();
		print("$tag:onCreate");
		setContentView(getContentView());
		findViewById(ID('btn'))?.clickListener = (v) {
			print('${tag}Page click!');
			(v as TextView).setText('${tag}Page is Finish');
			finish();
		};
	}

	View getContentView() => RelativeLayout(SizeSpec.matchParent(), SizeSpec.wrapContent())
			..children = [
				WeightLayout.horizontal(SizeSpec.matchParent(), SizeSpec.wrapContent())
					..id = ID('bottomBar')
					..background = Colors.white54
					..padding = EdgeInsets.only(top: 10, bottom: 10)
					..layoutParams = RelativeLayoutParams([
						RelativeRule.alignParentBottom()
					])
					..children = [
						LinearLayout.vertical(SizeSpec.matchParent(), SizeSpec.wrapContent())
							..layoutParams = WeightLayoutParams(1, yGravity: Gravity.center)
							..children = [
								View(SizeSpec(50), SizeSpec(50))
									..background = Colors.grey
									..borderRadius = BorderRadius.all(Radius.circular(25))
									..layoutParams = LinearLayoutParams(xGravity: Gravity.center),
								TextView(SizeSpec.matchParent(), SizeSpec.wrapContent())
									..message = '首页'
									..contentGravity = LayoutGravity(x: Gravity.center, y: Gravity.center)
									..style = TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)
									..layoutParams = LinearLayoutParams(xGravity: Gravity.center)
							],
						LinearLayout.vertical(SizeSpec.matchParent(), SizeSpec.wrapContent())
							..layoutParams = WeightLayoutParams(1, yGravity: Gravity.center)
							..children = [
								View(SizeSpec(50), SizeSpec(50))
									..background = Colors.grey
									..borderRadius = BorderRadius.all(Radius.circular(25))
									..layoutParams = LinearLayoutParams(xGravity: Gravity.center),
								TextView(SizeSpec.matchParent(), SizeSpec.wrapContent())
									..message = '首页'
									..contentGravity = LayoutGravity(x: Gravity.center, y: Gravity.center)
									..style = TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)
									..layoutParams = LinearLayoutParams(xGravity: Gravity.center)
							],
						LinearLayout.vertical(SizeSpec.matchParent(), SizeSpec.wrapContent())
							..layoutParams = WeightLayoutParams(1, yGravity: Gravity.center)
							..children = [
								View(SizeSpec(50), SizeSpec(50))
									..background = Colors.grey
									..borderRadius = BorderRadius.all(Radius.circular(25))
									..layoutParams = LinearLayoutParams(xGravity: Gravity.center),
								TextView(SizeSpec.matchParent(), SizeSpec.wrapContent())
									..message = '首页'
									..contentGravity = LayoutGravity(x: Gravity.center, y: Gravity.center)
									..style = TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)
									..layoutParams = LinearLayoutParams(xGravity: Gravity.center)
							],
						LinearLayout.vertical(SizeSpec.matchParent(), SizeSpec.wrapContent())
							..layoutParams = WeightLayoutParams(1, yGravity: Gravity.center)
							..contentGravity = LayoutGravity(x: Gravity.center)
							..children = [
								View(SizeSpec(50), SizeSpec(50))
									..background = Colors.grey
									..borderRadius = BorderRadius.all(Radius.circular(25))
									..layoutParams = LinearLayoutParams(xGravity: Gravity.center),
								TextView(SizeSpec.matchParent(), SizeSpec.wrapContent())
									..message = '首页'
									..contentGravity = LayoutGravity(x: Gravity.center, y: Gravity.center)
									..style = TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)
									..layoutParams = LinearLayoutParams(xGravity: Gravity.center)
							],
					],

				View(SizeSpec.matchParent(), SizeSpec(1))
					..id = ID('bottomLine')
					..background = Colors.grey
					..layoutParams = RelativeLayoutParams([
						RelativeRule.toAboveOf(ID('bottomBar'))
					]),

				FrameLayout(SizeSpec.matchParent(), SizeSpec.matchParent())
					..background = Colors.white
					..layoutParams = RelativeLayoutParams([
						RelativeRule.toAboveOf(ID('bottomLine'))
					])
			];

	@override
	void onStart() {
		super.onStart();
		print("$tag:onStart");
	}

	@override
	void onResume() {
		super.onResume();
		print("$tag:onResume");
	}

	@override
	void onPause() {
		super.onPause();
		print("$tag:onPause");
	}

	@override
	void onStop() {
		super.onStop();
		print("$tag:onStop");
	}

	@override
	void onDestroy() {
		super.onDestroy();
		print("$tag:onDestroy");
	}
}