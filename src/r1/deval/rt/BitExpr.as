package r1.deval.rt
{
   import r1.deval.parser.ParserConsts;
   
   class BitExpr extends MultiExprBase
   {
       
      
      var op:int;
      
      function BitExpr(param1:IExpr, param2:*, param3:int)
      {
         super(param1,param2);
         this.op = param3;
      }
      
      public function isA(param1:int) : Boolean
      {
         return param1 == this.op;
      }
      
      override public function getBoolean() : Boolean
      {
         return Boolean(getNumber());
      }
      
      override public function getAny() : Object
      {
         return getNumber();
      }
      
      override public function getString() : String
      {
         return getNumber().toString();
      }
      
      override public function getNumber() : Number
      {
         var _loc1_:Number = first.getNumber();
         var _loc2_:int = 0;
         while(_loc2_ < rest.length)
         {
            if(op == ParserConsts.BITAND)
            {
               _loc1_ = _loc1_ & rest[_loc2_].getNumber();
            }
            else if(op == ParserConsts.BITOR)
            {
               _loc1_ = _loc1_ | rest[_loc2_].getNumber();
            }
            else
            {
               _loc1_ = _loc1_ ^ rest[_loc2_].getNumber();
            }
            _loc2_++;
         }
         return _loc1_;
      }
   }
}
