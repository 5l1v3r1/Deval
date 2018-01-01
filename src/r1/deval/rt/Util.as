package r1.deval.rt
{
  public class Util
  {
	public function Util() { super(); }

	public static function beginsWith(input:String, prefix:String):Boolean { return prefix == input.substring(0, prefix.length); }

	public static function endsWith(input:String, suffix:String):Boolean { return suffix == input.substring(input.length - suffix.length); }

	public static function substitute(str:String, ...rest):String
	{
	  var args:Array = null;
	  if (str == null) return "";
	  var len:uint = rest.length;
	  if (len == 1 && rest[0] is Array)
	  {
		args = rest[0] as Array;
		len = args.length;
	  }
	  else
	  {
		args = rest;
	  }
	  for (var i:int = 0; i < len; i++) str = str.replace(new RegExp("\\{" + i + "\\}", "g"), args[i]);
	  return str;
	}
  }
}