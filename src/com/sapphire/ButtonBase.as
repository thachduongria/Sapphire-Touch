package com.sapphire 
{
	import com.sapphire.core.SkinnableUISprite;
	
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	 * Lớp này không có ý nghĩa hiển thị, do đó không được quyền khai báo trong giao diện
	 */
	public class ButtonBase extends SkinnableUISprite 
	{
		public static const UP:String = "up";
		public static const OVER:String = "over";
		public static const DOWN:String = "down";
		public static const DISABLE:String = "disable";
		
		//=================================================================
		//
		// SKIN PARTS
		//
		//=================================================================
		public var labelDisplay:TextField;
		
		//=================================================================
		//
		// Constructors
		//
		//=================================================================
		public function ButtonBase() 
		{
			super();
			buttonMode = true;
			useHandCursor = true;
			mouseChildren = false;
			if (enabled) currentState = UP;
			else currentState = DISABLE;
		}
		
		//=================================================================
		//
		// Override properties (getter & setter)
		//
		//=================================================================
		override public function set enabled(value:Boolean):void
		{
			super.enabled = value;
			if (enabled)
			{
				buttonMode = true;
				useHandCursor = true;
				currentState = UP;
			}
			else
			{
				buttonMode = false;
				useHandCursor = false;
				currentState = DISABLE;
			}
		}
		//=================================================================
		//
		// Properties (getter & setter)
		//
		//=================================================================
		
		/**
		 * Lưu giá trị của label 
		 */		
		private var _label:String = "";
		private var labelDirty:Boolean = false;
		/**
		 * giá trị label để hiển thị của labelDisplay 
		 */
		public function get label():String
		{
			return _label;
		}

		/**
		 * @private
		 */
		public function set label(value:String):void
		{
			_label = value;
			labelDirty = true;
			invalidate(INVALIDATION_FLAG_PROPERTIES);
		}
		
		private var _contentPadding:Number = 5;
		private var contentPaddingDirty:Boolean = false;
		public function get contentPadding():Number
		{
			return _contentPadding;
		}

		public function set contentPadding(value:Number):void
		{
			if (_contentPadding == value) return;
			
			_contentPadding = value;
			invalidate(INVALIDATION_FLAG_SIZE,INVALIDATION_FLAG_DRAW);
		}
		
		private var _verticalAlign:String = 'none';
		public function get verticalAlign():String
		{
			return _verticalAlign;
		}

		public function set verticalAlign(value:String):void
		{
			if (_verticalAlign == value) return;
			
			_verticalAlign = value;			
			invalidate(INVALIDATION_FLAG_SIZE,INVALIDATION_FLAG_DRAW);
		}
		
		private var _horizontalAlign:String = 'none';
		public function get horizontalAlign():String
		{
			return _horizontalAlign;
		}

		public function set horizontalAlign(value:String):void
		{
			if (_horizontalAlign == value) return;
			
			_horizontalAlign = value;
			invalidate(INVALIDATION_FLAG_SIZE,INVALIDATION_FLAG_DRAW);
		}


		//=================================================================
		//
		// Override methods (public, protected)
		//
		//=================================================================		
		override protected function initSkinParts():void 
		{
			_skinParts = ["labelDisplay"];
		}
		
		override protected function activate():void
		{
			super.activate();
			trace('[ButtonBase][activate]');
			if (skin)
			{
				trace('[ButtonBase][activate] skin found');
				if (enabled) currentState = UP;
				else currentState = DISABLE;
			}
			
			this.addEventListener(MouseEvent.MOUSE_UP, onMouseUpHandler, false, 0, true);
			this.addEventListener(MouseEvent.MOUSE_OVER, onMouseOverHandler,false,0,true);
			this.addEventListener(MouseEvent.MOUSE_OUT, onMouseOutHandler,false,0,true);
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandler, false, 0, true);
		}		
		
		override protected function deactivate():void
		{
			super.deactivate();
			
			this.removeEventListener(MouseEvent.MOUSE_UP, onMouseUpHandler);
			this.removeEventListener(MouseEvent.MOUSE_OVER, onMouseOverHandler);
			this.removeEventListener(MouseEvent.MOUSE_OUT, onMouseOutHandler);
			this.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDownHandler);
		}
		
		override protected function partAdded(partName:String):void 
		{
			if (partName == "labelDisplay")
			{
				labelDisplay.mouseEnabled = false;
				labelDisplay.text = _label;
			}
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			if (labelDirty)
			{
				labelDirty = false;
				if (labelDisplay)
					labelDisplay.text = label;
			}
		}
		
		override protected function measure():void
		{
			super.measure();
			var needsWidth:Boolean = isNaN(explicitWidth);
			var needsHeight:Boolean = isNaN(explicitHeight);
			
			//explicitWidth & explicitHeight is a Number
			if (!needsWidth && !needsHeight) return;
			
			var measuredWidth:Number = this.explicitWidth;
			var measuredHeight:Number = this.explicitHeight;
			
			//explicitWidth is not a Number
			if (needsWidth)
			{
				if (labelDisplay) measuredWidth = labelDisplay.width;
			}
			measuredWidth += 2*_contentPadding;
			
			//explicitHeight is not a Number
			if (needsHeight)
			{
				if (labelDisplay) measuredHeight = labelDisplay.height;
			}
			measuredHeight += 2*_contentPadding;
			
			setSizeInternal(measuredWidth,measuredHeight,false);
		}
		
		override protected function draw(unscaledWidth:Number, unscaledHeight:Number):void
		{
			if (_verticalAlign == 'none' && _horizontalAlign == 'none') return;
		}
		//=================================================================
		//
		// Event handlers
		//
		//=================================================================
		protected function onMouseUpHandler(event:MouseEvent):void
		{
			
		}
		
		protected function onMouseOverHandler(event:MouseEvent):void
		{
			
		}
		
		protected function onMouseDownHandler(event:MouseEvent):void
		{
			
		}
		
		protected function onMouseOutHandler(event:MouseEvent):void
		{
			
		}
	}

}