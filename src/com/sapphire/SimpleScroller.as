package com.sapphire
{
	import com.sapphire.core.UISprite;
	import com.sapphire.event.ScrollerEvent;
	import com.sapphire.support.ScrollBarPolicy;
	import com.sapphire.utils.math.clamp;
	
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	public class SimpleScroller extends ScrollerBase
	{
		public var trackV:Sprite;
		public var thumbV:Sprite;
		
		public var trackH:Sprite;
		public var thumbH:Sprite;
		
		public function SimpleScroller()
		{
			super();
			if (this.hasOwnProperty('trackVDisplay'))
				trackV = this['trackVDisplay'];
			if (this.hasOwnProperty('thumbVDisplay'))
				thumbV = this['thumbVDisplay'];			
			
			if (thumbV && trackV)
				thumbV.y = trackV.y;
			
			if (this.hasOwnProperty('trackHDisplay'))
				trackH = this['trackHDisplay'];
			if (this.hasOwnProperty('trackHDisplay'))
				thumbH = this['thumbHDisplay'];
			
			if (trackH && thumbH) 
				thumbH.x = trackH.x;
		}
		//=================================================================
		//
		// Variables (public, protected, private)
		//
		//=================================================================
		
		private var _scrollRangeV:Number;
		private var _scrollRangeH:Number;
		
		private var thumbPosDirty:Boolean = false;
		//=================================================================
		//
		// Properties (getter & setter)
		//
		//=================================================================
		
		//=================================================================
		//
		// Override protected methods
		//
		//=================================================================
		
		override protected function activate():void
		{
			super.activate();
			
			if (thumbV && _verticalScrollPolicy != ScrollBarPolicy.OFF)
				thumbV.addEventListener(MouseEvent.MOUSE_DOWN, thumb_mouseDownHandler);
			if (thumbH && _horizontalScrollPolicy != ScrollBarPolicy.OFF)
				thumbH.addEventListener(MouseEvent.MOUSE_DOWN, thumb_mouseDownHandler);
		}
		
		override protected function deactivate():void
		{
			super.deactivate();
			
			if (thumbV)
				thumbV.removeEventListener(MouseEvent.MOUSE_DOWN, thumb_mouseDownHandler);
			if (thumbH)
				thumbH.removeEventListener(MouseEvent.MOUSE_DOWN, thumb_mouseDownHandler);
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			/*if (contentClipDirty)
			{
				contentClipDirty = false;
				if (!_clipContent && contentHolder && contentHolder.scrollRect)
				{
					contentHolder.scrollRect = null;
					var mask:Shape = new Shape();
				}
			}*/
			
			if (contentHolderDirty)
			{
				contentHolderDirty = false;				
				
				if (_verticalScrollPolicy == ScrollBarPolicy.ALWAYS)
				{
					thumbV.visible = true;
					trackV.visible = true;
				}
				else if (_verticalScrollPolicy == ScrollBarPolicy.OFF)
				{
					if (thumbV)
						thumbV.visible = false;
					if (trackV)
						trackV.visible = false;
				}
				else if (_verticalScrollPolicy == ScrollBarPolicy.AUTO)
				{
					if (contentHolder.height > viewport.height)
					{
						thumbV.visible = true;
						trackV.visible = true;
					}
					else
					{
						thumbV.visible = false;
						trackV.visible = false;
					}
				}
				
				if (_horizontalScrollPolicy == ScrollBarPolicy.ALWAYS)
				{
					thumbH.visible = true;
					trackH.visible = true;
				}
				else if (_horizontalScrollPolicy == ScrollBarPolicy.OFF)
				{
					if (thumbH)
						thumbH.visible = false;
					if (trackH)
						trackH.visible = false;
				}
				else if (_horizontalScrollPolicy == ScrollBarPolicy.AUTO)
				{
					if (contentHolder.width > viewport.width)
					{
						thumbH.visible = true;
						trackH.visible = true;
					}
					else
					{
						thumbH.visible = false;
						trackH.visible = false;
					}
				}
				
				if (trackV && thumbV && _verticalScrollPolicy != ScrollBarPolicy.OFF)
					_maxVerticalScrollPosition = Math.max(0,contentHolder.height - viewport.height);
				else
					_maxVerticalScrollPosition = 0;
				
				if (isNaN(_maxVerticalScrollPosition)) _maxVerticalScrollPosition = 0;
				
				if (thumbH && trackH && _horizontalScrollPolicy != ScrollBarPolicy.OFF)
					_maxHorizontalScrollPosition = Math.max(0,contentHolder.width - viewport.width);
				else 
					_maxHorizontalScrollPosition = 0;
				
				if (isNaN(_maxHorizontalScrollPosition)) _maxHorizontalScrollPosition = 0;
				
				if (allowScaleThumb)
				{
					if (_verticalScrollPolicy != ScrollBarPolicy.OFF)
					{
						var newThumbHeight:Number = (viewport.height / contentHolder.height) * trackV.height;
						if (newThumbHeight < _minThumbHeight) newThumbHeight = _minThumbHeight;
						thumbV.height = newThumbHeight;
					}
					
					if (_horizontalScrollPolicy != ScrollBarPolicy.OFF)
					{
						var newThumbWidth:Number = (viewport.width / contentHolder.width) * trackH.width;
						if (newThumbWidth < _minThumbWidth) newThumbWidth = _minThumbWidth;
						thumbV.width = newThumbWidth;
					}
				}
			}
		}
		
		override protected function measure():void
		{
			super.measure();
		}
		
		override protected function draw(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.draw(unscaledWidth,unscaledHeight);
			
			if (scrollDirty)
			{
				scrollDirty = false;
				
				trace('[SimpleScroller] pre scroll content, verPos:',_verticalScrollPosition,', maxVerPos:',_maxVerticalScrollPosition);
				if (!_scrollToEnd)
				{
					_verticalScrollPosition = clamp(_verticalScrollPosition,_minVerticalScrollPosition,_maxVerticalScrollPosition);
					_horizontalScrollPosition = clamp(_horizontalScrollPosition,_minHorizontalScrollPosition,_maxHorizontalScrollPosition);
				}
				else
				{
					_scrollToEnd = false;
					_verticalScrollPosition = _maxVerticalScrollPosition;
					_horizontalScrollPosition = _maxHorizontalScrollPosition;
					if (thumbV && trackV)
						thumbV.y = trackV.y + (trackV.height - thumbV.height);
					if (thumbH && trackH)
						thumbH.x = trackH.x + (trackH.width - thumbV.width);
				}
				
				
				if (_clipContent)
				{
					if (contentHolder.mask)
					{
						if (this.contains(contentHolder.mask))
							this.removeChild(contentHolder.mask);
						contentHolder.mask = null;
					}
					if (!this.contentHolder.scrollRect) this.contentHolder.scrollRect = new Rectangle();				
					
					contentHolder.x = viewport.x;
					contentHolder.y = viewport.y;
					trace('[SimpleScroller] scroll content, verPos:',_verticalScrollPosition,', horPos:',_horizontalScrollPosition);
					const scrollRect:Rectangle = this.contentHolder.scrollRect;
					scrollRect.width = viewport.width;
					scrollRect.height = viewport.height;
					scrollRect.x = _horizontalScrollPosition;
					scrollRect.y = _verticalScrollPosition;
					this.contentHolder.scrollRect = scrollRect;
				}
				else
				{
					if (contentHolder.scrollRect) contentHolder.scrollRect = null;
					
					if (!contentHolder.mask)
					{
						var maskShape:Shape = new Shape();
						with (maskShape)
						{
							graphics.beginFill(0xffffff,0);
							graphics.drawRect(0,0,viewport.width,viewport.height);
							graphics.endFill();
						}
						maskShape.x = viewport.x;
						maskShape.y = viewport.y;
						this.addChild(maskShape);
						
						contentHolder.mask = maskShape;
					}
					
					contentHolder.x = -_horizontalScrollPosition;
					contentHolder.y = -_verticalScrollPosition;
				}
			}
			
			if (thumbPosDirty)
			{
				if (thumbV && verticalScrollPolicy != ScrollBarPolicy.OFF)
				{
					_scrollRangeV = Math.round(trackV.height - thumbV.height);
					const rateV:Number = (contentHolder.height - viewport.height) / (_scrollRangeV);					
					thumbV.y = Math.ceil((_verticalScrollPosition/rateV + trackV.y))
				}
				
				if (thumbH && verticalScrollPolicy != ScrollBarPolicy.OFF)
				{
					_scrollRangeH = Math.round(trackH.width - thumbV.width);
					const rateH:Number = (contentHolder.width - viewport.width) / (_scrollRangeH);					
					thumbH.x = Math.ceil(_horizontalScrollPosition/rateH + trackH.x);
				}
			}
		}
		
		override public function scrollTo(verPos:Number=0, horPos:Number=0):void
		{
			super.scrollTo(verPos,horPos);
			thumbPosDirty = true;
			invalidate(INVALIDATION_FLAG_DRAW);
		}
		
		protected function update():void
		{
			const rateV:Number = (contentHolder.height - viewport.height) / (_scrollRangeV);
			const rateH:Number = (contentHolder.width - viewport.width) / (_scrollRangeH);
			
			if (_verticalScrollPolicy != ScrollBarPolicy.OFF)
				verticalScrollPosition = Math.ceil(thumbV.y - trackV.y) * rateV;
			if (_horizontalScrollPolicy != ScrollBarPolicy.OFF)
				horizontalScrollPosition = Math.ceil(thumbH.x - trackH.x) * rateH;
		}
		
		protected function thumb_mouseDownHandler(event:MouseEvent):void
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			if (thumbV && _verticalScrollPolicy != ScrollBarPolicy.OFF)
			{
				_scrollRangeV = Math.round(trackV.height - thumbV.height);
				thumbV.startDrag(false, new Rectangle(trackV.x,trackV.y,0,_scrollRangeV));
			}
			
			if (thumbH && _horizontalScrollPolicy != ScrollBarPolicy.OFF)
			{
				_scrollRangeH = Math.round(trackH.width - thumbV.width);
				thumbH.startDrag(false, new Rectangle(trackH.x,trackH.y,_scrollRangeH,0));
			}
			
			this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		protected function enterFrameHandler(event:Event):void
		{
			update();
		}
		
		protected function onStageMouseUp(event:MouseEvent):void
		{
			if (thumbV)
				thumbV.stopDrag();
			if (thumbH)
				thumbH.stopDrag();
			stage.removeEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
			this.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
	}
}