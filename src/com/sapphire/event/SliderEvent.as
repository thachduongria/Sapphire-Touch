package com.sapphire.event 
{
	import flash.events.Event;
	
	/**
	 * ...
	 * @author 
	 */
	public class SliderEvent extends Event 
	{
		public static const VALUE_CHANGE:String = "valueChange";
		
		
		public function SliderEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
		} 
		
		public override function clone():Event 
		{ 
			return new SliderEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("SliderEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}