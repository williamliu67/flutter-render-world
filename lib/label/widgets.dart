import 'package:flutter/rendering.dart';
import 'package:flutter_render_world/label/layout_compat.dart';
import 'package:flutter_render_world/label/view.dart';
import 'package:flutter_render_world/render/imageview.dart';
import 'package:flutter_render_world/render/textview.dart';

class ImageView<T extends LayoutParams> extends View{

	ImageView(SizeSpec width, SizeSpec height):super(width, height);

	@override
	RenderImageView createRenderBox() => RenderImageView(this);
}

class TextView<T extends LayoutParams> extends View{
	String _message;
	int maxLines;
	int maxLength = 999999999;
	TextStyle style;

	TextView(SizeSpec width, SizeSpec height):super(width, height);

	RenderTextView createRenderVue() => RenderTextView(this);

	set message(String content) => _message = content;

	String get message => maxLength >= 0 && _message.length > maxLength ? _message.substring(0, maxLength) : _message;

	void setText(String message) {
		_message = message;
		(renderVue as RenderTextView).updateContent();
	}
}