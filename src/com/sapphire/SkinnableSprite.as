package com.sapphire
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	
	public class SkinnableSprite extends Sprite
	{
		//=================================================================
		//
		// Constructors
		//
		//=================================================================
		public function SkinnableSprite()
		{
			super();
			
			this.addEventListener(Event.ADDED_TO_STAGE, onAddedToStage, false, 0, true);
			this.addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage, false, 0, true);
			
			initSkinParts();
			checkSkin();
		}
		//=================================================================
		//
		// Variables (public, protected, private)
		//
		//=================================================================
		protected var _skinParts:Array; //mảng String chứa tên của các skin_part
		//=================================================================
		//
		// Properties (getter & setter)
		//
		//=================================================================
		protected var _skin:Sprite;
		public function get skin():Sprite
		{
			if (this.hasOwnProperty('skinDisplay'))
				return this['skinDisplay'];
			return _skin;
		}
		
		public function set skin(value:Sprite):void
		{
			_skin = value;
		}	
		
		/**
		 * width
		 */
		override public function get width():Number 
		{
			if (skin)
				return skin.width;
			return NaN;
		}
		
		override public function set width(value:Number):void 
		{
			if (!isNaN(value))
			{
				if (skin) skin.width = value;
			}
		}
		
		/**
		 * height
		 */
		override public function get height():Number 
		{
			if (skin)
				return skin.height;
			return NaN;
		}
		
		override public function set height(value:Number):void 
		{
			if (!isNaN(value))
				if (skin) skin.height = value;
		}
		
		/**
		 * Định nghĩa xem đối tượng được enabled hay không 
		 */
		private var _enabled:Boolean = true;
		public function get enabled():Boolean
		{
			return _enabled;
		}
		public function set enabled(value:Boolean):void
		{
			_enabled = value;
			mouseEnabled = _enabled;
			mouseChildren = _enabled;
		}
		
		/**
		 * Class của skin của Sprite 
		 */	
		private var _skinClass:Object;
		public function get skinClass():Object
		{
			return _skinClass;
		}

		public function set skinClass(value:Object):void
		{
			_skinClass = value;
			attackSkin();
		}
		
		/**
		 * Trạng thái của Sprite 
		 */	
		protected var _currentState:String;
		public function get currentState():String
		{
			return _currentState;
		}
		public function set currentState(value:String):void
		{
			if (_currentState == value) return;
			
			_currentState = value;
			if (skin && skin is MovieClip)
			{
				MovieClip(skin).gotoAndStop(_currentState);
			}
			invalidateSkinParts();
		}
		
		/**
		 * Lựa chọn xem khi đối tượng bị removed khỏi stage thì có xóa luôn Skin không
		 */
		private var _autoDestroySkin:Boolean = false;
		public function get autoDestroySkin():Boolean 
		{
			return _autoDestroySkin;
		}
		
		public function set autoDestroySkin(value:Boolean):void 
		{
			_autoDestroySkin = value;
		}
		
		/**
		 * Skin_part thay đổi
		 * 
		 * Tìm xem có part nào được/bị add/remove không
		 */
		public function invalidateSkinParts():void
		{
			for each (var part:String in _skinParts)
			{
				if (this[part]) //part được ghi nhận là đã "added"
				{
					if (!skin[part]) //nhưng lại ko có trong skin
					{
						partRemoved(part);						
						this[part] = null;
					}
				}
				else if ((part in skin) && skin[part])
				{
					this[part] = skin[part];
					if (this[part] is SkinnableSprite)
						SkinnableSprite(this[part]).autoDestroySkin = autoDestroySkin;
					if (this[part] is TextField)
						TextField(this[part]).defaultTextFormat = TextField(skin[part]).defaultTextFormat;
					partAdded(part);
				}
			}
		}
		//=================================================================
		//
		// Methods (public, protected, private)
		//
		//=================================================================
		private function checkSkin():void
		{
			if (skin)
			{
				skinAdded();
			}
		}
		
		
		/**
		 * Khởi tạo mảng (String) các Skin Parts
		 */
		protected function initSkinParts():void
		{
			//_skinParts = ['part1','part2'];
		}
		
		/**
		 * attack skin
		 */
		protected function attackSkin():void
		{
			if (_skinClass)
			{
				if (skin)
				{
					this.removeChild(skin);
					skinRemoved();
					skin = null;
				}
				
				try
				{
					if (_skinClass is Class)
						skin = Sprite(new _skinClass());	
					else if (_skinClass is String)
					{
						var claz:Class = getDefinitionByName(String(_skinClass)) as Class;
						skin = Sprite(new claz());
					}
				}
				catch(e:Error)
				{
					throw new Error("Không thể khởi tạo SkinClass của ::" + this);
				}
				
				if (skin)
				{
					skinAdded();
					addChild(skin);
				}
			}
		}
		/**
		 * Khi một skin được add vào Sprite 
		 * 
		 */	
		protected function skinAdded():void
		{
			if(_skinParts)
			{
				for each (var part:String in _skinParts) 
				{
					if (part in skin && skin[part])
					{
						this[part] = skin[part];
						//có tự động hủy skin hay không
						if (this[part] is SkinnableSprite)
							SkinnableSprite(this[part]).autoDestroySkin = autoDestroySkin;
						if (this[part] is TextField)
							TextField(this[part]).defaultTextFormat = TextField(skin[part]).getTextFormat();
						partAdded(part);
					}
				}
			}
		}
		
		/**
		 * + Khi remove một skin ra khỏi SkinnableSprite
		 * + Khi SkinnableSprite bị remove khỏi stage thì phương thức này cũng được gọi do
		 *   SkinnableSprite sẽ tự đông remove skin
		 */	
		protected function skinRemoved():void
		{
			if (_skinParts)
			{
				for each (var part:String in _skinParts) 
				{
					if (this[part] != null)
					{
						partRemoved(part);
						this[part] = null;
					}
				}
			}
		}
		
		/**
		 * khi một skin_part được add
		 * @param partName: tên part
		 * @param partInstance: đối tượng
		 * 
		 */		
		protected function partAdded(partName:String):void
		{
			
		}
		
		/**
		 * Khi một skin_part bị remove 
		 * @param partName: tên part
		 * @param partInstance: đối tượng
		 * 
		 */		
		protected function partRemoved(partName:String):void
		{
			
		}
		
		//=================================================================
		//
		// Event handlers
		//
		//=================================================================
		
		protected function onAddedToStage(event:Event):void
		{
			if (skin == null)
			{				
				attackSkin();
			}
			else if (!this.contains(skin))
			{
				skinAdded();
				this.addChild(skin);
			}
		}
		protected function onRemovedFromStage(event:Event):void
		{
			skinRemoved();
			removeChild(skin);
			
			if (autoDestroySkin)
			{				
				skin = null;
			}
		}

	}
}