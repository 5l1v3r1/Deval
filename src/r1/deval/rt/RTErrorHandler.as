package r1.deval.rt {
	import flash.events.EventDispatcher;
	import flash.display.LoaderInfo;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.UncaughtErrorEvent;
	public class RTErrorHandler extends EventDispatcher {
		private static var _instance:RTErrorHandler=new RTErrorHandler();
		private static var _loaderInfo:LoaderInfo=null;
		private static var _currentError:Error;
		private static var errorTimer:Timer=getTimer();
		public static function setLoader(x:LoaderInfo):void {
			if (_loaderInfo!=null) {
				_loaderInfo.removeEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR,handleError);
				_loaderInfo=null;
			}
			_loaderInfo=x;
			_loaderInfo.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR,handleError);
		}
		private static function getTimer():Timer {
			var x:Timer=new Timer(0,1);
			x.addEventListener(TimerEvent.TIMER,clearError);
			return x;
		}
		private static function clearError(x:TimerEvent):void {
			_currentError=null;
		}
		public static function dispatch(x:Error):void {
			if (_loaderInfo==null) return;
			_currentError=x;
			if (!errorTimer.running) {
				errorTimer.reset();
				errorTimer.start();
			}
		}
		public static function getInstance():RTErrorHandler {
			return _instance;
		}
		private static function handleError(x:UncaughtErrorEvent):void {
			if (_currentError==null) return;
			var v:Error=_currentError;
			_currentError=null;
			if (x.error==v) _instance.dispatchEvent(new RTErrorEvent(v));
		}
	}
}