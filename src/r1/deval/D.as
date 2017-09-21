package r1.deval
{
   import r1.deval.parser.BaseParser;
   import r1.deval.rt.Block;
   import r1.deval.rt.Env;
   import r1.deval.rt.FunctionDef;
   
   public class D
   {
      
      private static var _programLimit:int = 512;
      
      private static var _cache:Object = {};
      
      private static var _useCache:Boolean = true;
      
      public static const OVERRIDE_GLOBAL_ERROR:int = 3;
      
      public static const OVERRIDE_GLOBAL_OVERRIDE:int = 1;
      
      public static const OVERRIDE_GLOBAL_WARN:int = 2;
      
      public static const OVERRIDE_GLOBAL_IGNORE:int = 0;
       
      
      public function D()
      {
         super();
      }
      
      public static function display(param1:String) : void
      {
         Env.display(param1);
      }
      
      public static function setOutput(param1:Function) : void
      {
         Env.outputFunction = param1;
      }
      
      public static function collectUserFunctions(param1:Object) : Object
      {
         var _loc3_:String = null;
         var _loc4_:Object = null;
         var _loc2_:Object = {};
         for each(_loc3_ in param1)
         {
            _loc4_ = param1[_loc4_];
            if(_loc4_ is FunctionDef)
            {
               _loc2_[_loc3_] = _loc4_;
            }
         }
         return _loc2_;
      }
      
      public static function useCache(param1:Boolean = true, param2:int = -1) : void
      {
         _useCache = param1;
         if(param2 > 0)
         {
            _programLimit = param2;
         }
      }
      
      public static function setTextControlOutput(param1:Object, param2:String = "text", param3:int = 2048) : void
      {
         var host:Object = param1;
         var prop:String = param2;
         var limit:int = param3;
         setOutput(function(param1:String):void
         {
            var _loc2_:String = host[prop];
            if(_loc2_ == "")
            {
               _loc2_ = param1;
            }
            else
            {
               if(_loc2_.length >= limit)
               {
                  _loc2_ = _loc2_.substring(_loc2_.length - limit);
               }
               _loc2_ = _loc2_ + "\n" + param1;
            }
            host[prop] = _loc2_;
         });
      }
      
      public static function parseProgram(param1:String) : Object
      {
         return new BaseParser().parseProgram(param1);
      }
      
      public static function importClass(param1:Class) : void
      {
         Env.importClass(param1);
      }
      
      public static function eval(param1:*, param2:Object = null, param3:Object = null) : Object
      {
         var _loc4_:String = null;
         var _loc5_:FunctionDef = null;
         if(param1 == null || param1 == "")
         {
            return null;
         }
         if(param1 is String)
         {
            _loc4_ = String(param1);
            if(_useCache && _loc4_.length <= _programLimit)
            {
               param1 = _cache[_loc4_];
               if(param1 == null)
               {
                  _cache[_loc4_] = param1 = parseProgram(_loc4_);
               }
            }
            else
            {
               param1 = parseProgram(_loc4_);
            }
         }
         if(param1 is Array)
         {
            if(param2 == null)
            {
               param2 = {};
            }
            for each(_loc5_ in param1[1])
            {
               param2[_loc5_.name] = _loc5_;
            }
            param1 = param1[0];
         }
         try{
            return Env.run(param1 as Block,param3,param2);
         }
         catch(e:Error) {
            throw e;
         }
         finally {
            Env.cleanUp();
         }
		 return null;
      }
      
      public static function importFunction(param1:String, param2:Function) : void
      {
         Env.importFunction(param1,param2);
      }
      
      public static function evalToNumber(param1:*, param2:Object = null, param3:Object = null) : Number
      {
         return Number(eval(param1,param2,param3));
      }
      
      public static function setOverrideGlobalOption(param1:int) : void
      {
         Env.setOverrideGlobalOption(param1);
      }
      
      public static function parseFunctions(param1:String) : Object
      {
         var _loc4_:FunctionDef = null;
         var _loc2_:Object = {};
         var _loc3_:Object = parseProgram(param1);
         if(_loc3_ is Array)
         {
            for each(_loc4_ in _loc3_[1])
            {
               _loc2_[_loc4_.name] = _loc4_;
            }
         }
         return _loc2_;
      }
      
      public static function evalToString(param1:*, param2:Object = null, param3:Object = null) : String
      {
         return eval(param1,param2,param3) as String;
      }
      
      public static function evalToBoolean(param1:*, param2:Object = null, param3:Object = null) : Boolean
      {
         return Boolean(eval(param1,param2,param3));
      }
      
      public static function evalToInt(param1:*, param2:Object = null, param3:Object = null) : int
      {
         return int(eval(param1,param2,param3));
      }
      
      public static function importStaticMethods(param1:Class, param2:* = null) : void
      {
         Env.importStaticMethods(param1,param2);
      }
   }
}
