package com.sapphire.list 
{
	import com.sapphire.SimpleScroller;
	import com.sapphire.support.IItemRenderer;
	import com.sapphire.support.ScrollBarPolicy;
	
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	public class VList extends ListBase 
	{
		public function VList()
		{
			
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (scroller)
			{
				scroller.verticalScrollPolicy = ScrollBarPolicy.AUTO;
				scroller.horizontalScrollPolicy = ScrollBarPolicy.OFF;
			}
			
			if (contentHolder  && scroller)
			{
				contentHolder.visibleHeight = scroller.viewport.height;
			}
		}
	}

}