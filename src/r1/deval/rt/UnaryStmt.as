package r1.deval.rt
{
   import r1.deval.parser.ParserConsts;
   import r1.deval.parser.TokenStream;
   
   public class UnaryStmt extends EmptyStmt
   {
       
      
      private var value:IExpr;
      
      private var type:int;
      
      public function UnaryStmt(param1:int, param2:*, param3:int,param4:TokenStream)
      {
         super(param3,param4);
         this.type = param1;
         this.value = param2;
      }
      
      override public function exec() : void
      {
         var _loc1_:Object = null;
         var _loc2_:Namespace = null;
         switch(type)
         {
            case ParserConsts.DEFAULT_NS:
               if(value != null)
               {
                  _loc2_ = value.getAny() as Namespace;
                  default xml namespace = _loc2_;
               }
               break;
            case ParserConsts.THROW:
               _loc1_ = value.getAny();
               if(_loc1_ is Error)
               {
                  throw _loc1_ as Error;
               }
               throw new Error(_loc1_.toString());
         }
      }
   }
}
