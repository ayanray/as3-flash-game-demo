/* 	
*	Copyright (c) 2007-2010 Ayan Ray | http://www.ayanray.com 
*
*	This script is free software: you can redistribute it and/or modify
*   it under the terms of the GNU General Public License as published by
*   the Free Software Foundation, either version 3 of the License, or
*   (at your option) any later version.
*
*   This program is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU General Public License for more details.
*
*   You should have received a copy of the GNU General Public License
*   along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
package com.ayanray.display 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageQuality;
	import flash.display.StageScaleMode;

	import flash.events.Event;
	import flash.events.ProgressEvent;
	
	/**
	 * The StageHandler class allows you to use your DocumentClass to extend anything you want<br />
	 * and still be able to reuse stage code very easily. It also has a very important feature<br />
	 * in that when you import your compiled SWF into another SWF, you will not get any stage<br />
	 * throw errors that are apparent if you try to access the stage from the loaded SWF.<br />
	 * <br /><br />
	 * Example Usage:<br />
	 * new StageHandler ( this , {onStageResize: onStageResize, onComplete: init});
	 * 
	 * Note that if you try to load an SWF that uses StageHandler, the loader must also use StageHandler.
	 */
	public class StageHandler 
	{		
		// Each Document Class requires their own
		private var settings				:Object;
		private var holder					:DisplayObject;
		
		// Stage and Root, once initialized once, never need it again.
		private static var __stage			:Stage;
		private static var __root			:DisplayObject;
		
		/**
		 * Initiates the StageHandler. Do this once for each document class. Unfortunately, it does not work if you place it on frame 1 of an AS3 file. 
		 * 
		 * @param	holder		Pass a reference of "this" to the StageHandler in your DocumentClass
		 * @param	settings	User defined call-back functions. Available callbacks: onComplete, onStart, handleProgress, onStageResize, onMouseLeave
		 * @param	defaults	Whether or not to use the default settings that I use in 90% of my projects (defaults to true)
		 */
		public function StageHandler( 	holder:DisplayObject, settings:Object, defaults:Boolean = true )
		{
			if(  __stage == null ) __stage = holder.stage;
			if(  __root == null ) __root = holder; 
			
			this.settings = settings;
			
			// Set Default Stage Properties (most common settings)
			if(defaults) 
			{
				// Set Scaling/Alignment
				__stage.scaleMode = StageScaleMode.NO_SCALE;
				__stage.align = StageAlign.TOP_LEFT;
				__stage.displayState = StageDisplayState.NORMAL;
				__stage.quality = StageQuality.BEST;
			}
			
			if (this.settings.debugWindow) this.settings.debugWindow.htmlText += "Starting Stage Handler/.." + "<br />";
			if (this.settings.debugWindow) this.settings.debugWindow.htmlText += "Holder:"+ this.holder.loaderInfo + "<br />";
			// Save Holder Reference to remove Listeners at end
			this.holder = holder;
				
			// Handle Initial Loading ---- sometimes loaderInfo is null... why?? - occurs only when loading it through js... framework
			this.holder.loaderInfo.addEventListener(Event.INIT, handleRootLoaderInit);
			this.holder.loaderInfo.addEventListener(ProgressEvent.PROGRESS, handleRootLoaderProgress);
			this.holder.loaderInfo.addEventListener(Event.COMPLETE, handleRootLoaderComplete);
			this.holder.addEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStage );
					
			// Add Stage Resize Listener and Mouse Leave Listener
			__stage.addEventListener(Event.RESIZE, onStageResize);
			__stage.addEventListener(Event.MOUSE_LEAVE, onMouseLeave, false, 0, true);
		}
		public static function get stage() :Stage
		{
			return __stage;
		}
		public static function get root() :DisplayObject
		{
			return __root;
		}
		private function handleRootLoaderInit ( e:Event )	:void
		{
			if(this.settings.onStart != null) this.settings.onStart();
		}
		private function handleRootLoaderProgress ( e:ProgressEvent )	:void
		{
			if(this.settings.handleProgress != null) this.settings.handleProgress( { event: e } );
		}
		private function handleRootLoaderComplete ( e:Event )	:void
	 	{
			if (this.settings.debugWindow) this.settings.debugWindow.htmlText += "Stage Loaded Complete" + "<br />";
			
			var loaded:int = e.target.bytesLoaded;
			var total:int = e.target.bytesTotal;
			var percent:int = loaded/total*100;
			if(percent>=100 && this.settings.onComplete != null) this.settings.onComplete();
			
			// Remove Listeners
			this.holder.loaderInfo.removeEventListener(Event.INIT, handleRootLoaderInit);
	        this.holder.loaderInfo.removeEventListener(ProgressEvent.PROGRESS, handleRootLoaderProgress);
	        this.holder.loaderInfo.removeEventListener(Event.COMPLETE, handleRootLoaderComplete);
		}
		private function onRemovedFromStage (e:Event) :void
		{
			if (this.settings.onRemovedFromStage != null) this.settings.onRemovedFromStage();
			
			__stage.removeEventListener(Event.RESIZE, onStageResize);
			__stage.removeEventListener(Event.MOUSE_LEAVE, onMouseLeave);
			this.holder.removeEventListener( Event.REMOVED_FROM_STAGE, onRemovedFromStage );
			
			this.settings = null;
			this.holder = null;
		}
		private function onStageResize( e:Event ) :void
		{
			if(this.settings.onStageResize != null) this.settings.onStageResize();
		}
		private function onMouseLeave( e:Event ) :void
		{
			if(this.settings.onMouseLeave != null) this.settings.onMouseLeave();
		}
		/*
		function fullScreenRedraw(event:FullScreenEvent) {
			stage.displayState = StageDisplayState.FULL_SCREEN;
		}*/
	}
}