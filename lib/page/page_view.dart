import 'package:flutter/material.dart';
import 'package:flutter_render_world/label/layout.dart';
import 'package:flutter_render_world/label/layout_compat.dart';
import 'package:flutter_render_world/label/view.dart';
import 'package:flutter_render_world/label/widgets.dart';
import 'package:flutter_render_world/page/page.dart';

class LoginPage extends Page {
	final String tag = "LoginPage";
	int _index = 0;
	TextView _textView;

	@override
	void onCreate() {
		super.onCreate();
		print("$tag:onCreate");
		setContentView(getContentView());

		_textView = findViewById(ID('loginBtn'));
		_textView?.clickListener = (v) {
			_index ++;
			_textView.setText("LoginPage Click[${_index})]");
			if (_index > 5) {
				PageIntent intent = PageIntent()
					..router = 'main'
					..routerFlag = RouterFlag.standard;

				start(intent);
				_index = 0;
				_textView.setText("LoginPage");
			}
		};
	}

	View getContentView() => FrameLayout(SizeSpec.matchParent(), SizeSpec.matchParent())
		..background = Colors.blue
		..children = [
			TextView(SizeSpec.wrapContent(), SizeSpec.wrapContent())
				..id = ID('loginBtn')
				..padding = EdgeInsets.fromLTRB(10, 5, 10, 5)
				..background = Colors.white
				..margin = EdgeInsets.only(top: 50)
				..message = "LoginPage"
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
		View contentView = LinearLayout.vertical(SizeSpec.matchParent(), SizeSpec(500))
			..padding = EdgeInsets.fromLTRB(10, 5, 10, 5)
			..background = Colors.grey
			..children = [
				RelativeLayout(SizeSpec.matchParent(), SizeSpec.wrapContent())
					..background = Colors.grey
					..padding = EdgeInsets.fromLTRB(10, 5, 10, 5)
					..children = [
						View<RelativeLayoutParams>(SizeSpec(50), SizeSpec(50))
							..background = Colors.cyan
							..layoutParams = RelativeLayoutParams([])
							..id = ID('head'),
						TextView<RelativeLayoutParams>(SizeSpec.matchParent(), SizeSpec.wrapContent())
							..id = ID('name')
							..message = 'Name'
							..background = Colors.amber
							..margin = EdgeInsets.only(left:10, top:10)
							..layoutParams = RelativeLayoutParams([
								RelativeRule.toRightOf(ID('head')),
							]),

					],
				LinearLayout.vertical(
					SizeSpec.matchParent(), SizeSpec.matchParent())
					..background = Colors.yellow
					..contentGravity = LayoutGravity(x: Gravity.center)
					..children = [
						TextView(SizeSpec.matchParent(), SizeSpec.wrapContent())
							..id = ID('btn')
							..margin = EdgeInsets.only(top: 10, bottom: 10)
							..message = "This is ${tag}Page!"
							..background = Colors.red
							..style = TextStyle(color: Colors.cyan, fontSize: 30),
						TextView(SizeSpec.matchParent(), SizeSpec.wrapContent())
							..id = ID('btn')
							..margin = EdgeInsets.only(top: 10, bottom: 10)
							..message = "This is ${tag}Page!"
							..background = Colors.red
							..style = TextStyle(color: Colors.cyan, fontSize: 30),
						TextView(SizeSpec.matchParent(), SizeSpec.wrapContent())
							..id = ID('btn')
							..margin = EdgeInsets.only(top: 10, bottom: 10)
							..message = "This is ${tag}Page!"
							..background = Colors.red
							..style = TextStyle(color: Colors.cyan, fontSize: 30),
						TextView(SizeSpec.matchParent(), SizeSpec.wrapContent())
							..id = ID('btn')
							..margin = EdgeInsets.only(top: 10, bottom: 10)
							..message = "This is ${tag}Page!"
							..background = Colors.red
							..style = TextStyle(color: Colors.cyan, fontSize: 30),
						TextView(SizeSpec.matchParent(), SizeSpec.wrapContent())
							..id = ID('btn')
							..margin = EdgeInsets.only(top: 10, bottom: 10)
							..message = "This is ${tag}Page!"
							..background = Colors.red
							..style = TextStyle(color: Colors.cyan, fontSize: 30),
						TextView(SizeSpec.matchParent(), SizeSpec.wrapContent())
							..id = ID('btn')
							..margin = EdgeInsets.only(top: 10, bottom: 10)
							..message = "This is ${tag}Page!"
							..background = Colors.red
							..style = TextStyle(color: Colors.cyan, fontSize: 30),
						TextView(SizeSpec.matchParent(), SizeSpec.wrapContent())
							..id = ID('btn')
							..message = "This is ${tag}Page!"
							..background = Colors.red
							..style = TextStyle(color: Colors.cyan, fontSize: 30),
						TextView(SizeSpec.matchParent(), SizeSpec.wrapContent())
							..id = ID('btn')
							..message = "This is ${tag}Page!"
							..background = Colors.red
							..style = TextStyle(color: Colors.cyan, fontSize: 30),
						TextView(SizeSpec.matchParent(), SizeSpec.wrapContent())
							..id = ID('btn')
							..message = "This is ${tag}Page!"
							..background = Colors.red
							..style = TextStyle(color: Colors.cyan, fontSize: 30),
						TextView(SizeSpec.matchParent(), SizeSpec.wrapContent())
							..id = ID('btn')
							..message = "This is ${tag}Page!"
							..background = Colors.red
							..style = TextStyle(color: Colors.cyan, fontSize: 30),
						TextView(SizeSpec.matchParent(), SizeSpec.wrapContent())
							..id = ID('btn')
							..message = "This is ${tag}Page!"
							..background = Colors.red
							..style = TextStyle(color: Colors.cyan, fontSize: 30),
						TextView(SizeSpec.matchParent(), SizeSpec.wrapContent())
							..id = ID('btn')
							..margin = EdgeInsets.only(top: 10, bottom: 10)
							..message = "This is ${tag}Page!"
							..background = Colors.red
							..padding = EdgeInsets.fromLTRB(20, 10, 20, 10)
							..style = TextStyle(color: Colors.cyan, fontSize: 30),

					]
			];
		setContentView(contentView);
		findViewById(ID('btn')).clickListener = (v) {
			print('${tag}Page click!');
			(v as TextView).setText('${tag}Page is Finish');
			finish();
		};
	}

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