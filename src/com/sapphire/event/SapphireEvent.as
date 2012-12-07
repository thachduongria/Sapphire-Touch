package com.sapphire.event
{
	import flash.events.Event;
	
	public class SapphireEvent extends Event
	{
		public static const RESIZE:String = 'sapphireResize';
		public function SapphireEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}