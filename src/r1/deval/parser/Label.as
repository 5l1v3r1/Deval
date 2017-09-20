package r1.deval.parser
{
   import r1.deval.rt.Block;
   import r1.deval.rt.IExpr;
   
   public class Label implements IExpr
   {
       
      
      public var name:String;
      
      public var block:Block;
      
      public var postfix:Block;
      
      public var isSwitch:Boolean;
      
      public function Label(param1:String, param2:Boolean = false)
      {
         super();
         this.name = param1;
         this.isSwitch = param2;
      }
      
      public function getString() : String
      {
         throw new Error("UNIMPLEMENTED");
      }
      
      public function getBoolean() : Boolean
      {
         throw new Error("UNIMPLEMENTED");
      }
      
      public function getAny() : Object
      {
         throw new Error("UNIMPLEMENTED");
      }
      
      public function getNumber() : Number
      {
         throw new Error("UNIMPLEMENTED");
      }
   }
}
