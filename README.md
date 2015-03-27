# DeviceBmp v0.1.0

*EXIF aware AS3 AIR class to obtain image bitmapdata via CameraUI or CameraRoll on mobile 
or file browse on desktop*

For use in AIR mobile and desktop applications.

The image will read any associated EXIF information from the bitmap and the result will be 
automatically rotated to eye-oriented angle.

Also contains some static bitmap manipulation methods that can be called stand-alone.

Documentation
-------------

```as3
DeviceBmp(source:uint, onSuccess:Function, onCancel:Function, onError:Function, destinationBounds:Rectangle = null, resizeMode:uint = 0, hiQualityScaling:Boolean = true, sourceFallbackEnabled:Boolean = true, allowUpscale:Boolean = false) {
```		

- `source`  
  *Type: uint constant  
  `DeviceBmp.RESIZE_MODE_LETTERBOX`  
  `DeviceBmp.RESIZE_MODE_NOGAPS`  
  `DeviceBmp.RESIZE_MODE_FIT_WIDTH`  
  `DeviceBmp.RESIZE_MODE_FIT_HEIGHT`*  
  *Required: Yes*  
  The source to obtain the bitmap		
- `onSuccess`    
  *Type: Function, Required: Yes*  
  Called on successfull completion with one result arg of type `BitmapData`		
- `onCancel`    
  *Type: Function, Required: Yes*  
  Called when user cancels with no args		
- `onError`  
  *Type: Function, Required: Yes*  
  Called when error is encoutered with one message arg of type `String`		
- `destinationBounds`  
  *Type: Boolean, Required: No, Default: null*  
  Optionally scale bitmap during processing to these bounds		
- `resizeMode`  
  *Type: uint constant  
  `DeviceBmp.RESIZE_MODE_LETTERBOX`  
  `DeviceBmp.RESIZE_MODE_NOGAPS`  
  `DeviceBmp.RESIZE_MODE_FIT_WIDTH`  
  `DeviceBmp.RESIZE_MODE_FIT_HEIGHT`*  
  *Required: No, Default: `DeviceBmp.RESIZE_MODE_LETTERBOX`*  
  How to resize the source bitmap relative to |destinationBounds|			
- `hiQualityScaling`  
  *Type: Boolean, Required: No, Default: true*  
  Set the quality of scaling processes		
- `sourceFallbackEnabled`  
  *Type: Boolean, Required: No, Default: true*  
  If camera not present will offer camera roll browse on mobile		
- `allowUpscale`  
  *Type: Boolean, Required: No, Default: false*  
  Whether to allow upscaling during scaling processes	
  
**Usage:**

```as3  

import devicebmp.DeviceBmp;

// ...

var deviceBmp:DeviceBmp;

private function getBitmapOffDevice():void {

	deviceBmp = new DeviceBmp(DeviceBmp.SOURCE_CAMERA, onDeviceBmpSuccess, onDeviceBmpCancel, onDeviceBmpError, new Rectangle(0.0,0.0,128,128), DeviceBmp.RESIZE_MODE_NOGAPS, true, true, false);
	
}

private function onDeviceBmpCancel():void {
	
	disposeDeviceBmp();
	
}

private function onDeviceBmpSuccess(bmpData:BitmapData):void {
	
	disposeDeviceBmp();
	
	trace('Got bitmap ' + bmpData.width + 'x' + bmpData.height + ' bmp');
	
}

private function onDeviceBmpError(msg:String):void{

	disposeDeviceBmp();
	
	trace('Error: ' + msg);

}

// Clean up
// --------

private function disposeDeviceBmp():void {

	if (deviceBmp != null){
		deviceBmp.dispose();
		deviceBmp = null;
	}
	
}

override public function dispose():void {
		
		disposeDeviceBmp();
		
		super.dispose();
}
	
```

### Release History ###

- v0.1.0 - First release. Tested with AIR 17 / iOS / Mac desktop.