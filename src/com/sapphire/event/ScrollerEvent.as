package com.sapphire.event
{
	import flash.events.Event;
	
	public class ScrollerEvent extends Event
	{
		public static const SCROLL_POSITION_CHANGE:String = 'scrollPositionChange';
		
		public function ScrollerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}