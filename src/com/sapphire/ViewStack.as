package com.sapphire
{
	import com.sapphire.core.UISprite;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	
	public class ViewStack extends UISprite
	{
		public static const AUTO:String = 'auto';
		public static const ALL:String = 'all';
		
		public var mViewContainer:Sprite;
		
		public function ViewStack()
		{
			super();
			mViewContainer = this['viewContainer'] as Sprite;
		}
		
		private var _classStacks:Array = [];
		private var _viewStack:Array = [];
		
		private var _creationPolicy:String = AUTO;		
		public function get creationPolicy():String
		{
			return _creationPolicy;
		}

		public function set creationPolicy(value:String):void
		{
			_creationPolicy = value;
		}
		
		private var _selectedIndex:int = -1;
		private var viewIndexDirty:Boolean = false;
		/**
		 * index cuả view đang được chọn 
		 */
		public function get selectedIndex():int
		{
			return _selectedIndex;
		}

		/**
		 * @private
		 */
		public function set selectedIndex(value:int):void
		{
			if (_selectedIndex == value) return;			
			_selectedIndex = value;
			viewIndexDirty = true;
			invalidate(INVALIDATION_FLAG_DRAW);
		}

		
		public function pushView(viewObj:Object):void
		{
			if (viewObj is Class)
			{
				var claz:Class = viewObj as Class;
				_classStacks.push(claz);
				if (_creationPolicy == ALL)
				{
					var view:DisplayObject = new claz() as DisplayObject;
					_viewStack.push(view);
				}
				else if (_creationPolicy == AUTO)
				{
					if (_viewStack.length == 0)
					{
						var v:DisplayObject = new claz() as DisplayObject;
						_viewStack.push(view);
					}
				}
			}
			else if (viewObj as DisplayObject)
			{
				_viewStack.push(viewObj);
			}
			
			if (_selectedIndex == -1)
				selectedIndex = 0;
		}
		
		public function popView():void
		{
			if (_classStacks.length > _viewStack.length)
			{
				_classStacks.pop();
			}
			else if (_classStacks.length < _viewStack.length)
			{
				var v:DisplayObject = _viewStack.pop();
				if (mViewContainer.contains(v))
				{
					if (v is ViewStackChild)
						ViewStackChild(v).deactivate();
					mViewContainer.removeChild(v);
				}
				selectedIndex = _viewStack.length - 1;
			}
			else if (_classStacks.length == _viewStack.length)
			{
				_classStacks.pop();
				var view:DisplayObject = _viewStack.pop();
				if (mViewContainer.contains(view))
				{
					if (view is ViewStackChild)
						ViewStackChild(view).deactivate();
					mViewContainer.removeChild(view);
				}
				selectedIndex = _viewStack.length - 1;
			}
			
		}
		
		override protected function draw(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.draw(unscaledWidth,unscaledHeight);
			
			if (viewIndexDirty)
			{
				viewIndexDirty = false;
				var viewToRemove:DisplayObject;
				var viewToAdd:DisplayObject;
				//find in viewStack
				if (_viewStack[_selectedIndex] != null)
				{
					if (mViewContainer.numChildren > 0)
					{
						viewToRemove = mViewContainer.getChildAt(0);
						if (viewToRemove is ViewStackChild)
							ViewStackChild(viewToRemove).deactivate();
						mViewContainer.removeChild(viewToRemove);
					}
					
					viewToAdd = _viewStack[_selectedIndex];
					if (viewToAdd is ViewStackChild) 
						ViewStackChild(viewToAdd).activate();
					mViewContainer.addChildAt(_viewStack[_selectedIndex],0);
				}
				//find in classStack
				else if (_classStacks[_selectedIndex] != null)
				{
					if (mViewContainer.numChildren > 0)
					{
						viewToRemove = mViewContainer.getChildAt(0);
						if (viewToRemove is ViewStackChild)
							ViewStackChild(viewToRemove).deactivate();
					}
					viewToAdd = new _classStacks[_selectedIndex]() as DisplayObject;
					_viewStack.push(viewToAdd);
					if (viewToAdd is ViewStackChild)
						ViewStackChild(viewToAdd).activate();
					mViewContainer.addChildAt(viewToAdd,0);
				}
				
				viewToRemove = null;
				viewToAdd = null;
			}
		}

		
	}
}