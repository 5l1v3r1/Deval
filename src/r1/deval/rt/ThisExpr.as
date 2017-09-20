package r1.deval.rt
{
   class ThisExpr extends ObjectExprBase
   {
      
      static const INSTANCE:ThisExpr = new ThisExpr();
       
      
      function ThisExpr()
      {
         super();
      }
      
      override public function getAny() : Object
      {
         return Env.getThis();
      }
   }
}
