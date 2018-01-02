package r1.deval.util
{
  import flash.utils.ByteArray;

  public class StringBuffer
  {
	private var buf:ByteArray;

	public function StringBuffer(str:String = null)
	{
	  super();
	  buf = new ByteArray();
	  if (str != null) append(str);
	}

	public function substr(start:int=0, len:int=2147483647):String { return toString().substr(start, len); }

	public function append(x:*):StringBuffer
	{
	  if (x != null) buf.writeUTFBytes(x.toString());
	  return this;
	}

	public function get length():int { return buf.length; }

	public function substring(start:int=0, end:int=2147483647):String { return toString().substring(start, end); }

	public function toString():String
	{
	  buf.position = 0;
	  return buf.readUTFBytes(buf.bytesAvailable);
	}

	public function clear():void { buf.length = 0; }

	public function println(x:*=null):void
	{
	  if (x != null) append(x);
	  append("\n");
	}
  }
}