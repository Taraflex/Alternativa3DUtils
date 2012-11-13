package qw.utils
{
	import flash.display.BitmapData;
	import flash.display.Shader;
	import flash.filters.ShaderFilter;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public final class TextureUtils
	{
		[Embed(source="../pb/SmartNormalMap.pbj", mimeType="application/octet-stream")]
		private static const NormalShader:Class;
		private static const normalMapFilter:Shader = new Shader(new NormalShader);
		
		public static function normalMapFromDiffuse(bmp:BitmapData, softSobel:Boolean, amount:Number, invertRed:Number, invertGreen:Number):BitmapData
		{
			normalMapFilter.data.soft_sobel.value = [int(softSobel)];
			normalMapFilter.data.amount.value = [amount];
			normalMapFilter.data.invert_red.value = [invertRed];
			normalMapFilter.data.invert_green.value = [invertGreen];
			var resbmp:BitmapData = new BitmapData(bmp.width, bmp.height, false, 0x0);
			resbmp.applyFilter(bmp, new Rectangle(0, 0, bmp.width, bmp.height), new Point, new ShaderFilter(normalMapFilter));
			return resbmp;
		}
	
	}

}