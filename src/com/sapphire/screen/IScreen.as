package com.sapphire.screen
{
	import flash.display.DisplayObjectContainer;
	public interface IScreen
	{
		/**
		 * Được gọi khi một screen được add lên một container 
		 * 
		 */		
		function onShow():void;
		
		/**
		 * Được gọi khi một screen bị remove khỏi một container 
		 * 
		 */		
		function onHide():void;
		
		/**
		 * khi chuyển sang screen khác thì screen này sẽ được xóa hết hay tái sử dụng
		 */
		function get persisted():Boolean;
		function set persisted(value:Boolean):void;
		
		function get screenContainer():DisplayObjectContainer;
	}
}