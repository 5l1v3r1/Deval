package r1.deval.rt
{
   class AndOrExpr extends MultiExprBase
   {
       
      
      private var op:Boolean;
      
      private var isNot:Boolean;
      
      private var isXor:Boolean;
      
      function AndOrExpr(param1:IExpr, param2:*, param3:Boolean, param4:Boolean, param5:Boolean)
      {
         super(param1,param2);
         this.op = param3;
         this.isNot = param4;
         this.isXor = param5;
      }
      
      override public function getString() : String
      {
         return getBoolean().toString();
      }
      
      override public function getBoolean() : Boolean
      {
         var _loc1_:int = 0;
         var _loc2_:Boolean = false;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc3_:int = rest.length;
         var _loc4_:Boolean = first.getBoolean();
         if(isXor)
         {
            _loc5_ = !!_loc4_?1:0;
            _loc6_ = !!_loc4_?0:1;
            _loc1_ = 0;
            while(_loc1_ < _loc3_)
            {
               if(IExpr(rest[_loc1_]).getBoolean())
               {
                  _loc5_++;
               }
               else
               {
                  _loc6_++;
               }
               _loc1_++;
            }
            return _loc5_ != ++_loc3_ && _loc6_ != _loc3_;
         }
         _loc1_ = 0;
         while(_loc1_ < _loc3_)
         {
            _loc2_ = IExpr(rest[_loc1_]).getBoolean();
            if(isXor)
            {
               _loc5_ = _loc5_ + (!!_loc2_?1:0);
            }
            else if(op)
            {
               _loc4_ = _loc4_ && _loc2_;
            }
            else
            {
               _loc4_ = _loc4_ || _loc2_;
            }
            _loc1_++;
         }
         return !!isNot?!_loc4_:Boolean(_loc4_);
      }
      
      override public function getAny() : Object
      {
         return getBoolean();
      }
      
      public function isA(param1:Boolean, param2:Boolean, param3:Boolean) : Boolean
      {
         if(param3)
         {
            return this.isXor;
         }
         return param1 == this.op && param2 == this.isNot;
      }
      
      override public function getNumber() : Number
      {
         return Number(getBoolean());
      }
   }
}
