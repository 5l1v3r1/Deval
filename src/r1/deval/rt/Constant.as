package r1.deval.rt
{
   public class Constant implements IExpr
   {
      
      public static const FALSE:Constant = new Constant(false);
      
      public static const NULL:Constant = new Constant(null);
      
      public static const ZERO:Constant = new Constant(0);
      
      public static const EMPTY_STRING:Constant = new Constant("");
      
      public static const ONE:Constant = new Constant(1);
      
      public static const TRUE:Constant = new Constant(true);
      
      public static const MINUSONE:Constant = new Constant(-1);
       
      
      var value:Object;
      
      public function Constant(param1:Object)
      {
         super();
         this.value = param1;
      }
      
      public function getString() : String
      {
         return value == null?"null":value.toString();
      }
      
      public function getBoolean() : Boolean
      {
         return Boolean(value);
      }
      
      public function getAny() : Object
      {
         return value;
      }
      
      public function getNumber() : Number
      {
         return value == null?Number(0):Number(Number(value));
      }
   }
}
