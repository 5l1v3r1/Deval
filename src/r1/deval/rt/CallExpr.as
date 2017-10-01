package r1.deval.rt
{
  public class CallExpr extends ObjectExprBase
  {
	private var newOp:Boolean;
	private var expr:IExpr;
	private var params:Array;

	public function CallExpr(newOp:Boolean, expr:IExpr)
	{
	  params = [];
	  super();
	  this.expr = expr;
	  this.newOp = newOp;
	}

	private static function newInstance(clz:*, v:Array):Object
	{
	  switch(v.length)
	  {
		case 0:
		  return new clz();
		case 1:
		  return new clz(v[0]);
		case 2:
		  return new clz(v[0], v[1]);
		case 3:
		  return new clz(v[0], v[1], v[2]);
		case 4:
		  return new clz(v[0], v[1], v[2], v[3]);
		case 5:
		  return new clz(v[0], v[1], v[2], v[3], v[4]);
		case 6:
		  return new clz(v[0], v[1], v[2], v[3], v[4], v[5]);
		case 7:
		  return new clz(v[0], v[1], v[2], v[3], v[4], v[5], v[6]);
		case 8:
		  return new clz(v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7]);
		case 9:
		  return new clz(v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8]);
		case 10:
		  return new clz(v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9]);
		case 11:
		  return new clz(v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10]);
		case 12:
		  return new clz(v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10], v[11]);
		case 13:
		  return new clz(v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10], v[11], v[12]);
		case 14:
		  return new clz(v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10], v[11], v[12], v[13]);
		case 15:
		  return new clz(v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10], v[11], v[12], v[13], v[14]);
		case 16:
		  return new clz(v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10], v[11], v[12], v[13], v[14], v[15]);
		case 17:
		  return new clz(v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10], v[11], v[12], v[13], v[14], v[15], v[16]);
		case 18:
		  return new clz(v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10], v[11], v[12], v[13], v[14], v[15], v[16], v[17]);
		case 19:
		  return new clz(v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10], v[11], v[12], v[13], v[14], v[15], v[16], v[17], v[18]);
		case 20:
		  return new clz(v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10], v[11], v[12], v[13], v[14], v[15], v[16], v[17], v[18], v[19]);
		default:
		  throw new Error("Number of parameters exceeds limit of 20.");
	  }
	}

	public function addParam(p:IExpr):void { params.push(p); }

	override public function getAny():Object
	{
	  var fxn:* = undefined;
	  var x:* = undefined;
	  var acc:Accessor = null;
	  var mthdInfo:Array = null;
	  var vals:Array = [];
	  for each (x in params)
	  {
		if (x is IExpr) x = (x as IExpr).getAny();
		vals.push(x);
	  }
	  if(newOp)
	  {
		fxn = expr.getAny();
		if (fxn is ClassProxy) return fxn.deval_namesp::getInstance(vals);
		if (!fxn) throw new RTError("msg.rt.no.class");
 		if (!(fxn is Class) && !(fxn is Function)) throw new RTError("msg.rt.not.callable");
		return newInstance(fxn, vals);
	  }
	  if (expr is Accessor)
	  {
		acc = expr as Accessor;
		mthdInfo = [null, null, false];
		acc.resolveMethod(mthdInfo);
		x = mthdInfo[0];
		fxn = mthdInfo[1];
		if(mthdInfo[2])
		{
		  vals.unshift(x);
		  x = null;
		}
	  }
	  else
	  {
		x = null;
		fxn = expr.getAny();
	  }
	  if(fxn != null)
	  {
		if(fxn is Function) return (fxn as Function).apply(x == null ? Env.peekObject() : x, vals);
		if(fxn is Class)
		{
		  if(vals.length <= 0) return null;
		  return vals[0] as (fxn as Class);
		}
	  }
	  throw new RTError("msg.rt.no.function");
	}
  }
}