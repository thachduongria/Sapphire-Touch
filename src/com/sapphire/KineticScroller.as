package com.sapphire
{
	import com.greensock.TweenMax;
	import com.greensock.easing.Circ;
	import com.greensock.easing.Expo;
	import com.greensock.easing.Quad;
	import com.sapphire.core.UISprite;
	import com.sapphire.event.ScrollerEvent;
	import com.sapphire.support.ScrollBarPolicy;
	import com.sapphire.utils.math.clamp;
	import com.urbansquall.metronome.Ticker;
	import com.urbansquall.metronome.TickerEvent;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.utils.getTimer;

	public class KineticScroller extends ScrollerBase
	{
		/**
		 * @private
		 * The minimum physical distance (in inches) that a touch must move
		 * before the scroller starts scrolling.
		 */
		private static const MINIMUM_DRAG_DISTANCE:Number = 0.04;
		
		/**
		 * @private
		 * The point where we stop calculating velocity changes because floating
		 * point issues can start to appear.
		 */
		private static const MINIMUM_VELOCITY:Number = 0.02;
		
		/**
		 * @private
		 * The friction applied every frame when the scroller is "thrown".
		 */
		private static const FRICTION:Number = 0.998;
		
		/**
		 * @private
		 * Extra friction applied when the scroller is beyond its bounds and
		 * needs to bounce back.
		 */
		private static const EXTRA_FRICTION:Number = 0.95;
		
		/**
		 * @private
		 * Older saved velocities are given less importance.
		 */
		private static const VELOCITY_WEIGHTS:Vector.<Number> = new <Number>[2, 1.66, 1.33, 1];
		
		/**
		 * @private
		 */
		private static const MAXIMUM_SAVED_VELOCITY_COUNT:int = 4;
		
		//=================================================================
		//
		// Skin state
		//
		//=================================================================
		public static const NORMAL:String = 'normal';
		public static const DISABLE:String = 'disable';
		//=================================================================
		//
		// Skin parts
		//
		//=================================================================
		protected var verticalThumb:KineticScrollThumb;
		protected var horizontalThumb:KineticScrollThumb;
		
		public function KineticScroller()
		{
			super();
			viewport = this['viewportDisplay'];
		}
		//=================================================================
		//
		// Variables (public, protected, private)
		//
		//=================================================================
		private var _touchPointID:int = -1;
		private var _startTouchX:Number;
		private var _startTouchY:Number;		
		private var _currentTouchX:Number;
		private var _currentTouchY:Number;
		private var _previousTouchTime:int;
		private var _previousTouchX:Number;
		private var _previousTouchY:Number;
		private var _velocityX:Number;
		private var _velocityY:Number;
		private var _previousVelocityX:Vector.<Number> = new <Number>[];
		private var _previousVelocityY:Vector.<Number> = new <Number>[];
		
		private var _startHorizontalScrollPosition:Number;
		private var _startVerticalScrollPosition:Number;
		
		private var _horizontalAutoScrollTween:TweenMax;
		private var _verticalAutoScrollTween:TweenMax;
		private var _isDraggingHorizontally:Boolean = false;
		private var _isDraggingVertically:Boolean = false;
		
		private var _ticker:Ticker;
		
		//flag		
		protected var thumbStyleDirty:Boolean = false;
		
		//=================================================================
		//
		// Properties (getter & setter)
		//
		//=================================================================
		override public function set verticalScrollPosition(value:Number):void
		{
			super.verticalScrollPosition = value;				
			if (verticalThumb) 
			{
				////trace('[KineticScroller] set verticalThumb position');
				verticalThumb.verticalScrollPosition = _verticalScrollPosition;			
			}
		}
		
		override public function set horizontalScrollPosition(value:Number):void
		{
			super.horizontalScrollPosition = value;			
			if (horizontalThumb) horizontalThumb.horizontalScrollPosition = _horizontalScrollPosition;			
		}

		/**
		 * @private
		 */
		private var _hasElasticEdges:Boolean = true;
		
		/**
		 * Determines if the scrolling can go beyond the edges of the viewport.
		 */
		public function get hasElasticEdges():Boolean
		{
			return this._hasElasticEdges;
		}
		
		/**
		 * @private
		 */
		public function set hasElasticEdges(value:Boolean):void
		{
			this._hasElasticEdges = value;
		}
		
		private var _scrollDirection:String = 'natual';
		public function get scrollDirection():String
		{
			return _scrollDirection;
		}

		public function set scrollDirection(value:String):void
		{
			if (_scrollDirection == value) return;
			
			_scrollDirection = value;
			invalidate(INVALIDATION_FLAG_DRAW);
		}
		
		private var _scrollThumbColor:int = 0xffffff;

		public function get scrollThumbColor():int
		{
			return _scrollThumbColor;
		}

		public function set scrollThumbColor(value:int):void
		{
			if (_scrollThumbColor == value) return;
			_scrollThumbColor = value;
			thumbStyleDirty = true;
			invalidate(INVALIDATION_FLAG_STYLES);
		}

		
		private var _isScrollingStopped:Boolean = false;
		
		//=================================================================
		//
		// Override methods (public, protected)
		//
		//=================================================================		
		override protected function activate():void
		{			
			super.activate();
			
			//calculate min,max scroll position
			scrollPositionDirty = true;
			//calculate size
			invalidate(INVALIDATION_FLAG_SIZE);
			//interactive
			this.addEventListener(MouseEvent.MOUSE_DOWN, touchBeginHandler);
		}
		
		override protected function deactivate():void
		{
			super.deactivate();
			this._touchPointID = -1;
			this._velocityX = 0;
			this._velocityY = 0;
			this._previousVelocityX.length = 0;
			this._previousVelocityY.length = 0;
			if(this._verticalAutoScrollTween)
			{
				this._verticalAutoScrollTween.paused = true;
				this._verticalAutoScrollTween = null;
			}
			if(this._horizontalAutoScrollTween)
			{
				this._horizontalAutoScrollTween.paused = true;
				this._horizontalAutoScrollTween = null;
			}
			
			//if we stopped the animation while the list was outside the scroll
			//bounds, then let's account for that
			this._horizontalScrollPosition = clamp(this._horizontalScrollPosition, 0, this._maxHorizontalScrollPosition);
			this._verticalScrollPosition = clamp(this._verticalScrollPosition, 0, this._maxVerticalScrollPosition);
			
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_touchMoveHandler);
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, stage_touchEndHandler);
			this.stage.removeEventListener(TouchEvent.TOUCH_MOVE, stage_touchMoveHandler);
			this.stage.removeEventListener(TouchEvent.TOUCH_END, stage_touchEndHandler);
		}
		override protected function commitProperties():void
		{
			super.commitProperties();
			//trace('[KineticScroller] commit properties');
			
			if (contentHolderDirty)
			{
				contentHolderDirty = false;				
				
				if (_verticalScrollPolicy != ScrollBarPolicy.OFF && !verticalThumb)
				{
					//trace('[KineticScroller] create vertical scroll thumb');
					verticalThumb = new KineticScrollThumb();	
					verticalThumb.type = KineticScrollThumb.VERTICAL;
					verticalThumb.contentHolder = contentHolder;
					verticalThumb.viewport = viewport;
					
					//this.parent.addChildAt(verticalThumb,this.parent.getChildIndex(this));
					this.addChild(verticalThumb);
				}
				
				if (_horizontalScrollPolicy != ScrollBarPolicy.OFF && !horizontalThumb)
				{
					//trace('[KineticScroller] create horizontal scroll thumb');
					horizontalThumb = new KineticScrollThumb();
					horizontalThumb.type = KineticScrollThumb.HORIZONTAL;
					horizontalThumb.contentHolder = contentHolder;
					horizontalThumb.viewport = viewport;
					
					//this.parent.addChildAt(horizontalThumb, this.parent.getChildIndex(this));
					this.addChild(horizontalThumb);
				}
				
				if (horizontalScrollPolicy != ScrollBarPolicy.OFF)
				{
					_maxHorizontalScrollPosition = Math.max(0,contentHolder.width - viewport.width);
					if (isNaN(_maxHorizontalScrollPosition)) _maxHorizontalScrollPosition = 0;
				}
				else
				{
					_maxHorizontalScrollPosition = 0;
				}
				
				if (verticalScrollPolicy != ScrollBarPolicy.OFF)
				{
					_maxVerticalScrollPosition = Math.max(0,contentHolder.height - viewport.height);
					if (isNaN(_maxVerticalScrollPosition)) _maxVerticalScrollPosition = 0;
				}
				else
				{
					_maxVerticalScrollPosition = 0;
				}
			}
			
			if (scrollPositionDirty)
			{
				scrollPositionDirty = false;
				
				if(viewport)
				{
					this._minVerticalScrollPosition = 0;					
					this._maxVerticalScrollPosition = Math.max(0,contentHolder.height - viewport.height);	
					if (isNaN(_maxVerticalScrollPosition)) _maxVerticalScrollPosition = 0;
					
					this._minHorizontalScrollPosition = 0;
					this._maxHorizontalScrollPosition = Math.max(0,contentHolder.width - viewport.width);
					if (isNaN(_maxHorizontalScrollPosition)) _maxHorizontalScrollPosition = 0;
				}
				else
				{
					this._minHorizontalScrollPosition = 0;
					this._minVerticalScrollPosition = 0;
					this._maxHorizontalScrollPosition = 0;
					this._maxVerticalScrollPosition = 0;
				}
			}
		}		
		
		override protected function commitStyles():void
		{
			super.commitStyles();
			
			if (thumbStyleDirty)
			{
				thumbStyleDirty = false;
				if (verticalThumb) verticalThumb.thumbColor = _scrollThumbColor;
				if (horizontalThumb) horizontalThumb.thumbColor = _scrollThumbColor;
			}
		}
		
		override protected function measure():void
		{
			super.measure();
						
			const needsWidth:Boolean = isNaN(this.explicitWidth);
			const needsHeight:Boolean = isNaN(this.explicitHeight);
			
			if(!needsWidth && !needsHeight)
			{
				return;
			}
			
			var newWidth:Number = this.explicitWidth;
			var newHeight:Number = this.explicitHeight;
			if(needsWidth)
			{
				newWidth = this.viewport.width;
			}
			if(needsHeight)
			{
				newHeight = this.viewport.height;
			}
			this.setSizeInternal(newWidth, newHeight, false);			
		}
		
		override protected function draw(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.draw(unscaledWidth,unscaledHeight);
			if (scrollDirty)
			{
				scrollDirty = false;				
				scrollContent();
			}
		}
		
		override public function updateContentHolder(scrollToEnd:Boolean = false):void
		{
			super.updateContentHolder(scrollToEnd);
			if (verticalThumb) verticalThumb.updateContentHolder();
			if (horizontalThumb) horizontalThumb.updateContentHolder();
		}
		
		
		//=================================================================
		//
		// Methods (public, protected, private)
		//
		//=================================================================
		protected function scrollContent():void
		{	
			if (!_scrollToEnd)
			{
				//_verticalScrollPosition = clamp(_verticalScrollPosition,_minVerticalScrollPosition,_maxVerticalScrollPosition);
				//_horizontalScrollPosition = clamp(_horizontalScrollPosition,_minHorizontalScrollPosition,_maxHorizontalScrollPosition);
			}
			else
			{
				_scrollToEnd = false;
				_verticalScrollPosition = _maxVerticalScrollPosition;
				_horizontalScrollPosition = _maxHorizontalScrollPosition;
				if (verticalThumb) verticalThumb.verticalScrollPosition = _verticalScrollPosition;
				if (horizontalThumb) horizontalThumb.horizontalScrollPosition = _horizontalScrollPosition;
			}
			
			
			if(this._clipContent)
			{
				if (contentHolder.mask)
				{
					if (this.contains(contentHolder.mask))
						this.removeChild(contentHolder.mask);
					contentHolder.mask = null;
				}
				
				if(!this.contentHolder.scrollRect) this.contentHolder.scrollRect = new Rectangle();
				
				contentHolder.x = viewport.x;
				contentHolder.y = viewport.y;
				//trace('[KineticScroller][scrollContent] clipContent, actualWidth: ',actualWidth,', actualHeith: ',actualHeight);
				const scrollRect:Rectangle = this.contentHolder.scrollRect;
				scrollRect.width = viewport.width;
				scrollRect.height = viewport.height;
				scrollRect.x = this._horizontalScrollPosition;
				scrollRect.y = this._verticalScrollPosition;
				this.contentHolder.scrollRect = scrollRect;
			}
			else
			{
				if (contentHolder.scrollRect) contentHolder.scrollRect = null;
				
				if (!contentHolder.mask)
				{
					var maskShape:Shape = new Shape();
					with (maskShape)
					{
						graphics.beginFill(0xffffff,0);
						graphics.drawRect(0,0,viewport.width,viewport.height);
						graphics.endFill();
					}
					maskShape.x = viewport.x;
					maskShape.y = viewport.y;
					this.addChild(maskShape);
					
					contentHolder.mask = maskShape;
				}
				
				contentHolder.x = -_horizontalScrollPosition;
				contentHolder.y = -_verticalScrollPosition;
			}
		}
		/**
		 * If the user is dragging the scroll, calling stopScrolling() will
		 * cause the scroller to ignore the drag.
		 */
		public function stopScrolling():void
		{
			this._isScrollingStopped = true;
			this._velocityX = 0;
			this._velocityY = 0;
			
			this._previousVelocityX.length = 0;
			this._previousVelocityY.length = 0;
		}
		
		/**
		 * Throws the scroller to the specified position. If you want to throw
		 * in one direction, pass in NaN or the current scroll position for the
		 * value that you do not want to change.
		 */
		public function throwTo(targetHorizontalScrollPosition:Number = NaN, targetVerticalScrollPosition:Number = NaN, duration:Number = 0.25):void
		{
			if(!isNaN(targetHorizontalScrollPosition))
			{
				if(this._horizontalAutoScrollTween)
				{
					this._horizontalAutoScrollTween.paused = true;
					this._horizontalAutoScrollTween = null;
				}
				if(this._horizontalScrollPosition != targetHorizontalScrollPosition)
				{
					this._horizontalAutoScrollTween = new TweenMax (this, duration,
						{
							horizontalScrollPosition: targetHorizontalScrollPosition,
							ease: Quad.easeOut,
							onComplete: horizontalAutoScrollTween_onComplete
						});
				}
				else
				{
					this.finishScrollingHorizontally();
				}
			}
			
			if(!isNaN(targetVerticalScrollPosition))
			{
				if(this._verticalAutoScrollTween)
				{
					this._verticalAutoScrollTween.paused = true;
					this._verticalAutoScrollTween = null;
				}
				if(this._verticalScrollPosition != targetVerticalScrollPosition)
				{
					this._verticalAutoScrollTween = new TweenMax(this, duration,
						{
							verticalScrollPosition: targetVerticalScrollPosition,
							ease: Quad.easeOut,					
							onComplete: verticalAutoScrollTween_onComplete
						});
				}
				else
				{
					this.finishScrollingVertically();
				}
			}
			
			if (isNaN(targetVerticalScrollPosition) && isNaN(targetHorizontalScrollPosition))
			{
				if (verticalThumb) verticalThumb.hide();
				if (horizontalThumb) horizontalThumb.hide();
			}
		}
		
		/**
		 * @private
		 */
		protected function throwHorizontally(pixelsPerMS:Number):void
		{
			var absPixelsPerMS:Number = Math.abs(pixelsPerMS);
			if(absPixelsPerMS <= MINIMUM_VELOCITY)
			{
				this.finishScrollingHorizontally();
				return;
			}
			var targetHorizontalScrollPosition:Number = this._horizontalScrollPosition + (pixelsPerMS - MINIMUM_VELOCITY) / Math.log(FRICTION);
			if(targetHorizontalScrollPosition < 0 || targetHorizontalScrollPosition > this._maxHorizontalScrollPosition)
			{
				var duration:Number = 0;
				targetHorizontalScrollPosition = this._horizontalScrollPosition;
				while(Math.abs(pixelsPerMS) > MINIMUM_VELOCITY)
				{
					targetHorizontalScrollPosition -= pixelsPerMS;
					if(targetHorizontalScrollPosition < 0 || targetHorizontalScrollPosition > this._maxHorizontalScrollPosition)
					{
						if(this._hasElasticEdges)
						{
							pixelsPerMS *= FRICTION * EXTRA_FRICTION;
						}
						else
						{
							targetHorizontalScrollPosition = clamp(targetHorizontalScrollPosition, 0, this._maxHorizontalScrollPosition);
							duration++;
							break;
						}
					}
					else
					{
						pixelsPerMS *= FRICTION;
					}
					duration++;
				}
			}
			else
			{
				duration = Math.log(MINIMUM_VELOCITY / absPixelsPerMS) / Math.log(FRICTION);
			}
			this.throwTo(targetHorizontalScrollPosition, NaN, duration / 1000);
		}
		
		/**
		 * @private
		 */
		protected function throwVertically(pixelsPerMS:Number):void
		{
			var absPixelsPerMS:Number = Math.abs(pixelsPerMS);
			if(absPixelsPerMS <= MINIMUM_VELOCITY)
			{
				this.finishScrollingVertically();
				return;
			}
			
			var targetVerticalScrollPosition:Number = this._verticalScrollPosition + (pixelsPerMS - MINIMUM_VELOCITY) / Math.log(FRICTION);
			if(targetVerticalScrollPosition < 0 || targetVerticalScrollPosition > this._maxVerticalScrollPosition)
			{
				var duration:Number = 0;
				targetVerticalScrollPosition = this._verticalScrollPosition;
				while(Math.abs(pixelsPerMS) > MINIMUM_VELOCITY)
				{
					targetVerticalScrollPosition -= pixelsPerMS;
					if(targetVerticalScrollPosition < 0 || targetVerticalScrollPosition > this._maxVerticalScrollPosition)
					{
						if(this._hasElasticEdges)
						{
							pixelsPerMS *= FRICTION * EXTRA_FRICTION;
						}
						else
						{
							targetVerticalScrollPosition = clamp(targetVerticalScrollPosition, 0, this._maxVerticalScrollPosition);
							duration++;
							break;
						}
					}
					else
					{
						pixelsPerMS *= FRICTION;
					}
					duration++;
				}
			}
			else
			{
				duration = Math.log(MINIMUM_VELOCITY / absPixelsPerMS) / Math.log(FRICTION);
			}
			this.throwTo(NaN, targetVerticalScrollPosition, duration / 1000);
		}
		
		/**
		 * @private
		 */
		protected function horizontalAutoScrollTween_onComplete():void
		{
			this._horizontalAutoScrollTween = null;
			this.finishScrollingHorizontally();
		}
		
		/**
		 * @private
		 */
		protected function verticalAutoScrollTween_onComplete():void
		{
			//trace('[KineticScroller][verticalAutoScrollTween_onComplete]');
			this._verticalAutoScrollTween = null;		
				
			this.finishScrollingVertically();
		}
		
		/**
		 * @private
		 */
		private function finishScrollingHorizontally():void
		{
			var targetHorizontalScrollPosition:Number = NaN;
			
			if(this._horizontalScrollPosition < this._minVerticalScrollPosition)
			{
				targetHorizontalScrollPosition = _minVerticalScrollPosition;
			}
			else if(this._horizontalScrollPosition > this._maxHorizontalScrollPosition)
			{
				targetHorizontalScrollPosition = this._maxHorizontalScrollPosition;
			}
			
			this._isDraggingHorizontally = false;
			this.throwTo(targetHorizontalScrollPosition, NaN);
		}
		
		/**
		 * @private
		 */
		private function finishScrollingVertically():void
		{
			var targetVerticalScrollPosition:Number = NaN;
			
			//trace('[KineticScroller][finishScrollingVertically] natual,',_minVerticalScrollPosition,' ',_maxVerticalScrollPosition,' ', _verticalScrollPosition);
			if(this._verticalScrollPosition > this._maxVerticalScrollPosition)
			{
				targetVerticalScrollPosition = this._maxVerticalScrollPosition;
			}
			else if(this._verticalScrollPosition < this._minVerticalScrollPosition)
			{
				targetVerticalScrollPosition = this._minVerticalScrollPosition;
			}
			this._isDraggingVertically = false;
			
			//trace('[KineticScroller][finishScrollingVertically] targetVertiaclScrollPosition:', targetVerticalScrollPosition);
			this.throwTo(NaN, targetVerticalScrollPosition);
		}
		
		/**
		 * @private
		 */
		protected function updateHorizontalScrollFromTouchPosition(touchX:Number):void
		{
			const offset:Number = this._startTouchX - touchX;
			var position:Number = this._startHorizontalScrollPosition + offset;
			if(position < this._minHorizontalScrollPosition)
			{
				if(this._hasElasticEdges)
				{
					position /= 2;
				}
				else
				{
					position = 0;
				}
			}
			else if(position > this._maxHorizontalScrollPosition)
			{
				if(this._hasElasticEdges)
				{
					position -= (position - this._maxHorizontalScrollPosition) / 2;
				}
				else
				{
					position = this._maxHorizontalScrollPosition;
				}
			}
			
			this.horizontalScrollPosition = position;
		}
		
		/**
		 * @private
		 */
		protected function updateVerticalScrollFromTouchPosition(touchY:Number):void
		{
			const offset:Number = this._startTouchY - touchY;
			var position:Number = this._startVerticalScrollPosition + offset;
			if(position < _minVerticalScrollPosition)
			{
				if(this._hasElasticEdges)
				{
					position /= 2;
				}
				else
				{
					position = _minVerticalScrollPosition;
				}
			}
			else if(position > this._maxVerticalScrollPosition)
			{
				if(this._hasElasticEdges)
				{
					position -= (position - this._maxVerticalScrollPosition) / 2;
				}
				else
				{
					position = this._maxVerticalScrollPosition;
				}
			}
			
			this.verticalScrollPosition = position;
		}
		//=================================================================
		//
		// Event handlers
		//
		//=================================================================
		/**
		 * @private
		 */
		protected function touchBeginHandler(event:Event):void
		{
			if(!this.enabled)
			{
				return;
			}
			if(event is TouchEvent && this._touchPointID >= 0 && TouchEvent(event).touchPointID != this._touchPointID)
			{
				return;
			}
			
			if(this._horizontalAutoScrollTween)
			{
				this._horizontalAutoScrollTween.paused = true;
				this._horizontalAutoScrollTween = null
			}
			if(this._verticalAutoScrollTween)
			{
				this._verticalAutoScrollTween.paused = true;
				this._verticalAutoScrollTween = null
			}
			_scrollToEnd = false; //không cho phép tự động scroll xuống dưới khi đang scroll
			
			
			this._velocityX = 0;
			this._velocityY = 0;
			this._previousVelocityX.length = 0;
			this._previousVelocityY.length = 0;
			this._previousTouchTime = getTimer();
			this._previousTouchX = this._startTouchX = this._currentTouchX = (event is TouchEvent) ? TouchEvent(event).stageX : MouseEvent(event).stageX;
			this._previousTouchY = this._startTouchY = this._currentTouchY = (event is TouchEvent) ? TouchEvent(event).stageY : MouseEvent(event).stageY;
			this._startHorizontalScrollPosition = this._horizontalScrollPosition;
			this._startVerticalScrollPosition = this._verticalScrollPosition;
			this._isDraggingHorizontally = false;
			this._isDraggingVertically = false;
			this._isScrollingStopped = false;
			
			if(event is TouchEvent)
			{
				this._touchPointID = TouchEvent(event).touchPointID;
				this.stage.addEventListener(TouchEvent.TOUCH_MOVE, stage_touchMoveHandler);
				this.stage.addEventListener(TouchEvent.TOUCH_END, stage_touchEndHandler);
			}
			else
			{
				this.stage.addEventListener(MouseEvent.MOUSE_MOVE, stage_touchMoveHandler);
				this.stage.addEventListener(MouseEvent.MOUSE_UP, stage_touchEndHandler);
			}
			
			if (!_ticker)
				_ticker = new Ticker();
			_ticker.addEventListener(TickerEvent.TICK, onTick);
			_ticker.start();
			//this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		
		private function stage_touchMoveHandler(event:Event):void
		{
			if(event is TouchEvent && this._touchPointID >= 0 && TouchEvent(event).touchPointID != this._touchPointID)
			{
				return;
			}
			
			_scrollToEnd = false; //ko tự động scroll xuống dưới
			this._currentTouchX = (event is TouchEvent) ? TouchEvent(event).stageX : MouseEvent(event).stageX;
			this._currentTouchY = (event is TouchEvent) ? TouchEvent(event).stageY : MouseEvent(event).stageY;			
		}
		
		private function onTick(event:TickerEvent):void
		{
			if(this._isScrollingStopped)
			{
				return;
			}
			
			const now:int = getTimer();
			const timeOffset:int = now - this._previousTouchTime;
			if(timeOffset > 0)
			{
				//we're keeping two velocity updates to improve accuracy
				this._previousVelocityX.unshift(this._velocityX);
				if (this._previousVelocityX.length > MAXIMUM_SAVED_VELOCITY_COUNT)
					this._previousVelocityX.pop();
				this._previousVelocityY.unshift(this._velocityY);
				if (this._previousVelocityY.length > MAXIMUM_SAVED_VELOCITY_COUNT)
					this._previousVelocityY.pop();
				this._velocityX = (this._currentTouchX - this._previousTouchX) / timeOffset;
				this._velocityY = (this._currentTouchY - this._previousTouchY) / timeOffset;
				this._previousTouchTime = now
				this._previousTouchX = this._currentTouchX;
				this._previousTouchY = this._currentTouchY;
			}
			const horizontalInchesMoved:Number = Math.abs(this._currentTouchX - this._startTouchX) / Capabilities.screenDPI;
			const verticalInchesMoved:Number = Math.abs(this._currentTouchY - this._startTouchY) / Capabilities.screenDPI;
			if(this._horizontalScrollPolicy != ScrollBarPolicy.OFF && !this._isDraggingHorizontally && horizontalInchesMoved >= MINIMUM_DRAG_DISTANCE)
			{
				this._isDraggingHorizontally = true;
			}
			if(this._verticalScrollPolicy != ScrollBarPolicy.OFF && !this._isDraggingVertically && verticalInchesMoved >= MINIMUM_DRAG_DISTANCE)
			{
				this._isDraggingVertically = true;
			}
			
			if(this._isDraggingHorizontally && !this._horizontalAutoScrollTween)
			{
				this.updateHorizontalScrollFromTouchPosition(this._currentTouchX);
			}
			if(this._isDraggingVertically && !this._verticalAutoScrollTween)
			{
				this.updateVerticalScrollFromTouchPosition(this._currentTouchY);
			}
		}
		
		private function stage_touchEndHandler(event:Event):void
		{
			if(event is TouchEvent && this._touchPointID >= 0 && TouchEvent(event).touchPointID != this._touchPointID)
			{
				return;
			}
			
			this._touchPointID = -1;
			if (_ticker)
			{
				_ticker.removeEventListener(TickerEvent.TICK, onTick);
				_ticker.stop();
			}
			//this.removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			this.stage.removeEventListener(MouseEvent.MOUSE_MOVE, stage_touchMoveHandler);			
			this.stage.removeEventListener(MouseEvent.MOUSE_UP, stage_touchEndHandler);
			this.stage.removeEventListener(TouchEvent.TOUCH_MOVE, stage_touchMoveHandler);
			this.stage.removeEventListener(TouchEvent.TOUCH_END, stage_touchEndHandler);
			
			var isFinishingHorizontally:Boolean = false;
			var isFinishingVertically:Boolean = false;
			if(this._horizontalScrollPosition < this._minHorizontalScrollPosition || this._horizontalScrollPosition > this._maxHorizontalScrollPosition)
			{
				isFinishingHorizontally = true;
				this.finishScrollingHorizontally();
			}
			if(this._verticalScrollPosition < this._minVerticalScrollPosition || this._verticalScrollPosition > this._maxVerticalScrollPosition)
			{
				isFinishingVertically = true;
				this.finishScrollingVertically();
			}
			if(isFinishingHorizontally && isFinishingVertically)
			{
				return;
			}
			
			if(!isFinishingHorizontally && this._horizontalScrollPolicy != ScrollBarPolicy.OFF)
			{
				//take the average for more accuracy
				var sum:Number = this._velocityX * 2.33;
				var velocityCount:int = this._previousVelocityX.length;
				var totalWeight:Number = 0;
				for(var i:int = 0; i < velocityCount; i++)
				{
					var weight:Number = VELOCITY_WEIGHTS[i];
					sum += this._previousVelocityX.shift() * weight;
					totalWeight += weight;
				}
				this.throwHorizontally(sum / totalWeight);
			}
			
			if(!isFinishingVertically && this._verticalScrollPolicy != ScrollBarPolicy.OFF)
			{
				sum = this._velocityY * 2.33;
				velocityCount = this._previousVelocityY.length;
				totalWeight = 0;
				for(i = 0; i < velocityCount; i++)
				{
					weight = VELOCITY_WEIGHTS[i];
					sum += this._previousVelocityY.shift() * weight;
					totalWeight += weight;
				}
				this.throwVertically(sum / totalWeight);
			}
			
		}
		
	}
}