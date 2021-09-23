comment{
	SPAWN FUNCTIONS
	
	by kenoxite, unless specified otherwise
};

comment{ Check for dependencies };
if(format ["%1",EXT_fnc_isNil]=="scalar bool array string 0xfcffffef")then { player globalchat "ERROR: Common function library (common.sqf) is needed and it hasn't been loaded yet!" };

comment{
SPAWN INFANTRY
	Description:
	Spawns an infantry unit and returns the new unit
	
	Parameters:
		0: STRING - Class of the unit to be spawned
		1: OBJECT - Spawner unit. The spawner can be any infantry unit
		2: GROUP - Group to attach the unit to, once spawned
		3 (Optional): ARRAY - Array with extra parameters. Format: <param1>,<value1>,<param2>,<value2>,etc
			Parameters can be:
				_pos (Optional): ARRAY - Position where to place the new unit (default: spawner's position)
				_skill (Optional): NUMBER - Skill of the new unit (default: 0.5)
				_rank (Optional): STRING - Rank of the new unit (default: "private")
				_init (Optional): STRING - Code to run when the unit has spawned (default: "")
				_ID (Optional): NUMBER - Personal ID number for the spawned unit (only used to be able to retrieve the new spawned unit) (default: 0)

	Returns:
	OBJECT - Spawned unit. Returns objNull if it couldn't be spawned
	
	Example 1:
	[{soldierEB},player,group player] call EXT_fnc_spawnUnit;
	Spawns a soviet rifleman in the player's group, using the player as spawner
		
	Example 2:
	[{soldierWB},westSpawner,group wg1,[{pos},getPos leader wg1,{rank},{{SERGEANT}}]] call EXT_fnc_spawnUnit;
	Spawns an american rifleman of rank sergeant in the westSpawner's group, which will then join the wg1 group and be place besides its leader
};
EXT_fnc_spawnUnit = {
	private["_ID","_class","_params","_i","_grp","_pos","_rank","_init","_skill","_spawner","_unit"];
	_class=_this select 0;
	_spawner=if(count _this>1)then{_this select 1}else{player};
	_grp=if(count _this>2)then{_this select 2}else{grpNull};
	comment{Optional parameters};
	_params=if(count _this > 3)then {_this select 3}else{[]};
	_i=0;{if((_i%2)==0)then{call format ["_%1=%2",_x,_params select (_i+1)]};_i=_i+1;}forEach _params;
	if([_ID] call EXT_fnc_isNil) then {_ID = 0};
	if([_pos] call EXT_fnc_isNil) then {_pos=getPos _spawner};
	if([_init] call EXT_fnc_isNil) then {_init={}};
	if([_skill] call EXT_fnc_isNil) then {_skill=0.5};
	if([_rank] call EXT_fnc_isNil) then {_rank = "PRIVATE"};
	if!([_spawner] call EXT_fnc_isNil)then{
		comment{Make sure the new ID isn't a duplicate};
		if(_ID==0)then{_ID="newUnit" call EXT_fnc_createObjectID};
		comment{Spawn the unit};
		_init = _init+format ["newUnit%1=this;",_ID];
		_class createUnit [_pos,group _spawner,_init,_skill,_rank];
		_unit=call format ["newUnit%1",_ID];
		call format ["newUnit%1=nil",_ID];
		[_unit] join _grp;
	};
	if(_ID>0)then{_unit}else{objNull}
};