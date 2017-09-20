package r1.deval.rt
{
   class AddSubExpr extends MultiOpExprBase
   {
       
      
      function AddSubExpr(param1:IExpr, param2:Array, param3:Array)
      {
         super(param1,param2,param3);
      }
      
      override public function getNumber() : Number
      {
         return Number(getAny());
      }
      
      override public function getString() : String
      {
         return getAny().toString();
      }
      
      override public function getBoolean() : Boolean
      {
         return Boolean(getAny());
      }
      
      override public function getAny() : Object
      {
         var _loc3_:Number = NaN;
         var _loc4_:Object = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:Array = null;
         var _loc8_:String = null;
         var _loc9_:XMLList = null;
         var _loc1_:Boolean = true;
         var _loc2_:int = ops.length - 1;
         while(_loc2_ >= 0)
         {
            if(!ops[_loc2_])
            {
               _loc1_ = false;
               break;
            }
            _loc2_--;
         }
         if(_loc1_)
         {
            _loc4_ = first.getAny();
            _loc5_ = _loc4_ is Number?1:0;
            _loc6_ = _loc4_ is XML?1:0;
            _loc7_ = [_loc4_];
            _loc2_ = 0;
            while(_loc2_ < rest.length)
            {
               _loc4_ = (rest[_loc2_] as IExpr).getAny();
               if(_loc4_ is Number)
               {
                  _loc5_++;
               }
               else if(_loc4_ is XML || _loc4_ is XMLList)
               {
                  _loc6_++;
               }
               _loc7_.push(_loc4_);
               _loc2_++;
            }
            if(_loc6_ == rest.length + 1)
            {
               _loc9_ = new XMLList("");
               for each(_loc4_ in _loc7_)
               {
                  _loc9_ = _loc9_ + _loc4_;
               }
               return _loc9_;
            }
            if(_loc5_ == rest.length + 1)
            {
               _loc3_ = 0;
               for each(_loc4_ in _loc7_)
               {
                  _loc3_ = _loc3_ + Number(_loc4_);
               }
               return _loc3_;
            }
            _loc8_ = "";
            for each(_loc4_ in _loc7_)
            {
               _loc8_ = _loc8_ + _loc4_;
            }
            return _loc8_;
         }
         _loc3_ = first.getNumber();
         _loc2_ = 0;
         while(_loc2_ < rest.length)
         {
            if(ops[_loc2_])
            {
               _loc3_ = _loc3_ + rest[_loc2_].getNumber();
            }
            else
            {
               _loc3_ = _loc3_ - rest[_loc2_].getNumber();
            }
            _loc2_++;
         }
         return _loc3_;
      }
   }
}
