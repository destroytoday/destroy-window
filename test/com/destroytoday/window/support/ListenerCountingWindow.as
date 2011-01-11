package com.destroytoday.window.support
{
	import com.destroytoday.window.Window;
	
	import flash.display.NativeWindowInitOptions;
	
	public class ListenerCountingWindow extends Window
	{
		public var numListeners:int;
		
		public function ListenerCountingWindow()
		{
		}
		
		override public function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void
		{
			numListeners++;
		}
		
		override public function removeEventListener(type:String, listener:Function, useCapture:Boolean=false):void
		{
			numListeners--;
		}
	}
}