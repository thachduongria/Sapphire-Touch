package
{
	public class InvitePlayRenderer extends InvitePlayRendererDesign
	{
		public function InvitePlayRenderer()
		{
			super();
		}
		
		override public function set data(value:Object):void
		{
			super.data = value;
			
			if (data)
			{
				nameDisplay.text = data['name'];
			}
		}
	}
}