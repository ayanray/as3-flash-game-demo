package com.ayanray.game.entities.rooms
{
	import as3isolib.display.primitive.IsoRectangle;
	
	import com.ayanray.game.entities.characters.Patient;
	import com.ayanray.game.managers.BuildingManager;
	import com.junkbyte.console.ConsoleChannel;
	
	import flash.events.TimerEvent;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	/**
	 * Draws and manages the patient rooms. Helps other classes determine if the room is empty
	 * and if so, receives patient for treatment.
	 * 
	 * @author Ayan Ray
	 * 
	 */
	public class PatientRoom extends Room
	{
		/**
		 * Timer for seeing the doctor.
		 * TODO: Should be based on update loop. Okay for a demo. 
		 */		
		private var _patientTimer:Timer;
		/**
		 * Current patient being treated 
		 */		
		private var _currentPatient:Patient;
		/**
		 * Position within the room (that's important) where the patient will walk to 
		 */		
		private var _seatPosition:Point;
		/**
		 * Roof tiles to show/hide during and after treatment 
		 */		
		private var _roof:Array;
		/**
		 * Debug console 
		 */		
		private var _channel:ConsoleChannel = new ConsoleChannel('Patient Room');
		
// --------------------------------------------------------------------------------
		public function PatientRoom(owner:BuildingManager, area:Array, seatPosition:Point, roof:Array)
		{
			super(owner, area);
			
			this._seatPosition = seatPosition;
			this._roof = roof;
			
			_patientTimer = new Timer(5000, 1);
			_patientTimer.addEventListener(TimerEvent.TIMER_COMPLETE, this._onPatientProcedureFinished);
		}
		
// --------------------------------------------------------------------------------		
		/**
		 * Manages the movement of patients from the waiting room to the patient rooms. 
		 */		
		override public function acceptPatient(patient:Patient):Boolean
		{
			if(_currentPatient != null || patient.status != Patient.WAITING) return false;
			
			_channel.log("Patient", patient.uid, "has been accepted.");
			patient.status = Patient.PATIENT_ROOM;
			
			_currentPatient = patient;
			_patientTimer.delay = patient.timeValue;
			
			// Move patient
			patient.moveToSpot(this._seatPosition.x, this._seatPosition.y, function():void {_patientTimer.start(); showRoof();});
			
			return true;
		}	
		
// --------------------------------------------------------------------------------		
		
		private function _onPatientProcedureFinished(event:TimerEvent):void
		{
			_currentPatient.moveToSpot(this._owner.exitLocation.x, this._owner.exitLocation.y, 
				function():void { 
					_owner.owner.patientManager.removePatient(_currentPatient); 				
					_currentPatient = null;
				});
			
			// Move out
			hideRoof();
		}
		
// --------------------------------------------------------------------------------
// Roof Functions
				
		/**
		 * Shows roof by adding tiles from roof array to scene.
		 * @param id Room ID
		 * 
		 */
		public function showRoof():void
		{
			for(var i:int = 0; i < _roof.length; i++)
			{
				this._owner.owner.scene.addChild( _roof[i] as IsoRectangle );
			}
		}
		/**
		 * Hides roof by removing tiles from roof array to scene.
		 * @param id Room ID
		 * 
		 */
		public function hideRoof():void
		{
			for(var i:int = 0; i <_roof.length; i++)
			{
				this._owner.owner.scene.removeChild( _roof[i] as IsoRectangle );
			}
		}
		
// --------------------------------------------------------------------------------		
		
		public function isOpen():Boolean
		{
			if(this._currentPatient == null) return true;
			else return false;
		}
	}
}