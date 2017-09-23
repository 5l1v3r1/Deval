package r1.deval.parser
{
  import r1.deval.rt.Block;
  import r1.deval.rt.IExpr;

  public class Label implements IExpr
  {
	public var name:String, block:Block, postfix:Block, isSwitch:Boolean;

	public function Label(name:String, isSwitch:Boolean=false)
	{
	  super();
	  this.name = name;
	  this.isSwitch = isSwitch;
	}

	public function getString():String { throw new Error("UNIMPLEMENTED"); }

	public function getBoolean():Boolean { throw new Error("UNIMPLEMENTED"); }

	public function getAny():Object { throw new Error("UNIMPLEMENTED"); }

	public function getNumber():Number { throw new Error("UNIMPLEMENTED"); }
  }
}