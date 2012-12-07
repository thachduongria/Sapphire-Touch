package com.sapphire 
{
	import flash.display.Sprite;
	public class ProgressBarBase extends SkinnableSprite 
	{
		public static const DIRECTION_LEFT:String = "left";
		public static const DIRECTION_RIGHT:String = "right";
		//=================================================================
		//
		// Skin parts
		//
		//=================================================================
		public var track:Sprite;
		public var mover:Sprite;
		//=================================================================
		//
		// Constructors
		//
		//=================================================================
		public function ProgressBarBase() 
		{
			
		}
		//=================================================================
		//
		// Variables (public, protected, private)
		//
		//=================================================================
		private var _maxValue:Number = 100;
		//=================================================================
		//
		// Properties (getter & setter)
		//
		//=================================================================
		/**
		 * Giá trị lớn nhất của progress
		 */
		public function get maxValue():Number 
		{
			return _maxValue;
		}
		
		public function set maxValue(value:Number):void 
		{
			_maxValue = value;
		}
		//=================================================================
		//
		// Override methods (public, protected)
		//
		//=================================================================
		override protected function initSkinParts():void 
		{
			_skinParts = ["mover","track"];
		}
		override protected function partAdded(partName:String):void 
		{
			if (partName == "mover")
			{
				mover.width = 0;
			}
		}
	}

}