package r1.deval.rt
{
  import r1.deval.parser.ParserConsts;

  internal class EqRelExpr extends MultiOpExprBase
  {
	public function EqRelExpr(first:IExpr, rest:*, ops:*)
	{
	  super(first, rest, ops);
	}

	override public function getNumber():Number { return Number(getBoolean()); }

	override public function getString():String { return getBoolean().toString(); }

	override public function getBoolean():Boolean
	{
	  var option:int = 0;
	  var _r:Object = null;
	  var _nl:Number = NaN;
	  var _nr:Number = NaN;
	  var left:IExpr = first;
	  var _l:Object = left.getAny();
	  var i:int = 0;
	  loop0:
	  while (true)
	  {
		if (i >= rest.length) return true;
		option = ops[i] as int;
		_r = (rest[i] as IExpr).getAny();
		if (_l is Number || _r is Number)
		{
		  _nl = Number(_l);
		  _nr = Number(_r);
		  switch (option)
		  {
			case ParserConsts.EQ:
			case ParserConsts.SHEQ:
			  if (_nl != _nr) return false;
			  break;
			case ParserConsts.NE:
			case ParserConsts.SHNE:
			  if (_nl == _nr) return false;
			  break;
			case ParserConsts.LE:
			  if (_nl > _nr) return false;
			  break;
			case ParserConsts.LT:
			  if (_nl >= _nr) return false;
			  break;
			case ParserConsts.GE:
			  if (_nl < _nr) return false;
			  break;
			case ParserConsts.GT:
			  if (_nl <= _nr) return false;
			  break;
		  }
		}
		else
		{
		  switch (option)
		  {
			case ParserConsts.EQ:
			  if (_l != _r) return false;
			  break;
			case ParserConsts.NE:
			  if (_l == _r) return false;
			  break;
			case ParserConsts.SHEQ:
			  if (_l !== _r) return false;
			  break;
			case ParserConsts.SHNE:
			  if (_l === _r) return false;
			  break;
			case ParserConsts.LE:
			case ParserConsts.LT:
			case ParserConsts.GE:
			case ParserConsts.GT:
			  break loop0;
		  }
		}
		_l = _r;
		i++;
	  }
	  return false;
	}

	override public function getAny():Object { return getBoolean(); }
  }
}