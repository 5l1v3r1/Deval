package r1.deval.rt
{
  import r1.deval.parser.ParserConsts;

  internal class ShiftExpr extends MultiOpExprBase
  {
	public function ShiftExpr(first:IExpr, rest:*, ops:*) { super(first, rest, ops); }

	override public function getNumber():Number
	{
	  var n:Number = NaN;
	  var result:Number = first.getNumber();
	  for (var i:int = 0; i < rest.length; i++)
	  {
		n = (rest[i] as IExpr).getNumber();
		switch (ops[i])
		{
		  case ParserConsts.LSH:
			result = result << n;
			break;
		  case ParserConsts.RSH:
			result = result >> n;
			break;
		  case ParserConsts.URSH:
			result = result >>> n;
		}
	  }
	  return result;
	}
  }
}