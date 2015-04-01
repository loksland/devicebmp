package lks.bmputils {
	import flash.geom.Rectangle;
	/**
	 * # BmpOutputOptions.as
	 * 
	 * Contains all the settings needed to resize an image to a specfic output
	 *
	 */
	public class BmpOutputOptions {
		
		public var destinationBounds:Rectangle;
		public var scaleMode:uint;
		public var allowUpscale:Boolean;
		public var hiQuality:Boolean;
		
		//- `destinationBounds`  
		//  *Type: Boolean, Required: No, Default: null*  
		//  Optionally scale bitmap during processing to these bounds
		
		//- `resizeMode`  
		//  *Type: uint constants `BmpScaleMode.LETTERBOX`, `BmpScaleMode.NOGAPS`, `BmpScaleMode.FIT_WIDTH`, `BmpScaleMode.FIT_HEIGHT`, `BmpScaleMode.CROP`*
		//  *Required: No, Default: `BmpScaleMode.LETTERBOX`*  
		//  How to resize the source bitmap relative to |destinationBounds|
		
		//- `allowUpscale`  
		//  *Type: Boolean, Required: No, Default: false*  
		//  Whether to allow upscaling during scaling processes	
		
		//- `hiQuality`  
		//  *Type: Boolean, Required: No, Default: true*  
		//  Set the quality of scaling processes
		
		/**
		 * BmpOutputOptions
		 * 
		 * @param {Rectangle} destinationBounds Target dimensions
		 * @param {uint} scaleMode BmpScaleMode constant
		 * @param {Boolean} allowUpscale 
		 * @param {uint} scaleMode BmpScaleMode constant
		 * @return {uint} scaleMode
		 */
		public function BmpOutputOptions($destinationBounds:Rectangle = null, $scaleMode:uint = 0, $allowUpscale:Boolean = false, $hiQuality:Boolean = true):void {
			
			destinationBounds = $destinationBounds;
			scaleMode = $scaleMode;
			allowUpscale = $allowUpscale;
			hiQuality = $hiQuality;
			
		}
		/**
		 * Escape the given `html`.
		 *
		 * ### Examples:
		 *
		 *     utils.escape('<script></script>')
		 *     // => '&lt;script&gt;&lt;/script&gt;'
		 *
		 * @param {String} html string to be escaped
		 * @return {String} escaped html
		 * @api public
		 */
	}
}