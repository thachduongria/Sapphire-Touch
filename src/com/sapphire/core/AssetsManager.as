package com.sapphire.core
{
	import flash.display.DisplayObject;
	import flash.events.EventDispatcher;
	import flash.system.ApplicationDomain
	/**
	 * ...
	 * @author Ciao Team
	 */
	public class AssetsManager extends EventDispatcher
	{
		private var applicationDomains:Array = [];
		public function AssetsManager() 
		{
			
		}
		private  static var instance:AssetsManager
		public static function getInstance():AssetsManager{
		  if (!instance) 
			 instance = new AssetsManager();
			return instance;
		}
		public function addApplicationDomain(app:ApplicationDomain):void {
			applicationDomains.push(app);
		}
		public function getClassByName(_name:String):Class {
			var takenClass:Class;
			for (var i:int = 0; i < applicationDomains.length; i++) 
			{
				if (ApplicationDomain(applicationDomains[i]).hasDefinition(_name)) {
					takenClass =   ApplicationDomain(applicationDomains[i]).getDefinition(_name) as Class;
				}
			}
			
			
			if (!takenClass) {
				throw new Error("Khoong co class nao voi ten nay :::: ------>>>> " + takenClass + "-----" + _name);
			}
			else {
				return takenClass;
			}
			
			
			
		}
		public function getSymbolByName(_name:String):DisplayObject {
			var obj:Class = getClassByName(_name) as Class;
			var objInstance:DisplayObject = new obj();
			trace("objInstance*****--- " + objInstance);
			return objInstance
		}
		
	}

}