import 'package:flutter/rendering.dart';
import 'package:flutter_render_world/label/widgets.dart';
import 'package:flutter_render_world/render/renderview.dart';

///TODO 设计Image
class RenderImageView extends RenderVue{
  ImageView imageView;
  RenderImage _image;
  ImageProvider _imageProvider;
  ImageStream _imageStream;
  ImageInfo _imageInfo;
  ImageChunkEvent _loadingProgress;
  bool _wasSynchronouslyLoaded;
  int _frameNumber;

  RenderImageView(this.imageView): super(imageView){
    _image = createRenderImageByImageViewConfig();
  }

  RenderImage createRenderImageByImageViewConfig() {
    ///TODO  ImageConfiguration  此处需要传递系统上下文Context
    _imageStream = _imageProvider.resolve(ImageConfiguration(
      bundle: null,
      devicePixelRatio: 0.0,
      locale: null,
      textDirection: null,
      size: size,
      platform: null
    ));
    ///TODO 设计RenderVue的生命周期，在适当的时机，将其remove掉
    _imageStream.addListener(ImageStreamListener(_handleImageFrame, onChunk: _handleImageChunkEvent, onError: _handleImageLoadError));
    return null;
  }

  Size onMeasure(double width, double height,
      BoxConstraints childBoxConstraints,
      bool parentUsesChildWidth, bool parentUsesChildHeight){
    _image.layout(childBoxConstraints, parentUsesSize: true);

    Size childSize = _image.size;

    if (parentUsesChildWidth) {
      width = childSize.width + imageView.margin.horizontal + imageView.padding.horizontal;
      width = width.clamp(constraints.minWidth, constraints.maxWidth);
    }
    if (parentUsesChildHeight) {
      height = childSize.height + imageView.margin.vertical + imageView.padding.vertical;
      height = height.clamp(constraints.minHeight, constraints.maxHeight);
    }

    return Size(width, height);
  }

  onDraw(PaintingContext context, Offset offset){
    offset = offset + Offset(imageView.padding.left, imageView.padding.top);
    context.paintChild(_image, offset);
  }

  void _handleImageFrame(ImageInfo imageInfo, bool synchronousCall) {
    _imageInfo = imageInfo;
    _loadingProgress = null;
    _frameNumber = _frameNumber == null ? 0 : _frameNumber + 1;
    _wasSynchronouslyLoaded |= synchronousCall;
  }

  void _handleImageChunkEvent(ImageChunkEvent event) {
    _loadingProgress = event;
    markNeedsPaint();
  }

  void _handleImageLoadError(dynamic exception, StackTrace stackTrace){}
}