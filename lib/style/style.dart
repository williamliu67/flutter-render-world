/*
///样式是用来修饰标签的
///样式分为如下两种：
///1.布局样式
///     主要用来renderEngine栅格化的时候，确认标签的大小及位置
///2.内容装饰
///     主要用来renderEngine绘制时，每个标签内部的具体表现  例如 Text中文字的大小、颜色...
///内容装饰的样式是可以继承的
///样式的引用有三种模式
///1.style文件引用  优先级->1
///2.父标签继承过来的内容装饰样式 优先级->100
///3.标签内部style下的样式   优先级->10000
///
/// 样式组 StyleSheet
/// 每个页面可以设置设置页面样式，设置方式有两种：
/// 【1】.通过路由路径进行引用  styleSheet.path('之前在StyleSheetContext注册的路径')
/// 【2】.直接创建 page.styleSheet = [StyleSheet1, StyleSheet2,...)]
/// 样式选择器提供样式查找功能，所以需要StyleSheetContext提供这个查找功能
/// 每个StyleSheet都拥有一个StyleSheetContext
///
/// 样式组的定义有ID，name，label三种
/// 【ID】：整个StyleSheetContext中，不能有ID重复的StyleSheet，如果出现了ID重复，则一次进行覆盖，
///        覆盖原则是通过StyleSheetContext.style设置的优先级要高于通过path引用的，且后面出现的覆盖前面出现的
/// 【name】：通过名字命名的
///
///================================
///样式在各个平台下的多态            ||
///================================
///原理：
///     样式的绘制主要通过RenderEngine的各个平台的实现类去绘制
///RenderEngine会实现style中定义的所有样式的绘制，且是根据不同标签所在的层级进行绘制
///     为了兼容各个平台，需要自定义Canvas，然后各个平台去实现Canvas的绘制动作
///

/// 标签样式处理的mixin
abstract class StyleExtendsBehavior{
	///标签通过clazz引用外部定义好的标签样式列表，
	List<StyleSheet> styleSheets;
	///标签通过style定义的样式列表
	List<Style> styles;
	///父标签继承过来的样式
	List<Style> parentContentStyles;

	///标签的内容样式
	List<Style> contentStyles;
	///标签的布局样式
	List<Style> layoutStyles;
	///计算出此标签当前内容支出的样式，不包含子标签
	List<Style> contentSelfStyles;

	List<int> _supportStyleTypes;

	initStyles(List<StyleSheet> styleSheets, List<Style> styles, List<int> supportStyleTypes){
		_supportStyleTypes = List();
		_supportStyleTypes.addAll(supportStyleTypes);
		//TODO 通过StyleSheetContext获取此标签支持的StyleSheet

	}


	///当给标签设置父标签时，要继承父标签的content样式，然后跟本身的content样式进行合并
	set parentStyles(List<Style> parentContentStyles){
		for(int i = 0, n = parentContentStyles.length; i < n; i++){
			Style style = parentContentStyles[i];
			///布局样式无法继承过来
			if(layoutStyles.contains(style.type)){
				continue;
			}
			///看该样式的样式约束，是否允许此标签进行继承

			///父布局继承过来的样式优先级要低，所以，如果子标签已有此样式，则不进行继承
			if(contentStyles.contains(style)){
				continue;
			}

			contentStyles.add(style);
		}
	}
}

///此处定义标签选择器

class StyleSheetContext{
	///通过路由路径注册进来的
	static Map<String, List<StyleSheet>> _globalStyleSheets = Map();

	///通过静态注册的方式，把一组样式注册到全局，以供外部引用
	static registerStyleSheets(String router, List<StyleSheet> styleSheets){
		_globalStyleSheets[router] = styleSheets;
	}

	List<StyleSheet> _styleSheet;
	List<StyleSheet> _importStyles;
	List<StyleSheet> _contextStyles;

	StyleSheetContext():
				_styleSheet = List(),
				_importStyles = List();

	set import(List<String> routers) {
		for (String router in routers) {
			if (!_globalStyleSheets.containsKey(router)) {
				continue;
			}
			///开始于之前通过path方法合并的StyleSheet进行覆盖合并
			List<StyleSheet> styleSheet = _globalStyleSheets[router];
			_mergeStyleSheet(_importStyles, styleSheet);
		}
	}

	set style(List<StyleSheet> styleSheets){
		_mergeStyleSheet(_styleSheet, styleSheets);
	}

	_mergeStyleSheet(List<StyleSheet> targetStyleSheets, List<StyleSheet> styleSheets){
		for(int i = 0, n = styleSheets.length; i < n; i++){
			StyleSheet sheet = styleSheets[i];
			for(int j = 0, m = targetStyleSheets.length; j < m; j++){
				StyleSheet item = targetStyleSheets[j];

				///比较ID是否一致
				if(item.filter.startsWith("#") && sheet.filter.startsWith("#") && item.filter == sheet.filter){
					///后出现的覆盖前出现的
					targetStyleSheets[i] = sheet;
					continue;
				}
				///比较名字是否一致 TODO 后续需要支持样式选择器
				if(item.filter.startsWith(".") && sheet.filter.startsWith(".") && item.filter == sheet.filter){
					///其实这里还需要比较样式选择器产生的样式filter是否一致，因为虽然名字一样，但是样式选择器不一样，也是可以存在的
					///后出现的覆盖前出现的
					targetStyleSheets[i] = sheet;
					continue;
				}
				///比较修饰的标签是否一致 TODO 后续需要支持样式选择器
				if(item.filter == sheet.filter){
					///其实这里还需要比较样式选择器产生的样式filter是否一致，因为虽然修饰的标签一样，但是样式选择器不一样，也是可以存在的
					///后出现的覆盖前出现的
					targetStyleSheets[i] = sheet;
					continue;
				}
				targetStyleSheets.add(sheet);
			}
		}
	}

	void mergeAllStyle(){
		_mergeStyleSheet(_contextStyles, _importStyles);
		_mergeStyleSheet(_contextStyles, _styleSheet);
	}
}

///一组样式
class StyleSheet{
	List<Style> styles;
	String filter;

	StyleSheet(this.filter);

	///相当于StyleSheet('#nav');
	StyleSheet.id(String id): filter = "#" + id;

	///相当于StyleSheet('.name')
	StyleSheet.name(String name): filter = "." + name;

	///相当于StyleSheet('label')
	StyleSheet.label(String label): filter = label;


	///定义该标签的所有后代标签的样式
	///当StyleSheet出现此操作符的时候，此标签就成了
	operator > (String filter){
		return StyleSheet(filter);
	}

	set style(List<Style> styles) => this;
}

///样式选择器约束
class StyleChildConstraints{

}

styleTest(){
	StyleSheetContext.registerStyleSheets('nav', [

	]);


	StyleSheetContext()
		..import=['nav']
		..style = [
				StyleSheet.id('.nav')
					..style = [Width.matchParent(), Height(46), Padding(10, 0, 0, 10)]
		];
}

class StyleType{
	static const List<int> layoutTypes = [
		width, height, padding, margin, border
	];

	static const List<int> contentTypes = [
		background_color, background_image
	];

	///===============Layout布局样式==================
	static const int group_box = 1;
	///宽
	static const int width = 1;
	///高
	static const int height = 2;
	///内边距
	static const int padding = 3;
	///外边距
	static const int margin = 4;
	///边框
	static const int border = 5;
	///================End=================

	///===============Content内容装饰==================
	///背景
	static const int group_background = 2;
	static const int background_color = 1;
	static const int background_image = 2;
	///文本
	static const int group_font = 3;
	static const int font_size = 1;
	static const int font_color = 2;
	static const int font_family = 3;
	static const int text_indent = 4;
	static const int text_align = 5;
	static const int word_spacing = 6;
	static const int letter_spacing = 7;
	static const int text_transform = 8;
	static const int text_decoration = 9;
	static const int font_line_height = 10 ;
	///布局
	static const int group_display = 4;
	static const int display = 1;

}

abstract class Style {
	///样式类别
	int group;
	int type;
	bool canExtends;

	Style(this.group, this.type,{this.canExtends:false});
}

///布局属性开始---------------------------
class Width extends Style {
	int unit;///长度党委
	int width;
	int layoutType;///像素单位

	Width(this.width) : unit = Unit.AUTO, layoutType = SizeSpec.EXACTLY, super(StyleType.group_box, StyleType.width);

	Width.px(this.width) : unit = Unit.PX, layoutType = SizeSpec.EXACTLY, super(StyleType.group_box, StyleType.width);

	Width.warpParent(): layoutType = SizeSpec.UNSPECIFIED, super(StyleType.group_box, StyleType.width);

	Width.matchParent(): layoutType = SizeSpec.AT_MOST, super(StyleType.group_box, StyleType.width);
}

class Height extends Style {
	int unit;///长度党委
	int height;
	int layoutType;///像素单位

	Height(this.height) : unit = Unit.AUTO, layoutType = SizeSpec.EXACTLY, super(StyleType.group_box, StyleType.height);

	Height.px(this.height) : unit = Unit.PX, layoutType = SizeSpec.EXACTLY, super(StyleType.group_box, StyleType.height);

	Height.warpParent(): layoutType = SizeSpec.UNSPECIFIED, super(StyleType.group_box, StyleType.height);

	Height.matchParent(): layoutType = SizeSpec.AT_MOST, super(StyleType.group_box, StyleType.height);
}

class Padding extends Style {
	int left;
	int top;
	int right;
	int bottom;

	Padding.all(int padding):
				left = padding,
				top = padding,
				right = padding,
				bottom = padding,
				super(StyleType.group_box, StyleType.padding);

	Padding(this.left, this.top, this.right, this.bottom)
			:super(StyleType.group_box, StyleType.padding);
}

class Margin extends Style {
	int left;
	int top;
	int right;
	int bottom;

	Margin.all(int padding):
				left = padding,
				top = padding,
				right = padding,
				bottom = padding,
				super(StyleType.group_box, StyleType.margin);

	Margin(this.left, this.top, this.right, this.bottom)
			:super(StyleType.group_box, StyleType.margin);
}

class Border extends Style {
	int radiusLeftTop;
	int radiusLeftBottom;
	int radiusRightTop;
	int radiusRightBottom;

	Color color;

	///边框宽度
	int width;

	Border(int radius, Color color, int width):
				radiusLeftTop = radius,
				radiusRightTop = radius,
				radiusLeftBottom = radius,
				radiusRightBottom = radius,
				color = color,
				width = width,
				super(StyleType.group_box, StyleType.border);
}
///布局属性结束---------------------------

///内容修饰属性----Background
class BackgroundColor  extends Style{
	Color color;

	BackgroundColor(this.color):super(StyleType.group_background, StyleType.background_color);
}

class BackgroundImage extends Style{
	String url;
	RepeatMode repeatMode;
	///TODO 背景position还未支持
	BackgroundImage(this.url, {this.repeatMode:RepeatMode.NoRepeat}):
				super(StyleType.group_background, StyleType.background_image);
}

///内容修饰属性----文本
class FontSize extends Style{
	int fontSize;
	int unit;///长度单委
	static final int _SMALL = 16;
	static final int _MEDIUN = 16;
	static final int _LARGE = 16;

	FontSize.small() :
				fontSize = _SMALL,
				super(StyleType.group_font, StyleType.font_size);

	FontSize.medium() :
				fontSize = _MEDIUN,
				super(StyleType.group_font, StyleType.font_size);

	FontSize.large() :
				fontSize = _LARGE,
				super(StyleType.group_font, StyleType.font_size);

	FontSize(this.fontSize, this.unit):super(StyleType.group_font, StyleType.font_size);
}

///文本字体颜色
class FontColor extends Style{
	Color color;

	FontColor(this.color):super(StyleType.group_font, StyleType.font_color);
}

///文本字体
class FontFamily extends Style{
	String fontFamily;
	///TODO 字体默认路径
	String path;

	FontFamily(this.fontFamily, {this.path}):super(StyleType.group_font, StyleType.font_family);

	FontFamily.Serif():
			fontFamily = 'Serif',
			super(StyleType.group_font, StyleType.font_family);

	FontFamily.San_serif():
				fontFamily = 'San-serif',
				super(StyleType.group_font, StyleType.font_family);

	FontFamily.Monospace():
				fontFamily = 'Monospace',
				super(StyleType.group_font, StyleType.font_family);

	FontFamily.Cursive():
				fontFamily = 'Cursive',
				super(StyleType.group_font, StyleType.font_family);

	FontFamily.Fantasy():
				fontFamily = 'Fantasy',
				super(StyleType.group_font, StyleType.font_family);
}

///文本缩进
class TextIndent extends Style{
	int size;
	int unit;

	TextIndent(this.size, this.unit):super(StyleType.group_font, StyleType.text_indent);
}

///元素中文本行的水平对齐方式
class TextAlign extends Style{
	int _align = LEFT;

	static const int LEFT = 0;
	static const int CENTER = 0;
	static const int RIGHT = 0;

	TextAlign.left():super(StyleType.group_font, StyleType.text_align);

	TextAlign.center():
				_align = CENTER,
				super(StyleType.group_font, StyleType.text_align);

	TextAlign.right():
				_align = RIGHT,
				super(StyleType.group_font, StyleType.text_align);

	get align => _align;
}

///单词间隔，文本中，空格符前后为一个单词
class WordSpacing extends Style{
	int size;
	int unit;

	WordSpacing(this.size, this.unit):super(StyleType.group_font, StyleType.word_spacing);
}

///字间隔
class LetterSpacing extends Style{
	int size;
	int unit;

	LetterSpacing(this.size, this.unit):super(StyleType.group_font, StyleType.letter_spacing);
}

class TextTransform extends Style{
	int _transform = NONE;

	static const int NONE = 0;
	static const int LOWERCASE = 1;
	static const int UPPERCASE = 2;
	static const int CAPITALIZE = 3;

	///默认值，对文本不做任何处理
	TextTransform.none():_transform = NONE, super(StyleType.group_font, StyleType.text_transform);

	TextTransform.lowercase():_transform = LOWERCASE, super(StyleType.group_font, StyleType.text_transform);

	TextTransform.uppercase():_transform = UPPERCASE, super(StyleType.group_font, StyleType.text_transform);

	///只对每个单词的首字母大写
	TextTransform.capitalize():_transform = CAPITALIZE, super(StyleType.group_font, StyleType.text_transform);

	get textTransform => _transform;
}

class TextDecoration extends Style{
	int _decoration = NONE;

	static const int NONE = 0;
	static const int UNDERLINE = 1;
	static const int OVERLINE = 2;
	static const int LINE_THROUGH = 3;

	TextDecoration.none():super(StyleType.group_font, StyleType.text_decoration);

	TextDecoration.underLine():_decoration = UNDERLINE, super(StyleType.group_font, StyleType.text_decoration);

	TextDecoration.overLine():_decoration = OVERLINE, super(StyleType.group_font, StyleType.text_decoration);

	TextDecoration.lineThrough():_decoration = LINE_THROUGH, super(StyleType.group_font, StyleType.text_decoration);
}

///文字行高：上下两行baseline的距离
class FontLineHeight extends Style{
	int size;
	int unit;

	FontLineHeight(this.size, this.unit):super(StyleType.group_font, StyleType.font_line_height);
}

///Display用来制定布局方式，每个布局类型，有自己的布局参数会附加到子标签上
class Display extends Style{
	int _type;

	static const int LINEARLAYOUT = 0;
	static const int RELATIVELAOUT = 1;
	static const int FRAMELAYOUT = 2;

	///线性布局
	Display.linearLayout() : _type = LINEARLAYOUT, super(StyleType.group_display, StyleType.display);

	///相对布局
	Display.relativeLayout() : _type = RELATIVELAOUT, super(StyleType.group_display, StyleType.display);

	///层级布局
	Display.frameLayout() : _type = FRAMELAYOUT, super(StyleType.group_display, StyleType.display);
}

///===============辅助类===================
class Unit{
	///通过设定当前屏幕尺寸，来自动适配
	static const int AUTO = 0;
	///像素
	static const int PX = 1;
}

class SizeSpec{
	///确定的大小
	static const int EXACTLY = 0;
	///当前标签不知道要多大，类似于android的wrap_content
	static const int UNSPECIFIED = 1;
	///当前标签尽量要的大一点 类似于android的match_parent
	static const int AT_MOST = 1;
}

enum RepeatMode{
	Repeat, RepeatX, RepeatY, NoRepeat
}

class Color {
	String color;

	Color.string(this.color);

	Color.red();

	Color.white();

	Color.blue();

	Color.argb(int alpha, int r, int g, int b);
}

main(){
	StyleSheetContext.registerStyleSheets('user', [
		StyleSheet('#name')..style = [

		],
		StyleSheet.label('body') > 'div'..style = [
			Width(320), Height(320), Display.linearLayout()
		]

	]);


	StyleSheet.name('nav').style = [
		Width(320), Height(320)
	];

	///页面中会自带上下文，此处为了测试API
	StyleSheetContext styleSheetContext = null;
	styleSheetContext.import =['user'];
}*/
