package com.sapphire.support 
{
	import com.sapphire.RadioButton;
	import flash.events.Event;
	import flash.events.EventDispatcher;

	public class RadioButtonGroup extends EventDispatcher 
	{
		
		public function RadioButtonGroup() 
		{
			
		}
		
		private var _radios:Array = [];
		
		public function addRadio(radio:RadioButton):void
		{
			_radios.push(radio);
			radio.addEventListener(Event.CHANGE, radio_changeHandler, false, 0, true);
		}
		
		public function removeRadio(radio:RadioButton):void
		{
			var l:int = _radios.length;
			for (var i:int =  0; i < l; i++)
			{
				if (radio == RadioButton(_radios[i]))
				{
					RadioButton(_radios[i]).removeEventListener(Event.CHANGE, radio_changeHandler);
					_radios.splice(i, 1);
					i = l;
				}
			}
		}
		
		public function unselectAll():void 
		{
			if (_radios && _radios.length > 0)
			{
				for each (var radio:RadioButton in _radios)
				{
					radio.selected = false;
				}
			}
		}
		
		private function radio_changeHandler(event:Event):void
		{
			var currentRadio:RadioButton = RadioButton(event.currentTarget);
			if (currentRadio.selected)
			{
				for each (var radio:RadioButton in _radios)
				{
					if (currentRadio != radio && radio.selected)
					{
						radio.selected = false;
					}
				}
			}	
		}
		
	}

}