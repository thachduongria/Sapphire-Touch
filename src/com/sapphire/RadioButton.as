package com.sapphire 
{
	import com.sapphire.support.RadioButtonGroup;
	
	public class RadioButton extends ToggleBase 
	{
		
		public function RadioButton() 
		{
			super();
		}
		
		private var _radioGroup:RadioButtonGroup;
		
		public function get radioGroup():RadioButtonGroup 
		{
			return _radioGroup;
		}
		
		public function set radioGroup(value:RadioButtonGroup):void 
		{
			if (_radioGroup == value) return;
			
			if (_radioGroup)
				_radioGroup.removeRadio(this);
			
			_radioGroup = value;
			
			if (_radioGroup)
				_radioGroup.addRadio(this);
		}
		
	}

}