package com.destroytoday.window
{
	import com.destroytoday.window.support.ListenerCountingWindow;
	
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.events.Event;
	
	import mockolate.nice;
	import mockolate.prepare;
	import mockolate.received;
	
	import org.flexunit.async.Async;
	import org.hamcrest.assertThat;
	import org.hamcrest.core.isA;
	import org.hamcrest.core.not;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.nullValue;
	import org.hamcrest.object.strictlyEqualTo;

	public class WindowManagerTest
	{		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		protected static var runnerWindow:NativeWindow;
		
		protected var manager:WindowManager;
		
		//--------------------------------------------------------------------------
		//
		//  Prep
		//
		//--------------------------------------------------------------------------
		
		[BeforeClass]
		public static function setUpBeforeClass():void
		{
			runnerWindow = NativeApplication.nativeApplication.openedWindows[0];
		}
		
		[AfterClass]
		public static function tearDownAfterClass():void
		{
			runnerWindow = null;
		}
		
		[Before(async, timeout=5000)]
		public function setUp():void
		{
			manager = new WindowManager();
			
			Async.proceedOnEvent(this, prepare(NativeWindow), Event.COMPLETE);
		}
		
		[After]
		public function tearDown():void
		{
			closeAllWindows();
			
			manager = null;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Helper Methods
		//
		//--------------------------------------------------------------------------
		
		protected function closeAllWindows():void
		{
			for each (var window:NativeWindow in NativeApplication.nativeApplication.openedWindows)
				if (window != runnerWindow) window.close();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Tests
		//
		//--------------------------------------------------------------------------
		
		[Test]
		public function manager_implements_window_manager():void
		{
			assertThat(manager, isA(IWindowManager));
		}
		
		[Test]
		public function window_count_is_initially_zero():void
		{
			assertThat(manager.numWindows, equalTo(0));
		}
		
		[Test]
		public function manager_can_add_window():void
		{
			var window:Window = new Window();
			
			manager.addWindow(window);
			
			assertThat(manager.hasWindow(window));
		}
		
		[Test]
		public function manager_ignores_adding_duplicate_windows():void
		{
			var window:Window = new Window();
			
			manager.addWindow(window);
			manager.addWindow(window);
			
			assertThat(manager.numWindows, equalTo(1));
		}
		
		[Test]
		public function adding_window_returns_window():void
		{
			var window:Window = new Window();
			
			assertThat(manager.addWindow(window), strictlyEqualTo(window));
		}
		
		[Test]
		public function adding_windows_increases_window_count():void
		{
			manager.addWindow(new Window());
			manager.addWindow(new Window());
			manager.addWindow(new Window());
			
			assertThat(manager.numWindows, equalTo(3));
		}
		
		[Test]
		public function manager_can_remove_window():void
		{
			var window:Window = new Window();
			
			manager.addWindow(window);
			manager.removeWindow(window);
			
			assertThat(manager.hasWindow(window), not(true));
		}
		
		[Test]
		public function manager_ignores_removing_windows_that_do_not_exist():void
		{
			var window:Window = new Window();
			
			manager.addWindow(window);
			manager.removeWindow(window);
			manager.removeWindow(window);
			
			assertThat(manager.hasWindow(window), not(true));
		}
		
		[Test]
		public function removing_window_returns_window():void
		{
			var window:NativeWindow = manager.addWindow(new Window());
			
			assertThat(manager.removeWindow(window), strictlyEqualTo(window));
		}
		
		[Test]
		public function removing_windows_decreases_window_count():void
		{
			var window:NativeWindow = manager.addWindow(new Window());
			
			manager.removeWindow(window);
			
			assertThat(manager.numWindows, equalTo(0));
		}
		
		[Test]
		public function manager_can_remove_all_windows():void
		{
			manager.addWindow(new Window());
			manager.addWindow(new Window());
			manager.addWindow(new Window());
			
			manager.removeAllWindows();
			
			assertThat(manager.numWindows, equalTo(0));
		}
		
		[Test]
		public function manager_returns_window_at_index():void
		{
			manager.addWindow(new Window());
			var window:NativeWindow = manager.addWindow(new Window());
			manager.addWindow(new Window());
			
			assertThat(manager.getWindowAtIndex(1), strictlyEqualTo(window));
		}
		
		[Test]
		public function manager_returns_window_index():void
		{
			manager.addWindow(new Window());
			var window:NativeWindow = manager.addWindow(new Window());
			manager.addWindow(new Window());
			
			assertThat(manager.getWindowIndex(window), equalTo(1));
		}
		
		[Test]
		public function manager_can_close_all_windows():void
		{
			var window0:NativeWindow = manager.addWindow(nice(NativeWindow, null, [new NativeWindowInitOptions()]));
			var window1:NativeWindow = manager.addWindow(nice(NativeWindow, null, [new NativeWindowInitOptions()]));
			var window2:NativeWindow = manager.addWindow(nice(NativeWindow, null, [new NativeWindowInitOptions()]));

			manager.closeAllWindows();
			
			assertThat(window0, received().method('close').once())
			assertThat(window1, received().method('close').once())
			assertThat(window2, received().method('close').once())
		}
		
		[Test(async)]
		public function closing_window_removes_it_from_manager():void
		{
			var window:NativeWindow = manager.addWindow(new Window());
			
			window.close();

			Async.handleEvent(this, window, Event.CLOSE, function(event:Event, object:Object):void
			{
				assertThat(manager.hasWindow(window), not(true));
			});
		}
		
		[Test]
		public function active_window_is_initially_null():void
		{
			assertThat(manager.activeWindow, nullValue());
		}
		
		[Test]
		public function activating_window_populates_active_window():void
		{
			var window:NativeWindow = manager.addWindow(new Window());
			
			window.activate();
			
			assertThat(manager.activeWindow, strictlyEqualTo(window));
		}
		
		[Test]
		public function deactivating_active_window_unpopulates_active_window():void
		{
			var window:Window = manager.addWindow(new Window()) as Window;
			
			window.activate();
			window.deactivate();
			
			assertThat(manager.activeWindow, nullValue());
		}
		
		[Test]
		public function activating_window_with_populated_active_window_populates_active_window():void
		{
			var window0:NativeWindow = manager.addWindow(new Window());
			var window1:NativeWindow = manager.addWindow(new Window());
			
			window0.activate();
			window1.activate();
			
			assertThat(manager.activeWindow, strictlyEqualTo(window1));
		}
		
		[Test]
		public function closing_active_window_unpopulates_active_window():void
		{
			var window:NativeWindow = manager.addWindow(new Window());
			
			window.activate();
			window.close();
			
			assertThat(manager.activeWindow, nullValue());
		}
		
		[Test]
		public function removing_window_removes_windows_listeners():void
		{
			var window:ListenerCountingWindow = manager.addWindow(new ListenerCountingWindow()) as ListenerCountingWindow;
			
			manager.removeWindow(window);
			
			assertThat(window.numListeners, equalTo(0));
		}
		
		[Test]
		public function removing_all_windows_removes_windows_listeners():void
		{
			var window:ListenerCountingWindow = manager.addWindow(new ListenerCountingWindow()) as ListenerCountingWindow;
			
			manager.removeAllWindows();
			
			assertThat(window.numListeners, equalTo(0));
		}
		
		[Test]
		public function bringing_all_windows_to_front_orders_each_window_to_front():void
		{
			var window0:NativeWindow = manager.addWindow(nice(NativeWindow, null, [new NativeWindowInitOptions()]));
			var window1:NativeWindow = manager.addWindow(nice(NativeWindow, null, [new NativeWindowInitOptions()]));
			var window2:NativeWindow = manager.addWindow(nice(NativeWindow, null, [new NativeWindowInitOptions()]));

			manager.bringAllWindowsToFront();
			
			assertThat(window0, received().method('orderToFront').once())
			assertThat(window1, received().method('orderToFront').once())
			assertThat(window2, received().method('orderToFront').once())
		}
	}
}