package com.sapphire.list
{
	import com.sapphire.KineticScroller;
	import com.sapphire.support.ScrollBarPolicy;

	public class KineticHList extends ListBase
	{
		public function KineticHList()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (scroller)
			{
				scroller.verticalScrollPolicy = ScrollBarPolicy.OFF;
				scroller.horizontalScrollPolicy = ScrollBarPolicy.AUTO;
			}
			
			if (contentHolder && scroller)
			{
				contentHolder.visibleWidth = scroller.viewport.width;				
			}
		}
	}
}