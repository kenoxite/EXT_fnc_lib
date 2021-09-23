comment{
	COMMON FUNCTIONS
	Functions either commonly used by themselves or used by other functions in this library
	
	by kenoxite, unless specified otherwise
};

comment{
***********************************
    G E N E R A L
***********************************
};

comment{
IS NIL
	Description:
	Tests whether the variable defined by the String argument is undefined, or whether an expression result passed as Code is undefined.
	
	The command returns true if the variable or the expression result is undefined (i.e. the expression result is Void), and false in all other cases. 

	Parameters:
		0: VARIABLE or OBJECT

	Returns:
	BOOL
};
EXT_fnc_isNil={
	if(format ["%1",_this select 0] == "scalar bool array string 0xfcffffef") then { true } else { false }
};

comment{
IS SINGLEPLAYER
	Description:
	Return true if singleplayer

	Returns:
	BOOL
};
EXT_fnc_isSingleplayer={
	(playersNumber west+playersNumber east+playersNumber resistance+playersNumber civilian) == 0
};

comment{
IS CWA
	Description:
	Return true if using OFP v1.99 (CWA)

	Returns:
	BOOL
};
EXT_fnc_isCWA={
	!([getWorld] call EXT_fnc_isNil)
};

comment{
SPEED M/S
	Description:
	Returns the current speed of an object in m/s

	Parameters:
		OBJECT

	Returns:
	NUMBER
};
EXT_fnc_speedms={
	private["_v"];
	_v=velocity _this;
	sqrt (((_v select 0) ^ 2+((_v select 1) ^ 2)+((_v select 2) ^ 2)))
};

comment{
ROUND NUMBER
	Description:
	Rounds up or down to the closest integer

	Parameters:
		NUMBER

	Returns:
	NUMBER
};
EXT_fnc_round={
	((_this+0.5)-((_this+0.5) % 1))
};

comment{
FIND
	Description:
	Returns the index of the passed element

	Parameters:
		0: ARRAY - Array to look into
		1: NUMBER, STRING, OBJECT, SIDE or GROUP - Element to look for. It doesn't work with arrays

	Returns:
	NUMBER - Index or -1 if not found
};
EXT_fnc_find={
	private["_r","_e","_a","_i"];
	_a=_this select 0;
	_e=_this select 1;
	_r=-1;
	_i=0;{if(_x==_e)then{_r=_i};_i=_i+1;}forEach _a;
	_r
};

comment{
CREATE OBJECT ID
	Description:
	Creates a random non-duplicated ID number to be used as part of the name of a global variable which will be associated to an object

	Parameters:
		STRING - Name of the global variable

	Returns:
	NUMBER - ID for the global variable
};
EXT_fnc_createObjectID={
	private["_id"];
	_id=(random 1000) call EXT_fnc_round;
	while {!([call format ["%1%2",_this,_id]]call EXT_fnc_isNil)} do{
		_id=(random 1000) call EXT_fnc_round;
	};
	_id
};

comment{
RANDOM PLUS
	Author: Mr.Peanut (edited by Kenoxite)
	
	Description:
	This function may be used to replace the random command. It reduces correlation between successively generated random numbers.
	
	First time around it skips ahead 97 numbers in the random number sequence and then generates a global array of 97 random numbers. It then randomly selects one of these 97 numbers, and replaces it with a new random number.

	This function creates two persistent global variables called rshuf_arr and rshuf_id. Hopefully these two names will not conflict with other global variables.

	Algorithm taken from "Numerical Recipes" Fortran edition.

	Parameters:
		NUMBER - Range of the random number

	Returns:
	NUMBER
};
EXT_fnc_randomPlus={
	private ["_i","_id","_rn"];
	if ([rshuf_arr] call EXT_fnc_isNil) then
	{
		rshuf_arr=[];
		_i=0 ; 
		while {_i<97} do
		{
			random 1 ;
			_i=_i+1 ;
		}; 
		_i=0 ; 
		while {_i<97} do
		{
			rshuf_arr set [count rshuf_arr,random 1] ;
			_i=_i+1 ;
		}; 
		rshuf_id=random 1 ;
	};
	_id=97*rshuf_id-((97*rshuf_id) mod 1) ;
	_rn=rshuf_arr select _id ; 
	rshuf_arr set [_id, (random 1)] ; 
	rshuf_id=_rn ; 
	_rn=_this*_rn ;
	_rn
};

comment{
RANDOM RANGE
	Description:
	Returns a random integer between the two passed values

	Requires: EXT_fnc_round

	Parameters:
		0: NUMBER - Min value
		1: NUMBER - Max value

	Returns:
	INTEGER
};
EXT_fnc_randomRange={
	((random ((_this select 1)-(_this select 0)))+(_this select 0)) call EXT_fnc_round
};

comment{
VECTOR DISTANCE
	Description:
	Distance between two 3D vectors

	Parameters:
		0: ARRAY - Position 1
		1: ARRAY - Position 2
	
	Returns:
	NUMBER
};
EXT_fnc_vectorDistance={
	sqrt( (((_this select 0) select 0)-((_this select 1) select 0))^2+(((_this select 0) select 1)-((_this select 1) select 1))^2 )
};

comment{
VECTOR DIFF
	Description:
	Returns a vector that is the difference between <vector1> and <vector2>

	Parameters:
		0: ARRAY - Vector 1
		1: ARRAY - Vector 2

	Returns:
	ARRAY - Substracted vector
	
	Example:
	[getpos unit1, getpos unit2] call EXT_fnc_vectorDiff
};
EXT_fnc_vectorDiff={
	private["_p1","_p2"];
	_p1=_this select 0;
	_p2=_this select 1;
	[(_p1 select 0)-(_p2 select 0), (_p1 select 1)-(_p2 select 1), (_p1 select 2)-(_p2 select 2)]
};

comment{
DIR TO
	Description:
	Returns vector direction from object1 to object2

	Parameters:
		0: OBJECT - Origin object
		1: OBJECT - Ending object

	Returns:
	NUMBER
	
	Example:
	unit1 setDir ([unit1, unit2] call EXT_fnc_dirTo)
	Sets unit1 in the direction of unit2
};
EXT_fnc_dirTo={
	private["_vd","_d"];
	_vd=[getPos (_this select 1),getPos (_this select 0)] call EXT_fnc_vectorDiff;
	_d=(_vd select 0) atan2 (_vd select 1);
	if (_d<0) then {_d=360+_d};
	_d
};

comment{
RELATIVE DIR TO
	Description:
	Returns the relative direction from object 1 to object 2. Return is always 0-360. An unit to the right would be at a relative direction of 90 degrees, for example, and it would be behind if at 180

	Parameters:
		0: OBJECT - Origin object
		1: OBJECT - Ending object

	Returns:
	NUMBER
	
	Example:
	[unit1, unit2] call EXT_fnc_relativeDirTo
};
EXT_fnc_relativeDirTo={
	private["_xy","_d"];
	_xy=[(_this select 0),getPos (_this select 1)] call EXT_fnc_worldToModel;
	_d=(_xy select 0) atan2 (_xy select 1);
	if (_d<0) then {_d=360+_d};
	_d
};


comment{
***********************************
    A R R A Y S
***********************************
};

comment{ 
IN 2D ARRAY
	Description:
	Searchs for an element in a 2D array and returns an array with the indexes of all their parent arrays in the main array

	Parameters:
		0: ANY - Element to look for
		1: ARRAY - Array where it will be looked for
		2 (Optional): BOOL - Return only the first found index (default: false)
		3 (Optional): STRING - Expression to evaluate and that must be true in order to return the index (default: true)
	
	Returns:
		ARRAY - Array with the indexes in the main array of the found elements. Returns an empty array if nothing is found
};
EXT_fnc_in2Darray={
	private ["_ele","_a","_f","_i","_br","_r","_fl","_a1"];
	_ele=_this select 0;
	_a=_this select 1;
	_f=if(count _this >2)then{_this select 2}else{false};
	_fl=if(count _this >3)then{_this select 3}else{{true}};
	_r=[];
	_br=false;
	_i=0;while{_i<count _a && !_br}do{
		_a1=_a select _i;
		if(_ele in _a1 && !_br) then{
			if(_a1 call _fl)then{
				if(_f && count _r == 0)then{
					_br=true;
				};
				_r set [count _r,_i];
			};
		};
		_i=_i+1;
	};
	_r
};

comment{ 
FILTER 2D ARRAY BY INDEX
	Description:
	Returns an array with all the elements found in the passed indexes

	Parameters:
		0: ARRAY - Array that will be checked
		1: ARRAY - Indexes which content will be retrieved
	
	Returns:
		ARRAY - Array with the contents of the selected array indexes
};
EXT_fnc_filter2DarrayByIndex={
	private["_a","_i","_r"];
	_a=_this select 0;
	_i=_this select 1;
	_r=[];
	{
		_r set [count _r,_a select _x];
	} count _i;
	_r
};

comment{ 
TRIM 2D ARRAY BY INDEX
	Description:
	Trims the subarray found at the given index and returns the now trimmed array
	
	Parameters:
		0: NUMBER - Index of the element to trim
		1: ARRAY - Array that will be trimmed
	
	Returns:
		ARRAY - Trimmed array
};
EXT_fnc_trim2DarrayByIndex={
	private ["_i","_a"];
	_i=_this select 0;
	_a=_this select 1;
	if (_i<count _a)then{
		_a set [_i, -1];
		_a=_a-[-1];
	};
	_a
};

comment{ 
SORT BY DISTANCE
	Description:
	Sorts the array by shortest distance to the given position
	
	Parameters:
		0: ARRAY - Array to be sorted
		1: ARRAY - Origin position
	
	Returns:
		ARRAY - Sorted array
};
EXT_fnc_sortByDistance={
	private["_a","_p","_s","_d","_c","_i","_e"];
	_a=_this select 0;
	_p=_this select 1;
	_s=[];
	while {count _a > 0} do {
		 _c=_a select 0;
		 _d=[getpos _c,_p] call EXT_fnc_vectorDistance;
		 _i=0;
		 while {_i<count _a} do {
			_e=_a select _i;
			if (([getpos _e,_p] call EXT_fnc_vectorDistance)<_d) then {_c=_e};
			_i=_i+1;
		 };
		 _s set [count _s, _c];
		 _a=_a-[_c];
	};
	_s
};


comment{
***********************************
    O B J E C T S
***********************************
};

comment{
GET VEHICLE TYPE
	Description:
	Returns the vehicle type

	Parameters:
		OBJECT - Object to check
	
	Returns:
		ARRAY - Array with generic and specific class of the vehicle
};
EXT_fnc_getVehType={
	private ["_tg","_v","_ts"];
	_v=_this;
	_tg="";_ts="";
	if(_tg=="")then{ if(("man" countType [_v])==1)then{ _tg="inf"; _ts="inf" } };
	if(_tg=="")then{ if(("LandVehicle" countType [_v])==1)then{ _tg="land" } };
	if(_tg=="")then{ if(("air" countType [_v])==1)then{ _tg="air" } };
	if(_tg=="")then{ if(("Ship" countType [_v])==1)then{ _tg="boat"; } };
	if(_ts=="")then{ if(("ParachuteBase" countType [_v])==1)then{ _ts="parachute" } };
	if(_ts=="")then{ if(("Helicopter" countType [_v])==1)then{ _ts="helo" } };
	if(_ts=="")then{ if(("Plane" countType [_v])==1)then{ _ts="plane" } };
	if(_ts=="")then{ if(("apc" countType [_v])==1)then{ _ts="APC" } };
	if(_ts=="")then{ if(("car" countType [_v])==1)then{ _ts="car" } };
	if(_ts=="")then{ if(("truck" countType [_v])==1)then{ _ts="truck" } };
	if(_ts=="")then{ if(("MotorCycle" countType [_v])==1)then{ _ts="bike" } };
	if(_ts=="")then{ if(("SmallShip" countType [_v])==1)then{ _ts="patrolboat" } };
	if(_ts=="")then{ if(("BigShip" countType [_v])==1)then{ _ts="carrier" } };
	[_tg,_ts]
};

comment{
IS VEHICLE TYPE
	Description:
	Checks if the vehicle is of the passed type

	Parameters:
		0: OBJECT - Object to check
		1: STRING - type to check for. Defaults to "inf"
			Accepted values:
				* "inf"-infantry
				* "land"-land vehicle
				* "air"-air vehicle
				* "boat"-water vehicle
				* "parachute"-parachute
				* "helo"-helicopter
				* "plane"-plane
				* "apc"-apc
				* "car"-car
				* "truck"-truck
				* "bike"-bike
				* "tank"-tank
	
	Returns:
		BOOL
};
EXT_fnc_isVehType={
	private ["_t","_r","_v"];
	_v=_this select 0;
	_t=if(count _this > 1)then{_this select 1}else{"inf"};
	_r=false;
	if(!_r)then{ if(_t=="inf")then{ if(("man" countType [_v])==1)then{ _r=true } } };
	if(!_r)then{ if(_t=="boat")then{ if(("Ship" countType [_v])==1)then{ _r=true } } };
	if(!_r)then{ if(_t=="land")then{ if(("LandVehicle" countType [_v])==1)then{ _r=true } } };
	if(!_r)then{ if(_t=="air")then{ if(("air" countType [_v])==1)then{ _r=true } } };
	if(!_r)then{ if(_t=="parachute")then{ if(("ParachuteBase" countType [_v])==1)then{ _r=true } } };
	if(!_r)then{ if(_t=="helo")then{ if(("Helicopter" countType [_v])==1 && ("ParachuteBase" countType [_v])==0)then{ _r=true } } };
	if(!_r)then{ if(_t=="plane")then{ if(("Plane" countType [_v])==1)then{ _r=true } } };
	if(!_r)then{ if(_t=="APC")then{ if(("apc" countType [_v])==1)then{ _r=true } } };
	if(!_r)then{ if(_t=="car")then{ if(("car" countType [_v])==1)then{ _r=true } } };
	if(!_r)then{ if(_t=="truck")then{ if(("truck" countType [_v])==1)then{ _r=true } } };
	if(!_r)then{ if(_t=="bike")then{ if(("MotorCycle" countType [_v])==1)then{ _r=true } } };
	if(!_r)then{ if(_t=="tank")then{ if(("tank" countType [_v])==1)then{ _r=true } } };
	_r
};

comment{
CLOSEST UNIT
	Required: EXT_fnc_vectorDistance
	
	Description:
	Returns the closest unit from an array of units

	Parameters:
		0: OBJECT - Unit to use as center
		1: ARRAY - Array of units
	
	Returns:
		OBJECT - The closest unit or objNull if none is found
};
EXT_fnc_closestUnit={
	private["_u","_u1","_d","_d1"];
	_u=_this select 0;
	_u1=objNull;
	_d=99999;
	{if((vehicle _x)!=_u1)then{_d1=[getPos vehicle _u,getPos vehicle _x]call EXT_fnc_vectorDistance;if(_d1<_d)then{_d=_d1;_u1=vehicle _x}}}forEach (_this select 1);
	_u1
};

comment{
MOVEMENT MODE
	Description:
	Returns an estimate of the current movement mode of the unit (walking, running, jogging, etc)
	
	DEFAULTS: run 23.328 | jog 15.19 | walk 9.57 | jog slow 6.19 | crouch slow 5.91 | crawl fast 5.13 | walk slow 5.049 | crawl 2.58 | stop 0 | back crawl -1.407 | back walk -3.915 | back crouch -4.646 | back jog slow -5.004 | back jog -6.318

	Parameters:
		OBJECT - Unit to check
	
	Returns:
		STRING - Estimated movement mode.
			It can be: run, jog, walk, jojg slow, crouch slow, crawl fast, walk slow, crawl, stop, back crawl, back walk, back crouch, back jog slow or back jog
};
EXT_fnc_moveMode={
	private["_s","_r"];
	_s=speed _this;
	_r="";
	if(_s>23)then{_r="run"};
	if(_s>15 && _s<=23)then{_r="jog"};
	if(_s>9.5 && _s<=15)then{_r="walk"};
	if(_s>6.1 && _s<=9.5)then{_r="jog slow"};
	if(_s>5.9 && _s<=6.1)then{_r="crouch slow"};
	if(_s>5.1 && _s<=5.9)then{_r="crawl fast"};
	if(_s>5 && _s<=5.1)then{_r="walk slow"};
	if(_s>2.5 && _s<=5)then{_r="crawl"};
	if(_s<=2.5 && _s>=-1.4)then{_r="stop"};
	if(_s<-1.4 && _s>=-3.9)then{_r="back crawl"};
	if(_s<-3.9 && _s>=-4.6)then{_r="back walk"};
	if(_s<-4.6 && _s>=-5)then{_r="back crouch"};
	if(_s<-5 && _s>=-4.6)then{_r="back jog slow"};
	if(_s<-6.3)then{_r="back jog"};
	_r
};

comment{
IS TREE
	Description:
	Checks if there's trees in the passed array. Some tall bushes and telephone poles may also be detected as trees.

	Parameters:
		ARRAY - Array with the objects to check

	Returns:
		BOOL
};
EXT_fnc_isTree={
	private["_t","_o","_i"];
	_t=false;
	_i=0;while {_i<count _this && !_t} do {
		_o=_this select _i;
		if((getPos _o select 2)>7)then{_t=true};
		_i=_i+1;
	};
	_t
};

comment{
IS FOREST - SIMPLE
	Description:
	Checks if there's forests in the passed array. Result in forest corners, borders and between forest tiles is unreliable. Groves and lone trees may also be detected as forests
	Uses measurements of vanilla forests done by Rellikki.
	
	((_z >= 18.0418 && _z <= 23.1900) || (_z >= 25.8946 && _z <= 28.5844) || (_z >= 23.4063 && _z <= 24.344) || (_z >= 11.6016 && _z <= 12.7339))
	
	This function is faster but more imprecise than EXT_fnc_isForest

	Parameters:
		ARRAY - Array with the objects to check

	Returns:
		BOOL
};
EXT_fnc_isForestSimple={
	private["_f","_o","_i","_z"];
	_f=false;
	_i=0;while {_i<count _this && !_f} do {
		_o=_this select _i;
		_z=getPos _o select 2;
		if((typeOf _o)=="" && ((_z >= 14 && _z <= 24) || (_z >= 25 && _z <= 29) || (_z >= 23 && _z <= 26) || (_z >= 11 && _z <= 13)))then{_f=true};
		_i=_i+1;
	};
	_f
};

comment{
IS BUSH
	Description:
	Checks if there's bushes in the passed array. Some fences and signposts may also be detected as bushes.

	Parameters:
		ARRAY - Array with the objects to check

	Returns:
		BOOL
};
EXT_fnc_isBush={
	private["_b","_o","_i","_z"];
	_b=false;
	_i=0;while {_i<count _this && !_b} do {
		_o=_this select _i;
		_z=getPos _o select 2;
		if((typeOf _o)=="" && ((_z>2 && _z<3.5) || (_z>6 && _z<8.2)))then{_b=true};
		_i=_i+1;
	};
	_b
};


comment{
***********************************
    M A R K E R S
***********************************
};

comment{
SHOW MARKER
	Description:
	Displays a maker with the passed values

	Parameters:
		0: STRING - Name of the marker to display
		1 (Optional): POSITION - New position (default: same position)
		2 (Optional): STRING - New type of the marker (default: same type)
		3 (Optional): STRING - New color for the marker (default: same color)
		4 (Optional): ARRAY - New size for the marker (default: same size)

	Returns:
	BOOL
};
EXT_fnc_showMarker={
	private["_mrkr","_pos","_type","_color","_size"];
	_mrkr=_this select 0;
	_pos=if(count _this>1)then{_this select 1}else{getMarkerPos _mrkr};
	_type=if(count _this>2)then{_this select 2}else{getMarkerType _mrkr};
	_color=if(count _this>3)then{format["color%1",_this select 3]}else{getMarkerColor _mrkr};
	_size=if(count _this>4)then{_this select 4}else{getMarkerSize _mrkr};
	_mrkr setMarkerPos _pos;
	_mrkr setMarkerType _type;
	_mrkr setMarkerColor _color;
	_mrkr setMarkerSize _size;
	true
};

comment{
HIDE MARKER
	Description:
	Hides a maker and resets its size

	Parameters:
		STRING - Name of the marker to hide

	Returns:
		BOOL
};
EXT_fnc_hideMarker={
	private["_mrkr"];
	_mrkr=_this;
	_mrkr setMarkerPos [0,0,0];
	_mrkr setMarkerType "empty";
	_mrkr setMarkerSize [1,1];
	true
};


comment{
***********************************
    P O S I T I O N S
***********************************
};

comment{
GET TERRAIN HEIGHT ASL
	Description:
	Returns the elevation above sea level (ASL) of the terrain at the given position

	Parameters:
		ARRAY - Position to check
	
	Returns:
		NUMBER - Elevation
};
EXT_fnc_getTerrainHeightASL={
	private["_e"];
	EXT_fl_trigger setPos [_this select 0,_this select 1,0];
	_e=-(getPos EXT_fl_trigger select 2);
	EXT_fl_trigger setPos [0,0,0];
	_e
};
EXT_fnc_getTerrainHeightASL_old={
	private["_e","_t"];
	_t="emptydetector" camcreate [0,0,0];
	_t setPos [_this select 0,_this select 1,0];
	_e=-(getPos _t select 2);
	camdestroy _t;
	_e
};

comment{
GET POSITION ATL
	Description:
	Returns the position above terrain level (ATL) of an object

	Parameters:
		OBJECT - Object to check
	
	Returns:
		ARRAY - Position relative to terrain
};
EXT_fnc_getPosATL={
	private["_p"];
	_p=getPosASL _this;
	[_p select 0, _p select 1, (_p select 2)-(_p call EXT_fnc_getTerrainHeightASL)]
};

comment{
SET POSITION ATL
	Description:
	Sets the position above terrain level (ATL) of an object

	Parameters:
		0: OBJECT - Object to set
		1: ARRAY - New position
};
EXT_fnc_setPosATL={
	private["_p"];
	_p=_this select 1;
	(_this select 0) setPosASL [_p select 0,_p select 1,(_p call EXT_fnc_getTerrainHeightASL)+(_p select 2)];
};

comment{	 
RANDOM POSITION
	Requires: EXT_fnc_randomRange
	
	Description:
	Returns a random position in a given radius

	Parameters:
		0: ARRAY - Origin position
		1: NUMBER - Minimum radius to look for the new random position
		2: NUMBER - Maximum radius to look for the new random position
		3 (Optional): NUMBER - Height for the new random position (default: origin height)
	
	Returns:
		ARRAY - Random position
};
EXT_fnc_rndPos={
	private ["_p","_rMin","_rMax","_d","_dt","_p","_z"];
	_p=_this select 0;
	_rMin=_this select 1;
	_rMax=_this select 2;
	if(_rMin>=_rMax)then{_rMin=0};
	_z=if(count _this>3)then{_this select 3}else{_p select 2};
	_dt=[_rMin,_rMax] call EXT_fnc_randomRange;
	_d=random 359;
	[(_p select 0)-_dt*sin(_d),(_p select 1)-_dt*cos(_d), _z]
};

comment{
WORLD TO MODEL
	Description:
	Returns the relative position of a given point from an object (converts position from world space to object model space)

	Parameters:
		0: OBJECT - Object to check its relative position
		1: ARRAY - World position
	
	Returns:
	ARRAY - Relative position to model

	Example:
	[player,getPos car1]call EXT_fnc_worldToModel;
	That will return the relative position of car1 from the player (the offset from the player's position)
};
EXT_fnc_worldToModel={
	private ["_obj","_pos","_dir","_x1","_x2","_y1","_y2","_x","_y"];
	_obj=_this select 0;
	_pos=_this select 1;
	_x1=getPos _obj select 0;
	_y1=getPos _obj select 1;
	_x2=_pos select 0;
	_y2=_pos select 1;
	_dir=getDir _obj;
	_x=(((_x2-_x1)*cos _dir)-((_y2-_y1)*sin _dir));
	_y=(((_x2-_x1)*sin _dir)+((_y2-_y1)*cos _dir));
	[_x,_y,(_pos select 2)-(getPos _obj select 2)]
};

comment{
MODEL TO WORLD
	Description:
	Returns a world position relative to an object (translates relative position from object model space into world position)

	Parameters:
		0: OBJECT - Object to check its relative position
		1: ARRAY - Offset position
	
	Returns:
	ARRAY - World position relative to model

	Example:
	[player,[0,10,0]] call EXT_fnc_modelToWorld
	That will return a position 10 meters in front of the player
};
EXT_fnc_modelToWorld={
	private ["_obj","_pos","_dir","_x1","_x2","_y1","_y2","_x","_y"];
	_obj=_this select 0;
	_pos=_this select 1;
	_x1=getPos _obj select 0;
	_y1=getPos _obj select 1;
	_x2=_pos select 0;
	_y2=_pos select 1;
	_dir=getDir _obj;
	_x=_x1+_y2*sin(_dir)+_x2*cos(_dir);
	_y=_y1+_y2*cos(_dir)-_x2*sin(_dir);
	[_x, _y,(getPos _obj select 2)+(_pos select 2)]
};


comment{
***********************************
    N E A R    O B J E C T S
***********************************
};

comment{
NEAR OBJECTS
	Description:
	Find objects in a sphere with given radius.
	The first object in the returned array is not necessarily the closest one.
	If you need returned objects to be sorted by distance, use EXT_fnc_nearestObjects

	Parameters:
		0: ARRAY - Starting position
		1: ARRAY - Array with the type of objects to look for (must be strings). If left empty it will look for any kind of object
		2 (Optional): NUMBER - Radius to look for objects, in meters (default: 25)
		3 (Optional): ARRAY - Array of object types to exclude (default: [])
		4 (Optional): NUMBER - Step size (default: a third of the radius)
	
	Returns:
		ARRAY - Found objects
};
EXT_fnc_nearObjects={
	private ["_p","_o","_nO","_x","_y","_z","_i","_d","_dg","_r","_t","_j","_t1","_tO","_e","_k","_tmpO","_s"];
	_p=_this select 0;
	_t=_this select 1;
	_r=if(count _this>2)then{_this select 2}else{25};
	_e=if(count _this>3)then{_this select 3}else{[]};
	_s=if(count _this>4)then{_this select 4}else{(_r/3)};
	_dg=45;
	_x=_p select 0;
	_y=_p select 1;
	_z=_p select 2;
	_o=[];
	_i=0;while {_i<_r} do {
		comment{_d=random 360};
		comment{_d=0};
		_d=0;
		_j=0;
		while {_j<(360/_dg)} do {
			_nO=nearestObject [_x+_i *sin(_d),_y+_i *cos(_d),7];
			if(!isNull _nO)then{
				_tO=typeOf _nO;
				if !(_tO in EXT_fl_nAIv)then{
					_tmpO=objNull;
					if(!(_nO in _o) && (speed _nO<40))then{
						if(count _t>0)then{
							_k=0;
							while {_k<count _t} do {
								_t1=_t select _k;
								if(_t1=="forest")then{
									if([_nO] call EXT_fnc_isForestSimple)then{
										_tmpO=_nO;
									};
								}else{
									if(_t1=="road")then{
										if((getPos _nO select 2)<=0 && _tO=="")then{
											_tmpO=_nO;
										};
									}else{
										if(_t1=="bush")then{
											if([_nO] call EXT_fnc_isBush)then{
												_tmpO=_nO;
											};
										}else{
											if(_t1=="tree")then{
												if([_nO] call EXT_fnc_isTree)then{
													_tmpO=_nO;
												};
											}else{
												if((_t1 countType [_nO])>0)then{
													_tmpO=_nO;
												};
											};
										};
									};
								};
								_k=_k+1;
							};
						} else {
							_tmpO=_nO;
						};
						if(!isNull _tmpO)then{
							_k=0; while{_k<count _e && !isNull _tmpO}do{
								if(((_e select _k) countType [_tmpO])>0)then{ _tmpO=objNull};
								_k=_k+1;
							};
							if(!isNull _tmpO)then{
								_o set [count _o,_tmpO];
							};
						};
					};
				};
			};
			_d=(_d+_dg) mod 360;
			_j=_j+1;
		};
		_i=_i+_s;
	};
	_o
};

comment{
NEAREST OBJECTS
	Description:
	Returns a list of nearest objects of the given types to the given position or object, within the specified distance.
	If more than one object is found they will be ordered according to vector distance to the object (i.e. the closest one will be first in the array).
	Alternatively, you can use EXT_fnc_nearObjects command, which doesn't sort results

	Parameters:
		0: ARRAY - Starting position
		1: ARRAY - Array with the type of objects to look for (must be strings). If left empty it will look for any kind of object
		2 (Optional): NUMBER - Radius to look for objects, in meters (default: 25)
		3 (Optional): ARRAY - Array of object types to exclude (default: [])
	
	Returns:
		ARRAY - Found objects sorted by distance
};
EXT_fnc_nearestObjects={
	private ["_o"];
	_o=_this call EXT_fnc_nearObjects;
	if(count _o>1)then{[_o,_p] call EXT_fnc_sortByDistance}else{_o}
};

comment{
NEAREST OBJECT
	Description:
	Returns the nearest object of given type to given position.
	If object class type is used, any object derived from the type is found as well

	Parameters:
		0: ARRAY - Starting position
		1: STRING - Type of object to look for (must be strings). If left empty it will look for any kind of object
		2 (Optional): NUMBER - Radius to look for objects, in meters (default: 25)
		3 (Optional): ARRAY - Array of object types to exclude (default: [])
		4 (Optional): NUMBER - Step size (default: a third of the radius)
	
	Returns:
		OBJECT - Found object or objNull if none is found
};
EXT_fnc_nearestObject={
	private ["_p","_o","_nO","_x","_y","_i","_d","_s","_r","_t","_tmpO","_dist","_tmpDist","_tO","_j","_e","_k","_mrkri","_z","_dg"];
	_p=_this select 0;
	_t=_this select 1;
	_r=if(count _this>2)then{_this select 2}else{25};
	_e=if(count _this>3)then{_this select 3}else{[]};
	_s=if(count _this>4)then{_this select 4}else{(_r/3)};
	_dg=45;
	_x=_p select 0;
	_y=_p select 1;
	_o=objNull;
	_dist=9999;
	if(EXT_fl_debug)then{_mrkri=1;while{_mrkri<500}do{format["pos_%1",_mrkri] call EXT_fnc_hideMarker;_mrkri=_mrkri+1;}; _mrkri=1};
	_i=0;while {_i<_r} do {
		_d=random 360;
		_j=0;
		while {_j<(360/_dg)} do {
			_z=if(_t=="road")then{0}else{7};
			_nO=nearestObject [_x+_i *sin(_d),_y+_i *cos(_d),_z];
			if(!isNull _nO)then{
				_tO=typeOf _nO;
				if !(_tO in EXT_fl_nAIv)then{
					if(EXT_fl_debug)then{[format["pos_%1",_mrkri],getPos _nO,"dot","blue"] call EXT_fnc_showMarker;_mrkri=_mrkri+1};
					_tmpO=objNull;
					_tmpDist=-1;
					if(_nO!=_o && (speed _nO<40))then{
						if(_t=="forest")then{
							if([_nO] call EXT_fnc_isForestSimple)then{
								_tmpO=_nO;
							};
						}else{
							if(_t=="road")then{
								if((getPos _nO select 2)<=0 && _tO=="")then{
									_tmpO=_nO;
									comment{player globalchat format["road:%1",_nO]};
								};
							}else{
								if(_t=="bush")then{
									if([_nO] call EXT_fnc_isBush)then{
										_tmpO=_nO;
									};
								}else{
									if(_t=="tree")then{
										if([_nO] call EXT_fnc_isTree)then{
											_tmpO=_nO;
										};
									}else{
										if(_t!="")then{
											if((_t countType [_nO])>0)then{
												_tmpO=_nO;
											};
										}else{
											_tmpO=_nO;
										};
									};
								};
							};
						};
						if(!isNull _tmpO)then{
							_k=0; while{_k<count _e && !isNull _tmpO}do{
								if(((_e select _k) countType [_tmpO])>0)then{ _tmpO=objNull};
								_k=_k+1;
							};
							if(!isNull _tmpO)then{
								_tmpDist=[getpos _tmpO,_p] call EXT_fnc_vectorDistance;
								if (_tmpDist<_dist)then{
									_dist=_tmpDist;
									_o=_tmpO;
								};
							};
						};
					};
				};
			};
			_d=(_d+_dg) mod 360;
			_j=_j+1;
		};
		_i=_i+_s;
	};
	if(EXT_fl_debug && !isNull _o)then{[format["pos_%1",_mrkri-1],getPos _o,"dot","green",[2,2]] call EXT_fnc_showMarker;};
	_o
};


comment{
MAP GRID POSITION
	Author: uiox
	
	Description:
	

	Parameters:
		ARRAY - Position
	
	Returns:
		STRING
};
EXT_fnc_mapGridPosition={
	private ["_uc","_lc","_n","_nStr","_p","_ucArr","_lcArr"];
	_ucArr=["A","B","C","D","E","F","G","H","I","J"];
	_lcArr=["a","b","c","d","e","f","g","h","i","j"];
	_p=_this;
	_nStr ="";
	_uc=(((_p select 0)-((_p select 0) mod 1280))/1280);
	_lc =((((_p select 0) mod 1280)- (((_p select 0) mod 1280)mod 128))/128);   
	_n=(99-((_p select 1)-((_p select 1) mod 128))/128);         
	_nStr=format["%1",_n];
	if (_n<10) then  {_nStr="0"+_nStr };
	((_ucArr select _uc)+( _lcArr select _lc)+_nStr)
};


comment{
FIND NESTED
};
EXT_fnc_findNested={
	private ["_e","_a","_i","_br","_r","_a1","_s"];
	_e=_this select 0;
	_a=_this select 1;
	_s=if(count _this>2)then{_this select 2}else{0};
	_r=[];
	_br=false;
	_i=0; while{_i<(count _a) && !_br} do {
		_a1=(_a select _i) find _e;
		if(_a1>=0)then{
			_r=[_i,_a1];
			_br=true;
		};
		_i=_i+1+_s;
	};
	_r
};


comment{
SET HEIGHT
	Description:
	Changes the height of the passed object

	Parameters:
		0: OBJECT - Object to set
		1: NUMBER - New height
};
EXT_fnc_setHeight={
	private ["_obj","_height","_pos","_x","_y","_z"];
	_obj = _this select 0;
	_height = _this select 1;
	_pos = getPos _obj;
	_x = _pos select 0;
	_y = _pos select 1;
	_z = _pos select 2;
	_obj setPos [_x,_y,_z + _height];
};