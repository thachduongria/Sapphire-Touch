package com.sapphire 
{
	import com.sapphire.core.SkinnableUISprite;
	import com.sapphire.event.SliderEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.text.TextField;
	
	[Event(name="valueChange", type="com.sapphire.event.SliderEvent")]
	public class Slider extends SkinnableUISprite 
	{
		public static const NORMAL:String = 'normal';
		public static const DISABLED:String = 'disabled';
		public static const HORIZONAL:String = "horizonal";
		public static const VERTICAL:String = "vertical";
		private var _scrollBarDirection:String;
		//=================================================================
		//
		// Skin parts
		//
		//=================================================================
		//required
		public var thumb:Sprite;
		public var track:Sprite;
		//optional
		public var mover:Sprite;
		public var valueDisplay:TextField;
		
		public function Slider() 
		{
			super();
			if (enabled) currentState = NORMAL;
			else currentState = DISABLED;
		}
		//=================================================================
		//
		// Variables (public, protected, private)
		//
		//=================================================================
		/**
		 * directionObject['corSelected']
		 * directionObject['hwSelected']
		 */
		protected var directionObject:Object = {corSelected:'x',hwSelected:'width' };
		//=================================================================
		//
		// Override properties (getter & setter)
		//
		//=================================================================
		
		override public function set enabled(val:Boolean):void 
		{
			super.enabled = val;
			
			if (enabled)
			{
				currentState = NORMAL;
			}
			else
			{				
				if (stage)
				{
					stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
					stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
				}
				currentState = DISABLED;
			}
		}
		//=================================================================
		//
		// Properties (getter & setter)
		//
		//=================================================================
		protected var _value:Number = 0;
		private var valueDirty:Boolean = false;
		/**
		 * Giá trị hiện tại của slider
		 */
		public function get value():Number 
		{
			return _value;
		}
		
		public function set value(val:Number):void 
		{
			if (_value == val) return;
			
			_value = val;
			
			valueDirty = true;
			invalidate(INVALIDATION_FLAG_PROPERTIES);
						
			dispatchEvent(new SliderEvent(SliderEvent.VALUE_CHANGE));
		}
		
		protected var _maxValue:Number = 100;
		/**
		 * Giá trị lớn nhất của slider
		 */
		public function get maxValue():Number 
		{
			return _maxValue;
		}
		
		public function set maxValue(val:Number):void 
		{
			if (_maxValue == val) return;
			_maxValue = val;
			valueDirty = true;
			invalidate(INVALIDATION_FLAG_PROPERTIES);			
		}
		
		protected var _minValue:Number = 0;
		/**
		 * Giá trị nhỏ nhất của slider
		 */
		public function get minValue():Number 
		{
			return _minValue;
		}
		
		public function set minValue(val:Number):void 
		{
			if (_minValue == val) return;
			_minValue = val;
			valueDirty = true;
			invalidate(INVALIDATION_FLAG_PROPERTIES);		
		}
		
		protected var _snapInternal:int = 0; //snap to interval
		/**
		 * Snap Interval
		 */
		public function get snapInternal():int 
		{
			return _snapInternal;
		}
		
		public function set snapInternal(val:int):void 
		{
			_snapInternal = val;
		}
		
		protected var _labelFunction:Function;
		/**
		 * Hàm format text cho valueDisplay
		 */
		public function get labelFunction():Function 
		{
			return _labelFunction;
		}
		
		public function set labelFunction(val:Function):void 
		{
			_labelFunction = val;
		}
		
		private var _thumbPosition:Point;
		protected var thumbPositionDirty:Boolean = false;
		
		public function get thumbPosition():Point
		{
			return _thumbPosition;
		}

		public function set thumbPosition(val:Point):void
		{
			if (_thumbPosition && _thumbPosition[ directionObject['corSelected'] ] == val[ directionObject['corSelected'] ] && _thumbPosition.y == val.y) return;
			
			_thumbPosition = val;
			
			if (_thumbPosition)
			{
				thumbPositionDirty = true;
				invalidate(INVALIDATION_FLAG_PROPERTIES);
			}
		}
		
		private var _thumbAlwaysInsideTrack:Boolean = false;
		public function get thumbAlwaysInsideTrack():Boolean
		{
			return _thumbAlwaysInsideTrack;
		}

		public function set thumbAlwaysInsideTrack(value:Boolean):void
		{
			_thumbAlwaysInsideTrack = value;
		}
		
		public function get scrollBarDirection():String 
		{
			return _scrollBarDirection;
		}
		
		public function set scrollBarDirection(value:String):void 
		{
			_scrollBarDirection = value;
			if (_scrollBarDirection == HORIZONAL)
				directionObject = {corSelected:'x',hwSelected:'width' };
			else if(_scrollBarDirection == VERTICAL)
				directionObject = {corSelected:'y',hwSelected:'height' };
		}
		
		
		//=================================================================
		//
		// Override methods (public, protected)
		//
		//=================================================================
		override protected function initSkinParts():void 
		{
			_skinParts = ["thumb", "track", "mover","valueDisplay"];
		}
		
		override protected function activate():void
		{
			super.activate();
		}
		
		override protected function deactivate():void
		{
			super.deactivate();
		}
		
		override protected function partAdded(partName:String):void 
		{
			if (partName == "thumb")
			{
				thumb.addEventListener(MouseEvent.MOUSE_DOWN, thumb_mouseDownHandler, false, 0, true);
				//thumb[ directionObject['corSelected'] ] = 0;
				thumb.buttonMode = true;
				if (mover) mover[ directionObject['corSelected'] ] = thumb[ directionObject['corSelected'] ];
				thumbPosition = new Point(thumb[ directionObject['corSelected'] ],thumb.y);
			}
			if (partName == "track")
			{
				track.addEventListener(MouseEvent.MOUSE_DOWN, track_mouseDownHandler, false, 0, true);
				track.buttonMode = true;
			}
			if (partName == "mover")
			{
				//mover.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
				mover.buttonMode = true;
				if (thumb) mover[ directionObject['corSelected'] ] = thumb[ directionObject['corSelected'] ];
			}
		}
		
		override protected function partRemoved(partName:String):void 
		{
			if (partName == "thumb")
			{
				thumb.removeEventListener(MouseEvent.MOUSE_DOWN, thumb_mouseDownHandler);
			}
			if (partName == "track")
			{
				track.removeEventListener(MouseEvent.MOUSE_DOWN, track_mouseDownHandler);
			}
			if (partName == "mover")
			{
				//mover.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			}
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if (valueDirty)
			{
				commitValue();				
			}
			
			if (thumbPositionDirty)
			{
				commitThumbPosition();				
			}
		}
		
		
		//=================================================================
		//
		// Methods (public, protected, private)
		//
		//=================================================================
		protected function update(event:MouseEvent):void
		{
			if (skin)
			{
				var p:Point = new Point(event.stageX, event.stageY);
				p = skin.globalToLocal(p);			
				thumbPosition = p;
			}
		}
		
		private function commitValue():void
		{
			valueDirty = false;
			//đang commit value thì ko commit position của thumb nữa
			thumbPositionDirty = false;
			
			if (_minValue > _maxValue) _minValue = 0;
			if (_value < _minValue) _value = _minValue;
			if (_value > _maxValue) _value = _maxValue;
			
			var newThumbX:Number = 0;
			if (_snapInternal != 0)
			{
				//snapInterval ứng vơi bao nhiêu pixel
				var _interval:Number;
				if (_thumbAlwaysInsideTrack)
					_interval = _snapInternal * ( (track[ directionObject['hwSelected'] ] - thumb[ directionObject['hwSelected'] ]) / (_maxValue - _minValue));
				else 
					_interval = _snapInternal * ( track[ directionObject['hwSelected'] ] / (_maxValue - _minValue));
				
				//nhảy bao nhiêu _interval
				var snap:Number = Math.round((_value - _minValue) / _snapInternal);
				//cập nhật toạ độ
				if (_thumbAlwaysInsideTrack)
					newThumbX = snap * _interval + thumb[ directionObject['hwSelected'] ] / 2;
				else
					newThumbX = snap * _interval;
			}
			else
			{
				if (_thumbAlwaysInsideTrack)
					newThumbX = _value/(_maxValue - _minValue) * (track[ directionObject['hwSelected'] ] - thumb[ directionObject['hwSelected'] ]) + thumb[ directionObject['hwSelected'] ] / 2;
				else
					newThumbX = _snapInternal * ( (track[ directionObject['hwSelected'] ]) / (_maxValue - _minValue));
				
				//newThumbX = Math.round(newThumbX);
			}
			
			if (_thumbAlwaysInsideTrack)
			{
				if (newThumbX < thumb[ directionObject['hwSelected'] ] / 2)
					newThumbX = thumb[ directionObject['hwSelected'] ] / 2;
				if (newThumbX > (track[ directionObject['hwSelected'] ] - thumb[ directionObject['hwSelected'] ]/2))
					newThumbX = track[ directionObject['hwSelected'] ] - thumb[ directionObject['hwSelected'] ]/2;
			}
			else
			{
				if (newThumbX < 0)
					newThumbX = 0;
				if (newThumbX > track[ directionObject['hwSelected'] ])
					newThumbX = track[ directionObject['hwSelected'] ];
			}
			
			
			thumb[ directionObject['corSelected'] ] = newThumbX;
			if (mover)
				mover[ directionObject['corSelected'] ] = newThumbX;
			
			displayValue(newThumbX);
		}
		
		private function commitThumbPosition():void
		{
			thumbPositionDirty = false;
			
			var snap:Number = -1;
			if (_snapInternal != 0)
			{
				//từ snapInterval của giá trị
				//tính ra interval ứng với bao nhiêu pixel
				var _interval:Number;
				if (_thumbAlwaysInsideTrack)
				{
					_interval = _snapInternal * ( (track[ directionObject['hwSelected'] ] - thumb[ directionObject['hwSelected'] ]) / (_maxValue - _minValue) );
					//phảy bao nhiểu Interval
					snap = Math.round( (_thumbPosition[ directionObject['corSelected'] ] - thumb[ directionObject['hwSelected'] ]/2 ) / _interval);
					_thumbPosition[ directionObject['corSelected'] ] = snap * _interval + thumb[ directionObject['hwSelected'] ]/2;
				}
				else
				{
					_interval = _snapInternal * (track[ directionObject['hwSelected'] ] / (_maxValue - _minValue) );
					//phảy bao nhiểu Interval
					snap = Math.round(_thumbPosition[ directionObject['corSelected'] ] / _interval);
					_thumbPosition[ directionObject['corSelected'] ] = snap * _interval;
				}
			}
			
			if (_thumbAlwaysInsideTrack)
			{
				if (_thumbPosition[ directionObject['corSelected'] ] < thumb[ directionObject['hwSelected'] ] / 2)
					_thumbPosition[ directionObject['corSelected'] ] = thumb[ directionObject['hwSelected'] ] / 2;
				if (_thumbPosition[ directionObject['corSelected'] ] > (track[ directionObject['hwSelected'] ] - thumb[ directionObject['hwSelected'] ]/2) )
					_thumbPosition[ directionObject['corSelected'] ] = track[ directionObject['hwSelected'] ] - thumb[ directionObject['hwSelected'] ]/2;
			}
			else
			{
				if (_thumbPosition[ directionObject['corSelected'] ] < 0)
					_thumbPosition[ directionObject['corSelected'] ] = 0;
				if (_thumbPosition[ directionObject['corSelected'] ] > track[ directionObject['hwSelected'] ])
					_thumbPosition[ directionObject['corSelected'] ] = track[ directionObject['hwSelected'] ];
			}
			
			//_thumbPosition[ directionObject['corSelected'] ] = Math.round(_thumbPosition[ directionObject['corSelected'] ]);
			thumb[ directionObject['corSelected'] ] = _thumbPosition[ directionObject['corSelected'] ];
			if (mover)
				mover[ directionObject['corSelected'] ] = _thumbPosition[ directionObject['corSelected'] ];
			
			var result:int;
			if (snap != -1)
			{
				result = snap * _snapInternal + _minValue;
			}
			else
			{
				if (_thumbAlwaysInsideTrack)					
					result = int((_maxValue - _minValue) * ( (thumb[ directionObject['corSelected'] ] - (thumb[ directionObject['hwSelected'] ] / 2)) / (track[ directionObject['hwSelected'] ] - thumb[ directionObject['hwSelected'] ]))) + _minValue;
				else
					result = int((_maxValue - _minValue) * (thumb[ directionObject['corSelected'] ] / track[ directionObject['hwSelected'] ])) + _minValue;
			}
			
			if (result > maxValue) result = maxValue;
			if (result < minValue) result = minValue;			
			
			_value = result;
			
			displayValue(NaN);
			
			dispatchEvent(new SliderEvent(SliderEvent.VALUE_CHANGE));
		}			
		protected function displayValue(newThumbX:Number = NaN):void
		{
			if (valueDisplay) 
			{
				if (_labelFunction != null) valueDisplay.text = _labelFunction(_value);
				else valueDisplay.text = String(_value);
				
				if (!isNaN(newThumbX))
					valueDisplay[ directionObject['corSelected'] ] = newThumbX - valueDisplay[ directionObject['hwSelected'] ] / 2;
				else
					valueDisplay[ directionObject['corSelected'] ] = thumb[ directionObject['corSelected'] ] - valueDisplay[ directionObject['hwSelected'] ] / 2;
			}
		}
		//=================================================================
		//
		// Override event handlers
		//
		//=================================================================
		//=================================================================
		//
		// Event handlers
		//
		//=================================================================
		private function thumb_mouseDownHandler(event:MouseEvent):void
		{
			if (this.stage)
			{
				stage.addEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler, false, 0, true);
				stage.addEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler, false, 0, true);
			}
		}
		
		private function track_mouseDownHandler(event:MouseEvent):void
		{
			update(event);
		}
		
		private function stageMouseMoveHandler(event:MouseEvent):void
		{
			update(event);
		}
		
		private function stageMouseUpHandler(event:MouseEvent):void
		{
			if (stage)
			{	stage.removeEventListener(MouseEvent.MOUSE_UP, stageMouseUpHandler);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, stageMouseMoveHandler);
			}
		}
	}

}