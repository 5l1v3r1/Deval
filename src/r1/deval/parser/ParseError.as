package r1.deval.parser
{
  import r1.deval.rt.Util;

  public class ParseError extends Error
  {
	public static const codeBugMessage:String = "PARSING CODE ERROR";

	private var _lineno:int, _id:String, _line:String;

	public function ParseError(msg:String, id:String, lineno:int=0, line:String="")
	{
	  super(processMessage(msg));
	  this._id = id;
	  this._lineno = lineno;
	  this._line = line;
	}

	public static function processMessage(msg:String):String
	{
	  if (!msg) return codeBugMessage;
	  if (!Util.beginsWith(msg,"msg.")) { }
	  return msg;
	}

	public function get lineno():int { return _lineno; }

	public function get line():String { return _line; }

	public function get id():String { return Boolean(_id) ? _id : ""; }

	public function toString():String
	{
	  var str:String = "Parse Error: " + super.message;
	  if (_lineno <= 0 && !_id) return str;
	  if (_lineno > 0) str = str + ("\n\tat line:" + _lineno + ": " + _line);
//    if(id) str = str + ("/" + id);
	  return str;
	}
  }
}