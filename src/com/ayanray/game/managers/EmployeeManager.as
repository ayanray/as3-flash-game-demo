package com.ayanray.game.managers
{
	import as3isolib.display.primitive.IsoBox;
	import as3isolib.display.scene.IsoScene;
	
	import com.ayanray.game.entities.World;
	/**
	 * Manages doctors, receptionists, etc.
	 * 
	 * @author Ayan Ray
	 * 
	 */	
	public class EmployeeManager
	{
		/**
		 * Reference to World (aka owner) 
		 */		
		private var _owner:World;
		/**
		 * Reference to World Scene 
		 */		
		private var _scene:IsoScene;
		/**
		 * Keep's track of employees. TODO: Could turn to dictionary arranged by type of employee. 
		 */		
		private var employees:Array = new Array(); // {employee, anger, health}
		
		// TODO: Move to Enum class?
		public static const DOCTOR:String 		= "doctor";
		public static const RECEPTIONIST:String = "receptionist";
		
// --------------------------------------------------------------------------------	
		public function EmployeeManager(scene:IsoScene, owner:World)
		{
			this._scene = scene;
			this._owner = owner;
		}
		
// --------------------------------------------------------------------------------		
		
		public function addEmployee( type:String, health:int, x:int, y:int ):void
		{
			var employee:*;
			if(type == DOCTOR)
			{
				employee = new IsoBox();
				employee.setSize(20, 20, 20);
			}
			else if(type == RECEPTIONIST)
			{
				employee = new IsoBox();
				employee.setSize(20, 20, 20);
			}
			else
			{
				throw new Error("Cannot create unknown employee:" + type); // TODO: Add gametime to error
				return; 
			}
			employee.x = this._owner.getPosition(x);
			employee.y = this._owner.getPosition(y);
			this._scene.addChild(employee);
			this.employees.push(employee);
		}
		
// --------------------------------------------------------------------------------	
		/**
		 * TODO: Implement class logic 
		 * @param employee
		 * 
		 */		
		public function removeEmployee( employee:IsoBox ):void
		{
			// Cleanup employee (need to animate out?)
		}
	}
}