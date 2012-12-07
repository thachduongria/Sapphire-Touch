package com.sapphire.window 
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.easing.Elastic;
	import com.sapphire.SkinnableSprite;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	
	public class BaseWindow extends Sprite 
	{
		public function BaseWindow() 
		{
			
		}
		//=================================================================
		//
		// Variables (public, protected, private)
		//
		//=================================================================
		private var _openTime:Number = .3;
		/**
		 * Tween for Open Effect
		 */
		protected var _openTween:TweenMax;
		
		//=================================================================
		//
		// Methods (public, protected, private)
		//
		//=================================================================	
		public function open(runEffect:Boolean = true):void
		{
//			if (runEffect)
//			{				
//				//run animation
//				var bound:Rectangle = this.getBounds(this);
//				var popupBD:BitmapData = new BitmapData(bound.width*this.scaleX,bound.height*this.scaleY,true,0x00000000);
//				var xPos:Number = Math.round(bound.x * Math.abs(this.scaleX));
//				var yPos:Number = Math.round(bound.y * Math.abs(this.scaleY));
//				var mat:Matrix = new Matrix(Math.abs(this.scaleX),0,0,Math.abs(this.scaleY), -xPos,-yPos);
//				popupBD.draw(this,mat);
//				var popupBM:Bitmap = new Bitmap(popupBD);
//				popupBM.smoothing = true;
//				popupBM.x = xPos;
//				popupBM.y = yPos;
//				
//				var popupSprite:Sprite = new Sprite();
//				popupSprite.addChild(popupBM);				
//				
//				/*if (Capabilities.cpuArchitecture == 'ARM')
//				{
//					popupSprite.cacheAsBitmapMatrix = new Matrix();
//					popupSprite.cacheAsBitmap = true;
//				}*/
//				popupSprite.x = this.x;
//				popupSprite.y = this.y;
//				this.parent.addChild(popupSprite);	
//				this.visible = false;
//				_openTween = TweenMax.from(popupSprite,_openTime,{scaleX:0,scaleY:0,ease:Back.easeOut,onComplete:openTweenComplete,onCompleteParams:[popupSprite]});
//			}
//			else
			{
				this.visible = true;
				onShow();
			}			
		}
		
		public function onShow():void
		{
			
		}
		
		public function onHide():void
		{
			
		}
		
		public function close(runEffect:Boolean = false):void
		{
//			if  (TweenMax.isTweening(_openTween))
//			{			
//				_openTween.pause();
//				_openTween.kill();
//				if (this.parent && this.parent.contains(_openTween.target as Sprite)) this.parent.removeChild(_openTween.target as Sprite);
//				_openTween.target = null;
//				_openTween = null;
//			}
//			
//			if (runEffect)
//			{
//				//run animation
//				var bound:Rectangle = this.getBounds(this);
//				var popupBD:BitmapData = new BitmapData(bound.width*this.scaleX,bound.height*this.scaleY,true,0x00000000);
//				var xPos:Number = Math.round(bound.x * Math.abs(this.scaleX));
//				var yPos:Number = Math.round(bound.y * Math.abs(this.scaleY));
//				var mat:Matrix = new Matrix(Math.abs(this.scaleX),0,0,Math.abs(this.scaleY), -xPos,-yPos);
//				popupBD.draw(this,mat);
//				var popupBM:Bitmap = new Bitmap(popupBD);
//				popupBM.smoothing = true;
//				popupBM.x = xPos;
//				popupBM.y = yPos;
//				
//				var popupSprite:Sprite = new Sprite();
//				popupSprite.addChild(popupBM);
//				popupSprite.x = this.x;
//				popupSprite.y = this.y;
//				this.parent.addChild(popupSprite);	
//				this.visible = false;
//				TweenMax.to(popupSprite,_openTime,{scaleX:0,scaleY:0,ease:Back.easeIn,onComplete:closeTweenComplete,onCompleteParams:[popupSprite]});
//			}			
		}
		
		//=================================================================
		//
		// Event handlers
		//
		//=================================================================		
		
		protected function openTweenComplete(popupSprite:Sprite):void
		{
			if (this.parent && this.parent.contains(popupSprite)) this.parent.removeChild(popupSprite);
			popupSprite = null;
			this.visible = true;
			onShow();
		}
		
		protected function closeTweenComplete(popupSprite:Sprite):void
		{
			if (this.parent && this.parent.contains(popupSprite)) this.parent.removeChild(popupSprite);
			popupSprite = null;			
		}
	}

}