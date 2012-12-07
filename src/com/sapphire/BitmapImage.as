package com.sapphire
{
	import com.sapphire.core.UISprite;
	import com.sapphire.support.BitmapFillMode;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	
	import spark.primitives.Rect;
	
	public class BitmapImage extends UISprite
	{
		public function BitmapImage()
		{
			super();
		}
		
		private var _claz:Class;		
		public function get claz():Class
		{
			return _claz;
		}

		public function set claz(value:Class):void
		{
			if (_claz == value) return;
			_claz = value;			
			_bitmapData = Bitmap(new _claz()).bitmapData;
			var rect:Rectangle = _bitmapData.rect;
			setSizeInternal(rect.width,rect.height,true);
			invalidate(INVALIDATION_FLAG_DRAW,INVALIDATION_FLAG_PROPERTIES);
		}

		
		private var _bitmapData:BitmapData;		
		public function get bitmapData():BitmapData
		{
			return _bitmapData;
		}

		public function set bitmapData(value:BitmapData):void
		{
			if (_bitmapData == value) return;
			_bitmapData = value;	
			var rect:Rectangle = _bitmapData.rect;
			setSizeInternal(rect.width,rect.height,true);
			invalidate(INVALIDATION_FLAG_DRAW,INVALIDATION_FLAG_PROPERTIES);
		}
		
		private var _fillMode:String = BitmapFillMode.REPEAT;
		public function get fillMode():String
		{
			return _fillMode;
		}

		public function set fillMode(value:String):void
		{
			if (_fillMode == value) return;
			_fillMode = value;
			invalidate(INVALIDATION_FLAG_DRAW);
		}
		
		override public function set width(value:Number):void {
			super.width = value;
			invalidate(INVALIDATION_FLAG_DRAW);
		}
		
		override public function set height(value:Number):void {
			super.height = value;
			invalidate(INVALIDATION_FLAG_DRAW);
		}
		
		override protected function draw(unscaledWidth:Number, unscaledHeight:Number):void {
			super.draw(unscaledWidth,unscaledHeight);
			
			if (_bitmapData) {
				var repeatMode:Boolean = _fillMode == BitmapFillMode.REPEAT;
				this.graphics.clear();
				this.graphics.beginBitmapFill(_bitmapData,null,repeatMode,true);
				this.graphics.drawRect(0,0,this.width,this.height);
				this.graphics.endFill();
			}
		}


	}
}