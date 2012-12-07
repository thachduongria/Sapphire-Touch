package com.sapphire.list
{
	import com.sapphire.DataContainer;
	import com.sapphire.ScrollerBase;
	import com.sapphire.core.SkinnableUISprite;
	import com.sapphire.event.SapphireEvent;
	import com.sapphire.event.ScrollerEvent;
	import com.sapphire.support.IItemRenderer;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	public class ListBase extends SkinnableUISprite
	{
		//skin parts
		public var contentHolder:DataContainer;
		public var scroller:ScrollerBase;
		
		public function ListBase()
		{
			super();
		}
		protected var dataProviderDirty:Boolean = false;
		protected var itemRendererDirty:Boolean = false;
		protected var scrollDirty:Boolean = false;
		protected var dataProviderLengthDirty:Boolean = false;
		
		private var _dataProvider:Array;
		public function get dataProvider():Array
		{
			return _dataProvider;
		}

		public function set dataProvider(value:Array):void
		{
			if (_dataProvider == value) return;
			var oldLength:int = 0;
			var newLength:int = 0;
			if (_dataProvider)
			{
				oldLength = _dataProvider.length;
			}
			
			_dataProvider = value;
			
			if (_dataProvider)
			{
				newLength = _dataProvider.length;
				//cập nhật scroll position
				if (newLength < oldLength) {
					dataProviderLengthDirty = true;
				}
				dataProviderDirty = true;
				invalidate(INVALIDATION_FLAG_PROPERTIES);
			}
		}
		
		private var _itemRenderer:Class;
		public function get itemRenderer():Class
		{
			return _itemRenderer;
		}

		public function set itemRenderer(value:Class):void
		{
			if (_itemRenderer == value) return;
			
			_itemRenderer = value;
			itemRendererDirty = true;
			invalidate(INVALIDATION_FLAG_PROPERTIES);
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
			invalidate(INVALIDATION_FLAG_PROPERTIES);
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
			invalidate(INVALIDATION_FLAG_PROPERTIES);
		}

		private var _allowScaleThumb:Boolean = false;
		public function get allowScaleThumb():Boolean
		{
			return _allowScaleThumb;
		}

		public function set allowScaleThumb(value:Boolean):void
		{
			if (_allowScaleThumb == value) return;
			_allowScaleThumb = value;
			if (scroller) scroller.allowScaleThumb = _allowScaleThumb;
		}
		
		private var _vGap:Number = 0;
		public function get vGap():int
		{
			return _vGap;
		}
		
		public function set vGap(value:int):void
		{
			if (_vGap == value) return;
			_vGap = value;
			invalidate(INVALIDATION_FLAG_STYLES);
		}
		
		private var _hGap:Number = 0;
		public function get hGap():Number
		{
			return _hGap;
		}

		public function set hGap(value:Number):void
		{
			if (_hGap == value) return;
			_hGap = value;
			invalidate(INVALIDATION_FLAG_STYLES);
		}
		
		private var selectionDirty:Boolean = false;
		private var _selectedItem:Object;
		public function get selectedItem():Object
		{
			return _selectedItem;
		}

		public function set selectedItem(value:Object):void
		{
			if (_selectedItem == value) return;
			_selectedItem = value;
			selectionDirty = true;
			invalidate(INVALIDATION_FLAG_PROPERTIES);
		}
		
		private var _selectedIndex:int = -1;
		public function get selectedIndex():int
		{
			return _selectedIndex;
		}

		public function set selectedIndex(value:int):void
		{
			if (_selectedIndex == value) return;			
			_selectedIndex = value;
			selectionDirty = true;
			invalidate(INVALIDATION_FLAG_PROPERTIES);
		}
		
		private var _paddingTop:Number = 0;
		
		public function get paddingTop():Number
		{
			return _paddingTop;
		}
		
		public function set paddingTop(value:Number):void
		{
			_paddingTop = value;
			invalidate(INVALIDATION_FLAG_STYLES);
		}
		
		private var _paddingLeft:Number = 0;
		
		public function get paddingLeft():Number
		{
			return _paddingLeft;
		}
		
		public function set paddingLeft(value:Number):void
		{
			_paddingLeft = value;
			invalidate(INVALIDATION_FLAG_STYLES);
		}
		
		private var _paddingBottom:Number = 0;
		
		public function get paddingBottom():Number
		{
			return _paddingBottom;
		}
		
		public function set paddingBottom(value:Number):void
		{
			_paddingBottom = value;
			invalidate(INVALIDATION_FLAG_STYLES);
		}
		
		private var _paddingRight:Number = 0;
		
		public function get paddingRight():Number
		{
			return _paddingRight;
		}
		
		public function set paddingRight(value:Number):void
		{
			_paddingRight = value;
			invalidate(INVALIDATION_FLAG_STYLES);
		}

		
		override protected function initSkinParts():void
		{
			_skinParts = ['scroller','contentHolder'];
		}
		
		override protected function partAdded(partName:String):void
		{
			if (partName == 'contentHolder')
			{
				if (scroller)
				{
					scroller.contentHolder = contentHolder;
					contentHolder.paddingTop = _paddingTop;
					contentHolder.paddingLeft = _paddingLeft;
					contentHolder.paddingBottom = _paddingBottom;
					contentHolder.paddingRight = _paddingRight;
					
					contentHolder.addEventListener(SapphireEvent.RESIZE, contentHolder_resizeHandler);
					contentHolder.addEventListener(Event.CHANGE, contentHolder_itemChangeHandler);
				}			
			}
			if (partName == 'scroller')
			{
				if (contentHolder) 
				{			
					scroller.contentHolder = contentHolder;					
				}
				scroller.allowScaleThumb = _allowScaleThumb;
				scroller.addEventListener(ScrollerEvent.SCROLL_POSITION_CHANGE, onScrolling);
			}
		}
		
		
		
		override protected function partRemoved(partName:String):void
		{
			if (partName == 'scroller')
			{
				scroller.removeEventListener(ScrollerEvent.SCROLL_POSITION_CHANGE, onScrolling);
				scroller.contentHolder = null;				
			}
			if (partName == 'contentHolder')
			{
				contentHolder.removeEventListener(SapphireEvent.RESIZE, contentHolder_resizeHandler);
				contentHolder.removeEventListener(Event.CHANGE, contentHolder_itemChangeHandler);
			}
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			//trace('[ListBase] commit properties');
			
			if (itemRendererDirty)
			{
				itemRendererDirty = false;
				if (contentHolder) contentHolder.itemRenderer = itemRenderer;
			}
			
			if (selectionDirty)
			{
				//trace('[ListBase] selection dirty');
				selectionDirty = false;
				if (contentHolder)
				{
					//trace('[ListBase] selection dirty, has contentHolder, _selectedIndex',_selectedIndex);
					contentHolder.selectedIndex = _selectedIndex;
					contentHolder.selectedItem = _selectedItem;
				}
			}
			
			if (dataProviderDirty)
			{
				dataProviderDirty = false;
				var itemRendererTmp:IItemRenderer;
				try {
					itemRendererTmp = IItemRenderer(new _itemRenderer());
				} catch (err:Error) {
					throw err;
				}
				
				var newVScrollPos:Number = 0;
				var newHScrollPos:Number = 0;
				var l:int = this._dataProvider.length;
				var rowWidth:int = DisplayObject(itemRendererTmp).width;
				var rowHeight:int = DisplayObject(itemRendererTmp).height;
				newVScrollPos = _verticalScrollPosition;
				while (newVScrollPos > l * rowHeight ) {						
					newVScrollPos = newVScrollPos - rowHeight;
					newVScrollPos = Math.max(0,newVScrollPos);				
				}
				newHScrollPos = _horizontalScrollPosition;
				if (newHScrollPos > l * rowWidth) {							
					newHScrollPos = newHScrollPos - rowWidth;
					newHScrollPos = Math.max(0,newHScrollPos);			
				}
				
				verticalScrollPosition = newVScrollPos;
				horizontalScrollPosition = newHScrollPos;
				
				if (contentHolder) {
					contentHolder.verticalScrollPosition = newVScrollPos;
					contentHolder.horizontalScrollPosition = newHScrollPos;				
					contentHolder.dataProvider = _dataProvider;				
					contentHolder.invalidate(INVALIDATION_FLAG_SIZE,INVALIDATION_FLAG_DRAW);
				}
				
				if (scroller) {
					scroller.verticalScrollPosition = newVScrollPos;
					scroller.horizontalScrollPosition = newHScrollPos;
					scroller.updateContentHolder(false);
				}				
			}
			
			if (scrollDirty)
			{
				scrollDirty = false;
				contentHolder.verticalScrollPosition = _verticalScrollPosition;
				contentHolder.horizontalScrollPosition = _horizontalScrollPosition;
			}
			
		}
		
		override protected function commitStyles():void
		{
			super.commitStyles();
			if (contentHolder)
			{
				contentHolder.vGap = _vGap;
				contentHolder.hGap = _hGap;
				contentHolder.paddingTop = _paddingTop;
				contentHolder.paddingLeft = _paddingLeft;
				contentHolder.paddingBottom = _paddingBottom;
				contentHolder.paddingRight = _paddingRight;
			}
		}
		
		public function getItemByField(field:String,value:*):Object
		{
			if (!_dataProvider || _dataProvider.length <= 0)
				return null;
			for each (var item:Object in _dataProvider)
			{
				if (item[field] == value) return item;
			}
			return null;
		}
		
		public function getItemByFields(fields:Array,values:Array):Object
		{
			if (!_dataProvider || _dataProvider.length <= 0)
				return null;
			
			if (fields.length != values.length) return null;
			
			var i:int = 0;
			var l:int = fields.length;
			var count:int = 0; //đếm số trường thoả mãn
			for each (var item:Object in _dataProvider)
			{				
				for (i=0;i<l;i++)
				{
					if (item[fields[i]] == values[i]) 			
						count++;
				}
				//thoả mãn tất cả các trường
				if (count == l)
					return item;
				
				count = 0;
			}
			return null;
		}
		
		public function getItemsByField(field:String,value:*):Array
		{
			if (!_dataProvider || _dataProvider.length <= 0)
				return null;
			
			var result:Array = [];
			for each (var item:Object in _dataProvider)
			{
				if (item[field] == value) result.push(item);
			}
			
			return result;
		}
		
		public function getItemsByFields(fields:Array,values:Array):Array
		{
			if (!_dataProvider || _dataProvider.length <= 0)
				return null;
			
			if (fields.length != values.length) return null;
			
			var result:Array = [];
			var i:int = 0;
			var l:int = fields.length;
			var count:int = 0; //đếm số trường thoả mãn
			for each (var item:Object in _dataProvider)
			{				
				for (i=0;i<l;i++)
				{				
					if (item[fields[i]] == values[i])					
						count++;
				}				
				//thoả mãn tất cả các trường
				if (count == l)
					result.push(item);				
				
				count = 0;
			}
			return result;
		}
		
		public function deleteItemByField(field:String,value:*):void
		{
			if (!_dataProvider || _dataProvider.length <= 0)
				return;
			
			var item:Object;
			for (var i:int = 0; i < _dataProvider.length;i++)
			{
				item = _dataProvider[i];
				if (item[field] == value)
				{
					trace('[ListBase] delete item by field:',field,',value:',value);
					_dataProvider.splice(i,1);
					if (contentHolder)					
					{
//						//cập nhật scroll position mới
//						var itemRendererTmp:IItemRenderer;
//						try {					
//							itemRendererTmp = IItemRenderer(new _itemRenderer());
//						} catch (err:Error) {
//							throw err;
//						}
//						
//						var newVScrollPos:Number = 0;
//						var newHScrollPos:Number = 0;
//						if (verticalScrollPosition > 0) {						
//							newVScrollPos = _verticalScrollPosition - DisplayObject(itemRendererTmp).height - 5 - _vGap;
//							newVScrollPos = Math.max(0,newVScrollPos);
//							verticalScrollPosition = newVScrollPos;
//						}
//						if (horizontalScrollPosition > 0) {							
//							newHScrollPos = _horizontalScrollPosition - DisplayObject(itemRendererTmp).width - 5 - _hGap;
//							newHScrollPos = Math.max(0,newHScrollPos);
//							horizontalScrollPosition = newHScrollPos;
//						}
//						
//						contentHolder.verticalScrollPosition = newVScrollPos;
//						contentHolder.horizontalScrollPosition = newHScrollPos;
						
						contentHolder.invalidateDataProvider();
//						contentHolder.dataProvider = _dataProvider;
						contentHolder.invalidate(INVALIDATION_FLAG_SIZE,INVALIDATION_FLAG_DRAW);
						
						if (scroller) {
//							scroller.verticalScrollPosition = newVScrollPos;
//							scroller.horizontalScrollPosition = newHScrollPos;
							scroller.updateContentHolder(false);
						}
					}										
					return;
				}
			}
		}
		
		public function scrollTo(verPos:Number = 0,horPos:Number=0):void
		{
			if (scroller) scroller.scrollTo(verPos,horPos);
		}
		
		protected function onScrolling(event:ScrollerEvent):void
		{
			verticalScrollPosition = scroller.verticalScrollPosition;
			horizontalScrollPosition = scroller.horizontalScrollPosition;
		}
		
		protected function contentHolder_resizeHandler(event:SapphireEvent):void
		{
			if (scroller) scroller.updateContentHolder();
		}
		
		//======================================================================
		// event handlers
		//======================================================================
		protected function contentHolder_itemChangeHandler(event:Event):void
		{
			_selectedIndex = contentHolder.selectedIndex;
			_selectedItem = contentHolder.selectedItem;
			dispatchEvent(new Event(Event.CHANGE));
		}
	}
}