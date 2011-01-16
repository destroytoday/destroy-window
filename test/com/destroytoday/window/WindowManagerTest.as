package com.destroytoday.window
{
	import com.destroytoday.invalidation.InvalidationManager;
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
	import org.osflash.signals.Signal;

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
			Async.proceedOnEvent(this, prepare(NativeWindow, Signal), Event.COMPLETE);
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
			manager = new WindowManager();
			
			assertThat(manager, isA(IWindowManager));
		}
		
		[Test]
		public function window_count_is_initially_zero():void
		{
			manager = new WindowManager();
			
			assertThat(manager.numWindows, equalTo(0));
		}
		
		[Test]
		public function manager_can_add_window():void
		{
			manager = new WindowManager();
			var window:Window = new Window();
			
			manager.addWindow(window);
			
			assertThat(manager.hasWindow(window));
		}
		
		[Test]
		public function manager_ignores_adding_duplicate_windows():void
		{
			manager = new WindowManager();
			var window:Window = new Window();
			
			manager.addWindow(window);
			manager.addWindow(window);
			
			assertThat(manager.numWindows, equalTo(1));
		}
		
		[Test]
		public function adding_window_returns_window():void
		{
			manager = new WindowManager();
			var window:Window = new Window();
			
			assertThat(manager.addWindow(window), strictlyEqualTo(window));
		}
		
		[Test]
		public function adding_windows_increases_window_count():void
		{
			manager = new WindowManager();
			
			manager.addWindow(new Window());
			manager.addWindow(new Window());
			manager.addWindow(new Window());
			
			assertThat(manager.numWindows, equalTo(3));
		}
		
		[Test]
		public function adding_window_dispatches_window_list_changed_signal():void
		{
			manager = new WindowManager();
			manager.windowListChanged = nice(Signal, null, [Vector.<NativeWindow>]);
			
			manager.addWindow(new Window());
			
			assertThat(manager.windowListChanged, received().method('dispatch').once());
		}
		
		[Test]
		public function adding_active_window_populates_active_window_property():void
		{
			manager = new WindowManager();
			var window:Window = new Window();
			
			window.activate();
			manager.addWindow(window);
			
			assertThat(manager.activeWindow, strictlyEqualTo(window));
		}
		
		[Test]
		public function manager_can_remove_window():void
		{
			manager = new WindowManager();
			var window:Window = new Window();
			
			manager.addWindow(window);
			manager.removeWindow(window);
			
			assertThat(manager.hasWindow(window), not(true));
		}
		
		[Test]
		public function manager_ignores_removing_windows_that_do_not_exist():void
		{
			manager = new WindowManager();
			var window:Window = new Window();
			
			manager.addWindow(window);
			manager.removeWindow(window);
			manager.removeWindow(window);
			
			assertThat(manager.hasWindow(window), not(true));
		}
		
		[Test]
		public function removing_window_returns_window():void
		{
			manager = new WindowManager();
			var window:NativeWindow = manager.addWindow(new Window());
			
			assertThat(manager.removeWindow(window), strictlyEqualTo(window));
		}
		
		[Test]
		public function removing_windows_decreases_window_count():void
		{
			manager = new WindowManager();
			var window:NativeWindow = manager.addWindow(new Window());
			
			manager.removeWindow(window);
			
			assertThat(manager.numWindows, equalTo(0));
		}
		
		[Test]
		public function removing_window_dispatches_window_list_changed_signal():void
		{
			manager = new WindowManager();
			var window:NativeWindow = manager.addWindow(new Window());
			manager.windowListChanged = nice(Signal, null, [Vector.<NativeWindow>]);
			
			manager.removeWindow(window);
			
			assertThat(manager.windowListChanged, received().method('dispatch').once());
		}
		
		[Test]
		public function removing_active_window_nullifies_active_window_property():void
		{
			manager = new WindowManager();
			var window:Window = manager.addWindow(new Window()) as Window;
			
			window.activate();
			manager.removeWindow(window);
			
			assertThat(manager.activeWindow, nullValue());
		}
		
		[Test]
		public function manager_can_remove_all_windows():void
		{
			manager = new WindowManager();
			
			manager.addWindow(new Window());
			manager.addWindow(new Window());
			manager.addWindow(new Window());
			
			manager.removeAllWindows();
			
			assertThat(manager.numWindows, equalTo(0));
		}
		
		[Test]
		public function removing_all_windows_dispatches_window_list_changed_signal():void
		{
			manager = new WindowManager();
			
			manager.addWindow(new Window());
			manager.addWindow(new Window());
			manager.addWindow(new Window());
			
			manager.windowListChanged = nice(Signal, null, [Vector.<NativeWindow>]);
			
			manager.removeAllWindows();
			
			assertThat(manager.windowListChanged, received().method('dispatch').once());
		}
		
		[Test]
		public function removing_all_windows_nullifies_active_window_property():void
		{
			manager = new WindowManager();
			var window:Window = new Window();
			
			manager.addWindow(new Window());
			manager.addWindow(new Window());
			manager.addWindow(new Window()).activate();
			manager.removeAllWindows();
			
			assertThat(manager.activeWindow, nullValue());
		}
		
		[Test]
		public function manager_returns_window_at_index():void
		{
			manager = new WindowManager();
			
			manager.addWindow(new Window());
			var window:NativeWindow = manager.addWindow(new Window());
			manager.addWindow(new Window());
			
			assertThat(manager.getWindowAtIndex(1), strictlyEqualTo(window));
		}
		
		[Test]
		public function manager_returns_window_index():void
		{
			manager = new WindowManager();
			
			manager.addWindow(new Window());
			var window:NativeWindow = manager.addWindow(new Window());
			manager.addWindow(new Window());
			
			assertThat(manager.getWindowIndex(window), equalTo(1));
		}
		
		[Test]
		public function manager_can_close_all_windows():void
		{
			manager = new WindowManager();
			var window0:NativeWindow = manager.addWindow(nice(NativeWindow, null, [new NativeWindowInitOptions()]));
			var window1:NativeWindow = manager.addWindow(nice(NativeWindow, null, [new NativeWindowInitOptions()]));
			var window2:NativeWindow = manager.addWindow(nice(NativeWindow, null, [new NativeWindowInitOptions()]));

			manager.closeAllWindows();
			
			assertThat(window0, received().method('close').once())
			assertThat(window1, received().method('close').once())
			assertThat(window2, received().method('close').once())
		}
		
		[Test]
		public function closing_all_windows_dispatches_window_list_changed_signal():void
		{
			manager = new WindowManager();
			
			manager.addWindow(new Window());
			manager.addWindow(new Window());
			manager.addWindow(new Window());
			
			manager.windowListChanged = nice(Signal, null, [Vector.<NativeWindow>]);
			
			manager.closeAllWindows();
			
			assertThat(manager.windowListChanged, received().method('dispatch').once());
		}
		
		[Test(async)]
		public function closing_window_removes_it_from_manager():void
		{
			manager = new WindowManager();
			var window:NativeWindow = manager.addWindow(new Window());
			
			window.close();

			Async.handleEvent(this, window, Event.CLOSE, function(event:Event, object:Object):void
			{
				assertThat(manager.hasWindow(window), not(true));
			}, 1000);
		}
		
		[Test]
		public function active_window_is_initially_null():void
		{
			manager = new WindowManager();
			
			assertThat(manager.activeWindow, nullValue());
		}
		
		[Test]
		public function activating_window_populates_active_window():void
		{
			manager = new WindowManager();
			var window:NativeWindow = manager.addWindow(new Window());
			
			window.activate();
			
			assertThat(manager.activeWindow, strictlyEqualTo(window));
		}
		
		[Test]
		public function activating_window_dispatches_active_window_changed_signal():void
		{
			manager = new WindowManager();
			var window:NativeWindow = manager.addWindow(new Window());
			manager.activeWindowChanged = nice(Signal, null, [NativeWindow]);
			
			window.activate();
			
			assertThat(manager.activeWindowChanged, received().method('dispatch').once());
			assertThat(manager.activeWindowChanged, received().method('dispatch').arg(window));
		}
		
		[Test]
		public function deactivating_active_window_nullifies_active_window():void
		{
			manager = new WindowManager();
			var window:Window = manager.addWindow(new Window()) as Window;
			
			window.activate();
			window.deactivate();
			
			assertThat(manager.activeWindow, nullValue());
		}
		
		[Test]
		public function deactivating_window_dispatches_active_window_changed_signal():void
		{
			manager = new WindowManager();
			var window:Window = manager.addWindow(new Window()) as Window;
			window.activate();
			
			manager.activeWindowChanged = nice(Signal, null, [NativeWindow]);
			
			window.deactivate();
			
			assertThat(manager.activeWindowChanged, received().method('dispatch').once());
			assertThat(manager.activeWindowChanged, received().method('dispatch').arg(null));
		}
		
		[Test]
		public function activating_window_while_active_window_exists_populates_active_window():void
		{
			manager = new WindowManager();
			var window0:NativeWindow = manager.addWindow(new Window());
			var window1:NativeWindow = manager.addWindow(new Window());
			
			window0.activate();
			window1.activate();
			
			assertThat(manager.activeWindow, strictlyEqualTo(window1));
		}
		
		[Test]
		public function activating_window_while_active_window_exists_dispatches_active_window_changed_signal_twice():void
		{
			manager = new WindowManager();
			var window0:Window = manager.addWindow(new Window()) as Window;
			var window1:Window = manager.addWindow(new Window()) as Window;
			window0.activate();
			
			manager.activeWindowChanged = nice(Signal, null, [NativeWindow]);
			
			window1.activate();
			
			assertThat(manager.activeWindowChanged, received().method('dispatch').twice());
			assertThat(manager.activeWindowChanged, received().method('dispatch').arg(null));
			assertThat(manager.activeWindowChanged, received().method('dispatch').arg(window1));
		}
		
		[Test(async)]
		public function activating_window_using_invalidation_while_active_window_exists_dispatches_active_window_changed_signal_once():void
		{
			manager = new WindowManager(new InvalidationManager());
			var window0:Window = manager.addWindow(new Window()) as Window;
			var window1:Window = manager.addWindow(new Window()) as Window;
			window0.activate();
			
			manager.activeWindowChanged = nice(Signal, null, [NativeWindow]);
			
			window1.activate();
			
			Async.delayCall(this, function():void
			{
				assertThat(manager.activeWindowChanged, received().method('dispatch').once());
				assertThat(manager.activeWindowChanged, received().method('dispatch').arg(window1));
			}, 500);
		}
		
		[Test]
		public function closing_active_window_unpopulates_active_window():void
		{
			manager = new WindowManager();
			var window:NativeWindow = manager.addWindow(new Window());
			
			window.activate();
			window.close();
			
			assertThat(manager.activeWindow, nullValue());
		}
		
		[Test]
		public function removing_window_removes_windows_listeners():void
		{
			manager = new WindowManager();
			var window:ListenerCountingWindow = manager.addWindow(new ListenerCountingWindow()) as ListenerCountingWindow;
			
			manager.removeWindow(window);
			
			assertThat(window.numListeners, equalTo(0));
		}
		
		[Test]
		public function removing_all_windows_removes_windows_listeners():void
		{
			manager = new WindowManager();
			var window:ListenerCountingWindow = manager.addWindow(new ListenerCountingWindow()) as ListenerCountingWindow;
			
			manager.removeAllWindows();
			
			assertThat(window.numListeners, equalTo(0));
		}
		
		[Test]
		public function bringing_all_windows_to_front_orders_each_window_to_front():void
		{
			manager = new WindowManager();
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