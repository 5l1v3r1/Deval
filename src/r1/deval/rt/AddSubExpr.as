package r1.deval.rt
{
  internal class AddSubExpr extends MultiOpExprBase
  {
	function AddSubExpr(param1:IExpr, param2:Array, param3:Array) { super(param1, param2, param3); }

	override public function getNumber():Number { return Number(getAny()); }

	override public function getString():String { return getAny().toString(); }

	override public function getBoolean():Boolean { return Boolean(getAny()); }

	override public function getAny():Object
	{
	  var numResult:Number = NaN;
	  var o:Object = null;
	  var cntNumber:int = 0;
	  var cntXML:int = 0;
	  var vals:Array = null;
	  var strResult:String = null;
	  var xmlResult:XMLList = null;
	  var allSame:Boolean = true;
	  for (var i:int = ops.length - 1; i >= 0; i--)
	  {
		if (!ops[i])
		{
		  allSame = false;
		  break;
		}
	  }
	  if (allSame)
	  {
		o = first.getAny();
		cntNumber = o is Number?1:0;
		cntXML = o is XML?1:0;
		vals = [o];
		i = 0;
		while (i < rest.length)
		{
		  o = (rest[i] as IExpr).getAny();
		  if (o is Number) cntNumber++;
		  else if (o is XML || o is XMLList) cntXML++;
		  vals.push(o);
		  i++;
		}
		if (cntXML == rest.length + 1)
		{
		  xmlResult = new XMLList("");
		  for each (o in vals)
		  {
			xmlResult = xmlResult + o;
		  }
		  return xmlResult;
		}
		if (cntNumber == rest.length + 1)
		{
		  numResult = 0;
		  for each (o in vals)
		  {
			numResult = numResult + Number(o);
		  }
		  return numResult;
		}
		strResult = "";
		for each (o in vals)
		{
		  strResult = strResult + o;
		}
		return strResult;
	  }
	  numResult = first.getNumber();
	  for (i = 0; i < rest.length; i++)
	  {
		if (ops[i]) numResult = numResult + rest[i].getNumber();
		else numResult = numResult - rest[i].getNumber();
	  }
	  return numResult;
	}
  }
}