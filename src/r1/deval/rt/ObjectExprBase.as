package r1.deval.rt
{
   class ObjectExprBase implements IExpr
   {
       
      
      function ObjectExprBase()
      {
         super();
      }
      
      public function getNumber() : Number
      {
         return Number(getAny());
      }
      
      public function getBoolean() : Boolean
      {
         return Boolean(getAny());
      }
      
      public function getAny() : Object
      {
         throw new Error("UNIMPLEMENTED");
      }
      
      public function getString() : String
      {
         var _loc1_:Object = getAny();
         if(_loc1_ == null)
         {
            return null;
         }
         return _loc1_.toString();
      }
   }
}
