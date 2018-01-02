package r1.deval.rt
{
  public class ObjectExprBase implements IExpr
  {
	public function ObjectExprBase() { super(); }
	
	public function getNumber():Number { return Number(getAny()); }
	
	public function getBoolean():Boolean { return Boolean(getAny()); }
	
	public function getAny():Object { throw new Error("UNIMPLEMENTED"); }
	
	public function getString():String
	{
	  var o:Object = getAny();
	  if (o == null) return null;
	  return o.toString();
	}
  }
}