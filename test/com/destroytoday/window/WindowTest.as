package com.destroytoday.window
{
	import flash.display.NativeWindow;
	import flash.display.Screen;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.geom.Rectangle;
	
	import org.hamcrest.assertThat;
	import org.hamcrest.core.isA;
	import org.hamcrest.core.not;
	import org.hamcrest.object.equalTo;

	public class WindowTest
	{		
		//--------------------------------------------------------------------------
		//
		//  Properties
		//
		//--------------------------------------------------------------------------
		
		protected var window:Window;
		
		//--------------------------------------------------------------------------
		//
		//  Prep
		//
		//--------------------------------------------------------------------------
		
		[Before(async, timeout=5000)]
		public function setUp():void
		{
		}
		
		[After]
		public function tearDown():void
		{
			window.close();
			
			window = null;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Tests
		//
		//--------------------------------------------------------------------------
		
		[Test]
		public function window_is_native_window():void
		{
			window = new Window();
			
			assertThat(window, isA(NativeWindow));
		}
		
		[Test]
		public function window_stage_does_not_scale_by_default():void
		{
			window = new Window();
			
			assertThat(window.stage.scaleMode, equalTo(StageScaleMode.NO_SCALE));
		}
		
		[Test]
		public function window_stage_aligns_top_left_by_default():void
		{
			window = new Window();
			
			assertThat(window.stage.align, equalTo(StageAlign.TOP_LEFT));
		}
		
		[Test]
		public function default_window_size_is_400x222():void
		{
			window = new Window();
			
			assertThat(window.width, equalTo(400.0));
			assertThat(window.height, equalTo(222.0));
		}
		
		[Test]
		public function window_centers_on_rectangle():void
		{
			window = new Window();
			var screenRect:Rectangle = new Rectangle(0.0, 0.0, 1024.0, 768.0);
			
			window.center(screenRect);
			
			assertThat(window.x, equalTo(312.0));
			assertThat(window.y, equalTo(273.0));
		}
		
		[Test]
		public function window_centers_on_main_screen_when_no_rectangle_is_provided():void
		{
			window = new Window();
			var screenRect:Rectangle = Screen.mainScreen.visibleBounds;
			
			window.center();
			
			var targetX:int = screenRect.x + (screenRect.width - window.width) * 0.5;
			var targetY:int = screenRect.y + (screenRect.height - window.height) * 0.5;
			
			assertThat(window.x, equalTo(targetX));
			assertThat(window.y, equalTo(targetY));
		}
		
		[Test]
		public function window_centers_on_rectangle_with_non_zero_position():void
		{
			window = new Window();
			var screenRect:Rectangle = new Rectangle(-1920.0, -1080.0, 1024.0, 768.0);
			
			window.center(screenRect);
			
			assertThat(window.x, equalTo(-1608.0));
			assertThat(window.y, equalTo(-807.0));
		}
		
		[Test]
		public function window_can_deactivate():void
		{
			window = new Window();
			
			window.activate();
			window.deactivate();
			
			assertThat(window.active, not(true));
		}
	}
}