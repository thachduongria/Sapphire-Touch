package com.sapphire.event
{
	import flash.events.Event;
	
	public class UISpriteEvent extends Event
	{
		public static const RESIZE:String = 'uiResize';
		
		public function UISpriteEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}