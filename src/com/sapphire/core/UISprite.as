package com.sapphire.core
{
	import com.sapphire.event.UISpriteEvent;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	
	public class UISprite extends Sprite
	{
		/**
		 * Flag to indicate that everything is invalid and should be redrawn.
		 */
		public static const INVALIDATION_FLAG_ALL:String = "all";
		
		/**
		 * Invalidation flag to indicate that the state has changed. Used by
		 * <code>isEnabled</code>, but may be used for other control states too.
		 * 
		 * @see isEnabled
		 */
		public static const INVALIDATION_FLAG_STATE:String = "state";
		
		/**
		 * Invalidation flag to indicate that the dimensions of the UI control
		 * have changed.
		 */
		public static const INVALIDATION_FLAG_SIZE:String = "size";
		
		/**
		 * Invalidation flag to indicate that the styles or visual appearance of
		 * the UI control has changed.
		 */
		public static const INVALIDATION_FLAG_STYLES:String = "styles";
		
		/**
		 * Invalidation flag to indicate that the primary data displayed by the
		 * UI control has changed.
		 */
		public static const INVALIDATION_FLAG_PROPERTIES:String = "properties";
		
		/**
		 * Invalidation flag to indicate that the layout of the
		 * UI control has changed.
		 */
		public static const INVALIDATION_FLAG_DRAW:String = 'draw';
				
		/**
		 * Invalidation flag to indicate that the scroll position of the UI
		 * control has changed.
		 */
		public static const INVALIDATION_FLAG_SCROLL:String = "scroll";
		
		/**
		 * Invalidation flag to indicate that the selection of the UI control
		 * has changed.
		 */
		public static const INVALIDATION_FLAG_SELECTED:String = "selected";
		
		/**
		 * @private
		 * A display object that fires frame events that trigger validation.
		 */
		private static const ENTER_FRAME_DISPLAY_OBJECT:Shape = new Shape();
		
		/**
		 * Flag to indicate that the call later queue is being processed.
		 */
		protected static var isCallingLater:Boolean = false;
		
		/**
		 * @private
		 * The queue of functions to be called later.
		 */
		private static var callLaterQueue:Vector.<CallLaterQueueItem>;
		

		/**
		 * Calls a function later, within one frame. Used for invalidation of
		 * UI controls when properties change.
		 */
		protected static function callLater(target:UISprite, method:Function, arguments:Array = null):void
		{
			if(!callLaterQueue)
			{
				callLaterQueue = new <CallLaterQueueItem>[];
			}
			
			const queueLength:int = callLaterQueue.length;
			
			for(var i:int = 0; i < queueLength; i++)
			{
				var item:CallLaterQueueItem = callLaterQueue[i];
				if(target.contains(item.target))
				{
					break;
				}
			}
			
			//push to queue
			callLaterQueue.splice(i, 0, new CallLaterQueueItem(target, method, arguments));
			
			if(!ENTER_FRAME_DISPLAY_OBJECT.hasEventListener(Event.ENTER_FRAME))
			{
				if(target.stage)
				{
					// "request" flash player to redraw and fire Event.RENDER
					target.stage.invalidate();
				}
				
				ENTER_FRAME_DISPLAY_OBJECT.addEventListener(Event.FRAME_CONSTRUCTED, callLater_frameEventHandler);
				ENTER_FRAME_DISPLAY_OBJECT.addEventListener(Event.RENDER, callLater_frameEventHandler);
				ENTER_FRAME_DISPLAY_OBJECT.addEventListener(Event.ENTER_FRAME, callLater_frameEventHandler);
				ENTER_FRAME_DISPLAY_OBJECT.addEventListener(Event.EXIT_FRAME, callLater_frameEventHandler);
			}
		}
		
		/**
		 * @private
		 * Processes functions in the queue that are to be called later.
		 */
		private static function callLater_frameEventHandler(event:Event):void
		{
			isCallingLater = true;
			
			var methodCount:int;
			while(callLaterQueue.length > 0)
			{
				var item:CallLaterQueueItem = callLaterQueue.shift();
				item.method.apply(null, item.parameters);
			}
			ENTER_FRAME_DISPLAY_OBJECT.removeEventListener(Event.FRAME_CONSTRUCTED, callLater_frameEventHandler);
			ENTER_FRAME_DISPLAY_OBJECT.removeEventListener(Event.RENDER, callLater_frameEventHandler);
			ENTER_FRAME_DISPLAY_OBJECT.removeEventListener(Event.ENTER_FRAME, callLater_frameEventHandler);
			ENTER_FRAME_DISPLAY_OBJECT.removeEventListener(Event.EXIT_FRAME, callLater_frameEventHandler);
			isCallingLater = false;
		}
		
		public function UISprite()
		{
			super();
			
			this.addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler,false,0,true);
			this.addEventListener(Event.REMOVED_FROM_STAGE, removedFromStageHandler,false,0,true);
		}
		
		/**
		 * @private
		 * Flag indicating if the <code>initialize()</code> function has been called yet.
		 */
		private var _isInitialized:Boolean = false;
		
		/**
		 * @private
		 * A counter for the number of times <code>invalidate()</code> has been
		 * called during validation. If it gets called too many times, the UI
		 * control will automatically stop to avoid hanging.
		 */
		private var _invalidateCount:int;
		
		/**
		 * @private
		 * A flag that indicates that everything is invalid. If true, no other
		 * flags will need to be tracked.
		 */
		private var _isAllInvalid:Boolean = false;
		
		/**
		 * @private
		 * Flag to indicate that the control is currently validating.
		 */
		private var _isValidating:Boolean = false;
		
		/**
		 * @private
		 * The current invalidation flags.
		 */
		private var _invalidationFlags:Dictionary = new Dictionary(true);
		
		private var _lastUnscaledWidth:Number = 0;
		private var _lastUnscaledHeight:Number = 0;
		
		//======================================================================
		// Properties
		//======================================================================
		private var _enabled:Boolean = true;
		public function get enabled():Boolean
		{
			return _enabled;
		}
		
		public function set enabled(value:Boolean):void
		{
			if (_enabled == value)
				return;
			_enabled = value;
			mouseEnabled = _enabled;
			mouseChildren = _enabled;
			invalidate(INVALIDATION_FLAG_STATE);
		}
		
		
		/**
		 * The width value explicitly set by calling the width setter or
		 * setSize().
		 */
		protected var explicitWidth:Number = NaN;
		
		/**
		 * The final width value that should be used for layout. If the width
		 * has been explicitly set, then that value is used. If not, the actual
		 * width will be calculated automatically. Each component has different
		 * automatic sizing behavior, but it's usually based on the component's
		 * skin or content, including text or sub-components.
		 */
		protected var actualWidth:Number = NaN;
		
		/**
		 * The width of the component, in pixels. This could be a value that was
		 * set explicitly, or the component will automatically resize if no
		 * explicit width value is provided. Each component has a different
		 * automatic sizing behavior, but it's usually based on the component's
		 * skin or content, including text or sub-components.
		 */
		override public function get width():Number
		{
			return this.actualWidth;
		}
		
		/**
		 * @private
		 */
		override public function set width(value:Number):void
		{
			this.explicitWidth = value;
			this.setSizeInternal(value, this.actualHeight, true);
		}
		
		/**
		 * The height value explicitly set by calling the height setter or
		 * setSize().
		 */
		protected var explicitHeight:Number = NaN;
		
		/**
		 * The final height value that should be used for layout. If the height
		 * has been explicitly set, then that value is used. If not, the actual
		 * height will be calculated automatically. Each component has different
		 * automatic sizing behavior, but it's usually based on the component's
		 * skin or content, including text or sub-components.
		 */
		protected var actualHeight:Number = NaN;
		
		/**
		 * The height of the component, in pixels. This could be a value that
		 * was set explicitly, or the component will automatically resize if no
		 * explicit height value is provided. Each component has a different
		 * automatic sizing behavior, but it's usually based on the component's
		 * skin or content, including text or sub-components.
		 */
		override public function get height():Number
		{
			return this.actualHeight;
		}
		
		/**
		 * @private
		 */
		override public function set height(value:Number):void
		{
			this.explicitHeight = value;
			this.setSizeInternal(this.explicitWidth, value, true);
		}
		
		/**
		 * @private
		 */
		private var _minWidth:Number = 0;
		
		/**
		 * The minimum recommend width to be used for self-measurement and,
		 * optionally, by the parent who is resizing this component. A width
		 * value that is smaller than <code>minWidth</code> may be set
		 * explicitly, and it will not be affected by this value.
		 */
		public function get minWidth():Number
		{
			return this._minWidth;
		}
		
		/**
		 * @private
		 */
		public function set minWidth(value:Number):void
		{
			if(this._minWidth == value)
			{
				return;
			}
			this._minWidth = value;
			this.invalidate(INVALIDATION_FLAG_SIZE);
		}
		
		/**
		 * @private
		 */
		private var _minHeight:Number = 0;
		
		/**
		 * The minimum recommend height to be used for self-measurement and,
		 * optionally, by the parent who is resizing this component. A height
		 * value that is smaller than <code>minHeight</code> may be set
		 * explicitly, and it will not be affected by this value.
		 */
		public function get minHeight():Number
		{
			return this._minHeight;
		}
		
		/**
		 * @private
		 */
		public function set minHeight(value:Number):void
		{
			if(this._minHeight == value)
			{
				return;
			}
			this._minHeight = value;
			this.invalidate(INVALIDATION_FLAG_SIZE);
		}
		
		
		/**
		 * When called, the UI control will redraw within one frame.
		 * Invalidation limits processing so that multiple property changes only
		 * trigger a single redraw.
		 * 
		 * <p>If the UI control isn't on the display list, it will never redraw.
		 * The control will automatically invalidate once it has been added.</p>
		 * 
		 * <p>if no params passed, all flag is set.</p>
		 */
		public function invalidate(...rest:Array):void
		{			
			if(!this.stage)
			{
				return;
			}
			//trace('[UISprite][invalidate]');
			
			const isInvalidAlready:Boolean = this.isInvalid();
			
			for each(var flag:String in rest)
			{
				if(flag == INVALIDATION_FLAG_ALL)
				{
					continue;
				}
				this._invalidationFlags[flag] = true;
			}
			
			if(rest.length == 0 || rest.indexOf(INVALIDATION_FLAG_ALL) >= 0)
			{
				this._isAllInvalid = true;
			}
			
			//we're validating , defer invalidation to the next frame
			if(this._isValidating)
			{
				this._invalidateCount++;
				if(this._invalidateCount > 10)
				{
					trace("Stopping out of control invalidation. Control may not invalidate() more than 10 ten times during validate() step.");
					return;
				}
				callLater(this, this.invalidate, rest);
				return;
			}
			
			this._invalidateCount = 0;
			
			//nothing is already invalid
			if(!isInvalidAlready)
			{
				callLater(this, validate);
			}
		}
		
		/**
		 * Immediately validates the control, which triggers a redraw, if one
		 * is pending.
		 */
		public function validate():void
		{
			if(!this.stage || !this.isInvalid())
			{
				return;
			}
			
			//trace('[UISprite][validate]');
			this._isValidating = true;
			
			var propertiesInvalid:Boolean = isInvalid(INVALIDATION_FLAG_PROPERTIES);
			var stylesInvalid:Boolean = isInvalid(INVALIDATION_FLAG_STYLES);
			var sizeInvalid:Boolean = isInvalid(INVALIDATION_FLAG_SIZE);
			var drawInvalid:Boolean = isInvalid(INVALIDATION_FLAG_DRAW);
			var stateInvalid:Boolean = isInvalid(INVALIDATION_FLAG_STATE);
			
			if (propertiesInvalid)
				commitProperties();
			if (stylesInvalid)
				commitStyles();
			if (sizeInvalid)
				measure();
			if (drawInvalid)
				validateDraw();
			
			for(var flag:String in this._invalidationFlags)
			{
				delete this._invalidationFlags[flag];
			}
			this._isAllInvalid = false;
			this._isValidating = false;
		}
		
		/**
		 * Indicates whether the control is invalid or not. You may optionally
		 * pass in a specific flag to check if that particular flag is set. If
		 * the "all" flag is set, the result will always be true.
		 */
		public function isInvalid(flag:String = null):Boolean	
		{
			//all flag is invalidate
			if(this._isAllInvalid)
			{
				return true;
			}
			
			if(!flag) 
			{
				//return true if any flag is set
				for(var flag:String in this._invalidationFlags)
				{
					return true;
				}
				return false;
			}
			
			return this._invalidationFlags[flag];
		}
		
		private function validateDraw():void
		{
			var unscaledWidth:Number = width;
			var unscaledHeight:Number = height;
			
			unscaledWidth = scaleX == 0 ? 0 : width / scaleX;
			unscaledHeight = scaleY == 0 ? 0 : height / scaleY;
			
			if (Math.abs(unscaledWidth - _lastUnscaledWidth) < 0.00001)
				unscaledWidth = _lastUnscaledWidth;
			if (Math.abs(unscaledHeight - _lastUnscaledHeight) < 0.00001)
				unscaledHeight = _lastUnscaledHeight;
			
			draw(unscaledWidth,unscaledHeight);
			
			_lastUnscaledWidth = unscaledWidth;
			_lastUnscaledHeight = unscaledHeight;
		}
		
		/**
		 * Override to initialize the UI control. Should be used to create
		 * children and set up event listeners.
		 */
		protected function initialize():void
		{
			
		}
		
		/**
		 * component become activate 
		 * 
		 */		
		protected function activate():void
		{
			
		}
		
		/**
		 * Sets the width and height of the control, with the option of
		 * invalidating or not.
		 */
		protected function setSizeInternal(internalWidth:Number, internalHeight:Number, canInvalidate:Boolean):void
		{
			var resized:Boolean = false;
			if(!isNaN(this.explicitWidth))
			{
				internalWidth = this.explicitWidth;
			}
			else
			{
				internalWidth = Math.max(this._minWidth, internalWidth);
			}
			
			if(!isNaN(this.explicitHeight))
			{
				internalHeight = this.explicitHeight;
			}
			else
			{
				internalHeight = Math.max(this._minHeight, internalHeight);
			}
			
			//update actual size of the component
			if(this.actualWidth != internalWidth)
			{
				this.actualWidth = internalWidth;
				resized = true;
			}
			if(this.actualHeight != internalHeight)
			{
				this.actualHeight = internalHeight;
				resized = true;
			}
			if(resized)
			{
				if(canInvalidate)
				{
					this.invalidate(INVALIDATION_FLAG_SIZE);
				}
				this.dispatchEvent(new UISpriteEvent(UISpriteEvent.RESIZE));
			}
		}
		
		protected function commitProperties():void
		{
			
		}
		
		protected function commitStyles():void
		{
			
		}
		
		/**
		 * Calculate the widht,height of the component 
		 * 
		 */		
		protected function measure():void
		{
			
		}
		
		/**
		 * layout content based on the calculated size
		 * 
		 * @param unscaledWidth 
		 * @param unscaledHeight
		 * 
		 */		
		protected function draw(unscaledWidth:Number,unscaledHeight:Number):void
		{
				
		}
		
		/**
		 * Component is removed from stage
		 * 
		 * Override to remove all reference 
		 */		
		protected function deactivate():void
		{
			//this._onResize.removeAll();
		}
		
		/**
		 * @private
		 * Initialize the control, if it hasn't been initialized yet. 
		 * Then, call first invalidate()
		 */
		private function addedToStageHandler(event:Event):void
		{
			if(event.target != this)
			{
				return;
			}
			if(!this._isInitialized)
			{
				this.initialize();
				this._isInitialized = true;
			}
			activate();
			this.invalidate();						
		}
		
		/**
		 * @private
		 * call deactivate
		 * 
		 */		
		private function removedFromStageHandler(event:Event):void
		{
			deactivate();
		}
	}
}


import com.sapphire.core.UISprite;

/**
 * Private Class
 * 
 */
class CallLaterQueueItem
{
	public function CallLaterQueueItem(target:UISprite, method:Function, parameters:Array)
	{
		this.target = target;
		this.method = method;
		this.parameters = parameters;
	}
	
	public var target:UISprite;
	public var method:Function;
	public var parameters:Array;
}