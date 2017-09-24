package r1.deval.rt
{
   public class FunctionDef implements IExpr
   {
       
      
      private var head:Block;
      
      private var params:Array;
      
      public var name:String;

      private var restParam:String=null;
      
      private var tail:EndBlock;

      private var snp:Env;
      
      private var func:Function=null;

      public static const THISOBJECT:Object=new Dummy();

      public function FunctionDef(param1:String, param2:Array, param3:Block, param4:EndBlock)
      {
         super();
         this.name = param1 == null?"_anonymous_":param1;
         if (param2.length>0&&param2[param2.length-1].substring(0,3)=="...") {
            restParam=param2.pop().substr(3);
         }
         this.params = param2;
         this.head = param3;
         this.tail = param4;
      }
      
      public function optimize() : void
      {
         if(head != null)
         {
            head.optimize();
         }
      }
      
      public function getString() : String
      {
         throw new RTError("msg.rt.eval.function.to.value");
      }
      
      public function getBoolean() : Boolean
      {
         throw new RTError("msg.rt.eval.function.to.value");
      }
      
      public function getFunction(thisobj:Object=null):Function {
         if (func!=null) return func;
         var fixthisobj:Object=thisobj;
         snp=Env.createSnapshot();
         if (thisobj) snp.setThis(thisobj);
         var x:Function = function(...args):Object {
            var v:Object;
            Env.pushEnv(snp);
            if (!fixthisobj){
               if (this!=THISOBJECT) v=this;
               else v=Env.getCurrentScope();
               Env.setThis(v);
            }
            try{
               return run(args,null);
            }
            catch(e:Error) {throw e;}
            finally {
               if (!fixthisobj) Env.setThis(null);
               Env.popEnv();
            }
			   return null;
         }
         func=x;
         return x;
      }
      public function run(param1:Array,cont:Object=null) : Object
      {
         var paramVals:Array = param1;
         var paramsLen:int = params == null?0:int(params.length);
         var len:int = paramVals == null?0:int(paramVals.length);
         if(len > paramsLen)
         {
            len = paramsLen;
         }
         var context:Object;
         if (cont!=null) context=cont;
         else context=new Object();
         var idx:int = 0;
         while(idx < len)
         {
            context[params[idx]] = paramVals[idx];
            idx++;
         }
         if (restParam!=null) {
            var v:Array=new Array();
            for (var i:int=len;i<paramVals.length;i++) v.push(paramVals[i]);
            context[restParam]=v;
         }
         try
         {
            Env.pushObject(context);
            Env.setContext(context);
            Env.setReturnValue(null);
            head.run(tail);
            return Env.getReturnValue();
         }
         finally
         {
            Env.popObject();
            Env.setContext(null);
         }
         return null;
      }
      
      public function dump(param1:Object) : void
      {
         var _loc2_:* = "\n<Function name=\"" + name + "\" params=\"";
         var _loc3_:int = params == null?0:int(params.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            if(_loc4_ > 0)
            {
               _loc2_ = _loc2_ + ",";
            }
            _loc2_ = _loc2_ + params[_loc4_];
            _loc4_++;
         }
         trace(_loc2_ + "\">");
         head.dump(param1,1);
         trace("\n</Function>");
      }
      
      public function getAny() : Object
      {
         return getFunction();
      }
      
      public function getNumber() : Number
      {
         throw new RTError("msg.rt.eval.function.to.value");
      }
   }
}
