package r1.deval.rt {
	public class ClassDef {
		private var internalClasses:Object;
		private var staticExpressions:Object;
		private var isInited:Boolean=false;
		private var isIniting:Boolean=false;
		private var classObj:ClassProxy;
		private var globalVars:Object;
		private var globalDyns:Array;
		private var classname:String;
		private var importStmts:Array;
		private var varExprs:Object;
		private var functionExprs:Object;
		private var construct:FunctionDef;
		private var staticgetters:Object;
		private var staticsetters:Object;
		private var vargetters:Object;
		private var varsetters:Object;
		public function ClassDef(classname:String,classes:Object,staticExprs:Object,varExprs:Object,functionExprs:Object,importStmts:Array,staticgetters:Object,staticsetters:Object,vargetters:Object,varsetters:Object):void {
			this.internalClasses=classes;
			this.staticExpressions=staticExprs;
			this.classObj=new ClassProxy(this);
			this.globalDyns=new Array();
			this.globalVars=new Object();
			this.classname=classname;
			for (var v:String in this.staticExpressions) {
				this.classObj[v]=undefined;
			}
			this.importStmts=importStmts;
			this.varExprs=varExprs;
			this.functionExprs=functionExprs;
			this.vargetters=vargetters;
			this.varsetters=varsetters;
			this.staticsetters=staticsetters;
			this.staticgetters=staticgetters;
			for (var v in this.staticgetters) this.classObj.deval_namesp::addGetter(v,null);
			for (var v in this.staticsetters) this.classObj.deval_namesp::addSetter(v,null);
			if (this.functionExprs[classname]!=undefined) {
				this.construct=this.functionExprs[classname];
				delete this.functionExprs[classname];
			}
		}
		private function doInit():void {
			var ok:Boolean=false;
			try{
				isIniting=true;
				var v:ExprHolder=new ExprHolder(this.staticExpressions);
				var w:Env=new Env(null,null);
				w._globalVars=this.globalVars;
				w._globalDyns=this.globalDyns;
				Env.pushEnv(w);
				ok=true;
				Env.pushObject(this.internalClasses,true);
				Env.pushObject(this.classObj);
				Env.setContext(this.classObj);
				Env.pushObject(v,true);
				for (var s:String in this.staticgetters) this.classObj.deval_namesp::addGetter(s,this.staticgetters[s].getFunction());
				this.staticgetters=null;
				for (var s:String in this.staticsetters) this.classObj.deval_namesp::addSetter(s,this.staticsetters[s].getFunction());
				this.staticsetters=null;
				for each(var m:ImportStmt in this.importStmts) m.exec();
				this.importStmts=null;
				for (var s:String in this.staticExpressions) {
					this.classObj[s]=v[s];
					delete v[s];
				}
				v.deval_namesp::clear();
				this.isInited=true;
				this.staticExpressions=null;
			}
			finally {
				isIniting=false;
				if (ok) Env.popEnv();
			}
		}
		public function getStaticObject():ClassProxy {
			if (!isIniting&&!isInited) doInit();
			return this.classObj;
		}
		public function getInstance(...args):Object {
			var ths:InstanceProxy=new InstanceProxy();
			var m:ExprHolder=new ExprHolder(null);
			var w:Env=new Env(m,null);
			w._globalVars=this.globalVars;
			w._globalDyns=this.globalDyns;
			Env.pushEnv(w);
			Env.pushObject(this.internalClasses,true);
			Env.pushObject(this.classObj);
			Env.pushObject(ths);
			Env.setContext(ths);
			Env.pushObject(m,true);
			for (var s:String in this.vargetters) ths.deval_namesp::addGetter(s,this.vargetters[s].getFunction(ths));
			for (var s:String in this.varsetters) ths.deval_namesp::addSetter(s,this.varsetters[s].getFunction(ths));
			try{
				for (var s:String in this.functionExprs) ths[s]=this.functionExprs[s].getFunction(ths);
				for (var s:String in this.varExprs) m.deval_namesp::addProperty(s,this.varExprs[s],false);
				for (var s:String in this.varExprs) {
					ths[s]=m[s];
					delete m[s];
				}
				m.deval_namesp::clear();
				if (this.construct!=null) this.construct.getFunction(ths).apply(null,args);
			}
			finally {
				Env.popEnv();
			}
			return ths;
		}
	}
}