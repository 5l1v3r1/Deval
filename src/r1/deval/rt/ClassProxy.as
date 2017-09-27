package r1.deval.rt {
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	public class ClassProxy extends Proxy {
		private var classDef:ClassDef;
		private var classObj:Object;
		public function ClassProxy(classDef:ClassDef):void {
			this.classDef=classDef;
			this.classObj=new Object();
		}
		public function getInstance(...args):Object {
			return this.classDef.getInstance.apply(null,args);
		}
		flash_proxy override function getProperty(name:*):* {
			return this.classObj[name];
		}
		flash_proxy override function setProperty(name:*,value:*):void {
			this.classObj[name]=value;
		}
		flash_proxy override function callProperty(name:*,...args):* {
			return this.classObj[name].apply(this.classObj[name],args);
		}
		flash_proxy override function deleteProperty(name:*):Boolean {
			if (!this.classObj.hasOwnProperty(name)) return false;
			delete this.classObj[name];
			return true;
		}
	}
}