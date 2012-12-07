package com.sapphire.event 
{
	import flash.events.Event;
	
	
	public class PropertyChangeEvent extends Event 
	{
		public static const PROPERTY_CHANGE:String = 'sapphirePropertyChange';
		public var host:*;
		public var field:*;
		public var newValue:*;
		
		public function PropertyChangeEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			return new PropertyChangeEvent(type, bubbles, cancelable);
		} 
		
		public override function toString():String 
		{ 
			return formatToString("PropertyChangeEvent", "type", "bubbles", "cancelable", "eventPhase"); 
		}
		
	}
	
}