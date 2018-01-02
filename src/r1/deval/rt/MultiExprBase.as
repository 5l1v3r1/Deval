package r1.deval.rt
{
  public class MultiExprBase implements IExpr
  {
	internal var first:IExpr, rest:Array;

	public function MultiExprBase(_first:IExpr, _rest:*)
	{
	  super();
	  this.first = _first;
	  this.rest = _rest is Array ? _rest as Array : [_rest];
	}

	public function getNumber():Number { throw new Error("UNIMPLEMENTED"); }

	public function getString():String { throw new Error("UNIMPLEMENTED"); }

	public function addOperand(more:*, extra:*=null):void
	{
	  var x:IExpr = null;
	  if (more is IExpr)
	  {
		rest.push(more);
	  }
	  else if (more is Array)
	  {
		for each (x in more as Array)
		{
		  rest.push(x);
		}
	  }
	}
	
	public function getBoolean():Boolean { throw new Error("UNIMPLEMENTED"); }
	
	public function getAny():Object { throw new Error("UNIMPLEMENTED"); }
  }
}