package r1.deval.rt
{
  import r1.deval.parser.TokenStream;

  internal class EmptyStmt implements IStmt
  {
	protected var _lineno:int;

	private var tokenstream:TokenStream;

	public function EmptyStmt(lineno:int, ts:TokenStream)
	{
	  super();
	  _lineno = lineno;
	  tokenstream = ts;
	}

	public function get line():String { return tokenstream.getLineFromNo(_lineno); }

	public function exec():void { }

	public function get lineno():int { return _lineno; }
  }
}