package com.destroytoday.window
{
	import com.destroytoday.invalidation.IInvalidatable;
	import com.destroytoday.invalidation.IInvalidationManager;
	
	import flash.display.NativeWindow;
	import flash.events.Event;
	
	import org.osflash.signals.Signal;
	
	public class WindowManager implements IWindowManager, IInvalidatable
	{
		//--------------------------------------------------------------------------
		//
		//  Signals
		//
		//--------------------------------------------------------------------------
		
		protected var _windowListChanged:Signal;
		
		public function get windowListChanged():Signal
		{
			return _windowListChanged ||= new Signal(Vector.<NativeWindow>);
		}
		
		public function set windowListChanged(value:Signal):void
		{
			_windowListChanged = value;
		}
		
		protected var _activeWindowChanged:Signal;
		
		public function get activeWindowChanged():Signal
		{
			return _activeWindowChanged ||= new Signal(NativeWindow);
		}
		
		public function set activeWindowChanged(value:Signal):void
		{
			_activeWindowChanged = value;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		protected var _invalidationManager:IInvalidationManager;
		
		protected var _windowList:Vector.<NativeWindow> = new Vector.<NativeWindow>();
		
		protected var _activeWindow:NativeWindow;
		
		//--------------------------------------------------------------------------
		//
		//  Flags
		//
		//--------------------------------------------------------------------------
		
		protected var isWindowListDirty:Boolean;
		
		protected var isActiveWindowDirty:Boolean;
		
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		public function WindowManager(invalidationManager:IInvalidationManager = null)
		{
			this.invalidationManager = invalidationManager;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Getters / Setters
		//
		//--------------------------------------------------------------------------
		
		public function get invalidationManager():IInvalidationManager
		{
			return _invalidationManager;
		}
		
		public function set invalidationManager(value:IInvalidationManager):void
		{
			_invalidationManager = value;
		}
		
		public function get numWindows():int
		{
			return _windowList.length;
		}
		
		public function get activeWindow():NativeWindow
		{
			return _activeWindow;
		}
		
		protected function setActiveWindow(value:NativeWindow):void
		{
			if (value == _activeWindow) return;
			
			_activeWindow = value;
			
			isActiveWindowDirty = true;
			invalidate();
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
				
				if (window.active)
					setActiveWindow(window);
				
				addWindowListeners(window);
				invalidateWindowList();
			}
			
			return window;
		}
		
		public function removeWindow(window:NativeWindow):NativeWindow
		{
			if (hasWindow(window))
			{
				if (window == activeWindow)
					setActiveWindow(null);
				
				_windowList.splice(_windowList.indexOf(window), 1);
				
				removeWindowListeners(window);
				invalidateWindowList();
			}
			
			return window;
		}
		
		public function removeAllWindows():void
		{
			if (_windowList.length == 0)
				return;
			
			setActiveWindow(null);
			
			for each (var window:NativeWindow in _windowList)
				removeWindowListeners(window);
			
			_windowList.length = 0;
			invalidateWindowList();
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
			if (_windowList.length == 0)
				return;
			
			for each (var window:NativeWindow in _windowList)
				window.close();
				
			_windowList.length = 0;
			invalidateWindowList();
		}
		
		public function bringAllWindowsToFront():void
		{
			for each (var window:NativeWindow in _windowList)
				window.orderToFront();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Invalidation
		//
		//--------------------------------------------------------------------------
		
		protected function invalidateWindowList():void
		{
			isWindowListDirty = true;
			
			invalidate();
		}
		
		public function invalidate():void
		{
			if (invalidationManager)
			{
				invalidationManager.invalidateObject(this);
			}
			else
			{
				validate();
			}
		}
		
		public function validate():void
		{
			if (isWindowListDirty)
			{
				isWindowListDirty = false;
				
				windowListChanged.dispatch(_windowList);
			}
			
			if (isActiveWindowDirty)
			{
				isActiveWindowDirty = false;
				
				if (_activeWindow && !_activeWindow.active)
					_activeWindow.activate();
				
				activeWindowChanged.dispatch(_activeWindow);
			}
		}
		
		//--------------------------------------------------------------------------
		//
		//  Handlers
		//
		//--------------------------------------------------------------------------
		
		protected function windowActivateHandler(event:Event):void
		{
			setActiveWindow(event.currentTarget as NativeWindow);
		}
		
		protected function windowDeactivateHandler(event:Event):void
		{
			var window:NativeWindow = event.currentTarget as NativeWindow;
			
			if (window == activeWindow)
				setActiveWindow(null);
		}
		
		protected function windowCloseHandler(event:Event):void
		{
			var window:NativeWindow = event.currentTarget as NativeWindow;

			removeWindow(window);
		}
	}
}