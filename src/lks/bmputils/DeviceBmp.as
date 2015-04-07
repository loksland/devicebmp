package lks.bmputils {
	
	import flash.display.Loader;
	import flash.media.CameraUI;
	import flash.media.MediaType;
	import flash.media.MediaPromise;
	import starling.core.Starling;
	import flash.display.BitmapData;
	import jp.shichiseki.exif.ExifInfo;
	import jp.shichiseki.exif.IFD;
	import flash.utils.ByteArray;
	import flash.utils.IDataInput;
	import flash.net.URLRequest;
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	import flash.media.CameraRoll;
	import flash.media.CameraRollBrowseOptions;
	import flash.events.Event;
	import flash.events.MediaEvent;
	import flash.events.ErrorEvent;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	import flash.events.ProgressEvent;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import jp.shichiseki.exif.ExifUtils;
	import jp.shichiseki.exif.ExifLoader;
	import flash.geom.Matrix;
	import flash.system.Capabilities;
			
	public class DeviceBmp {
		
		public static const SOURCE_CAMERA:uint = 0;
		public static const SOURCE_BROWSE:uint = 1;

		private var onSuccess:Function;
		private var onCancel:Function;
		private var onError:Function;
		
		private var imageLoader:Loader; 
		//private var exifBytes:ByteArray;
		private var mediaPromise:MediaPromise;
		private var exifLoader:ExifLoader;
		private var exifInfo:ExifInfo
		
		private var outputOptions:Array;
		
		//- `source`  
		//  *Type: uint constants `DeviceBmp.RESIZE_MODE_LETTERBOX`, `DeviceBmp.RESIZE_MODE_NOGAPS`, `DeviceBmp.RESIZE_MODE_FIT_WIDTH`, `DeviceBmp.RESIZE_MODE_FIT_HEIGHT`*
		//  *Required: Yes*  
		//  The source to obtain the bitmap
		
		//- `onSuccess`    
		//  *Type: Function, Required: Yes*  
		//  Called on successfull completion with one result arg of type `BitmapData`
		
		//- `onCancel`    
		//  *Type: Function, Required: Yes*  
		//  Called when user cancels with no args
		
		//- `onError`  
		//  *Type: Function, Required: Yes*  
		//  Called when error is encoutered with one message arg of type `String`
		
		//- **|sourceFallbackEnabled|**  
		//  *Type: Boolean, Required: No, Default: true*  
		//  If camera not present will offer camera roll browse on mobile
		
		//- `allowUpscale`  
		//  *Type: Boolean, Required: No, Default: false*  
		//  Whether to allow upscaling during scaling processes	
		
		public function DeviceBmp(source:uint, $onSuccess:Function, $onCancel:Function, $onError:Function, sourceFallbackEnabled:Boolean = true, ... $outputOptions:Array) {
		
			onSuccess = $onSuccess;
			onCancel = $onCancel;
			onError = $onError;
			
			if ($outputOptions && $outputOptions.length == 1 && $outputOptions[0] is Array){				
				$outputOptions = $outputOptions[0];
			}
			
			outputOptions = $outputOptions;
			
			if(source == SOURCE_CAMERA && CameraUI.isSupported) {
                
				var cameraUI:CameraUI = new CameraUI();
				cameraUI.addEventListener(MediaEvent.COMPLETE, onPhotoComplete, false, 0, true);
				cameraUI.addEventListener(Event.CANCEL, onCaptureCancelled, false, 0, true);
				cameraUI.addEventListener(ErrorEvent.ERROR, onCameraError, false, 0, true);
				cameraUI.launch(MediaType.IMAGE);
				
			} else if ((source == SOURCE_BROWSE || sourceFallbackEnabled) && CameraRoll.supportsBrowseForImage) {
				
				//var crOpts:CameraRollBrowseOptions = new CameraRollBrowseOptions();
				//crOpts.height = this.stage.stageHeight / 3;
				//crOpts.width = this.stage.stageWidth / 3;
				//crOpts.origin = new Rectangle(e.target.x, e.target.y, e.target.width, e.target.height);
				var cameraRoll:CameraRoll = new CameraRoll();
				cameraRoll.addEventListener(MediaEvent.SELECT, onPhotoComplete);
				cameraRoll.addEventListener(Event.CANCEL, onCaptureCancelled, false, 0, true);
				cameraRoll.addEventListener(ErrorEvent.ERROR, onCameraError, false, 0, true);
				cameraRoll.browseForImage();
				
			} else if (Capabilities.playerType.toLowerCase().indexOf("desktop") != -1){
				
				var picDir:File;
				if (File.userDirectory.resolvePath("Pictures").exists){
					
					picDir = File.userDirectory.resolvePath("Pictures");
					
				} else if (File.userDirectory.resolvePath("My Pictures").exists){
					
					picDir = File.userDirectory.resolvePath("My Pictures");
					
				} else {
					
					picDir = File.userDirectory;
					
				}
				picDir.addEventListener(Event.SELECT, onImageSelected, false, 0, true);
				picDir.addEventListener(Event.CANCEL, onCaptureCancelled, false, 0, true);
				picDir.browseForOpen("Choose a picture", [new FileFilter("JPEGs", "*.jpg;*.jpeg")]);
			}
			
		}
		
		// Desktop only
		private function onImageSelected(event:Event):void {
			
			var picDir:File = event.target as File;			
			picDir.removeEventListener(Event.SELECT, onImageSelected);
			picDir.removeEventListener(Event.CANCEL, onCaptureCancelled);
			
			var pic:File = event.target as File;
			pic.removeEventListener(Event.SELECT, onImageSelected);
			var fs:FileStream = new FileStream();
			fs.open(pic, FileMode.READ);
			//var eb:ByteArray = this.getExifBytes(fs);

			var imageBytes = new ByteArray()			
			IDataInput(fs).readBytes(imageBytes)  //
			
			fs.close();
			//this.parse(eb);
			
			loadImageAsByteArray(imageBytes);
			//var picURLRequest:URLRequest= new URLRequest(pic.url);
			//loadImageAsMediaPromiseOrURL(picURLRequest);
		}
			
		private function throwError(msg:String):void {
			
			if (onError != null){
				onError(msg);
			}
			
		}
		
		// CameraUI or CameraRoll
		private function onCaptureCancelled( event:Event ):void {
				trace('onCaptureCancelled()');
			if (onCancel != null){
			  onCancel();
			}

		}
		
		// CameraUI or CameraRoll
		private function onCameraError(error:ErrorEvent):void {
			
			throwError('An error has occurred');
			
		}
		
		// CameraUI or CameraRoll
		private function onPhotoComplete(event:MediaEvent):void {
			
			var cameraRollOrCameraUI:EventDispatcher = event.target as EventDispatcher;
			cameraRollOrCameraUI.removeEventListener(MediaEvent.COMPLETE, onPhotoComplete);
			cameraRollOrCameraUI.removeEventListener(MediaEvent.SELECT, onPhotoComplete);
			cameraRollOrCameraUI.removeEventListener(Event.CANCEL, onCaptureCancelled);
			cameraRollOrCameraUI.removeEventListener(ErrorEvent.ERROR, onCameraError);
			mediaPromise = event.data;
			
			//dataSource = mediaPromise.open();  // STILL NEED THIS?
			
			exifLoader = new ExifLoader();
			exifLoader.addEventListener(Event.COMPLETE, onExifCompleteHandler, false, 0, true);
			exifLoader.addEventListener(IOErrorEvent.IO_ERROR, onExifError, false, 0, true);
			exifLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onExifError, false, 0, true);
			
			if (mediaPromise.file != null){
			
				exifLoader.load(new URLRequest(mediaPromise.file.url));
				
			} else {
				
				//loadImageAsMediaPromiseOrURL();
				
				if (this.mediaPromise.isAsync){		
					
					var mediaDispatcher:IEventDispatcher = this.mediaPromise.open() as IEventDispatcher;
					//this.exifBytes = new ByteArray();
					mediaDispatcher.addEventListener(Event.COMPLETE, onAsynMediaPromiseLoaded);					
					//mediaDispatcher.addEventListener(ProgressEvent.PROGRESS, onMediaPromiseProgress);
				} else {
					// NOTE: Untested
					var input:IDataInput = mediaPromise.open();
					
					// get the bytes
					var imageBytes:ByteArray = new ByteArray();
					input.readBytes(imageBytes);
					
					loadImageAsByteArray(imageBytes);
					
				}
			}
		}
		
		private function onAsynMediaPromiseLoaded(e:Event):void {
			
			var input:IDataInput = e.target as IDataInput;
			
			var imageBytes:ByteArray = new ByteArray();
			input.readBytes(imageBytes);
			
			loadImageAsByteArray(imageBytes);
			
		}
		
		public function onExifError(event:Event): void {
			
			loadImageAsMediaPromise();
			
		}
		
		//3. once Exif data is available, use loader to obviously load mediaPromised found in step 2
		private function onExifCompleteHandler(event:Event):void {
			
			exifInfo = exifLoader.exif;
			loadImageAsMediaPromise();
			
		}
		
		// Load image
		// ----------
		
		private function loadImageAsByteArray(imageBytes:ByteArray):void {
					
			exifInfo = new ExifInfo(imageBytes);
			debugExifInfo(exifInfo);
			
			imageLoader = new Loader();
			imageLoader.addEventListener(IOErrorEvent.IO_ERROR, onImageNotFound, false, 0, true);
			imageLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onImageLoadSecurityError, false, 0, true);
			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onMediaPromiseImageLoaded, false, 0, true);
			imageLoader.loadBytes(imageBytes);
		}	
		
		private function loadImageAsMediaPromise():void { //eOrURL(urlRequest:URLRequest = null):void {
			
			imageLoader = new Loader();
			imageLoader.addEventListener(IOErrorEvent.IO_ERROR, onImageNotFound, false, 0, true);
			imageLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onImageLoadSecurityError, false, 0, true);
			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onMediaPromiseImageLoaded, false, 0, true);
			imageLoader.loadFilePromise(mediaPromise);
			
		}

		private function onMediaPromiseImageLoaded(e:Event):void {
			var bitmap:Bitmap = e.currentTarget.content as Bitmap;
			if (bitmap == null){
				trace('WARNING bmp is NULL');
			}
			onBitmap(bitmap);
		}
		
		private function onBitmap(bitmap:Bitmap):void {
			
			var bmpdata:BitmapData = bitmap.bitmapData;
			bitmap = null;
						
			if (exifInfo != null && exifInfo.ifds != null && exifInfo.ifds.primary != null){
				
				if (exifInfo.ifds.primary != null && exifInfo.ifds.exif != null && exifInfo.ifds.primary['Orientation'] == null && exifInfo.ifds.exif['PixelXDimension'] != null && exifInfo.ifds.exif['PixelYDimension'] != null){
					
					// Experimental feature. Found some images (from Picassa) were missing 'Orientation' tag
					var pxX:Number = Number(exifInfo.ifds.exif['PixelXDimension']);
					var pxY:Number = Number(exifInfo.ifds.exif['PixelYDimension']);
					if (!isNaN(pxX) && !isNaN(pxY)){
						if (pxX != pxY){
							if ((pxY > pxX && bmpdata.width > bmpdata.height) || (pxY < pxX && bmpdata.width < bmpdata.height)){								
								
								var tmpBitmapdata:BitmapData = BmpUtils.rotateBmpData(bmpdata, 90);
								bmpdata.dispose();
								bmpdata = null;
								bmpdata = tmpBitmapdata;
							}
						}
					}
					
				} else {
				
					//var rotation:int = ExifUtils.getEyeOrientedAngle(exifInfo.ifds);	
					var tmpBitmap = new Bitmap(bmpdata);
					
					var rotatedBitmap:Bitmap = ExifUtils.getEyeOrientedBitmap(tmpBitmap, exifInfo.ifds);
					tmpBitmap.bitmapData.dispose();
					tmpBitmap = null;
					
					bmpdata = rotatedBitmap.bitmapData;
					rotatedBitmap = null;
				
				}
			} 
			
			var result:Vector.<BitmapData> = BmpUtils.scaleBmpDataWithMultipleOptions(bmpdata, outputOptions);
			bmpdata.dispose();
			
			if (result && result.length > 0){
				onSuccess(result);
			} else {
				throwError('Unable to save image');
			}
		}
		
		private function onImageNotFound(e:ErrorEvent):void {
			
			throwError('Unable to open image');
		}		
		
		private function onImageLoadSecurityError(e:ErrorEvent):void {

			throwError('Unable to load image');
			
		}	
		
		// Debug
		// -----
		
		private function debugExifInfo(exifInfo:ExifInfo){
			
			if (exifInfo != null && exifInfo.ifds != null){
				trace('\n\n')
				if (exifInfo.ifds.primary != null){
					trace('primary:');				
					this.iterateTags(exifInfo.ifds.primary);
				}
				if (exifInfo.ifds.exif != null){
					trace('exif:');
					this.iterateTags(exifInfo.ifds.exif);
				}
				if (exifInfo.ifds.gps != null){
					trace('gps:');
					this.iterateTags(exifInfo.ifds.gps);
				}
				if (exifInfo.ifds.interoperability != null){
					trace('interoperability:');
					this.iterateTags(exifInfo.ifds.interoperability)
				}
				if (exifInfo.ifds.thumbnail != null){
					trace('thumbnail:');
					this.iterateTags(exifInfo.ifds.thumbnail);
				}
				trace('\n\n');
			}
		}
		private function iterateTags(ifd:IFD):void {
			
			if (!ifd) return;
			for (var entry:String in ifd) {
				if (entry == "MakerNote") continue;
				trace(entry + ": " + ifd[entry]);
			}
		}
		
		// Dispose
		// -------
	
		public function dispose():void {
			
			if (mediaPromise != null){

				try {
					mediaPromise.close()
				} catch( exc ) {
					//Do nothing
				}
				
				mediaPromise = null;
			}
			
			if (exifLoader != null){
				
				try {
					exifLoader.close()
				} catch( exc ) {
					//Do nothing
				}
				
				exifLoader.addEventListener(Event.COMPLETE, onExifCompleteHandler);
				exifLoader.addEventListener(IOErrorEvent.IO_ERROR, onExifError);
				exifLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onExifError);
				exifLoader = null;
			}
			
			if (imageLoader != null){	
				
				try {
					imageLoader.close()
				} catch( exc ) {
					//Do nothing
				}
				//imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onUrlRequestImageLoaded);
				imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onMediaPromiseImageLoaded);
				
				imageLoader.addEventListener(IOErrorEvent.IO_ERROR, onImageNotFound);
				imageLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onImageLoadSecurityError);
				imageLoader = null;
			}
			
			//dataSource = null;			
			onSuccess = null;
			onCancel = null;
			onError = null;			
			
		}
		

	}
}