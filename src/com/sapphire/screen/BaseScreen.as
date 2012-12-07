package com.sapphire.screen
{
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	
	public class BaseScreen extends Sprite implements IScreen
	{
		public function BaseScreen()
		{
			super();
			addListeners();
			init();
			createChildren();
		}
		//=================================================================
		//
		// Properties (getter & setter)
		//
		//=================================================================
		protected var _persisted:Boolean = true;
		public function get persisted():Boolean 
		{
			return _persisted;
		}
		
		public function set persisted(value:Boolean):void 
		{
			_persisted = value;
		}
		
		public function get screenContainer():DisplayObjectContainer
		{
			return super.parent;
		}
		//=================================================================
		//
		// Methods (public, protected, private)
		//
		//=================================================================
		
		private function addListeners():void
		{
			this.addEventListener(Event.ADDED_TO_STAGE, screenAdded,false,0,true);
		}
		
		protected function init():void
		{
		}
		
		protected function createChildren():void
		{
		}
		
		public function onShow():void
		{
		}
		
		public function onHide():void
		{
		}
		
		//=================================================================
		//
		// Event handlers
		//
		//=================================================================
		protected function screenAdded(event:Event = null):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, screenAdded);
		}
	}
}