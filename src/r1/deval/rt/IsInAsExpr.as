package r1.deval.rt
{
  import flash.system.ApplicationDomain;
  import r1.deval.parser.ParserConsts;

  public class IsInAsExpr extends UnaryExpr
  {
	private static const IS_DATE:int = -7, IS_ARRAY:int = -2, IS_NUMBER:int = -3, IS_STRING:int = -6, IS_UINT:int = -5, IS_BOOLEAN:int = -8, IS_INT:int = -4, IS_OBJECT:int = -1;

	private var type:*, id:int;

	public function IsInAsExpr(base:IExpr, _type:*, _op:int)
	{
	  var typeName:String = null;
	  super(base, _op);
	  this.type = _type as IExpr;
	  id = IS_OBJECT;
	  if (_type is String)
	  {
		typeName = String(_type).toLowerCase();
		if (typeName == "int") id = IS_INT;
		else if (typeName == "uint") id = IS_UINT;
		else if (typeName == "number") id = IS_NUMBER;
		else if (typeName == "string") id = IS_STRING;
		else if (typeName == "boolean") id = IS_BOOLEAN;
		else if (typeName == "date") id = IS_DATE;
		else if (typeName == "array") id = IS_ARRAY;
	  }
	}

	override public function getNumber():Number { return Number(getBoolean()); }

	public function getInParts():Array
	{
	  if (op != ParserConsts.IN) return null;
	  return [base, type];
	}

	override public function getString():String { return getBoolean().toString(); }

	override public function getBoolean():Boolean
	{
	  var clzName:String = null;
	  var clz:Class = null;
	  var x:Object = null;
	  if (op == ParserConsts.AS) return Boolean(getAny());
	  var o:Object = base.getAny();
	  if (op == ParserConsts.IN)
	  {
		try
		{
		  return o in (type as IExpr).getAny();
		}
		catch (e:Error)
		{
		  return false;
		}
		if (id == IS_OBJECT)
		{
		  clz = null;
		  if (type is String)
		  {
			clzName = type as String;
		  }
		  else
		  {
			try
			{
			  x = (type as IExpr).getAny();
			  if (x is Class) clz = x as Class;
			  else clzName = x.toString();
			}
			catch (e:Error)
			{
			  return false;
			}
		  }
		  if (clz == null)
		  {
			try
			{
			  clz = ApplicationDomain.currentDomain.getDefinition(clzName) as Class;
			}
			catch(e:Error)
			{
			  return false;
			}
		  }
		  if (op == ParserConsts.IS) return o is clz;
		  return o instanceof clz;
		}
		switch (id)
		{
		  case IS_INT:
			return o is int;
		  case IS_UINT:
			return o is uint;
		  case IS_NUMBER:
			return o is Number;
		  case IS_BOOLEAN:
			return o is Boolean;
		  case IS_STRING:
			return o is String;
		  case IS_DATE:
			return o is Date;
		  case IS_ARRAY:
			return o is Array;
		  default:
			return false;
		}
	  }
	  else
	  {
		if (id == IS_OBJECT)
		{
		  clz = null;
		  if (type is String)
		  {
			clzName = type as String;
		  }
		  else
		  {
			x = (type as IExpr).getAny();
			if (x is Class) clz = x as Class;
			else clzName = x.toString();
		  }
		  if (clz == null) clz = ApplicationDomain.currentDomain.getDefinition(clzName) as Class;
		  if (op == ParserConsts.IS) return o is clz;
		  return o instanceof clz;
		}
		switch (id)
		{
		  case IS_INT:
			return o is int;
		  case IS_UINT:
			return o is uint;
		  case IS_NUMBER:
			return o is Number;
		  case IS_BOOLEAN:
			return o is Boolean;
		  case IS_STRING:
			return o is String;
		  case IS_DATE:
			return o is Date;
		  case IS_ARRAY:
			return o is Array;
		  default:
			return false;
		}
	  }
	  return false;
	}
	
	override public function getAny():Object
	{
	  var o:Object = null;
	  var clzName:String = null;
	  var x:Object = null;
	  if (op != ParserConsts.AS) return getBoolean();
	  o = base.getAny();
	  switch (id)
	  {
		case IS_INT:
		  return o as int;
		case IS_UINT:
		  return o as uint;
		case IS_NUMBER:
		  return o as Number;
		case IS_BOOLEAN:
		  return o as Boolean;
		case IS_STRING:
		  return o as String;
		case IS_DATE:
		  return o as Date;
		case IS_ARRAY:
		  return o as Array;
		default:
		  var clz:Class = null;
		  if (type is String)
		  {
			clzName = type as String;
		  }
		  else
		  {
			try
			{
			  x = (type as IExpr).getAny();
			  if (x is Class) clz = x as Class;
			  else clzName = x.toString();
			}
			catch(e:Error)
			{
			  return o;
			}
		  }
		  if (clz == null)
		  {
			try
			{
			  clz = ApplicationDomain.currentDomain.getDefinition(clzName) as Class;
			}
			catch (e:Error)
			{
			  return o;
			}
		  }
		  return o as clz;
	  }
	}
  }
}