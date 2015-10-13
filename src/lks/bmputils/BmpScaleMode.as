package lks.bmputils {
	
	public class BmpScaleMode {
		
		// Constrain within destination bounds, leaving letterbox strips if aspects ratios do not match
		public static const LETTERBOX:uint=0; 		
		// Cover width and height of destination bounds, hanging over sides / tops if aspects ratios do not match
		public static const NOGAPS:uint=1;
		// Use destination bounds width, scale height proportionally
		public static const FIT_WIDTH:uint=2;
		// Use destination bounds height, scale width proportionally
		public static const FIT_HEIGHT:uint=3;
		// First peform a |NOGAPS| then crop to destination bounds
		public static const CROP:uint=4;
			
	}
}