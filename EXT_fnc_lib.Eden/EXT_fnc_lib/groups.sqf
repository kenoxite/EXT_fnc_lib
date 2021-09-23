comment{
	GROUP RELATED FUNCTIONS
	
	by kenoxite, unless specified otherwise
};

comment{
HAS BIS ORDERS
	Description:
	Returns wheter the group has waypoints assigned in the editor or not
	
	Parameters:
		GROUP - Group to check

	Returns:
	BOOL
};
EXT_fnc_hasBISorders={
	private["_p"];
	_p=getWPPos [_this,1];
	if((_p select 0)==0 && (_p select 1)==0)then{false}else{true}
};

comment{
NEEDS SUPPORT
	Requires: EXT_fnc_isVehType
	
	Description:
	Returns the type of support a unit needs, if any
	
	Parameters:
		OBJ - Unit to check

	Returns:
	BOOL
};
EXT_fnc_needsSupport={
	private["_u","_r"];
	_u=_this;
	_r="";
	if ([_u,"inf"] call EXT_fnc_isVehType) then {
		if(
			!canStand _u ||
			(handsHit _u) == 1 ||
			(damage _u) > 0.2
		)then{_r="medic"};
		if(
			!someAmmo _u
		)then{_r="ammo"};
	} else {
		if(
			!canFire _u ||
			!canMove _u ||
			(damage _u) > 0.2
		)then{_r="repairs"};
		if(
			!someAmmo _u
		)then{_r="ammo"};
		if(
			(fuel _u)<=0.2
		)then{_r="fuel"};
	};
	_r
};

comment{
CHECK GROUP PROXIMITY
	Requires: EXT_fnc_vectorDistance
	
	Description:
	Returns the distance between the leader of the group and *the closest unit* of the other group
	
	Parameters:
		0: GROUP - Group to use as center
		1: GROUP - Other group to check for proximity

	Returns:
	NUMBER - Distance
};
EXT_fnc_checkGroupProximity={
	private["_grp","_otherGrp","_dist","_uDist","_v"];
	_grp=_this select 0;
	_otherGrp=_this select 1;
	_v=vehicle leader _grp;
	_dist=9999;
	{_uDist=[getpos _v,getpos vehicle _x]call EXT_fnc_vectorDistance;if(_uDist<_dist)then{_dist=_uDist}}count units _otherGrp;
	_uDist
};

comment{
HAS AT
	Description:
	Returns whether the group has AT launchers and ammo for them or not
	AT supported: vanilla, WW4, WW4 Extended
	
	Parameters:
		GROUP - Group to check

	Returns:
	BOOL
};
EXT_fnc_hasAT={
	private["_r","_c","_u","_mag"];
	_c=[
		["WW4EXT_LAWLauncher","WW4EXT_LAWMag"],
		["WW4EXT_LAWA7Launcher","WW4EXT_LAWA7Mag"],
		["WW4EXT_CarlGustavLauncher","WW4EXT_CarlGustavMag"],
		["WW4EXT_AT4Launcher","WW4EXT_AT4Mag"],
		["WW4EXT_SMAWLauncher","WW4EXT_SMAWMag"],
		["WW4EXT_RPGLauncher","WW4EXT_RPGMag"],
		["WW4EXT_RPG16","WW4EXT_RPG16Mag"],
		["WW4EXT_RPG75","WW4EXT_RPG75Mag"],
		["WW4EXT_RPG18","WW4EXT_RPG18Mag"],
		["WW4EXT_RPG22","WW4EXT_RPG22Mag"],
		["WW4EXT_RPG26","WW4EXT_RPG26Mag"],
		["WW4EXT_RPG29","WW4EXT_RPG29Mag"],
		["WW4EXT_RPOLauncher","WW4EXT_RPOMag"],
		["WW4EXT_JavelinLauncher","WW4EXT_JavelinMag"],
		["WW4EXT_DragonLauncher","WW4EXT_DragonMag"],
		
		["WW4_LAWLauncher","WW4_LAWLauncher"],
		["WW4_RPGLauncher","WW4_RPGLauncher"],
		["WW4_CarlGustavLauncher","WW4_CarlGustavLauncher"],
		["WW4_AT4Launcher","WW4_AT4Launcher"],
		["WW4_JavelinLauncher","WW4_JavelinMag"],
		["WW4_VympelLauncher","WW4_VympelMag"],
		["WW4_SMAWLauncher","WW4_SMAWMag"],
		
		["AT3Launcher","AT3Launcher"],
		["AT4Launcher","AT4Launcher"],
		["CarlGustavLauncher","CarlGustavLauncher"],
		["LAWLauncher","LAWLauncher"],
		["RPGLauncher","RPGLauncher"]
	];
	_r=false;
	{
		_u=_x;
		if(alive _u)then{
		{
			if((_x select 0) in weapons _u)then{
				_mag=(_x select 1);
				{
					if(_x==_mag) then {
						_r=true;
					};
				}count magazines _u;
			};
		} count _c;
		};
	}count units _this;
	_r
};

comment{
HAS AA
	Description:
	Returns whether the group has AA launchers and ammo for them or not
	AA supported: vanilla, WW4, WW4 Extended
	
	Parameters:
		GROUP - Group to check

	Returns:
	BOOL
};
EXT_fnc_hasAA={
	private["_r","_c","_u","_mag"];
	_c=[
		["9K32Launcher","9K32Launcher"],
		["AALauncher","AALauncher"]
	];
	_r=false;
	{
		_u=_x;
		if(alive _u)then{
		{
			if((_x select 0) in weapons _u)then{
				_mag=(_x select 1);
				{
					if(_x==_mag) then {
						_r=true;
					};
				}count magazines _u;
			};
		} count _c;
		};
	}count units _this;
	_r
};

comment{
IS MEDIC
	Description:
	Checks whether the class of the passed unit can heal or not
	Medic classes supported: vanilla, WW4 Extended
	
	Parameters:
		UNIT - Unit to check

	Returns:
	BOOL
};
EXT_fnc_isMedic={
	private ["_u","_c","_r","_i"];
	_u=_this;
	_r=false;
	_c=[
		"WW4EXT_MedicBaseE",
		"WW4EXT_MedicBaseW",
		"WW4EXT_MedicBaseR",
		"WW4EXT_SquadLeaderHBaseE",
		"WW4EXT_SquadLeaderHBaseW",
		"WW4EXT_SquadLeaderHBaseR",
		"WW4EXT_OfficerHBaseE",
		"WW4EXT_OfficerHBaseW",
		"WW4EXT_OfficerHBaseR",
		"WW4EXT_TeamLeaderHBaseE",
		"WW4EXT_TeamLeaderHBaseW",
		"WW4EXT_TeamLeaderHBaseR",
		"WW4EXT_SFmedicBaseE",
		"WW4EXT_SFmedicBaseW",
		"WW4EXT_SFmedicBaseR",
		"WW4EXT_SFteamLeaderBaseE",
		"WW4EXT_SFteamLeaderBaseW",
		"WW4EXT_SFteamLeaderBaseR",
		"WW4EXT_SFofficerBaseE",
		"WW4EXT_SFofficerBaseW",
		"WW4EXT_SFofficerBaseR",
		"SoldierWMedic",
		"SoldierEMedic",
		"SoldierGMedic"
		];
	_i=0;
	while {_i < (count _c)} do 
		{
		if (((_c select _i) countType [_u])>0) then { _r=true };
		_i=_i + 1;
		};		
	_r
};

comment{
GET CREW
	Description:
	Returns the cargo and crew *of a vehicle*
	
	Parameters:
		OBJECT - Vehicle to check

	Returns:
	ARRAY - Array with crew and cargo
};
EXT_fnc_getCrew={
	private["_v","_cw","_cg"];
	_v=_this;
	_cw=[];
	_cg=[];
	if(!isNull driver _v)then{_cw set [count _cw,driver _v]};
	if(!isNull gunner _v)then{_cw set [count _cw,gunner _v]};
	if(!isNull commander _v)then{_cw set [count _cw,commander _v]};
	_cg=(crew _v)-_cw;
	[_cw,_cg]
};

comment{
GET GROUP CREW
	Requires: EXT_fnc_getCrew
	
	Description:
	Returns the cargo and crew *of all the vehicles in a group*
	
	Parameters:
		GROUP - Group to check

	Returns:
	ARRAY - Array with crew and cargo
};
EXT_fnc_getGroupCrew={
	private["_cw","_cg","_a"];
	_cw=[];
	_cg=[];
	{
	_a=_x call EXT_fnc_getCrew;
	_cw=_cw+(_a select 0);
	_cg=_cg+(_a select 1);
	} count _this;
	[_cw,_cg]
};

comment{
VEHICLE IS COMBAT READY
	Description:
	Returns true if the vehicle can move, fire, has fuel and it's not heavily damaged. False otherwise
	
	Parameters:
		OBJECT - Vehicle to check

	Returns:
	BOOL
};
EXT_fnc_vehCombatReady={
	private["_v","_r"];
	_v=_this;
	_r=true;
	if(_r)then{if(isNull _v)then{_r=false}};
	if(_r)then{if(!alive _v)then{_r=false}};
	if(_r)then{if(alive _v)then{
		if(_r)then{if(!canMove _v)then{_r=false}};
		if(_r)then{if((damage _v)>=0.7)then{_r=false}};
		if(_r)then{if((fuel _v)==0)then{_r=false}};
		if(_r)then{if!(isNull gunner _v)then{
			if(_r)then{if((count magazines _v)==0)then{_r=false}};
			if(_r)then{if(!canFire _v)then{_r=false}};
			}};
		};
	};
	_r
};

comment{
CLONE VEHICLE
	Description:
	Clones a given vehicle, trying to emulate its current status deletes the old one and returns the new clone
	
	Parameters:
		OBJECT - Vehicle to clone

	Returns:
	OBJECT - Cloned vehicle
};
EXT_fnc_cloneVeh={
	private["_v","_t","_p","_d","_f","_cf","_cm"];
	_v=_this;
	_t=typeOf _v;
	_p=getPos _v;
	_d=getDir _v;
	_f=fuel _v;
	_cf=canFire _v;
	_cm=canMove _v;
	deleteVehicle _v;	
	_v=_t createVehicle _p;
	_v setPos _p;
	_v setDir _d;
	_v setFuel _f;
	if(!_cm)then{_v setFuel 0};
	if(!_cf)then{{_v removeMagazines _x}forEach (magazines _v)};
	_v
};

comment{
IS IDLE
	Description:
	Returns whether a unit is idle (isn't completing any orders) or not
	Original function by Rübe
	
	Parameters:
		OBJECT - Unit to check

	Returns:
	BOOL
};
EXT_fnc_isIdle={
	private ["_u","_i"];
	_u=_this;
	_i=true;
	if(alive _u)then{
		{
			if (!(isNull _x)) then
			{
				_i=_i && (unitReady _x);
			};
		} forEach [
			(commander _u),
			(gunner _u),
			(driver _u)
		];
	};
	_i
};

comment{
GROUP VEHICLES
	Requires: EXT_fnc_isVehType
	
	Description:
	Returns an array with the vehicles present in the group
	
	Parameters:
		GROUP - Group to check

	Returns:
	ARRAY
};
EXT_fnc_groupVeh={
	private["_v"];
	_v=[];
	{
		_v=vehicle _x;
		if(!([_v,"inf"] call EXT_fnc_isVehType))then{
			if!(_v in _v)then{
				_v set[count _v,_v];
			};
		};
	}forEach units _this;
	_v
};

comment{
SEPARATE VEHICLE
	Description:
	Separates a vehicle and its crew from its current group
	
	Parameters:
		0: OBJECT - Vehicle to separate
		1 (Optional): STRING - Extra code to execute once the vehicle has been separated
};
EXT_fnc_separateVeh={
	private["_v","_grp","_e","_d","_g"];
	_v=_this select 0;
	_e=if(count _this>1)then{_this select 1}else{""};
	_d=driver _v;
	_g=gunner _v;
	if(!isNull _d)then{
		[_d] join grpNull;
		_grp=group _d;
		if(!isNull _g)then{[_g] join _grp};
		if(!isNull commander _v)then{[commander _v] join _grp};
	}else{
		[_g] join grpNull;
		_grp=group _g;
		if(!isNull commander _v)then{[commander _v] join _grp};
	};
	if(_e!="")then{call _e};
};

comment{
JOIN VEHICLE
	Description:
	Joins a vehicle and its crew to the group
	
	Parameters:
		0: GROUP - Group to join to
		1: OBJECT - Vehicle
		2 (Optional): STRING - Extra code to execute once the vehicle has joined
};
EXT_fnc_joinVeh={
	private["_v","_grp","_e"];
	_grp=_this select 0;
	_v=_this select 1;
	_e=if(count _this>2)then{_this select 2}else{""};
	[commander _v] join _grp;
	[gunner _v] join _grp;
	[driver _v] join _grp;
	if(_e!="")then{call _e};
};

comment{
GET GROUP SPREAD
	Author: Vektorboson
	
	Description:
	Calculates the spreading radius of a group.
	It calculates the min and max values of the x- and y- coordinates, subtracts and halves them and returns the diagonal length
	
	Parameters:
		GROUP - Group to check

	Returns:
	NUMBER - Radius length
	
	Example 1:
	group player call EXT_fnc_getGroupSpread;
};
EXT_fnc_getGroupSpread={
   private["_units","_c","_i","_p","_xmin","_xmax","_ymin","_ymax","_xx","_yy"];
   _units=units _this;
   _c=count _units;
   if(_c < 2) then {
      0.0
   } else {
      _i=1;
      _p=getpos (_units select 0);
      _xmin=_p select 0; _ymin=_p select 1;
      _xmax=_xmin; _ymax=_ymin;
      {
         _p=getpos _x;
         _xx=_p select 0; _yy=_p select 1;
         if(_xx < _xmin) then { _xmin=_xx };
         if(_xx > _xmax) then { _xmax=_xx };
         if(_yy < _ymin) then { _ymin=_yy };
         if(_yy > _ymax) then { _ymax=_yy };
      } foreach _units;
      
      sqrt( (_xmax-_xmin)^2 + (_ymax-_ymin)^2 )
   }
};

comment{
IN DANGER
	Description:
	Checks if the group is in danger (is detecting enemies nearby)
	
	Parameters:
		0: GROUP - Group to check
		1 (Optional): NUMBER - Distance an enemy has to be to be counted as enemy (default: 500)
		2 (Optional): ARRAY - Array of units to check for enemies (default: EXT_allUnits)

	Returns:
	BOOL
};
EXT_fnc_inDanger={
   private["_d","_a","_u","_i","_dg"];
	_u=leader(_this select 0);
	_d=if(count _this>1)then{_this select 1}else{500};
	_a=if(count _this>2)then{_this select 2}else{+(EXT_allUnits)};
	_dg=false;
	_i=0;while{_i<count _a && !_dg}do{
		if((_u countEnemy [vehicle (_a select _i)])>0)then{
			if ((_u distance (vehicle (_a select _i)))<=_d)then{
				_dg=true;
			};
		};
		_i=_i+1;
	};
	_dg
};

comment{
ENEMY HAS ARMOR
	Description:
	Returns the vehicle types among the detected enemies
	
	Parameters:
		0: GROUP - Group to check
		1 (Optional): NUMBER - Distance an enemy has to be to be counted as enemy (default: 300)
		2 (Optional): ARRAY - Array of units to check for enemies (default: EXT_allUnits)

	Returns:
	ARRAY - Armored land vehicles, soft land vehicles, air vehicles, water vehicles
};
EXT_fnc_enemyVehicles={
   private["_a","_u","_i","_c","_v","_d"];
	_u=leader(_this select 0);
	_d=if(count _this>1)then{_this select 1}else{300};
	_a=if(count _this>2)then{_this select 2}else{+(EXT_allUnits)};
	_v=[false,false,false,false];
	if(!isNull _u)then{
		_i=0;while{_i<count _a && (!(_v select 0) || !(_v select 1) || !(_v select 2) || !(_v select 3))}do{
			if((_u countEnemy [vehicle (_a select _i)])>0)then{
				if ((_u distance (vehicle (_a select _i)))<=_d)then{
					_c=(vehicle (_a select _i) call EXT_fnc_getVehType) select 1;
					if(_c=="tank" || _c=="APC")then{_v set [0,true]};
					if(_c=="car" || _c=="truck")then{_v set [1,true]};
					if(_c=="plane" || _c=="helo")then{_v set [2,true]};
					if(_c=="patrolboat")then{_v set [3,true]};
				};
			};
			_i=_i+1;
		};
	};
	_v
};

comment{
SET VARIABLE
	
};
EXT_fnc_setVariable={
	private["_vars","_i","_j","_k","_a","_vn"];
	_i=EXT_unitVars find (_this select 0);
	if(_i>=0)then{
		_vn=["initialized","spawnTime","lastPos","lastTime","inDanger","lastContact","inWater","inForest","nearestObj","nearestBuilding","nearMen","nearCorpses","onRoad","stance"];
		_a=EXT_unitVars select _i+1;
		_vars=_this select 1;
		if (count _vars>0)then{
			_j=0; while{_j<count _vars}do{
				_k=_vn find (_vars select _j);
				if(_k>=0)then{_a set [_k,_vars select (_j+1)]};
				_j=_j+2;
			};
		};
	};
};

comment{
GET VARIABLE
	
};
EXT_fnc_getVariable={
	private["_i","_j","_a","_r","_vn"];
	_r=false;
	_i=EXT_unitVars find (_this select 0);
	if(_i>=0)then{
		_vn=["initialized","spawnTime","lastPos","lastTime","inDanger","lastContact","inWater","inForest","nearestObj","nearestBuilding","nearMen","nearCorpses","onRoad","stance"];
		_a=EXT_unitVars select _i+1;
		_j=_vn find (_this select 1);
		if(_j>=0)then{_r=_a select _j};
	};
	_r
};

comment{
DUST TRAIL
	
};
EXT_fnc_dustTrail={
	private["_sprite","_type","_timerPeriod","_lifeTime","_rotationVel","_weight","_volume","_rubbing","_animationPhase","_randomDirPeriod","_randomDirIntensity","_onTimer","_beforeDestroy","_color1","_color2","_color3","_color4","_particlePos","_sizeStart","_sizeEnd","_object","_moveVel"];
	_object=_this select 0;
	_particlePos=if(count _this>1)then{_this select 1}else{[0,-1+(random 0.5 - random 0.5),-0.5]};
	_sizeStart=if(count _this>2)then{_this select 2}else{0.5+ random 1};
	_sizeEnd=if(count _this>3)then{_this select 3}else{1 + random 2};
	_lifeTime=if(count _this>4)then{_this select 4}else{5};
	
	_sprite="cl_basic";
	_type="Billboard";
	_timerPeriod=0.2;
	_rotationVel=10;
	_weight=1.4;
	_volume=1;
	_rubbing=random 0.1;
	_animationPhase=[0,0];
	_randomDirPeriod=0;
	_randomDirIntensity=0;
	_onTimer="";
	_beforeDestroy="";
	comment{light grey};
	_color1=[0.6,0.55,0.5,0.3+random 0.2];
	_color2=[0.6,0.55,0.5,0.2+random 0.3];
	_color3=[0.6,0.55,0.5,0.1];
	_color4=[0.6,0.55,0.5,0.05];
	_moveVel=[0,-1,0.1 + random 0.1];
	drop [_sprite,"",_type,_timerPeriod,_lifeTime,_particlePos,_moveVel,_rotationVel,_weight,_volume,_rubbing,[_sizeStart,_sizeEnd],[_color1,_color2,_color3,_color4],_animationPhase,_randomDirPeriod,_randomDirIntensity,_onTimer,_beforeDestroy,_object];
};

comment{
CONTEXTUAL STANCE
	
};
EXT_fnc_contextualStance={
	private["_u","_o","_crouch","_stand","_prone","_t","_c","_s","_beh"];
	_u=_this select 0;
	_o=_this select 1;
	_c=typeOf _o;
	_crouch=false;
	_stand=false;
	_prone=false;
	if([_o,"land"] call EXT_fnc_isVehType)then{_t="vehicle"};
	if([_o] call EXT_fnc_isBush)then{_t="bush"};
	if(("house" countType [_o])==1 || ("WW4EXT_tent_w" countType [_o])==1)then{_t="house"};
	if(("WW4EXT_fort_w" countType [_o])==1 || _c=="Fortress1" || _c=="Fortress2")then{_t="rampart"};
	if(("fence" countType [_o])==1)then{_t="fence"};
	if(_c=="WW4EXT_barricade01_w" || _c=="WW4EXT_barricade03_d" || _c=="WW4EXT_barricade01_a" || _c=="WW4EXT_barricade02_w")then{_t="rampart"};
	if(_c=="WW4EXT_fort06_w" || _c=="WW4EXT_fort07_w" || _c=="WW4EXT_barricade12_w" || _c=="WW4EXT_barricade01_d" || _c=="MAP_Position" || (("WW4EXT_bunker_w" countType [_o])==1 && (_c!="WW4EXT_bunker09_w" && _c!="WW4EXT_bunker09_d" && _c!="WW4EXT_bunker09_a")))then{_t="ground"};
	if(_c=="WW4EXT_bunker09_w" || _c=="WW4EXT_bunker09_d" || _c=="WW4EXT_bunker09_a")then{_t="house"};
	if(_c=="WW4EXT_fort01_w" || _c=="WW4EXT_fort02_w")then{_t="fence"};
	
	if(_t=="bush" || _t=="fence" || _t=="vehicle")then{_crouch=true};
	if(_t=="house")then{_crouch=true};
	if(_t=="rampart")then{_stand=true; _crouch=false};
	if(_t=="ground" || _t=="tree")then{_prone=true; _crouch=false; _stand=false};
	
	_beh=behaviour _u;
	if(_crouch && !(_beh=="COMBAT" || _beh=="STEALTH"))then{_crouch=false};
			
	_s=[_u,"stance"]call EXT_fnc_getVariable;
	if(_crouch)then{_u setunitpos "up"; _u playmove "Crouch"; if(_s!="crouching")then{[_u,["stance","crouching"]] call EXT_fnc_setVariable;}};
	if(!_crouch)then{if(_s=="crouching")then{[_u,["stance","none"]] call EXT_fnc_setVariable; _u setunitpos "auto"; _u playmove "";}}; 
	
	_s=[_u,"stance"]call EXT_fnc_getVariable;
	if(_stand)then{_u setunitpos "up"; _u playmove ""; if(_s!="standing")then{[_u,["stance","standing"]] call EXT_fnc_setVariable;}};
	if(!_stand)then{_s=if(_s=="standing")then{[_u,["stance","none"]] call EXT_fnc_setVariable; _u setunitpos "auto";_u playmove ""; }}; 
	
	_s=[_u,"stance"]call EXT_fnc_getVariable;
	if(_prone)then{_u setunitpos "down"; _u playmove ""; if(_s!="prone")then{[_u,["stance","prone"]] call EXT_fnc_setVariable;}};
	if(!_prone)then{if(_s=="prone")then{[_u,["stance","none"]] call EXT_fnc_setVariable; _u setunitpos "auto";_u playmove ""; }};
};

comment{
RANDOM BUILDING POSITION
	Description:
	Places the unit in one of the building positions, if any exists
	
	Parameters:
		0: OBJECT - Unit to place
		1 (Optional): OBJECT - Building to be placed into (default: nearestbuilding check)

	Returns:
	NUMBER - Building position
};
EXT_fnc_randomBuildingPos={
	private ["_u","_h","_i"];
	_u=_this select 0;
	_h=if(count _this>1)then{_this select 1}else{nearestbuilding (_u)};
	_i=0;
	if(!isNull _h)then{
		while {format ["%1",_h buildingPos _i]!="[0,0,0]"} do {_i=_i + 1};
		if (_i==1) then {_i=0};
		_i=_i - 1;
		_u setPos (_h buildingpos (random _i));
	};
	_i
};