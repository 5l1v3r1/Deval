package r1.deval.rt {
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	public class InstanceProxy extends Proxy {
		private var classObj:Object;
		private var getters:Object=new Object();
		private var setters:Object=new Object();
		public function InstanceProxy():void {
			this.classObj=new Object();
		}
		flash_proxy override function getProperty(name:*):* {
			if (this.getters.hasOwnProperty(name)) {
				return this.getters[name].apply(this,[]);
			}
			return this.classObj[name];
		}
		deval_namesp function addGetter(v:String,w:Function):void {
			this.getters[v]=w;
		}
		deval_namesp function addSetter(v:String,w:Function):void {
			this.setters[v]=w;
		}
		deval_namesp function hasSetProperty(name:*):Boolean {
			return (this.classObj.hasOwnProperty(name)||this.setters.hasOwnProperty(name));
		}
		deval_namesp function hasGetProperty(name:*):Boolean {
			return (this.classObj.hasOwnProperty(name)||this.getters.hasOwnProperty(name));
		}
		flash_proxy override function setProperty(name:*,value:*):void {
			if (this.setters.hasOwnProperty(name)) {
				this.setters[name].apply(this,[name]);
			}
			else this.classObj[name]=value;
		}
		flash_proxy override function hasProperty(name:*):Boolean {
			return this.classObj.hasOwnProperty(name);
		}
		flash_proxy override function callProperty(name:*,...args):* {
			return this.classObj[name].apply(this.classObj,args);
		}
		flash_proxy override function deleteProperty(name:*):Boolean {
			if (!this.classObj.hasOwnProperty(name)) return false;
			delete this.classObj[name];
			return true;
		}
	}
}