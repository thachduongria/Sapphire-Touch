package com.sapphire.support 
{
	
	public interface IItemRenderer 
	{
		function set itemIndex(value:int):void;
		function get itemIndex():int;
		function set selected(value:Boolean):void;
		function get selected():Boolean;
		function get data():Object;
		function set data(value:Object):void;
		function destroy():void;
	}
	
}