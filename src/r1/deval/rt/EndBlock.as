package r1.deval.rt
{
  public class EndBlock extends Block
  {
	public static const EXIT:EndBlock = new EndBlock(":EXIT:");

	public function EndBlock(name:String)
	{
	  super(name, false);
	}
  }
}