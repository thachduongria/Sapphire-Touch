package com.sapphire 
{	
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class ToggleBase extends ButtonBase 
	{
		public static const SELECTED:String = "selected";
		
		public static const SELECTED_UP:String = "selectedUp";
		public static const SELECTED_OVER:String = "selectedOver";
		public static const SELECTED_DOWN:String = "selectedDown";
		public static const SELECTED_DISABLE:String = "selectedDisable";
		
		
		public function ToggleBase() 
		{
			
		}
		
		//=================================================================
		//
		// Properties (getter & setter)
		//
		//=================================================================
		/**
		 * is Selected
		 */
		protected var _selected:Boolean = false;
		public function get selected():Boolean 
		{
			return _selected;
		}
		
		public function set selected(value:Boolean):void 
		{
			if (_selected == value) return;
			
			_selected = value;			
			
			if (_selected)
				currentState = SELECTED_UP;
			else
				currentState = UP;
				
			//dispatchEvent(new Event(Event.CHANGE));
		}
		
		override protected function activate():void
		{
			super.activate();
			if (skin)
			{
				if (enabled) 
				{
					if (selected) currentState = SELECTED_UP;
					else currentState = UP;
				}
				else
				{
					if (selected) currentState = SELECTED_DISABLE;
					else currentState = DISABLE;
				}
			}
		}
		//=================================================================
		//
		// Event handlers
		//
		//=================================================================
		override protected function onMouseOverHandler(event:MouseEvent):void 
		{
			if (enabled)
			{
				if (selected)
					currentState = SELECTED_OVER;
				else
					currentState = OVER;
			}
			else
			{
				if (selected)
					currentState = SELECTED_DISABLE;
				else
					currentState = DISABLE;
			}
		}
		
		override protected function onMouseDownHandler(event:MouseEvent):void 
		{
			_selected = !_selected;
			if (enabled)
			{
				if (selected)
					currentState = SELECTED_DOWN;
				else
					currentState = DOWN;
			}
			else
			{
				if (selected)
					currentState = SELECTED_DISABLE;
				else
					currentState = DISABLE;
			}
			
			dispatchEvent(new Event(Event.CHANGE));
		}
		
		override protected function onMouseOutHandler(event:MouseEvent):void 
		{
			if (enabled)
			{
				if (selected)
					currentState = SELECTED_UP;
				else
					currentState = UP;
			}
			else
			{
				if (selected)
					currentState = SELECTED_DISABLE;
				else
					currentState = DISABLE;
			}
		}
		
		override protected function onMouseUpHandler(event:MouseEvent):void 
		{
			if (enabled)
			{
				if (selected)
					currentState = SELECTED_UP;
				else
					currentState = UP;
			}
			else
			{
				if (selected)
					currentState = SELECTED_DISABLE;
				else
					currentState = DISABLE;
			}
		}
		
	}

}