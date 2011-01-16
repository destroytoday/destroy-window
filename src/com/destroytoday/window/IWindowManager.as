package com.destroytoday.window
{
	import flash.display.NativeWindow;
	
	import org.osflash.signals.Signal;

	public interface IWindowManager
	{
		function get windowListChanged():Signal;
		function get activeWindowChanged():Signal;
		
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