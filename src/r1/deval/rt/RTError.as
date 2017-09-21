package r1.deval.rt
{
   import r1.deval.parser.ParseError;
   
   public class RTError extends Error
   {
       
      
      private var _param1:String;
      
      private var _param2:String;
      
      private var linenos:Array;

      private var lines:Array;
      
      public function RTError(param1:String, param2:String = null, param3:String = null,_linenos:Array=null,_lines:Array=null)
      {
         super(ParseError.processMessage(param1));
         _param1 = param2;
         _param2 = param3;
         if (_lines==null) this.lines=new Array();
         else this.lines=_lines;
         if (_linenos==null) this.linenos=new Array();
         else this.linenos=_linenos;
      }
      
      public function pushline(line:String,lineno:int):void {
         if (linenos.length>0&&linenos[linenos.length-1]==lineno) return;
         this.lines.push(line);
         this.linenos.push(lineno);
      }
      public function toString() : String
      {
         var _loc1_:String = "Runtime Error: " + super.message;
         for (var j:int=0;j<lines.length;j++) {
            if (j==0) _loc1_+="\n";
            _loc1_+="\tat line: "+linenos[j]+": "+lines[j];
         }
         return _loc1_;
      }
   }
}
