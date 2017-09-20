package r1.deval.rt
{
   public class ExprList implements IExpr
   {
       
      
      var exprs:Array;
      
      public function ExprList(param1:IExpr, param2:IExpr)
      {
         exprs = [];
         super();
         if(param1 != null)
         {
            exprs.push(param1);
         }
         if(param2 != null)
         {
            exprs.push(param2);
         }
      }
      
      public function add(param1:IExpr) : void
      {
         exprs.push(param1);
      }
      
      public function getNumber() : Number
      {
         return Number(getAny());
      }
      
      public function reduce() : IExpr
      {
         if(exprs.length == 1)
         {
            return exprs[0] as IExpr;
         }
         return this;
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
      
      public function getBoolean() : Boolean
      {
         return Boolean(getAny());
      }
      
      public function getAny() : Object
      {
         var _loc1_:int = 0;
         while(_loc1_ < exprs.length - 1)
         {
            (exprs[_loc1_] as IExpr).getAny();
            _loc1_++;
         }
         return (exprs[exprs.length - 1] as IExpr).getAny();
      }
   }
}
