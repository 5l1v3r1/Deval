package r1.deval.rt
{
  public class ErrorContainer extends Error
  {
	private var _rtError:RTError, _error:Error;

	public function ErrorContainer(x:RTError, y:Error):void
	{
	  super(y.message, y.errorID);
	  this._rtError = x;
	  this._error = y;
	}

	public function get rtError():RTError { return this._rtError; }

	public function get error():Error { return this._error; }

	public function toString():String { return this._rtError.toString(); }
  }
}