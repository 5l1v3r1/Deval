package r1.deval.rt
{
  public class ObjectInit extends ObjectExprBase
  {
	private var elems:Array, objectInit:Object;

	public function ObjectInit(objInit:Object, _elems:Array)
	{
	  super();
	  objectInit = objInit;
	  this.elems = _elems;
	}

	override public function getAny() : Object
	{
	  var x:* = undefined;
	  var y:String = null;
	  var arr:Array = null;
	  if (objectInit is Array)
	  {
		arr = [];
		for each (x in objectInit as Array)
		{
		  if (x is IExpr) x = (x as IExpr).getAny();
		  arr.push(x);
		}
		return arr;
	  }
	  var obj:Object = new Object();
	  for each (y in elems)
	  {
		x = objectInit[y];
		if (x is IExpr) x = (x as IExpr).getAny();
		obj[y] = x;
	  }
	  return obj;
	}
  }
}