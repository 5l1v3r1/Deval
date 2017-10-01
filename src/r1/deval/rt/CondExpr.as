package r1.deval.rt
{
  internal class CondExpr implements IExpr
  {
	private var truePart:IExpr;
	private var cond:IExpr;
	private var falsePart:IExpr;

	public function CondExpr(cond:IExpr, truePart:IExpr, falsePart:IExpr)
	{
	  super();
	  this.cond = cond;
	  this.truePart = truePart;
	  this.falsePart = falsePart;
	}

	public function getNumber():Number { return !!cond.getBoolean() ? Number(truePart.getNumber()) : Number(falsePart.getNumber()); }

	public function getString():String { return !!cond.getBoolean() ? truePart.getString() : falsePart.getString(); }

	public function getBoolean():Boolean { return !!cond.getBoolean() ? Boolean(truePart.getBoolean()) : Boolean(falsePart.getBoolean()); }

	public function getAny():Object { return !!cond.getBoolean() ? truePart.getAny() : falsePart.getAny(); }
  }
}