package com.sapphire
{
	import com.sapphire.core.UISprite;
	import com.sapphire.event.SapphireEvent;
	import com.sapphire.support.IItemRenderer;
	
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	
	public class DataContainer extends UISprite
	{
		public function DataContainer()
		{
			super();
		}
		//=================================================================
		//
		// Variables (public, protected, private)
		//
		//=================================================================
		private var _unrenderedData:Array = [];
		private var _inactiveRenderers:Vector.<IItemRenderer> = new <IItemRenderer>[];
		private var _activeRenderers:Vector.<IItemRenderer> = new <IItemRenderer>[];
		private var _rendererMap:Dictionary = new Dictionary(true);
		
		private var _touchPointID:int = -1;
		private var _isScrolling:Boolean = false;
		
		private var scrollDirty:Boolean = false;
		private var selectionDirty:Boolean = false;
		private var styleDirty:Boolean = false;
		
		private var _rowHeight:Number = NaN;
		private var _rowWidth:Number = NaN;
		
		//=================================================================
		//
		// Properties (getter & setter)
		//
		//=================================================================
		private var _dataProvider:Array = [];
		private var dataProviderDirty:Boolean = false;
		public function get dataProvider():Array
		{
			return _dataProvider;
		}

		public function set dataProvider(value:Array):void
		{
			_dataProvider = value;			
			dataProviderDirty = true;
			invalidate(INVALIDATION_FLAG_PROPERTIES,INVALIDATION_FLAG_SIZE,INVALIDATION_FLAG_DRAW);			
		}
		
		private var _itemRenderer:Class;
		private var itemRendererDirty:Boolean = false;
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
		
		private var _useVirtualLayout:Boolean = true;
		public function get useVirtualLayout():Boolean
		{
			return _useVirtualLayout;
		}

		public function set useVirtualLayout(value:Boolean):void
		{
			_useVirtualLayout = value;
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
			invalidate(INVALIDATION_FLAG_PROPERTIES,INVALIDATION_FLAG_DRAW);
		}		
		
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
			invalidate(INVALIDATION_FLAG_PROPERTIES,INVALIDATION_FLAG_DRAW);
		}

		
		private var _visibleHeight:Number = NaN;		
		/**
		 * Chiều cao vùng nhìn thấy, được set trong trường hợp layout renderer theo chiều dọc 
		 */
		public function get visibleHeight():Number
		{
			return _visibleHeight;
		}

		/**
		 * @private
		 */
		public function set visibleHeight(value:Number):void
		{
			if (_visibleHeight == value) return;
			_visibleHeight = value;
			scrollDirty = true;
			invalidate(INVALIDATION_FLAG_DRAW);
		}
		
		private var _visibleWidth:Number = NaN;
		/**
		 * Chiều rộng vùng nhìn thấy, được set trong trường hợp layout renderer theo chiều ngang 
		 */
		public function get visibleWidth():Number
		{
			return _visibleWidth;
		}

		/**
		 * @private
		 */
		public function set visibleWidth(value:Number):void
		{
			if (_visibleWidth == value) return;
			_visibleWidth = value;
			scrollDirty = true;
			invalidate(INVALIDATION_FLAG_DRAW);
		}

		private var _vGap:Number = 0;
		public function get vGap():Number
		{
			return _vGap;
		}

		public function set vGap(value:Number):void
		{
			if (_vGap == value) return;
			_vGap = value;
			invalidate(INVALIDATION_FLAG_DRAW);
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
			invalidate(INVALIDATION_FLAG_DRAW);
		}
		
		private var _paddingTop:Number = 0;

		public function get paddingTop():Number
		{
			return _paddingTop;
		}

		public function set paddingTop(value:Number):void
		{
			_paddingTop = value;
		}

		private var _paddingLeft:Number = 0;

		public function get paddingLeft():Number
		{
			return _paddingLeft;
		}

		public function set paddingLeft(value:Number):void
		{
			_paddingLeft = value;
		}

		private var _paddingBottom:Number = 0;

		public function get paddingBottom():Number
		{
			return _paddingBottom;
		}

		public function set paddingBottom(value:Number):void
		{
			_paddingBottom = value;
		}

		private var _paddingRight:Number = 0;

		public function get paddingRight():Number
		{
			return _paddingRight;
		}

		public function set paddingRight(value:Number):void
		{
			_paddingRight = value;
		}


		//=================================================================
		//
		// Override protected methods
		//
		//=================================================================
		override protected function activate():void
		{
			super.activate();
		}
		override protected function commitProperties():void
		{
			super.commitProperties();
			//trace('[DataContainer] commit properties');
			if (dataProviderDirty)
			{
				dataProviderDirty = false;
				if (!selectionDirty)
				{
					_selectedIndex = -1;
					_selectedItem = null;
				}				
				
				_rendererMap = new Dictionary(true);
				_unrenderedData = [];
			}
		}
		
		override protected function measure():void
		{
			super.measure();
			//trace('[DataContainer] measure');
			//căn cứ theo layout (vertical, horizontal, tile) để tính toán trước các kích thước
			
			//kích thước của row†
			const needsRowHeight:Boolean = isNaN(this._rowHeight);
			const needsRowWidth:Boolean = isNaN(this._rowWidth);
			
			if (needsRowWidth || needsRowHeight)
			{
				//create temporary itemRenderer
				var tmpRenderer:IItemRenderer
				try
				{ 
					tmpRenderer = IItemRenderer(new _itemRenderer());
				}
				catch(err:Error)
				{
					throw err;
				}
				
				var displayRenderer:DisplayObject = DisplayObject(tmpRenderer);
				
				if (needsRowWidth)
				{
					if ('explicitWidth' in displayRenderer)
						_rowWidth = displayRenderer['explicitWidth'];
					else
						_rowWidth = displayRenderer.width;
				}
				
				if (needsRowHeight) 			
				{
					if ('explicitHeight' in displayRenderer)
						_rowHeight = displayRenderer['explicitHeight'];
					else
						_rowHeight = displayRenderer.height;
				}
				//destroy temporary renderer
				tmpRenderer = null;
			}
			
			var newWidth:Number;
			var newHeight:Number;
			
			//nếu layout là vertical
			if (!isNaN(_visibleHeight))
			{
				newWidth = isNaN(this.explicitWidth) ? _rowWidth : this.explicitWidth;
				newHeight = isNaN(_rowHeight) ? 0 : (_rowHeight * _dataProvider.length) + _vGap*(_dataProvider.length - 1);
			}
			//nếu layout là horizontal
			if (!isNaN(_visibleWidth))
			{
				newWidth = isNaN(_rowWidth) ? 0 : (_rowWidth * _dataProvider.length) + _hGap*(_dataProvider.length - 1);
				newHeight = isNaN(this.explicitHeight) ? _rowHeight : this.explicitHeight;
			}
			
			//set kích thước của component
			setSizeInternal(newWidth,newHeight,false);
			dispatchEvent(new SapphireEvent(SapphireEvent.RESIZE));
			//trace('[DataContainer] measure, actualWidth:',this.actualWidth,', actualHeight:',this.actualHeight);
		}
		
		override protected function draw(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.draw(unscaledWidth,unscaledHeight);
			
			refreshRenderers();
			drawRenderers();
			refreshSelection();
		}
		
		//=================================================================
		//
		// Protected methods
		//
		//=================================================================
		
		//=================================================================		
		// Phase #1
		//=================================================================
		protected function refreshRenderers(itemRendererChange:Boolean = false):void
		{
			if (!itemRendererChange)
			{
				//swap _inactiveRenderers & _activeRenderers
				var temp:Vector.<IItemRenderer> = this._inactiveRenderers;
				this._inactiveRenderers = this._activeRenderers;
				this._activeRenderers = temp;
			}
			
			this._activeRenderers.length = 0;
			
			findUnrenderedData();
			recoverInactiveRenderers();
			renderUnrenderedData();
			freeInactiveRenderers();
		}
		
		protected function findUnrenderedData():void
		{
			var startIndex:int = 0;
			var endIndex:int = this._dataProvider ? this._dataProvider.length : 0;
//			while (_verticalScrollPosition > endIndex * this._rowHeight) {
//				_verticalScrollPosition -= this._rowHeight;
//				_verticalScrollPosition = Math.max(0,_verticalScrollPosition);
//			}
//			while (_horizontalScrollPosition > endIndex * this._rowWidth) {
//				_horizontalScrollPosition -= this._rowWidth;
//				_horizontalScrollPosition = Math.max(0,_horizontalScrollPosition);
//			}
			if(this._useVirtualLayout && !isNaN(this._visibleHeight) && endIndex * this._rowHeight > this._visibleHeight)
			{
				startIndex = Math.max(startIndex, this._verticalScrollPosition / this._rowHeight);
				endIndex = Math.min(endIndex, startIndex + Math.ceil(this._visibleHeight / this._rowHeight) + 1);
			}
			
			if (this._useVirtualLayout && !isNaN(this._visibleWidth) && endIndex * this._rowWidth > this._visibleWidth)
			{
				startIndex = Math.max(startIndex, this._horizontalScrollPosition / this._rowWidth);
				endIndex = Math.min(endIndex, startIndex + Math.ceil(this._visibleWidth / this._rowWidth) + 1);
			}
			
			//trace('[DataContainer] [findUnrenderedData] _rowHeight: ',_rowHeight,', _visibleHeight: ',_visibleHeight);
			//trace('[DataContainer] [findUnrenderedData] _rowWidth: ',_rowWidth,', _visibleWidth: ',_visibleWidth);
			////trace('[DataContainer] [findUnrenderedData] startIndex:',startIndex,' ,endIndex:',endIndex);
			for(var i:int = startIndex; i < endIndex; i++)
			{
				var item:Object = this._dataProvider[i];
				var renderer:IItemRenderer = IItemRenderer(this._rendererMap[item]);
				if(renderer)
				{
					this._activeRenderers.push(renderer);
					this._inactiveRenderers.splice(this._inactiveRenderers.indexOf(renderer), 1);
				}
				else
				{
					this._unrenderedData.push(item);
				}
			}
		}
		
		protected function recoverInactiveRenderers():void
		{
			var itemCount:int = this._inactiveRenderers.length;
			for(var i:int = 0; i < itemCount; i++)
			{
				var renderer:IItemRenderer = this._inactiveRenderers[i];
				delete this._rendererMap[renderer.data];
			}
		}
		
		protected function renderUnrenderedData():void
		{
			var itemCount:int = this._unrenderedData.length;
			for(var i:int = 0; i < itemCount; i++)
			{
				var item:Object = this._unrenderedData.shift();
				var index:int = this._dataProvider.indexOf(item);
				createRenderer(item, index);
			}
		}
		
		protected function createRenderer(item:Object, index:int, isTemporary:Boolean = false):IItemRenderer
		{
			if(this._inactiveRenderers.length == 0)
			{
				var renderer:IItemRenderer;
				try
				{
					renderer = new _itemRenderer();
				}
				catch (err:Error)
				{
					throw (err);
				}
				
				
				const displayRenderer:DisplayObject = DisplayObject(renderer);
				
				/*displayRenderer.addEventListener(MouseEvent.MOUSE_DOWN, renderer_touchHandler);
				displayRenderer.addEventListener(MouseEvent.MOUSE_MOVE, renderer_touchHandler);
				displayRenderer.addEventListener(MouseEvent.MOUSE_UP, renderer_touchHandler);
				displayRenderer.addEventListener(MouseEvent.CLICK, renderer_touchHandler);
				displayRenderer.addEventListener(MouseEvent.ROLL_OVER, renderer_touchHandler);
				displayRenderer.addEventListener(MouseEvent.ROLL_OUT, renderer_touchHandler);*/
				displayRenderer.addEventListener(MouseEvent.CLICK, renderer_clickHandler);
				
				this.addChild(displayRenderer);
				
				//trace('[DataContainer] create new renderer');
			}
			else
			{
				renderer = this._inactiveRenderers.shift();
				//trace('[DataContainer] reuse renderer');
			}
			renderer.itemIndex = index;
			renderer.data = item;			
			//renderer.owner = this.owner;
			
			if(!isTemporary)
			{
				this._rendererMap[item] = renderer;
				this._activeRenderers.push(renderer);
			}
			
			return renderer;
		}		
		
		protected function freeInactiveRenderers():void
		{
			var itemCount:int = this._inactiveRenderers.length;
			for(var i:int = 0; i < itemCount; i++)
			{
				var renderer:IItemRenderer = this._inactiveRenderers.shift();
				destroyRenderer(renderer);
			}
		}
		
		protected function destroyRenderer(renderer:IItemRenderer):void
		{
			//trace('destroy renderere');
			renderer.destroy();
			const displayRenderer:DisplayObject = DisplayObject(renderer);
			displayRenderer.removeEventListener(MouseEvent.CLICK, renderer_clickHandler);			
			this.removeChild(displayRenderer);
		}		
		
		//=================================================================		
		// Phase #2
		//=================================================================
		protected function drawRenderers():void
		{
			if(!this._dataProvider)
			{
				return;
			}
			
			
			const itemCount:int = this._activeRenderers.length;
			
			var renderer:IItemRenderer;
			var displayRenderer:DisplayObject;
			var i:int = 0;
			//vertical layout
			if (!isNaN(_visibleHeight))
			{
				for(i = 0; i < itemCount; i++)
				{
					renderer = this._activeRenderers[i];
					displayRenderer = DisplayObject(renderer);				
					displayRenderer.x = _paddingLeft;
					displayRenderer.y = (this._rowHeight + _vGap) * renderer.itemIndex;
				}
			}
			
			//horizontal layout
			if (!isNaN(_visibleWidth))
			{
				for(i = 0; i < itemCount; i++)
				{
					renderer = this._activeRenderers[i];
					displayRenderer = DisplayObject(renderer);		
					displayRenderer.y = _paddingTop;
					displayRenderer.x = (this._rowWidth + _hGap) * renderer.itemIndex;
				}
			}
		}
		
		//=================================================================		
		// Phase #3
		//=================================================================
		protected function refreshSelection():void
		{
			var renderer:IItemRenderer;
			for each (renderer in this._activeRenderers)
			{
				renderer.selected = false;
			}
			
			if (_selectedItem != null)
			{
				renderer = this._rendererMap[_selectedItem];
				if (renderer)
				{
					_selectedIndex = renderer.itemIndex;
					renderer.selected = true;					
				}
			}
			else if (_selectedIndex != -1 )
			{
				for each (renderer in this._activeRenderers)
				{
					if (renderer.itemIndex == _selectedIndex)
					{
						_selectedItem = renderer.data;
						renderer.selected = true;
						return;
					}
				}
			}
			
			if (selectionDirty)
			{
				selectionDirty = false;
				dispatchEvent(new Event(Event.CHANGE));
			}
		}	
		
		//=================================================================
		//
		// public methods
		//
		//=================================================================
		public function scrollTo(verPos:Number = 0,horPos:Number = 0):void
		{
			verticalScrollPosition = verPos;
			horizontalScrollPosition = horPos;
		}
		
		/**
		 * Dữ liệu bên trong của DataProvider thay đổi, gọi hàm này để vẽ lại renderer 
		 * 
		 */		
		public function invalidateDataProvider():void
		{
			dataProviderDirty = true;
			invalidate(INVALIDATION_FLAG_PROPERTIES);
		}
		
		//=================================================================
		//
		// event handlers
		//
		//=================================================================
		private function renderer_clickHandler(event:MouseEvent):void
		{
			var renderer:IItemRenderer;
			for each (renderer in this._activeRenderers)
			{
				renderer.selected = false;
			}
			
			renderer = event.currentTarget as IItemRenderer;
			renderer.selected = true;
			_selectedIndex = renderer.itemIndex;		
			_selectedItem = renderer.data;
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		
	}
}