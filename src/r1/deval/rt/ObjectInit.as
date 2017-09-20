package r1.deval.rt
{
   class ObjectInit extends ObjectExprBase
   {
       
      
      var elems:Array;
      
      var objectInit:Object;
      
      function ObjectInit(param1:Object, param2:Array)
      {
         super();
         objectInit = param1;
         this.elems = param2;
      }
      
      override public function getAny() : Object
      {
         var _loc1_:* = undefined;
         var _loc3_:String = null;
         var _loc4_:Array = null;
         if(objectInit is Array)
         {
            _loc4_ = [];
            for each(_loc1_ in objectInit as Array)
            {
               if(_loc1_ is IExpr)
               {
                  _loc1_ = (_loc1_ as IExpr).getAny();
               }
               _loc4_.push(_loc1_);
            }
            return _loc4_;
         }
         var _loc2_:Object = {};
         for each(_loc3_ in elems)
         {
            _loc1_ = objectInit[_loc3_];
            if(_loc1_ is IExpr)
            {
               _loc1_ = (_loc1_ as IExpr).getAny();
            }
            _loc2_[_loc3_] = _loc1_;
         }
         return _loc2_;
      }
   }
}
