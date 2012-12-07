package
{
	public class InviteWindow extends InvitePlayWindowDesign
	{
		public function InviteWindow()
		{
			super();
			init();
		}
		
		private function init():void
		{
			invitePlayList.itemRenderer = InvitePlayRenderer;
			
			var provider:Array = [];
			for (var i:int = 0; i < 10; i++)
			{
				var obj:Object = {};
				obj.name = 'Quest ' + String(i);
				provider.push(obj);
			}
			
			invitePlayList.dataProvider = provider;
			
			progressingDisplay.stop();
			progressingDisplay.visible = false;
			
			messageDisplay.visible = false;
		}
	}
}