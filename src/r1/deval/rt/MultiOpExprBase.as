package r1.deval.rt
{
  public class MultiOpExprBase extends MultiExprBase
  {
	internal var ops:Array;

	public function MultiOpExprBase(first:IExpr, rest:Array, _ops:Array)
	{
	  super(first, rest);
	  this.ops = _ops;
	}

	override public function getBoolean():Boolean { return Boolean(getNumber()); }

	override public function getAny():Object { return getNumber(); }

	override public function getString():String { return getNumber().toString(); }

	override public function addOperand(more:*, op:*=null):void
	{
	  var i:int = 0;
	  var arr:Array = null;
	  super.addOperand(more);
	  var len:int = more is Array ? int((more as Array).length) : 1;
	  if (op is Array)
	  {
		arr = op as Array;
		for (i = 0; i < len; i++) ops.push(arr[i]);
	  }
	  else
	  {
		for (i = len; i > 0; i--) ops.push(op);
	  }
	}
  }
}