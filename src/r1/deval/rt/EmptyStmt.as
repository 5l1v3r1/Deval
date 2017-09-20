package r1.deval.rt
{
   import r1.deval.parser.TokenStream;
   class EmptyStmt implements IStmt
   {
       
      
      protected var _lineno:int;

      private var tokenstream:TokenStream;
      
      function EmptyStmt(param1:int,param2:TokenStream)
      {
         super();
         _lineno = param1;
         tokenstream=param2;
      }
      
      public function get line():String {
         return tokenstream.getLineFromNo(_lineno);
      }
      public function exec() : void
      {
      }
      
      public function get lineno() : int
      {
         return _lineno;
      }
   }
}
