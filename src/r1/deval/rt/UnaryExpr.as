package r1.deval.rt
{
  import r1.deval.parser.ParserConsts;

  public class UnaryExpr implements IExpr
  {
	internal var op:int, base:IExpr;

	public function UnaryExpr(_base:IExpr, _op:int)
	{
	  super();
	  this.base = _base;
	  this.op = _op;
	}

	private function incDec(inc:Boolean, postfix:Boolean):Number
	{
	  var _loc3_:ISettable = base as ISettable;
	  if (_loc3_ == null) throw new RTError("msg.rt.incdec.on.const");
	  var _loc4_:Number = base.getNumber();
	  _loc3_.setValue(_loc4_ + (!!inc ? 1 : -1));
	  return !!postfix ? Number(_loc4_) : Number(_loc4_ + (!!inc ? 1 : -1));
	}

	public function getNumber():Number
	{
	  switch (op)
	  {
		case ParserConsts.NOT:
		case ParserConsts.DELETE:
		  return Number(getBoolean());
		case ParserConsts.BITNOT:
		  return ~base.getNumber();
		case ParserConsts.SUB:
		  return -base.getNumber();
		case ParserConsts.INC:
		case ParserConsts.DEC:
		  return incDec(op == ParserConsts.INC, false);
		case ParserConsts.POSTFIX_INC:
		case ParserConsts.POSTFIX_DEC:
		  return incDec(op == ParserConsts.POSTFIX_INC, true);
		default:
		  return 0;
	  }
	}

	public function getString():String
	{
	  switch (op)
	  {
		case ParserConsts.NOT:
		case ParserConsts.DELETE:
		  return getBoolean().toString();
		case ParserConsts.ESCXMLATTR:
		  return "\"" + base.getString() + "\"";
		case ParserConsts.ESCXMLTEXT:
		  return XML(getAny()).toXMLString();
		case ParserConsts.TYPEOF:
		  return typeof base.getAny();
		case ParserConsts.VOID:
		  return "";
		default:
		  return getNumber().toString();
	  }
	}

	public function getAny():Object
	{
	  var str:String = null;
	  switch (op)
	  {
		case ParserConsts.NOT:
		case ParserConsts.DELETE:
		  return getBoolean();
		case ParserConsts.TYPEOF:
		case ParserConsts.ESCXMLATTR:
		  return getString();
		case ParserConsts.ESCXMLTEXT:
		  str = base.getString();
		  if (Util.beginsWith(str, "<>")) return new XMLList(str);
		  return new XML(str);
		case ParserConsts.VOID:
		  return null;
		default:
		  return getNumber();
	  }
	}

	public function getBoolean():Boolean
	{
	  switch (op)
	  {
		case ParserConsts.NOT:
		  return !base.getBoolean();
		case ParserConsts.ESCXMLATTR:
		case ParserConsts.ESCXMLTEXT:
		  return false;
		case ParserConsts.DELETE:
		  try
		  {
			return (base as ISettable).delProp();
		  }
		  catch (e:Error)
		  {
		  }
		  return false;
		default:
		  return Boolean(getNumber());
	  }
	}
  }
}