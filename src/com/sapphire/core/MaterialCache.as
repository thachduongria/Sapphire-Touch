package com.sapphire.core
{		
	import flash.utils.Dictionary;

	/**
	 * ...
	 * @author luuvinhloc
	 */
	public class MaterialCache
	{
		private static var instance:MaterialCache;
		public function MaterialCache() 
		{
			
		}
		
		public static function getInstance():MaterialCache
		{
			if(instance == null)
				instance = new MaterialCache();
			
			return instance;
		}
		
		private var materialMap:Dictionary = new Dictionary(true);
		//url exists
		public function hasKey(key:String):Boolean
		{				
			return materialMap[key] != null;
		}		
		
		public function push(content:Object, key:String = ""):void
		{
			if(key != "" && !hasKey(key))
			{
				materialMap[key] = content;
			}
		}
		
		public function getMaterial(key:String, useOnce:Boolean = false):Object
		{
			if(hasKey(key))
			{
				var content:Object = materialMap[key];
				if (useOnce) materialMap[key] = null;
				return content;
			}
			return null;
		}
		
	}
	
}