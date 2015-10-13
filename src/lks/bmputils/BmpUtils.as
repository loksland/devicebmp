package lks.bmputils {
	
	import flash.display.BitmapData;

	import lks.bmputils.BmpOutputOptions;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.geom.Matrix;
	
	public class BmpUtils {
		
		// Returns a NEW bitmapdata, so you will have to dispose of the |sourceBmpdata| yourself if you no longer need it.
		public static function scaleBmpDataWithMultipleOptions(sourceBmpdata:BitmapData,... multipleOptions:Array):Vector.<BitmapData>{
		
			if (multipleOptions && multipleOptions.length == 1 && multipleOptions[0] is Array){				
				multipleOptions = multipleOptions[0];
			}
			
			var result:Vector.<BitmapData> = new Vector.<BitmapData>(multipleOptions.length, true);

			for (var i:uint = 0; i < multipleOptions.length; i++){
					
				result[i] = scaleBmpData(sourceBmpdata, multipleOptions[i] as BmpOutputOptions);
				
			}
			
			return result;
			
		}
		
		// Returns a NEW bitmapdata, so you will have to dispose of the |sourceBmpdata| yourself if you no longer need it
		public static function scaleBmpData(sourceBmpdata:BitmapData, options:BmpOutputOptions):BitmapData {
			
			var workingBmp:BitmapData = sourceBmpdata.clone();
			
			if (!options.destinationBounds){
				return workingBmp;
			} 
			
			var scale:Number = BmpUtils.calculateScaleForOptions(new Rectangle(0.0,0.0,workingBmp.width,workingBmp.height), options)
			
			// If high quality, don't down scale any more than half at a time
			// this gets much better results
			
			var matrix:Matrix;
			var minDownscale:Number = options.hiQuality ? .5 : 0;
			var nextScale:Number;
			var interemDownscale:Boolean;
			var originalSourceDims:String = workingBmp.width + "x" + workingBmp.height;
			
			interemDownscale = true;
			var resizedBmpdata:BitmapData;
			
			while (interemDownscale){
			
				interemDownscale = false;
				
				if (scale < minDownscale){
					interemDownscale = true;
					nextScale = scale * (1/minDownscale)
					scale = minDownscale
				}
				
				matrix = new Matrix();
				matrix.scale(scale, scale);
				
				resizedBmpdata = new BitmapData(workingBmp.width * scale, workingBmp.height * scale, false, 0x000000);
				resizedBmpdata.draw(workingBmp, matrix, null, null, null, true);
				
				workingBmp.dispose();
				
				if (interemDownscale){
					workingBmp = resizedBmpdata;
					scale = nextScale;
				}
			}
			
			if (options.scaleMode == BmpScaleMode.CROP){
				
				var newBmpData:BitmapData;
				if (resizedBmpdata.width > options.destinationBounds.width){
					
					// Center origin.x
					newBmpData = BmpUtils.cropBitmapData(resizedBmpdata, new Point(Math.round(resizedBmpdata.width*0.5 - options.destinationBounds.width*0.5), 0.0), options.destinationBounds.width, options.destinationBounds.height);
					resizedBmpdata.dispose();
					return newBmpData;
					
				} else if (resizedBmpdata.height > options.destinationBounds.height){
					
					// Center origin.y
					newBmpData = BmpUtils.cropBitmapData(resizedBmpdata, new Point(0.0, Math.round(resizedBmpdata.height*0.5 - options.destinationBounds.height*0.5)), options.destinationBounds.width, options.destinationBounds.height);
					resizedBmpdata.dispose();
					return newBmpData;
					
				}
			}
			
			return resizedBmpdata;
		}
		
		// Returns a NEW bitmapdata, so you will have to dispose of the |sourceBmpdata| yourself if you no longer need it
		public static function cropBitmapData(sourceBitmapData:BitmapData, origin:Point, width:Number, height:Number):BitmapData {
			
			//trace('Cropping to ' + width + 'x' + height);
            var croppedBD:BitmapData = new BitmapData(width, height);
            croppedBD.copyPixels(sourceBitmapData, new Rectangle(origin.x, origin.y, width, height), new Point(0, 0));
			//trace('Cropped to ' + croppedBD.width + 'x' + croppedBD.height);
			return croppedBD;
			
        }
		
		// Returns a NEW bitmapdata, so you will have to dispose of the |sourceBmpdata| yourself if you no longer need it
		public static function rotateBmpData(sourceBmpdata:BitmapData, angle:Number):BitmapData {
			
			if (angle != 90 && angle != -90 && angle != 180){
				return null;
			}
			
			var m:Matrix = new Matrix();
			m.rotate(angle * (Math.PI / 180));
			var resultBmpdata:BitmapData
			if (angle == 90 || angle == -90){
				
				resultBmpdata = new BitmapData(sourceBmpdata.height, sourceBmpdata.width, false, 0x000000);
				
				if (angle == 90){
					m.translate(sourceBmpdata.height, 0);
				} else if (angle == -90){
					m.translate(0, sourceBmpdata.width);
				}
				
			} else if (angle == 180){
				
				resultBmpdata = new BitmapData(sourceBmpdata.width, sourceBmpdata.height, false, 0x000000);
				m.translate( sourceBmpdata.width, sourceBmpdata.height);
				
			}
			
			resultBmpdata.draw(sourceBmpdata, m, null, null, null, true);

			return resultBmpdata;
			
		}
		
		public static function calculateScaleForOptions(sourceBounds:Rectangle, options:BmpOutputOptions):Number {
			
			// If already fits within then no scaling required
			if (!options.allowUpscale &&
				sourceBounds.width <= options.destinationBounds.width && 
				sourceBounds.height <= options.destinationBounds.height){

				return 1;
					
			} else if (sourceBounds.width == options.destinationBounds.width && sourceBounds.height == options.destinationBounds.height){
				
				return 1;
				
			} 
			
			var srcRatio:Number = sourceBounds.width/sourceBounds.height;
			var destRatio:Number = options.destinationBounds.width/options.destinationBounds.height;
			
			var keepWidth:Boolean = false;
			
			if (options.scaleMode == BmpScaleMode.FIT_HEIGHT){
				keepWidth = false;
			} else if (options.scaleMode == BmpScaleMode.FIT_WIDTH){
				keepWidth = true;
			} else if (options.scaleMode == BmpScaleMode.LETTERBOX && srcRatio>=destRatio){
				keepWidth = true;
			} else if ((options.scaleMode == BmpScaleMode.NOGAPS || options.scaleMode == BmpScaleMode.CROP) && srcRatio<destRatio){
				keepWidth = true;
			} 
			
			if (keepWidth){
				// Keep dest width.
				return options.destinationBounds.width/sourceBounds.width;
			} else {
				// Keep dest height.
				return options.destinationBounds.height/sourceBounds.height;
			}
			
			
		
		};
	}
}