package com.destroytoday.window
{
	import flash.display.NativeWindow;

	public interface IWindowManager
	{
		function get numWindows():int;
		function get activeWindow():NativeWindow;
		
		function addWindow(window:NativeWindow):NativeWindow;
		function removeWindow(window:NativeWindow):NativeWindow;
		function removeAllWindows():void;
		
		function hasWindow(window:NativeWindow):Boolean;
		function getWindowIndex(window:NativeWindow):int;
		function getWindowAtIndex(index:int):NativeWindow;
		
		function bringAllWindowsToFront():void;
		function closeAllWindows():void;
	}
}