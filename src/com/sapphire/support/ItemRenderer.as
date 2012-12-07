package com.sapphire.support 
{
	import flash.display.Sprite;
	
	public class ItemRenderer extends Sprite implements IItemRenderer
	{
		//states
		public static const NORMAL:String = 'normal';
		public static const HOVERED:String = 'hovered';
		public static const SELECTED:String = 'selected';
		
		public function ItemRenderer() 
		{
			
		}
		
		protected var _data:Object;
		public function get data():Object
		{
			return _data;
		}
		
		public function set data(value:Object):void
		{
			if (_data == value) return;
			
			_data = value;
		}
		
		protected var _selected:Boolean;
		public function get selected():Boolean 
		{
			return _selected;
		}
		
		public function set selected(value:Boolean):void 
		{
			_selected = value;
		}
		
		protected var _itemIndex:int;
		public function get itemIndex():int 
		{
			return _itemIndex;
		}
		
		public function set itemIndex(value:int):void 
		{
			_itemIndex = value;
		}
		
		public function destroy():void
		{
			
		}
		
	}

}