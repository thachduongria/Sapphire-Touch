package com.sapphire.core
{
	import com.sapphire.error.ScreenError;
	import com.sapphire.screen.IScreen;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	public class ScreenManager extends EventDispatcher
	{
		//=================================================================
		//
		// Class variables
		//
		//=================================================================
		private static var _instance:ScreenManager;
		
		//=================================================================
		//
		// Class methods
		//
		//=================================================================
		public static function getInstance():ScreenManager
		{
			if (!_instance)
				_instance = new ScreenManager();
			return _instance;
		}
		
		//=================================================================
		//
		// Constructors
		//
		//=================================================================
		public function ScreenManager()
		{
			//screenContaner = CIAO88.contentLayer;
		}
		//=================================================================
		//
		// Variables (public, protected, private)
		//
		//=================================================================
		
		/**
		 * Các screen sẽ được add lên đây 
		 */		
		public var screenContaner:DisplayObjectContainer;
		
		private var _currentScreen:IScreen;
		private var _screenDictionary:Dictionary = new Dictionary(true);
		private var _screenStack:Array = [null];
		//=================================================================
		//
		// Methods (public, protected, private)
		//
		//=================================================================
		
		/**
		 * Đăng ký một screen vào trong từ điển 
		 * @param name : Tên
		 * @param instance : đối tượng screen
		 * 
		 */		
		public function registerScreen(name:String, instance:IScreen):void
		{
			_screenDictionary[name] = instance;
		}
		
		/**
		 * 
		 * Lấy ra đối tượng screen trong từ điển 
		 * 
		 * @param name : tên screen cần lấy
		 * @return : đối tượng IScreen
		 * 
		 */		
		public function getScreen(name:String):IScreen
		{
			return _screenDictionary[name];
		}
		
		/**
		 * Kiểm tra xem một screen có có trong từ điển hay không
		 * @param name : tên screen cần kiểm tra
		 * @return 
		 * 
		 */		
		public function hasScreen(name:String):Boolean
		{
			return getScreen(name) != null;
		}
		
		/**
		 * 
		 * Lấy đối tượng IScreen đang hiển thị hiện tại 
		 * 
		 * @return 
		 * 
		 */		
		public function getCurrentScreen():IScreen
		{
			return _currentScreen;
		}
		
		/**
		 * 
		 * Thiết lập screen hiện tại sẽ hiển thị nếu có
		 * @param value
		 * 
		 */		
		public function set currentScreen(value:String):void
		{
			//Xóa screen trước đó (nếu tồn tại)
			if (_currentScreen)
			{
				_currentScreen.onHide();
				_currentScreen = null;
			}
			//Tạo screen mới (nếu có)
			if (value)
			{
				_currentScreen = getScreen(value);
				if (!_currentScreen)
					throw new ScreenError("Không tồn tại screen với tên là: '" + value+"'");
				
				_currentScreen.onShow();
			}
		}
		
		/**
		 *
		 * Đưa một đối tượng screen vào trong stack và hiển thị
		 * 
		 * @param screenName: Tên screen trong từ điển
		 * 
		 */		
		public function push(screenName:String):void
		{
			_screenStack.push(screenName);
			currentScreen = screenName;
			
			screenContaner.addChild(getScreen(screenName) as DisplayObject);
		}
		
		/**
		 * Đưa một screen ra khỏi stack và xóa hiển thị
		 * 
		 */		
		public function pop():void
		{
			if (_screenStack.length == 0)
			{
				return;
			}
			
			//Lấy screen cũ
			var oldScreenName:String = _screenStack.pop();
			var oldScreen:IScreen = getScreen(oldScreenName);
			
			//đặt screen hiện tại nếu có
			currentScreen = _screenStack[_screenStack.length - 1];
			
			if (oldScreen && oldScreen.screenContainer)
			{
				oldScreen.screenContainer.removeChild(oldScreen as DisplayObject); // xóa hiển thị
				if (!oldScreen.persisted) delete _screenDictionary[oldScreenName]; //xóa mapping nếu muốn
				oldScreen = null;
			}
			
		}
		
		public function display(screenName:String):void
		{
			if (screenName == _screenStack[_screenStack.length - 1] )
			{
				trace("====CIAO SCREEN MANAGER==== đang ở " + screenName + " rồi");
				return;
			}
			pop();
			push(screenName);
		}
		
		public function previousScreen():void
		{
			pop();
			if (_screenStack.length > 0)
			{
				push(_screenStack[_screenStack.length - 1]);
			}
		}
		
		public function gotoFirst():void
		{
			while (_screenStack.length > 1)
			{
				_screenStack.pop();
			}
			
			currentScreen = _screenStack[0];
		}
		
		public function get currentScreenName():String
		{
			return _screenStack[_screenStack.length - 1];
		}
	}
}