package com.sapphire
{
	import com.sapphire.core.UISprite;
	
	import flash.display.DisplayObject;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	public class KineticScrollThumb extends UISprite
	{
		public static const MARGINS:Number = 2.0;
		public static const WIDTH:Number = 5.0;
		public static const MIN_INIT_HEIGHT:Number = 35.0;
		public static const MIN_HEIGHT:Number = 5.0;
		public static const MAX_HEIGHT_RATIO:Number = 0.2;
		public static const VERTICAL:String = 'vertical';
		public static const HORIZONTAL:String = 'horizontal';
		
		protected static const ALPHA_1:Number = 0.5;
		protected static const SCRUNCH_FACTOR:Number = 0.7;
		
		protected static const HV:Array = [WIDTH / 8, MIN_HEIGHT / 8, WIDTH / 2, MIN_HEIGHT / 2]; // height values
		
		public function KineticScrollThumb()
		{
			super();			
		}
		//=================================================================
		//
		// Variables (public, protected, private)
		//
		//=================================================================
		protected var _init_x:Number;
		protected var _init_y:Number;
		protected var _alpha_id:int;
		protected var _init_height:Number;
		
		private var scrollDirty:Boolean = false;
		private var thumbDirty:Boolean = false;
		private var contentHolderDirty:Boolean = false;
		
		//=================================================================
		//
		// Properties (getter & setter)
		//
		//=================================================================
		private var _thumbColor:int = 0xffffff;
		public function get thumbColor():int
		{
			return _thumbColor;
		}

		public function set thumbColor(value:int):void
		{
			if (_thumbColor == value) return;
			_thumbColor = value;
			invalidate(INVALIDATION_FLAG_STYLES);
		}
		
		private var _contentHolder:DisplayObject;
		public function get contentHolder():DisplayObject
		{
			return _contentHolder;
		}

		public function set contentHolder(value:DisplayObject):void
		{
			_contentHolder = value;
		}
		
		private var _viewport:DisplayObject;
		public function get viewport():DisplayObject
		{
			return _viewport;
		}

		public function set viewport(value:DisplayObject):void
		{
			_viewport = value;
		}

		
		private var _type:String = VERTICAL;
		public function get type():String
		{
			return _type;
		}

		public function set type(value:String):void
		{
			_type = value;
		}
		
		private var _verticalScrollPosition:Number = 0;
		public function get verticalScrollPosition():Number
		{
			return _verticalScrollPosition;
		}

		public function set verticalScrollPosition(value:Number):void
		{
			if (_verticalScrollPosition == value) return;
			_verticalScrollPosition = value;
			scrollDirty = true;
			invalidate(INVALIDATION_FLAG_DRAW);
		}
		
		private var _horizontalScrollPosition:Number = 0;
		
		public function get horizontalScrollPosition():Number
		{
			return _horizontalScrollPosition;
		}

		public function set horizontalScrollPosition(value:Number):void
		{
			if (_horizontalScrollPosition == value) return;
			_horizontalScrollPosition = value;
			scrollDirty = true;
			invalidate(INVALIDATION_FLAG_DRAW);
		}
		
				
		override public function set height(value:Number):void {
			if(value < MIN_HEIGHT) value = MIN_HEIGHT;
			
			this.graphics.clear();
			this.graphics.beginFill(_thumbColor);
			// top left
			this.graphics.moveTo(0, HV[3]);
			// top left to top center
			this.graphics.curveTo(HV[0], HV[1], HV[2], 0);
			// top center to top right
			this.graphics.curveTo(WIDTH - HV[0], HV[1], WIDTH, HV[3]);
			// top right to bottom right
			this.graphics.lineTo(WIDTH, value - HV[3]);
			// bottom right to bottom center
			this.graphics.curveTo(WIDTH - HV[0], value - HV[1], HV[2], value);
			// bottom center to bottom left
			this.graphics.curveTo(HV[0], value - HV[1], 0, value - HV[3]);
			// bottom left to top left
			this.graphics.endFill();
			
			super.height = value;
		}
		
		override protected function activate():void
		{
			super.activate();
			//trace('[KineticScrollThumb] thumb activate');
			this.alpha = 0;
			thumbDirty = true;
			invalidate(INVALIDATION_FLAG_PROPERTIES);
		}
		
		override protected function deactivate():void
		{
			super.deactivate();
			clearInterval(this._alpha_id);
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			//trace('[KineticScrollThumb] thumb commit properties');
			if (thumbDirty)
			{
				//trace('[KineticScrollThumb] type:',_type,', _viewportHeight:',viewport.height,', _viewportWidth:',viewport.height,', _contentWidth: ',contentHolder.width,', _contentHeight:',contentHolder.height);
				thumbDirty = false;						
				switch(_type) 
				{
					case VERTICAL:
						this.x = this._init_x = viewport.width - (WIDTH + MARGINS);
						this.y = this._init_y = viewport.y + MARGINS;
						
						if (contentHolder.height < viewport.height)
							this.initHeight = viewport.height - MARGINS*2 - viewport.height*MAX_HEIGHT_RATIO;
						else
							this.initHeight = viewport.height * (viewport.height / contentHolder.height);
						
						break;
					case HORIZONTAL:
						this.x = this._init_x = viewport.x + MARGINS;
						this.y = this._init_y = viewport.y + (viewport.height - MARGINS);
						
						if (contentHolder.width < viewport.width)
							this.initHeight = viewport.width - MARGINS*2 - viewport.width*MAX_HEIGHT_RATIO;
						else
							this.initHeight = viewport.width * (viewport.width / contentHolder.width);
						
						this.rotation = 270;
						break;
				}				
			}
			
			if (contentHolderDirty)
			{
				contentHolderDirty = false;
				switch(_type) 
				{
					case VERTICAL:
						this._init_x = viewport.width - (WIDTH + MARGINS);
						this._init_y = viewport.y + MARGINS;
						
						if (contentHolder.height < viewport.height)
							this.initHeight = viewport.height - MARGINS*2;
						else
							this.initHeight = viewport.height * (viewport.height / contentHolder.height);
						break;
					case HORIZONTAL:
						this._init_x = viewport.x + MARGINS;
						this._init_y = viewport.y + (viewport.height - MARGINS);
						
						if (contentHolder.width < viewport.width)
							this.initHeight = viewport.width - MARGINS*2;
						else
							this.initHeight = viewport.width * (viewport.width / contentHolder.width);
						
						this.rotation = 270;
						break;
				}
			}
		}
		
		override protected function commitStyles():void
		{
			super.commitStyles();
			this.height = this.height;
		}
		
		override protected function draw(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.draw(unscaledWidth,unscaledHeight);
			
			//trace('[KineticScrollThumb] draw');
			if (scrollDirty)
			{
				//trace('[KineticScrollThumb] scroll dirty, type:',_type);
				scrollDirty = false;
				if (_type == VERTICAL)
					this.percent = (viewport.y + _verticalScrollPosition) / Math.abs(contentHolder.height - viewport.height);
				if (_type == HORIZONTAL)
					this.percent = (viewport.x + _horizontalScrollPosition) / Math.abs(contentHolder.width - viewport.width);
			}
		}
		
		public function set percent(val:Number):void {
			this.show();
			
			switch(this._type) {
				case VERTICAL:
					
					if(val < 0) {
						this.height = this._init_height + (_verticalScrollPosition - viewport.y) * SCRUNCH_FACTOR;
						this.y = this._init_y + MARGINS;
					} else if(val > 1) {
						this.height = this._init_height - ((_verticalScrollPosition - viewport.y) - Math.abs(contentHolder.height - viewport.height)) * SCRUNCH_FACTOR;
						this.y = this._init_y + viewport.height - MARGINS*2 - this.height;
					} else if (val > 0) {
						this.height = this._init_height;
						this.y = this._init_y + (viewport.height - MARGINS*2 - this.height) * val;
					}
					else if (val == 0) {
						this.height = this._init_height;
						this.y = this._init_y + MARGINS;
					}
					break;
				case HORIZONTAL:
					this.rotation = 0;
					if(val < 0) {
						this.height = this._init_height + (_horizontalScrollPosition - viewport.y) * SCRUNCH_FACTOR;
						this.x = this._init_x + MARGINS;
					} else if(val > 1) {
						this.height = this._init_height - ((_horizontalScrollPosition - viewport.y) - Math.abs(contentHolder.width - viewport.width)) * SCRUNCH_FACTOR;
						this.x = this._init_x + viewport.width - MARGINS*2 - this.height;
					} else if (val > 0) {
						this.height = this._init_height;
						this.x = this._init_x + (viewport.width - MARGINS*2 - this.height) * val;
					}
					else if (val == 0) {
						this.height = this._init_height;
						this.x = this._init_x + MARGINS;
					}
						
					this.rotation = 270;
					
					//trace('[KineticScroller] x:',this.x,',y:',this.y);
					break;
			}
		}
		
		protected function set initHeight(val:Number):void {
			if(val < MIN_INIT_HEIGHT || val < 0) val = MIN_INIT_HEIGHT;
			
			this.height = this._init_height = val;
		}
		
		protected function fillThumb():void
		{
			
		}
		
		public function show():void 
		{			
			this.alpha = ALPHA_1;
		}
		
		public function hide():void
		{
			this._alpha_id = setInterval(function():void {
				alpha -= 0.04;
				if(alpha <= 0) clearInterval(_alpha_id);
			}, 4);
		}
		
		public function updateContentHolder():void
		{
			contentHolderDirty = true;
			invalidate(INVALIDATION_FLAG_PROPERTIES);
		}
	}
}