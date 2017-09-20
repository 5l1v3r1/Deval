package r1.deval.rt
{
   import r1.deval.parser.ParserConsts;
   import r1.deval.parser.TokenStream;
   
   public class ExprFactory extends ParserConsts
   {
       
      
      public function ExprFactory()
      {
         super();
      }
      
      public function createVarExpr(param1:String, param2:IExpr = null, param3:IExpr = null) : IExpr
      {
         return createExprList(param3,new VarExpr(param1,param2));
      }
      
      public function createXMLAttrExpr(param1:IExpr) : IExpr
      {
         return new UnaryExpr(param1,ESCXMLATTR);
      }
      
      public function createAndOrExpr(param1:IExpr, param2:*, param3:Boolean, param4:Boolean, param5:Boolean = false) : IExpr
      {
         if(param1 is AndOrExpr && AndOrExpr(param1).isA(param3,param4,param5))
         {
            AndOrExpr(param1).addOperand(param2);
            return param1;
         }
         return new AndOrExpr(param1,param2,param3,param4,param5);
      }
      
      public function createAccessor(param1:IExpr, param2:*, param3:IExpr = null, param4:Boolean = false, param5:Boolean = false) : IExpr
      {
         var _loc6_:* = param2;
         if(_loc6_ is Constant)
         {
            _loc6_ = (_loc6_ as Constant).getAny();
         }
         if(param3 == null && !param4 && !param5)
         {
            return new Accessor(param1,_loc6_);
         }
         return new XMLAccessor(param1,_loc6_,param3,false,param4,param5);
      }
      
      public function createEqRelExpr(param1:IExpr, param2:IExpr, param3:int) : IExpr
      {
         if(param1 is EqRelExpr)
         {
            EqRelExpr(param1).addOperand(param2,param3);
            return param1;
         }
         return new EqRelExpr(param1,[param2],[param3]);
      }
      
      public function createUnaryExpr(param1:IExpr, param2:int) : IExpr
      {
         if(param2 == ADD)
         {
            return param1;
         }
         if(param2 == SUB)
         {
            if(param1 is Constant)
            {
               if(param1 == Constant.ONE)
               {
                  return Constant.MINUSONE;
               }
               if(param1.getAny() is Number)
               {
                  return new Constant(-param1.getNumber());
               }
            }
         }
         return new UnaryExpr(param1,param2);
      }
      
      public function createAssignment(param1:ISettable, param2:IExpr, param3:int, param4:int, param5:TokenStream) : IExpr
      {
         return new Assignment(param1,param2,param3,param4,param5);
      }
      
      public function createDotQuery(param1:IExpr, param2:IExpr) : IExpr
      {
         return new XMLAccessor(param1,param2,null,true);
      }
      
      public function createObjectInit(param1:Object, param2:Boolean = false, param3:Array = null) : IExpr
      {
         return !!param2?new Constant(param1):new ObjectInit(param1,param3);
      }
      
      public function createBitExpr(param1:IExpr, param2:*, param3:int) : IExpr
      {
         if(param1 is BitExpr && BitExpr(param1).isA(param3))
         {
            BitExpr(param1).addOperand(param2);
            return param1;
         }
         return new BitExpr(param1,param2,param3);
      }
      
      public function createMulDivModExpr(param1:IExpr, param2:IExpr, param3:int) : IExpr
      {
         if(param1 is MulDivModExpr)
         {
            MulDivModExpr(param1).addOperand(param2,param3);
            return param1;
         }
         return new MulDivModExpr(param1,[param2],[param3]);
      }
      
      public function literal(param1:Object) : IExpr
      {
         if(param1 is Number)
         {
            if(param1 == 0)
            {
               return Constant.ZERO;
            }
            if(param1 == 1)
            {
               return Constant.ONE;
            }
            if(param1 == -1)
            {
               return Constant.MINUSONE;
            }
         }
         else
         {
            if(param1 is Boolean)
            {
               return param1 == true?Constant.TRUE:Constant.FALSE;
            }
            if(param1 == null)
            {
               return Constant.NULL;
            }
            if(param1 == "")
            {
               return Constant.EMPTY_STRING;
            }
         }
         return new Constant(param1);
      }
      
      public function createQNameInit(param1:IExpr, param2:IExpr) : IExpr
      {
         if(param1 is Constant && param2 is Constant)
         {
            return new Constant(new QName(param1.getAny() as Namespace,param2.getString()));
         }
         return new QNameInit(param1,param2);
      }
      
      public function createIsInAsExpr(param1:IExpr, param2:IExpr, param3:int) : IExpr
      {
         return new IsInAsExpr(param1,param2,param3);
      }
      
      public function thisExpr() : IExpr
      {
         return ThisExpr.INSTANCE;
      }
      
      public function createCallExpr(param1:IExpr) : CallExpr
      {
         return new CallExpr(false,param1);
      }
      
      public function createAddSubExpr(param1:IExpr, param2:IExpr, param3:Boolean = true) : IExpr
      {
         if(param1 == null)
         {
            return !!param3?param2:createUnaryExpr(param2,SUB);
         }
         if(param1 is AddSubExpr)
         {
            AddSubExpr(param1).addOperand(param2,param3);
            return param1;
         }
         return new AddSubExpr(param1,[param2],[param3]);
      }
      
      public function regExp(param1:String, param2:String) : IExpr
      {
         return new Constant(new RegExp(param1,param2));
      }
      
      public function createNewExpr(param1:IExpr) : CallExpr
      {
         return new CallExpr(true,param1);
      }
      
      public function createCondExpr(param1:IExpr, param2:IExpr, param3:IExpr) : IExpr
      {
         return new CondExpr(param1,param2,param3);
      }
      
      public function createShiftExpr(param1:IExpr, param2:IExpr, param3:int) : IExpr
      {
         if(param1 is ShiftExpr)
         {
            ShiftExpr(param1).addOperand(param2,param3);
            return param1;
         }
         return new ShiftExpr(param1,[param2],[param3]);
      }
      
      public function createXMLLiteralExpr(param1:IExpr, param2:IExpr) : IExpr
      {
         return new UnaryExpr(createAddSubExpr(param1,param2),ESCXMLTEXT);
      }
      
      public function createExprList(param1:IExpr, param2:IExpr) : IExpr
      {
         if(param1 == null)
         {
            return param2;
         }
         if(param1 is ExprList)
         {
            ExprList(param1).add(param2);
            return param1;
         }
         return new ExprList(param1,param2);
      }
   }
}
