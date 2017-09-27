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
		public function ClassDef(classname:String,classes:Object,staticExprs:Object,varExprs:Object,functionExprs:Object,importStmts:Array):void {
			this.internalClasses=classes;
			this.staticExpressions=staticExprs;
			this.classObj=new ClassProxy(this);
			this.globalDyns=new Array();
			this.globalVars=new Object();
			this.classname=classname;
			for (var v in this.staticExpressions) {
				this.classObj[v]=undefined;
			}
			this.importStmts=importStmts;
			this.varExprs=varExprs;
			this.functionExprs=functionExprs;
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
				for (var s:String in this.internalClasses) {
					v[s]=this.internalClasses[s];
				}
				var w:Env=new Env(null,v);
				w._globalVars=this.globalVars;
				w._globalDyns=this.globalDyns;
				Env.pushEnv(w);
				ok=true;
				for each(var m:ImportStmt in this.importStmts) m.exec();
				this.importStmts=null;
				for (var s:String in this.staticExpressions) v[s];
				var mn:Object=v.getObject();
				this.classObj=new ClassProxy(this);
				for (var s:String in mn) {
					this.classObj[s]=mn[s];
				}
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
			var m:ExprHolder=new ExprHolder(null);
			var w:Env=new Env(m,m);
			w._globalVars=this.globalVars;
			w._globalDyns=this.globalDyns;
			Env.pushEnv(w);
			Env.pushObject(this.internalClasses,true);
			Env.pushObject(this.classObj,true);
			var ths:Object=m.getObject();
			try{
				for (var s:String in this.functionExprs) m[s]=this.functionExprs[s].getFunction(ths);
				for (var s:String in this.varExprs) m.addProperty(s,this.varExprs[s],false);
				for (var s:String in this.varExprs) m[s];
				if (this.construct!=null) this.construct.getFunction(ths).apply(null,args);
			}
			finally {
				Env.popEnv();
			}
			return ths;
		}
	}
}