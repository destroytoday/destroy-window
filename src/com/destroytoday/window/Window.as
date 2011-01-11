package com.destroytoday.window
{
	import flash.display.NativeWindow;
	import flash.display.NativeWindowInitOptions;
	import flash.display.Screen;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.geom.Rectangle;
	
	public class Window extends NativeWindow
	{
		//--------------------------------------------------------------------------
		//
		//  Constructor
		//
		//--------------------------------------------------------------------------
		
		public function Window(initOptions:NativeWindowInitOptions = null)
		{
			if (!initOptions)
				initOptions = new NativeWindowInitOptions();
			
			super(initOptions);
			
			setupStage();
		}
		
		//--------------------------------------------------------------------------
		//
		//  Protected Methods
		//
		//--------------------------------------------------------------------------
		
		protected function setupStage():void
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Public Methods
		//
		//--------------------------------------------------------------------------
		
		public function deactivate():void
		{
			if (active)
			{
				visible = false;
				visible = true;
			}
		}
		
		public function center(screenRect:Rectangle = null):void
		{
			if (!screenRect)
				screenRect = Screen.mainScreen.visibleBounds;
			
			x = screenRect.x + (screenRect.width - width) * 0.5;
			y = screenRect.y + (screenRect.height - height) * 0.5;
		}
	}
}