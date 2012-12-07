package com.sapphire
{
	import flash.display.Sprite;

	public class VScrollBar extends SkinnableSprite
	{
		public var thumb:Sprite;
		public var track:Sprite;
		
		public function VScrollBar()
		{
			super();
		}
		
		override protected function initSkinParts():void
		{
			_skinParts = ['thumb','track'];
		}
		
		override protected function partAdded(partName:String):void
		{
			if (partName == 'thumb')
			{
				
			}
			if (partName == 'track')
			{
				
			}
		}
	}
}