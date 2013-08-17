package 
{
	import com.ayanray.display.StageHandler;
	import com.ayanray.game.entities.World;
	import com.ayanray.utils.MonitorFrameRate;
	import com.junkbyte.console.Cc;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	
	public class Demo extends Sprite
	{
		public var currentWorld:World;

// --------------------------------------------------------------------------------
		public function Demo ()
		{
			new StageHandler( this, { onComplete: init, onStageResize: _onStageResize } );
		}
		public function init():void
		{
			// Order of op (initial thoughts):
			// - Show Loading Screen (prefably all necessary assets embeded -- small footprint)
			// - Load UI Components for landing
			// - Get all necessary data for landing (active friends list, high scores, whatever, etc.)
			
			// As a proto, setup demo and start the game (rather than loading etc).
			this._setupDemo();
			this._startGame();
			
			Cc.startOnStage(this);
		}
		/**
		 * Anything that is FPO should go here that is necessary or useful for creating demo but is intended
		 * to be removed completely (so we can just delete this function all together and fix any precompiler ref errors).
		 */		
		private function _setupDemo():void
		{
			// Setup FPS Monitor
			MonitorFrameRate.init(this.stage);
			
			////////////////////////////////////////////////////////////////////////////////
			// Helper Texts
			
			// Helper Text: Cash Text
			var textField:TextField = new TextField();
			textField.name = "cashText";
			textField.defaultTextFormat = new TextFormat("Arial", 14, 0, true, false, false, null, null, "right");
			textField.width = 200;
			textField.text = "Cash: $0";
			//sprite.addChild( textField );
			textField.x = this.stage.stageWidth - textField.width;
			this.addChild(textField);
			
			// Helper Text: FPS Text
			textField = new TextField();
			textField.name = "fps";
			textField.width = 150;
			textField.height = 20;
			textField.defaultTextFormat = new TextFormat("Arial", 14, 0, true);
			textField.text = "FPS: " + MonitorFrameRate.fps;
			textField.y = this.stage.stageHeight - textField.height;
			this.addChild(textField);
			
			// Helper Text: Rate Per Minute
			var sprite:Sprite = new Sprite();
			textField = new TextField();
			textField.text = "Rate (per min):";
			textField.width = 150;
			textField.height = 20;
			sprite.addChild(textField);
			
			textField = new TextField();
			textField.type = TextFieldType.INPUT;
			textField.x = 75;
			textField.text = "8";
			textField.width = 150;
			textField.height = 20;
			// I'd move this to a class method if it turns out not to be FPO
			textField.addEventListener(Event.CHANGE, function(e:Event):void{ 
				if(currentWorld != null)
				{
					currentWorld.createPatientTimer.stop();
					currentWorld.createPatientTimer.delay = 60*1000 / int(e.currentTarget.text);
					currentWorld.createPatientTimer.start();
				}
			});
			sprite.addChild(textField);
			this.addChild(sprite);
		}
		
		private function _startGame():void
		{
			// Create new game manager (starting game)
			if(currentWorld != null) currentWorld.unload();
			currentWorld = new World(this.stage);
			
			// Loading screen
			// Load assets
			
			// Load Complete: Show world
			this.addChild(currentWorld);
			
			// Enterframe (1 global one)
			this.addEventListener(Event.ENTER_FRAME, _onStageEnterFrame);
		}
		
// --------------------------------------------------------------------------------
		private function _onStageEnterFrame(event:Event):void
		{
			// TODO: We need a game loop here (that checks for dropped frames according to time). For now, update and render.
			// Update
			currentWorld.update();
			
			// Render
			currentWorld.render();
			//Cc.log("CASH", currentWorld.cash);
			// Update FPS Text
			TextField(this.getChildByName("fps")).text = "fps: " + MonitorFrameRate.fps + " | lag: " + MonitorFrameRate.lag;
			TextField(this.getChildByName("cashText")).text = "Cash: $" + currentWorld.cash;
		}

// --------------------------------------------------------------------------------
		private function _onStageResize():void
		{
			this.getChildByName("cashText").x = this.stage.stageWidth - this.getChildByName("cashText").width;
			this.getChildByName("fps").y = this.stage.stageHeight - this.getChildByName("fps").height;
		}
	}
}