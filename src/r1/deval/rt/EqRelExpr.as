package r1.deval.rt
{
   import r1.deval.parser.ParserConsts;
   
   class EqRelExpr extends MultiOpExprBase
   {
       
      
      function EqRelExpr(param1:IExpr, param2:*, param3:*)
      {
         super(param1,param2,param3);
      }
      
      override public function getNumber() : Number
      {
         return Number(getBoolean());
      }
      
      override public function getString() : String
      {
         return getBoolean().toString();
      }
      
      override public function getBoolean() : Boolean
      {
         var _loc4_:int = 0;
         var _loc5_:Object = null;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc1_:IExpr = first;
         var _loc2_:Object = _loc1_.getAny();
         var _loc3_:int = 0;
         loop0:
         while(true)
         {
            if(_loc3_ >= rest.length)
            {
               return true;
            }
            _loc4_ = ops[_loc3_] as int;
            _loc5_ = (rest[_loc3_] as IExpr).getAny();
            if(_loc2_ is Number || _loc5_ is Number)
            {
               _loc6_ = Number(_loc2_);
               _loc7_ = Number(_loc5_);
               switch(_loc4_)
               {
                  case ParserConsts.EQ:
                  case ParserConsts.SHEQ:
                     if(_loc6_ != _loc7_)
                     {
                        return false;
                     }
                     break;
                  case ParserConsts.NE:
                  case ParserConsts.SHNE:
                     if(_loc6_ == _loc7_)
                     {
                        return false;
                     }
                     break;
                  case ParserConsts.LE:
                     if(_loc6_ > _loc7_)
                     {
                        return false;
                     }
                     break;
                  case ParserConsts.LT:
                     if(_loc6_ >= _loc7_)
                     {
                        return false;
                     }
                     break;
                  case ParserConsts.GE:
                     if(_loc6_ < _loc7_)
                     {
                        return false;
                     }
                     break;
                  case ParserConsts.GT:
                     if(_loc6_ <= _loc7_)
                     {
                        return false;
                     }
                     break;
               }
            }
            else
            {
               switch(_loc4_)
               {
                  case ParserConsts.EQ:
                     if(_loc2_ != _loc5_)
                     {
                        return false;
                     }
                     break;
                  case ParserConsts.NE:
                     if(_loc2_ == _loc5_)
                     {
                        return false;
                     }
                     break;
                  case ParserConsts.SHEQ:
                     if(_loc2_ !== _loc5_)
                     {
                        return false;
                     }
                     break;
                  case ParserConsts.SHNE:
                     if(_loc2_ === _loc5_)
                     {
                        return false;
                     }
                     break;
                  case ParserConsts.LE:
                  case ParserConsts.LT:
                  case ParserConsts.GE:
                  case ParserConsts.GT:
                     break loop0;
               }
            }
            _loc2_ = _loc5_;
            _loc3_++;
         }
         return false;
      }
      
      override public function getAny() : Object
      {
         return getBoolean();
      }
   }
}
