package r1.deval.parser
{
   import r1.deval.rt.Util;
   
   public class ParseError extends Error
   {
      
      public static const codeBugMessage:String = "PARSING CODE ERROR";
       
      
      private var _lineno:int;
      
      private var _id:String;
      
      public function ParseError(param1:String, param2:String, param3:int = 0)
      {
         super(processMessage(param1));
         this._id = param2;
         this._lineno = param3;
      }
      
      public static function processMessage(param1:String) : String
      {
         if(!param1)
         {
            return codeBugMessage;
         }
         if(!Util.beginsWith(param1,"msg."))
         {
         }
         return param1;
      }
      
      public function get lineno() : int
      {
         return _lineno;
      }
      
      public function get id() : String
      {
         return !!_id?_id:"";
      }
      
      public function toString() : String
      {
         var _loc1_:String = "Parse Error: " + super.message;
         if(_lineno <= 0 && !_id)
         {
            return _loc1_;
         }
         if(_lineno > 0)
         {
            _loc1_ = _loc1_ + (" [line:" + _lineno);
         }
         if(id)
         {
            _loc1_ = _loc1_ + ("/" + id);
         }
         return _loc1_ + "]";
      }
   }
}
