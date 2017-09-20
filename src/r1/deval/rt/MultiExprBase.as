package r1.deval.rt
{
   class MultiExprBase implements IExpr
   {
       
      
      var first:IExpr;
      
      var rest:Array;
      
      function MultiExprBase(param1:IExpr, param2:*)
      {
         super();
         this.first = param1;
         this.rest = param2 is Array?param2 as Array:[param2];
      }
      
      public function getNumber() : Number
      {
         throw new Error("UNIMPLEMENTED");
      }
      
      public function getString() : String
      {
         throw new Error("UNIMPLEMENTED");
      }
      
      public function addOperand(param1:*, param2:* = null) : void
      {
         var _loc3_:IExpr = null;
         if(param1 is IExpr)
         {
            rest.push(param1);
         }
         else if(param1 is Array)
         {
            for each(_loc3_ in param1 as Array)
            {
               rest.push(_loc3_);
            }
         }
      }
      
      public function getBoolean() : Boolean
      {
         throw new Error("UNIMPLEMENTED");
      }
      
      public function getAny() : Object
      {
         throw new Error("UNIMPLEMENTED");
      }
   }
}
