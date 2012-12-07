package com.sapphire
{
	import com.sapphire.core.UISprite;
	import com.sapphire.event.ScrollerEvent;
	import com.sapphire.support.ScrollBarPolicy;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	public class ScrollerBase extends UISprite
	{
		public var viewport:Sprite;
		public function ScrollerBase()
		{
			super();
			viewport = this['viewportDisplay'];
		}
		//=================================================================
		//
		// Variables (public, protected, private)
		//
		//=================================================================
		
		//flag
		protected var scrollDirty:Boolean = false;	
		protected var scrollPositionDirty:Boolean = false;		
		protected var contentHolderDirty:Boolean = false;
		protected var contentClipDirty:Boolean = false;
		
		
		protected var _scrollToEnd:Boolean = false;
		
		//=================================================================
		//
		// Properties (getter & setter)
		//
		//=================================================================		
		protected var _contentHolder:DisplayObject;		
		public function get contentHolder():DisplayObject
		{
			return _contentHolder;
		}
		
		public function set contentHolder(value:DisplayObject):void
		{			
			if (_contentHolder && this.contains(_contentHolder))
				this.removeChild(_contentHolder);
			
			_contentHolder = value;
			
			if (_contentHolder && !this.contains(_contentHolder))
				this.addChild(_contentHolder);
			
			if (_contentHolder)
			{
				contentHolderDirty = true;
				scrollDirty = true;
				invalidate(INVALIDATION_FLAG_PROPERTIES,INVALIDATION_FLAG_DRAW);
			}
		}	
		
		protected var _clipContent:Boolean = true;
		/**
		 * true : sử dụng ScrollRect
		 * false : sử dụng mask  
		 */
		public function get clipContent():Boolean
		{
			return _clipContent;
		}

		/**
		 * @private
		 */
		public function set clipContent(value:Boolean):void
		{
			if (_clipContent == value) return;
			_clipContent = value;
			contentClipDirty = true;
			invalidate(INVALIDATION_FLAG_PROPERTIES,INVALIDATION_FLAG_DRAW);
		}


		protected var _verticalScrollPosition:Number = 0;
		public function get verticalScrollPosition():Number
		{
			return _verticalScrollPosition;
		}
		
		public function set verticalScrollPosition(value:Number):void
		{
			if (_verticalScrollPosition == value) return;
			_verticalScrollPosition = value;
			scrollDirty = true;
			scrollPositionDirty = true;			
			invalidate(INVALIDATION_FLAG_PROPERTIES,INVALIDATION_FLAG_DRAW);
			dispatchEvent(new ScrollerEvent(ScrollerEvent.SCROLL_POSITION_CHANGE));
		}
		
		protected var _maxVerticalScrollPosition:Number = 0;
		public function get maxVerticalScrollPosition():Number
		{
			return _maxVerticalScrollPosition;
		}
		
		protected var _minVerticalScrollPosition:Number = 0;
		public function get minVerticalScrollPosition():Number
		{
			return _minVerticalScrollPosition;
		}
		
		
		protected var _horizontalScrollPosition:Number = 0;
		public function get horizontalScrollPosition():Number
		{
			return _horizontalScrollPosition;
		}
		
		public function set horizontalScrollPosition(value:Number):void
		{
			if (_horizontalScrollPosition == value) return;
			_horizontalScrollPosition = value;
			scrollPositionDirty = true;
			scrollDirty = true;			
			invalidate(INVALIDATION_FLAG_PROPERTIES,INVALIDATION_FLAG_DRAW);
			dispatchEvent(new ScrollerEvent(ScrollerEvent.SCROLL_POSITION_CHANGE));
		}
		
		protected var _maxHorizontalScrollPosition:Number = 0;
		public function get maxHorizontalScrollPosition():Number
		{
			return _maxHorizontalScrollPosition;
		}
		
		protected var _minHorizontalScrollPosition:Number = 0;
		public function get minHorizontalScrollPosition():Number
		{
			return _minHorizontalScrollPosition;
		}
		
		protected var _verticalScrollPolicy:String = ScrollBarPolicy.AUTO;
		public function get verticalScrollPolicy():String
		{
			return _verticalScrollPolicy;
		}
		
		public function set verticalScrollPolicy(value:String):void
		{
			_verticalScrollPolicy = value;
		}
		
		protected var _horizontalScrollPolicy:String = ScrollBarPolicy.OFF;
		public function get horizontalScrollPolicy():String
		{
			return _horizontalScrollPolicy;
		}
		
		public function set horizontalScrollPolicy(value:String):void
		{
			_horizontalScrollPolicy = value;
		}
		
		protected var _allowScaleThumb:Boolean = true;
		public function get allowScaleThumb():Boolean
		{
			return _allowScaleThumb;
		}

		public function set allowScaleThumb(value:Boolean):void
		{
			_allowScaleThumb = value;
		}
		
		protected var _minThumbWidth:Number = 10;
		public function get minThumbWidth():Number
		{
			return _minThumbWidth;
		}

		public function set minThumbWidth(value:Number):void
		{
			_minThumbWidth = value;
		}
		
		protected var _minThumbHeight:Number = 10;
		public function get minThumbHeight():Number
		{
			return _minThumbHeight;
		}

		public function set minThumbHeight(value:Number):void
		{
			_minThumbHeight = value;
		}

		//=================================================================
		//
		// Override methods
		//
		//=================================================================
		override protected function activate():void
		{
			super.activate();			
		}
		//=================================================================
		//
		// Public Methods
		//
		//=================================================================
		
		public function scrollTo(verPos:Number = 0,horPos:Number = 0):void
		{
			verticalScrollPosition = verPos;
			horizontalScrollPosition = horPos;
		}
		public function updateContentHolder(scrollToEnd:Boolean = false):void
		{
			contentHolderDirty = true;
			scrollDirty = true;
			_scrollToEnd = scrollToEnd;
			invalidate(INVALIDATION_FLAG_PROPERTIES,INVALIDATION_FLAG_DRAW);
		}
	}
}