package com.destroytoday.window
{
	import flash.display.NativeWindow;
	import flash.events.Event;
	
	public class WindowManager implements IWindowManager
	{
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		protected var _windowList:Vector.<NativeWindow> = new Vector.<NativeWindow>();
		
		protected var _activeWindow:NativeWindow;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		public function WindowManager()
		{
		}
		
		//--------------------------------------------------------------------------
		//
		//  Getters / Setters
		//
		//--------------------------------------------------------------------------
		
		public function get numWindows():int
		{
			return _windowList.length;
		}
		
		public function get activeWindow():NativeWindow
		{
			return _activeWindow;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Protected Methods
		//
		//--------------------------------------------------------------------------
		
		protected function addWindowListeners(window:NativeWindow):void
		{
			window.addEventListener(Event.ACTIVATE, windowActivateHandler);
			window.addEventListener(Event.DEACTIVATE, windowDeactivateHandler);
			window.addEventListener(Event.CLOSE, windowCloseHandler);
		}
		
		protected function removeWindowListeners(window:NativeWindow):void
		{
			window.removeEventListener(Event.ACTIVATE, windowActivateHandler);
			window.removeEventListener(Event.DEACTIVATE, windowDeactivateHandler);
			window.removeEventListener(Event.CLOSE, windowCloseHandler);
		}
		
		//--------------------------------------------------------------------------
		//
		//  Public Methods
		//
		//--------------------------------------------------------------------------
		
		public function addWindow(window:NativeWindow):NativeWindow
		{
			if (!hasWindow(window))
			{
				_windowList[_windowList.length] = window;
				
				addWindowListeners(window);
			}
			
			return window;
		}
		
		public function removeWindow(window:NativeWindow):NativeWindow
		{
			if (hasWindow(window))
			{
				_windowList.splice(_windowList.indexOf(window), 1);
				
				removeWindowListeners(window);
			}
			
			return window;
		}
		
		public function removeAllWindows():void
		{
			for each (var window:NativeWindow in _windowList)
				removeWindowListeners(window);
				
			_windowList.length = 0;
		}
		
		public function hasWindow(window:NativeWindow):Boolean
		{
			return _windowList.indexOf(window) != -1;
		}
		
		public function getWindowIndex(window:NativeWindow):int
		{
			return _windowList.indexOf(window);
		}
		
		public function getWindowAtIndex(index:int):NativeWindow
		{
			return _windowList[index];
		}
		
		public function closeAllWindows():void
		{
			for each (var window:NativeWindow in _windowList)
				window.close();
				
			_windowList.length = 0;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Handlers
		//
		//--------------------------------------------------------------------------
		
		protected function windowActivateHandler(event:Event):void
		{
			_activeWindow = event.currentTarget as NativeWindow;
		}
		
		protected function windowDeactivateHandler(event:Event):void
		{
			var window:NativeWindow = event.currentTarget as NativeWindow;
			
			if (window == _activeWindow)
				_activeWindow = null;
		}
		
		protected function windowCloseHandler(event:Event):void
		{
			var window:NativeWindow = event.currentTarget as NativeWindow;

			removeWindow(window);
		}
	}
}