package r1.deval.rt
{
   import r1.deval.parser.ParseError;
   
   public class RTError extends Error
   {
       
      
      private var _param1:String;
      
      private var _param2:String;
      
      private var _lineno:int;
      
      public function RTError(param1:String, param2:String = null, param3:String = null)
      {
         super(ParseError.processMessage(param1));
         _param1 = param2;
         _param2 = param3;
      }
      
      public function set lineno(param1:int) : void
      {
         _lineno = param1;
      }
      
      public function get lineno() : int
      {
         return _lineno;
      }
      
      public function toString() : String
      {
         var _loc1_:String = "Runtime Error: " + super.message;
         if(_lineno > 0)
         {
            _loc1_ = _loc1_ + (" [line:" + _lineno + "]");
         }
         return _loc1_;
      }
   }
}
