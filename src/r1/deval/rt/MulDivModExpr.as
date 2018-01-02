package r1.deval.rt
{
  import r1.deval.parser.ParserConsts;

  public class MulDivModExpr extends MultiOpExprBase
  {
	public function MulDivModExpr(first:IExpr, rest:Array, ops:Array) { super(first, rest, ops); }

	override public function getNumber():Number
	{
	  var n:Number = NaN;
	  var result:Number = first.getNumber();
	  for (var i:int = 0; i < rest.length; i++)
	  {
		n = (rest[i] as IExpr).getNumber();
		switch(ops[i])
		{
		  case ParserConsts.MUL:
			result = result * n;
			break;
		  case ParserConsts.DIV:
			result = result / n;
			break;
		  case ParserConsts.MOD:
			result = result % n;
		}
	  }
	  return result;
	}
  }
}