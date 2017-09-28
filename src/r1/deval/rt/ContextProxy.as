package r1.deval.rt {
	import flash.utils.Proxy;
	import flash.utils.describeType;
	import flash.utils.flash_proxy;
	public class ContextProxy extends Proxy {
		private var obj:Object;
		private var getters:Object=new Object();
		private var setters:Object=new Object();
		private var isProxy:Boolean=false;
		private var isnull:Boolean=false;
		public function ContextProxy(x:Object):void {
			this.obj=x;
			if (x==null) {
				this.isnull=true;
				return;
			}
			if ((x is ClassProxy)||(x is InstanceProxy)||(x is ContextProxy)) {
				this.isProxy=true;
				return;
			}
			var _loc3_:XML = describeType(x);
			var _loc5_:String;
			for each(var _loc4_:XML in _loc3_.accessor)
			{
				_loc5_ = _loc4_.@access;
				if(_loc5_ == "readwrite")
				{
					setters[_loc4_.@name] = getters[_loc4_.@name] = true;
				}
				else if(_loc5_ == "readonly")
				{
					getters[_loc4_.@name] = true;
				}
				else if(_loc5_ == "writeonly")
				{
					setters[_loc4_.@name] = true;
				}
			}
		}
		deval_namesp function hasGetProperty(x:*):Boolean {
			if (this.isnull) return false;
			if (this.isProxy) return this.obj.deval_namesp::hasGetProperty(x);
			return (this.obj.hasOwnProperty(x)||this.getters.hasOwnProperty(x));
		}
		deval_namesp function hasSetProperty(x:*):Boolean {
			if (this.isnull) return false;
			if (this.isProxy) return this.obj.deval_namesp::hasSetProperty(x);
			return (this.obj.hasOwnProperty(x)||this.setters.hasOwnProperty(x));
		}
		deval_namesp function getObject():Object {
			return this.obj;
		}
		flash_proxy override function callProperty(name:*,...args):* {
			return this.obj[name].apply(this.obj[name],args);
		}
		flash_proxy override function hasProperty(name:*):Boolean {
			return this.obj.hasOwnProperty(name);
		}
		flash_proxy override function getProperty(name:*):* {
			return this.obj[name];
		}
		flash_proxy override function setProperty(name:*,value:*):void {
			this.obj[name]=value;
		}
		flash_proxy override function deleteProperty(name:*):Boolean {
			if (this.obj.hasOwnProperty(name)) {
				delete this.obj[name];
				return true;
			}
			return false;
		}
	}
}