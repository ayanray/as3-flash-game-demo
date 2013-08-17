package com.ayanray.game.entities.rooms
{
	import com.ayanray.game.entities.World;
	import com.ayanray.game.entities.characters.Patient;
	import com.ayanray.game.managers.BuildingManager;
	import com.junkbyte.console.Cc;
	import com.junkbyte.console.ConsoleChannel;
	
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import flash.utils.setTimeout;

	public class ReceptionRoom extends Room
	{
		/**
		 * Time it takes to see the receptionist and then move to waiting 
		 */		
		private var _timeAtReception:int = 30 * 2; // 2 seconds;
		/**
		 * Used as a countdown for talking with reception (it's set to time at reception then decremented) 
		 */		
		private var _countdown:int = 0;
		/**
		 * Timer used to keep track of how long patient is at desk.
		 * TODO: These timers need to be moved into an update loop. 
		 */		
		private var _receptionTimer:Timer;
		/**
		 * Current Patient at the reception desk. 
		 * TODO: Need to make this unlimited so this room can support multiple reception desk. 
		 */		
		private var _patientAtReception:Patient = null;
		/**
		 * Current patients in line to see receptionist.
		 * TODO: Need to be able to support multiple reception lines. 
		 */		
		private var _patientsInLine:Array = new Array();
		/**
		 * Current spots where patients can stand in line
		 * TODO: Should be able to support multiple lines. 
		 */		
		private var _receptionLineSpots:Array = new Array();
		/**
		 * Debug Console 
		 */		
		private var _channel:ConsoleChannel = new ConsoleChannel('Reception Room');

// --------------------------------------------------------------------------------		
		public function ReceptionRoom(owner:BuildingManager, area:Array, receptionLineSpots:Array)
		{
			super(owner, area);
			
			this._receptionLineSpots = receptionLineSpots;
				
			// Reception Timer (amount of time to talk with and finish with receptionist)
			this._receptionTimer = new Timer(this._timeAtReception, 1);
			this._receptionTimer.addEventListener( TimerEvent.TIMER_COMPLETE, this._onFinishedAtReception );
		}

// --------------------------------------------------------------------------------
		/**
		 * Function that takes a patient and moves them to the reception line.
		 *  
		 * @param patient Patient VO
		 * 
		 */		
		override public function acceptPatient(patient:Patient):Boolean
		{
			// Assures one direction flow
			if(patient.status != Patient.RECEPTION) return false;
			
			var id:int = this._patientsInLine.length;
			if(id >= this._receptionLineSpots.length) 
			{
				// TODO: Currently there is no logic in place to handle what to do if the line is full
				// TODO: Need to handle line-full logic (wait by the wall, leave, etc.)
				// Currently, they will just stand forever on the spawn location
				_channel.log("Reception Room:", "Reception line is full");
				return false;
			}
			
			// Add Patient to Reception Line
			this._patientsInLine[id] = patient;
			
			// Get location of spot
			var endX:int = this._receptionLineSpots[id].x;
			var endY:int = this._receptionLineSpots[id].y;
			
			// Move patient to the reserved spot in line with callback to check reception line in 1 second
			patient.moveToSpot(endX, endY, null);
			
			_channel.log("Reception Room:", "Patient", patient.uid, "has been accepted.");
			return true;
		}
		
// --------------------------------------------------------------------------------
		/**
		 * Main update loop for the reception room. Should be called every frame and caught up if
		 * frames are skipped.
		 */		
		public function update():void
		{
			if(this.patientAtReception)
			{
				_countdown--;
				if(_countdown == 0)
				{
					if(!_onFinishedAtReception())
					{
						_countdown = 1;
					}
				}
			}
			else if(this._patientsInLine.length > 0)
			{
				var patient:Patient = this._patientsInLine[0] as Patient;
				var gridPoint:Point = patient.gridPoint;
				//_channel.log(gridPoint.toString(), _receptionLineSpots[0].x,_receptionLineSpots[0].y );
				if(gridPoint.x != _receptionLineSpots[0].x || gridPoint.y != _receptionLineSpots[0].y) return;
				
				// Move to be in front of reception
				patient.moveToSpot(this._owner.atReceptionLocation.x, this._owner.atReceptionLocation.y, function():void{} );
				this._patientAtReception = patient;
				_countdown = _timeAtReception;
				
				// Shift Previous
				this._patientsInLine.shift();
				for(var i:int = 0; i < this._patientsInLine.length; i++)
				{
					patient = this._patientsInLine[i] as Patient;
					setTimeout(patient.moveToSpot, 2000, this._receptionLineSpots[i].x, this._receptionLineSpots[i].y, null );
				}
			}
		}
		
// --------------------------------------------------------------------------------		
		/**
		 * Timed event when patient is finished at reception. 
		 * TODO: This should NOT be a timer. Need's to be part of the update loop. 
		 * @param event
		 * 
		 */		
		private function _onFinishedAtReception():Boolean
		{
			// Move patient to line
			var accepted:Boolean = this._owner.owner.patientManager.movePatientToRoom( patientAtReception, this._owner.getWaitingRoom(0));
			if(accepted)
			{
				this._patientAtReception = null;
			}
			return accepted;
		}
		
// --------------------------------------------------------------------------------
		/**
		 * Function to quickly determine if the line is full. Currently, there is only one line and one set of spots 
		 * so lineID is unused. 
		 * @param lineID Line ID for the respective line in the reception area
		 * @return 
		 * 
		 */			
		public function isLineFull(lineID:int):Boolean
		{
			if(_patientsInLine.length >= _receptionLineSpots.length) return true; 
			return false;
		}
		
// --------------------------------------------------------------------------------
		
		public function get patientAtReception():Patient { return _patientAtReception; };
		public function get patientsInLine():Array { return _patientsInLine };
	}
}