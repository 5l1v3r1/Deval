package r1.deval.util
{
   import flash.utils.ByteArray;
   
   public class StringBuffer
   {
       
      
      private var buf:ByteArray;
      
      public function StringBuffer(param1:String = null)
      {
         super();
         buf = new ByteArray();
         if(param1 != null)
         {
            append(param1);
         }
      }
      
      public function substr(param1:int = 0, param2:int = 2147483647) : String
      {
         return toString().substr(param1,param2);
      }
      
      public function append(param1:*) : StringBuffer
      {
         if(param1 != null)
         {
            buf.writeUTFBytes(param1.toString());
         }
         return this;
      }
      
      public function get length() : int
      {
         return buf.length;
      }
      
      public function substring(param1:int = 0, param2:int = 2147483647) : String
      {
         return toString().substring(param1,param2);
      }
      
      public function toString() : String
      {
         buf.position = 0;
         return buf.readUTFBytes(buf.bytesAvailable);
      }
      
      public function clear() : void
      {
         buf.length = 0;
      }
      
      public function println(param1:* = null) : void
      {
         if(param1 != null)
         {
            append(param1);
         }
         append("\n");
      }
   }
}
