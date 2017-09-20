package r1.deval.rt
{
   import r1.deval.parser.ParserConsts;
   import r1.deval.parser.TokenStream;
   
   class Assignment extends ObjectExprBase implements IStmt
   {
       
      
      protected var op:int;
      
      protected var left:ISettable;
      
      private var _next:IStmt;
      
      private var tokenstream:TokenStream;

      private var _lineno:int;
      
      protected var right:IExpr;
      
      function Assignment(param1:ISettable, param2:IExpr, param3:int, param4:int, param5:TokenStream)
      {
         super();
         this.left = param1;
         this.right = param2;
         this.op = param3;
         this.tokenstream = param5;
         this._lineno=param4;
      }
      
      public function set next(param1:IStmt) : void
      {
         _next = param1;
      }
      
      public function exec() : void
      {
         Env.setReturnValue(getAny());
      }
      
      public function get lineno() : int
      {
         return _lineno;
      }
      
      public function get line():String {
         return tokenstream.getLineFromNo(_lineno);
      }

      override public function getAny() : Object
      {
         var _loc1_:Object = null;
         var _loc4_:Object = null;
         var _loc5_:Boolean = false;
         var _loc6_:Boolean = false;
         switch(op)
         {
            case ParserConsts.ASSIGN:
               _loc1_ = right.getAny();
               left.setValue(_loc1_);
               return _loc1_;
            case ParserConsts.ASSIGN_ADD:
               _loc1_ = left.getAny();
               _loc4_ = right.getAny();
               if((_loc1_ is XML || _loc1_ is XMLList) && (_loc4_ is XML || _loc4_ is XMLList))
               {
                  if(_loc1_ is XML)
                  {
                     _loc1_ = new XMLList("") + _loc1_;
                  }
                  _loc1_ = _loc1_ + _loc4_;
               }
               else if(_loc1_ is String || _loc4_ is String)
               {
                  _loc1_ = _loc1_.toString() + _loc4_.toString();
               }
               else
               {
                  _loc1_ = Number(_loc1_) + Number(_loc4_);
               }
               left.setValue(_loc1_);
               return _loc1_;
            case ParserConsts.ASSIGN_AND:
            case ParserConsts.ASSIGN_OR:
               _loc5_ = left.getBoolean();
               _loc6_ = right.getBoolean();
               if(op == ParserConsts.ASSIGN_AND)
               {
                  _loc5_ = _loc5_ && _loc6_;
               }
               else
               {
                  _loc5_ = _loc5_ || _loc6_;
               }
               left.setValue(_loc5_);
               return _loc5_;
            default:
               var _loc2_:Number = left.getNumber();
               var _loc3_:Number = right.getNumber();
               switch(op)
               {
                  case ParserConsts.ASSIGN_BITOR:
                     _loc2_ = _loc2_ | _loc3_;
                     break;
                  case ParserConsts.ASSIGN_BITXOR:
                     _loc2_ = _loc2_ ^ _loc3_;
                     break;
                  case ParserConsts.ASSIGN_BITAND:
                     _loc2_ = _loc2_ & _loc3_;
                     break;
                  case ParserConsts.ASSIGN_LSH:
                     _loc2_ = _loc2_ << _loc3_;
                     break;
                  case ParserConsts.ASSIGN_RSH:
                     _loc2_ = _loc2_ >> _loc3_;
                     break;
                  case ParserConsts.ASSIGN_URSH:
                     _loc2_ = _loc2_ >>> _loc3_;
                     break;
                  case ParserConsts.ASSIGN_ADD:
                     _loc2_ = _loc2_ + _loc3_;
                     break;
                  case ParserConsts.ASSIGN_SUB:
                     _loc2_ = _loc2_ - _loc3_;
                     break;
                  case ParserConsts.ASSIGN_MUL:
                     _loc2_ = _loc2_ * _loc3_;
                     break;
                  case ParserConsts.ASSIGN_DIV:
                     _loc2_ = _loc2_ / _loc3_;
                     break;
                  case ParserConsts.ASSIGN_MOD:
                     _loc2_ = _loc2_ % _loc3_;
               }
               left.setValue(_loc2_);
               return _loc2_;
         }
      }
      
      public function get next() : IStmt
      {
         return _next;
      }
   }
}
