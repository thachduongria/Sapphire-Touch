package com.sapphire.core 
{
	import com.sapphire.window.BaseWindow;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	public class PopupManager extends EventDispatcher 
	{
		
		private static var _instance:PopupManager;
		
		public static function getInstance():PopupManager
		{
			if (!_instance)
				_instance = new PopupManager();
			return _instance;
		}
		//=================================================================
		//
		// Constructors
		//
		//=================================================================
		public function PopupManager() 
		{
			if (_instance)
				throw new Error("Singleton exception in PopupManager");
		}
		//=================================================================
		//
		// Variables (public, protected, private)
		//
		//=================================================================
		private var _modalMapping:Dictionary = new Dictionary(true);
		
		
		
		/**
		 * Các popup sẽ được add lên đây
		 */
		public var popupContainer:DisplayObjectContainer;
		
		public var stage:Stage;
		/**
		 * Vùng tối ở dưới popup
		 */
		private var _modalDisplay:Shape;
		private var _modalLinking:Dictionary = new Dictionary(true);
		
		//=================================================================
		//
		// Properties
		//
		//=================================================================
		/**
		 *Tỉ lệ giãn popup khi add vào 
		 */		
		private var _scaleFactor:Number = 1;
		public function get scaleFactor():Number
		{
			return _scaleFactor;
		}

		public function set scaleFactor(value:Number):void
		{
			_scaleFactor = value;
		}

		//=================================================================
		//
		// Methods (public, protected, private)
		//
		//=================================================================
		public function createPopup(popupClass:Class, createModal:Boolean = true):void
		{
			var _popup:DisplayObject = new popupClass();
			popupContainer.addChild(_popup);
		}
		
		public function addPopup(target:BaseWindow, createModal:Boolean = true , centerPopup:Boolean = true, runEffect:Boolean = true ):void
		{
			if (centerPopup)
			{
				target.x = stage.stageWidth / 2;
				target.y = stage.stageHeight / 2;
			}
			
			if (createModal)
			{			
				
				closeAllPopup(); //Đóng các popup khác
				if (!_modalDisplay) 
				{
					_modalDisplay = new Shape();
					_modalDisplay.graphics.beginFill(0x000000, .6);
					_modalDisplay.graphics.drawRect(0, 0, stage.stageWidth, stage.stageHeight);
					_modalDisplay.graphics.endFill();
				}
				if (!popupContainer.contains(_modalDisplay))
					popupContainer.addChild(_modalDisplay);
				
				_modalMapping[target] = _modalDisplay;
			}
			
			target.scaleX = target.scaleY = scaleFactor;
			popupContainer.addChild(target);
			
			
			target.open(runEffect);
		}
				
		public function closePopup(target:BaseWindow,runEffect:Boolean = false):void
		{
			if (!target) return;
			
			if (popupContainer.contains(target))
			{
				target.onHide();
				target.close(runEffect);
				popupContainer.removeChild(target);
				
				//remove modal
				if (_modalMapping[target])
				{
					delete _modalMapping[target];
					if (_modalDisplay && popupContainer.contains(_modalDisplay))
					{
						popupContainer.removeChild(_modalDisplay);
						_modalDisplay = null;
					}
				}			
				
				target = null;
			}
		}
		
		public function containPopup(target:BaseWindow):Boolean
		{
			return popupContainer.contains(target);
		}
		
		public function closeAllPopup():void
		{
			var i:int = 0;
			while (popupContainer.numChildren > 0)
			{
				var child:DisplayObject = popupContainer.getChildAt(0);
				if (child is BaseWindow)
				{
					BaseWindow(child).onHide();
					BaseWindow(child).close();
					if (_modalMapping[child])
						delete _modalMapping[child];
				}
				popupContainer.removeChild(child);				
				child = null;
			}
			if(_modalDisplay) _modalDisplay = null;
		}
	}
}