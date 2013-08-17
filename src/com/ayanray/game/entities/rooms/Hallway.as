package com.ayanray.game.entities.rooms
{
	import com.ayanray.game.managers.BuildingManager;
	/**
	 * Basic room type for Hallway (no custom functionality as it's just a passthrough room)
	 * @author Ayan Ray
	 * 
	 */	
	public class Hallway extends Room
	{
		public function Hallway(owner:BuildingManager, area:Array)
		{
			super(owner, area);
		}
	}
}