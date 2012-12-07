package com.sapphire
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class Button extends ButtonBase
	{
		//=================================================================
		//
		// Constructors
		//
		//=================================================================
		public function Button()
		{
			super();
		}
		//=================================================================
		//
		// Override event handlers
		//
		//=================================================================
		override protected function onMouseUpHandler(event:MouseEvent):void 
		{
			if (enabled)
				currentState = UP;
			else
				currentState = DISABLE;
		}
		
		override protected function onMouseOverHandler(event:MouseEvent):void
		{
			if (enabled)
				currentState = OVER;
			else
				currentState = DISABLE;
		}
		
		override protected function onMouseDownHandler(event:MouseEvent):void
		{
			if (enabled)
				currentState = DOWN;
			else
				currentState = DISABLE;
		}
		
		override protected function onMouseOutHandler(event:MouseEvent):void 
		{
			if (enabled)
				currentState = UP;
			else
				currentState = DISABLE;
		}
	}
}