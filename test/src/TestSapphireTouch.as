package
{
	import com.greensock.TweenMax;
	import com.sapphire.Button;
	import com.sapphire.KineticScroller;
	import com.sapphire.Slider;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	
	[SWF(width="640",height="960",frameRate="24",backgroundColor='0x999999')]
	public class TestSapphireTouch extends Sprite
	{
		private var buttonToDelete:Button;
		private var buttonClickMe:Button;
		private var mySlider:Slider;
		private var kineticScroller:KineticScroller;
		private var tween:TweenMax;
		
		public function TestSapphireTouch()
		{
			/*buttonToDelete = new Button();
			buttonToDelete.skinClass = ButtonSkin;			
			buttonToDelete.label = 'Delete me';			
			buttonToDelete.x = 400;
			buttonToDelete.y = 100;
			buttonToDelete.addEventListener(MouseEvent.CLICK, decrease);
			addChild(buttonToDelete);
			
			buttonClickMe = new MyButton();
			buttonClickMe.label = 'Click to Delete';
			buttonClickMe.x = 600;
			buttonClickMe.y = 100;
			buttonClickMe.addEventListener(MouseEvent.CLICK, increase);
			addChild(buttonClickMe);
			
			mySlider = new Slider();
			mySlider.thumbAlwaysInsideTrack = true;
			mySlider.snapInternal = 10;
			//mySlider.value = 100;
			mySlider.skinClass = SliderSkin;
			mySlider.x = 200;
			mySlider.y = 400;
			addChild(mySlider);
			
			var myContent:MyContentHolder = new MyContentHolder();
			myContent.x = 100;
			myContent.y = 100;
			
			
			kineticScroller = new KineticScroller();
			kineticScroller.skinClass = KineticScrollerSkin;
			kineticScroller.x = 100;
			kineticScroller.y = 100;
			kineticScroller.contentHolder = myContent;
			
			addChild(myContent);
			addChild(kineticScroller);*/
			
			var inviteWindow:InviteWindow = new InviteWindow();
			inviteWindow.x = stage.stageWidth >> 1;
			inviteWindow.y = stage.stageHeight >> 1;
			addChild(inviteWindow);
		}
		
		private function clickHandler(event:MouseEvent):void
		{
			if (this.contains(buttonToDelete))
			{
				removeChild(buttonToDelete);
				buttonClickMe.label = 'Click to Add';
			}
			else
			{
				addChild(buttonToDelete);
				buttonClickMe.label = 'Click to Delete';
			}
		}
		
		private function increase(e:MouseEvent):void
		{
			var val:Number = mySlider.value;
			mySlider.value = val + mySlider.snapInternal;
		}
		
		private function decrease(e:MouseEvent):void
		{
			var val:Number = mySlider.value;
			mySlider.value = val - mySlider.snapInternal;
		}
	}
}