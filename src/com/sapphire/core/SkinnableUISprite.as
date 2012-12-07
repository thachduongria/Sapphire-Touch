package com.sapphire.core
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.utils.getDefinitionByName;

	public class SkinnableUISprite extends UISprite
	{
		//=================================================================
		//
		// Constructors
		//
		//=================================================================
		public function SkinnableUISprite()
		{
			super();
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
		private var skinDirty:Boolean = false;
		public function get skin():Sprite
		{
			if (this.hasOwnProperty('skinDisplay'))
				return this['skinDisplay'];
			return _skin;
		}
		
		public function set skin(value:Sprite):void
		{
			if (_skin == value) return;
			
			_skin = value;			
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
			skinDirty = true;
			skinStateDirty = true;
			invalidate(INVALIDATION_FLAG_PROPERTIES,INVALIDATION_FLAG_SIZE);
		}
		
		/**
		 * Lựa chọn xem khi đối tượng bị removed khỏi stage thì có xóa luôn Skin không
		 */
		private var _autoDestroySkin:Boolean = false;
		private var _autoDestrouSkinChange:Boolean = false;
		public function get autoDestroySkin():Boolean 
		{
			return _autoDestroySkin;
		}
		
		public function set autoDestroySkin(value:Boolean):void 
		{
			if (_autoDestroySkin == value) return;
			
			_autoDestroySkin = value;
			_autoDestrouSkinChange = true;
			invalidate(INVALIDATION_FLAG_PROPERTIES);
			
		}
		
		private var _currentState:String = '';
		private var skinStateDirty:Boolean = false;
		public function get currentState():String
		{
			return _currentState;
		}

		public function set currentState(value:String):void
		{
			if (_currentState == value) return;
			
			_currentState = value;
			skinStateDirty = true;
			invalidate(INVALIDATION_FLAG_PROPERTIES,INVALIDATION_FLAG_DRAW);
		}

		
		//=================================================================
		//
		// Override protected methods
		//
		//=================================================================
		
		override protected function initialize():void
		{
			initSkinParts();
		}
		
		override protected function activate():void
		{
			if (skin)
			{
				if (!this.contains(skin)) 
					addChild(skin);
				skinAdded();
			}
		}
		
		override protected function deactivate():void
		{			
			if (autoDestroySkin)
			{
				detachSkin();
			}
			else
			{
				skinRemoved();
				removeChild(skin);
			}
		}
		
		protected function initSkinParts():void
		{
			_skinParts = [];
		}
		
		override protected function commitProperties():void
		{
			if (skinDirty)
			{
				skinDirty = false;
				//validate skin change
				if (skin)
					detachSkin();
				
				attachSkin();
			}
			
			if (skinStateDirty)
			{				
				skinStateDirty = false;
				if (skin && skin is MovieClip) {
					MovieClip(skin).gotoAndStop(currentState);
					findLostAndFoundSkinParts();
				}
			}
		}
		
		override protected function measure():void
		{
			super.measure();
			if (skin)
			{
				var measuredWidth:Number = skin.width;
				var measuredHeight:Number = skin.height;
				
				setSizeInternal(measuredWidth,measuredHeight,false);
			}
		}
		
		/**
		 * state is changed, some part is lost, some part is found 		
		 */		
		private function findLostAndFoundSkinParts():void
		{
			if (!_skinParts) return;
			
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
					try {
						this[part] = skin[part];
					}
					catch (err:Error)
					{
						throw err;
					}
					
					if (this[part] is SkinnableUISprite)
						SkinnableUISprite(this[part]).autoDestroySkin = autoDestroySkin;
					if (this[part] is TextField)
						TextField(this[part]).defaultTextFormat = TextField(skin[part]).defaultTextFormat;
					partAdded(part);
				}
			}
		}		
		
		private function attachSkin():void
		{
			if (_skinClass)
			{
				try
				{
					if (_skinClass is Class)
						skin = Sprite(new _skinClass());	
					else if (_skinClass is String)
					{
						var claz:Class = getDefinitionByName(String(_skinClass)) as Class;
						skin = Sprite(new claz());
					}
					
					addChild(skin);
					skinAdded();
				}
				catch(e:Error)
				{
					throw new Error("Không thể khởi tạo SkinClass của ::" + this);
				}
			}						
		}
		
		private function detachSkin():void
		{						
			removeChild(skin);
			skinRemoved();
			skin = null;
		}
		
		protected function skinAdded():void
		{
			findSkinParts();
		}
		
		private function findSkinParts():void
		{
			if(_skinParts)
			{
				for each (var part:String in _skinParts) 
				{
					if (part in skin && skin[part])
					{
						try {
							this[part] = skin[part];
						}
						catch (err:Error)
						{
							throw err;
						}
						//có tự động hủy skin hay không
						if (this[part] is SkinnableUISprite)
							SkinnableUISprite(this[part]).autoDestroySkin = autoDestroySkin;
						if (this[part] is TextField)
							TextField(this[part]).defaultTextFormat = TextField(skin[part]).getTextFormat();
						partAdded(part);
					}
				}
			}
		}
		
		protected function skinRemoved():void
		{
			clearSkinParts();
		}
		
		private function clearSkinParts():void
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
		
		protected function partAdded(partName:String):void
		{
			
		}
		
		protected function partRemoved(partName:String):void
		{
			
		}
	}
}