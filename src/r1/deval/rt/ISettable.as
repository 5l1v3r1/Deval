package r1.deval.rt
{
  public interface ISettable extends IExpr
  {
	function delProp():Boolean;
	function setValue(val:Object):void;
  }
}