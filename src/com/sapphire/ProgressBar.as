package com.sapphire 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.getTimer;
	public class ProgressBar extends ProgressBarBase 
	{
		public static const MODE_AUTO:String = "auto";
		public static const MODE_MANUAL:String = "manual";
		//=================================================================
		//
		// Skin parts
		//
		//=================================================================
		
		//=================================================================
		//
		// Constructors
		//
		//=================================================================
		public function ProgressBar() 
		{
			
		}
		//=================================================================
		//
		// Variables (public, protected, private)
		//
		//=================================================================
		private var _countValue:Number = 0;
		private var _startTime:Number; //Thời gian lúc bắt đầu
		//=================================================================
		//
		// Properties (getter & setter)
		//
		//=================================================================
		/**
		 * Chuyển động sang "trái" hay "phải"
		 */
		private var _direction:String = "left";
		public function get direction():String 
		{
			return _direction;
		}
		
		public function set direction(value:String):void 
		{
			if (_direction == value) return;
			
			_direction = value;			
		}
		
		/**
		 * Chế độ tự động hay do developer điều khiển
		 */
		private var _mode:String = "manual";
		public function get mode():String 
		{
			return _mode;
		}
		
		public function set mode(value:String):void 
		{
			_mode = value;
		}
		
		/**
		 * Tổng thời gian sẽ chạy progress, chỉ có tác dụng trong manual_mode
		 */
		private var _totalTime:Number = 0;
		public function get totalTime():Number 
		{
			return _totalTime;
		}
		
		public function set totalTime(value:Number):void 
		{
			_totalTime = value;
		}
		//=================================================================
		//
		// Override methods (public, protected)
		//
		//=================================================================
		override protected function skinRemoved():void 
		{
			super.skinRemoved();
			this.removeEventListener(Event.ENTER_FRAME, onProgressHandler);
		}
		//=================================================================
		//
		// Methods (public, protected, private)
		//
		//=================================================================
		
		/**
		 * Kích hoạt progress, chỉ có tác dụng trong manual_mode
		 */
		public function start():void
		{
			if (_mode != ProgressBar.MODE_MANUAL) return;
			
			checkDirection();
			_countValue = 0;
			_startTime = getTimer();
			this.addEventListener(Event.ENTER_FRAME, onProgressHandler, false, 0, true);
		}
		
		public function stop():void
		{
			if (_mode != ProgressBar.MODE_MANUAL) return;
			
			this.removeEventListener(Event.ENTER_FRAME, onProgressHandler);
			mover.width = 0;
		}
		
		public function isRunning():Boolean
		{
			return this.hasEventListener(Event.ENTER_FRAME);
		}
		private function checkDirection():void
		{
			if (_direction == DIRECTION_LEFT)
			{
				mover.width = track.width;
			}
			else if (_direction == DIRECTION_RIGHT)
			{
				mover.width = 0;
			}
		}
		//=================================================================
		//
		// Event handlers
		//
		//=================================================================
		protected function onProgressHandler(event:Event):void
		{
			if (!stage) return;
			
			//Nếu quá thời gian
			if (getTimer() - _startTime > _totalTime * 1000)
			{
				this.removeEventListener(Event.ENTER_FRAME, onProgressHandler);
				
				if (_direction == ProgressBarBase.DIRECTION_LEFT)
				{
					mover.width = 0;
				}
				else if (_direction == ProgressBarBase.DIRECTION_RIGHT)
				{
					mover.width = track.width;
				}
				
				this.dispatchEvent(new Event(Event.COMPLETE));
				return;
			}
			
			//update
			if (_direction == ProgressBarBase.DIRECTION_RIGHT)
			{
				mover.width += track.width / (_totalTime * stage.frameRate);
				
			}
			else if (_direction == ProgressBarBase.DIRECTION_LEFT)
			{
				mover.width -= track.width / (_totalTime * stage.frameRate);
			}
		}
	}

}