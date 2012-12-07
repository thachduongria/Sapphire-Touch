package com.sapphire
{
	import com.sapphire.support.TabButtonGroup;
	
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class TabButton extends ToggleBase
	{
		public function TabButton()
		{
			super();
		}
		
		private var _tabGroup:TabButtonGroup;
		public function get tabGroup():TabButtonGroup
		{
			return _tabGroup;
		}

		public function set tabGroup(value:TabButtonGroup):void
		{
			if (_tabGroup == value) return;
			if (_tabGroup) _tabGroup.removeTab(this);
			_tabGroup = value;
			if (_tabGroup) _tabGroup.addTab(this);			
			
		}

		
		override protected function onMouseDownHandler(event:MouseEvent):void
		{
			if (_selected) return;
			
			_selected = true;
			if (enabled)
			{
				currentState = SELECTED_DOWN;
				dispatchEvent(new Event(Event.CHANGE));
			}
			else
			{
				currentState = SELECTED_DISABLE;
			}						
		}
		
		
	}
}