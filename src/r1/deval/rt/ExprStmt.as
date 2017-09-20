package r1.deval.rt
{
   public class ExprStmt extends EmptyStmt
   {
       
      
      var _expr:IExpr;
      
      public function ExprStmt(param1:IExpr, param2:int)
      {
         super(param2);
         this._expr = param1;
      }
      
      override public function exec() : void
      {
         Env.setReturnValue(_expr.getAny());
      }
      
      public function get expr() : IExpr
      {
         return this._expr;
      }
      
      public function toString() : String
      {
         return String(_expr);
      }
   }
}
