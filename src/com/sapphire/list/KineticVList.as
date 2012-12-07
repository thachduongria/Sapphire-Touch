package com.sapphire.list
{
	import com.sapphire.KineticScroller;
	import com.sapphire.support.ScrollBarPolicy;

	public class KineticVList extends ListBase
	{
		public function KineticVList()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (scroller)
			{
				scroller.verticalScrollPolicy = ScrollBarPolicy.AUTO;
				scroller.horizontalScrollPolicy = ScrollBarPolicy.OFF;
			}
			
			if (contentHolder && scroller)
			{
				contentHolder.visibleHeight = scroller.viewport.height;				
			}
		}
	}
}