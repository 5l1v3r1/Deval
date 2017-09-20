package r1.deval.rt
{
   import r1.deval.parser.ParserConsts;
   
   class ShiftExpr extends MultiOpExprBase
   {
       
      
      function ShiftExpr(param1:IExpr, param2:*, param3:*)
      {
         super(param1,param2,param3);
      }
      
      override public function getNumber() : Number
      {
         var _loc3_:Number = NaN;
         var _loc1_:Number = first.getNumber();
         var _loc2_:int = 0;
         while(_loc2_ < rest.length)
         {
            _loc3_ = (rest[_loc2_] as IExpr).getNumber();
            switch(ops[_loc2_])
            {
               case ParserConsts.LSH:
                  _loc1_ = _loc1_ << _loc3_;
                  break;
               case ParserConsts.RSH:
                  _loc1_ = _loc1_ >> _loc3_;
                  break;
               case ParserConsts.URSH:
                  _loc1_ = _loc1_ >>> _loc3_;
            }
            _loc2_++;
         }
         return _loc1_;
      }
   }
}
