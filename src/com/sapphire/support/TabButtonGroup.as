package com.sapphire.support
{
	import com.sapphire.TabButton;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	
	public class TabButtonGroup extends EventDispatcher
	{
		public function TabButtonGroup()
		{
			super();
		}
		
		private var _tabs:Array = [];
		
		public function addTab(tab:TabButton):void
		{
			_tabs.push(tab);
			tab.addEventListener(Event.CHANGE, tab_changeHandler, false, 0, true);
		}
		
		public function removeTab(tab:TabButton):void
		{
			var l:int = _tabs.length;
			for (var i:int =  0; i < l; i++)
			{
				if (tab == TabButton(_tabs[i]))
				{
					TabButton(_tabs[i]).removeEventListener(Event.CHANGE, tab_changeHandler);
					_tabs.splice(i, 1);
					i = l;
				}
			}
		}
		
		public function unselectAll():void 
		{
			if (_tabs && _tabs.length > 0)
			{
				for each (var tab:TabButton in _tabs)
				{
					tab.selected = false;
				}
			}
		}
		
		private function tab_changeHandler(event:Event):void
		{
			var currentTab:TabButton = TabButton(event.currentTarget);
			if (currentTab.selected)
			{
				for each (var tab:TabButton in _tabs)
				{
					if (tab != currentTab)
					{
						tab.selected = false;
					}
				}
			}	
		}
		
	}
}