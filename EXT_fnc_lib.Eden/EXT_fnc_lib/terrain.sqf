comment{
	TERRAIN RELATED FUNCTIONS
	
	by kenoxite, unless specified otherwise
};

comment{
IN WATER
	Requires: EXT_fnc_getTerrainHeightASL
	
	Description:
	Returns if there's water at the given position

	Parameters:
		0: ARRAY - Position to check
		1 (Optional): NUMBER - Height at which it should be considered that there's water (default: 2.3)

	Returns:
	BOOL
};
EXT_fnc_inWater = {
	private ["_p","_w"];
	_p=_this select 0;
	_w=if(count _this>1)then{_this select 1}else{2.3};
	if((_p call EXT_fnc_getTerrainHeightASL)<=_w)then{true}else{false}
};

comment{
IS FLAT
	Requires: EXT_fnc_getTerrainHeightASL
	
	Description:
	Returns if the terrain area is more or less flat.
	
	Note that the returned position might be in a forest, building or other structures
	
	Parameters:
		0: ARRAY - Starting position
		1 (Optional): NUMBER - Radius (default: 50)
		2 (Optional): NUMBER - Tolerance (default: 2.5)

	Returns:
	BOOL
};
EXT_fnc_isFlat = {
	private ["_p","_r","_d","_flat","_x","_y","_e","_nE","_t"];
	_p=_this select 0;
	_r=if(count _this > 1)then{_this select 1}else{50};
	_t=if(count _this > 2)then{_this select 2}else{2.5};
	_x=_p select 0;
	_y=_p select 1;
	_e=0;
	_d=0;
	_flat=true;
	while {_d<360 && _flat} do {
		_nE=[_x+_r *sin(_d),_y+_r *cos(_d),0] call EXT_fnc_getTerrainHeightASL;
		_flat=if(_e!=0 && abs(_e-_nE)>=_t)then{false}else{true};
		_e=_nE;
		_d=_d+90;
	};
	_flat
};

comment{
IN FOREST
	Requires: EXT_fnc_isForest
	
	Description:
	Returns if the location is inside a forest.
	Result in forest corners, borders and between forest tiles is unreliable.
	
	Parameters:
		ARRAY - Starting position

	Returns:
	BOOL
};
EXT_fnc_inForest = {
	!(isNull(_this call EXT_fnc_isForest))
};

comment{
IS FOREST
	Requires: EXT_fnc_isForestSimple, EXT_fnc_isForestChunk, EXT_fnc_relativeDirTo
	
	Description:
	Checks if the location is inside a forest.
	Some groves might be considered forests. 
	This function is way more precise than EXT_fnc_isForestSimple, but it's a bit more processor intensive
	
	Parameters:
		0: ARRAY - Position to check
		1: BOOL - Simple check (quicker, less accurate) (default: false)

	Returns:
	OBJECT - Nearest forest chunk. objNull if none is found
};
EXT_fnc_isForest={
	private ["_p","_s","_o","_nO","_x","_y","_d","_tO","_fc","_ft","_rd","_i","_r","_dg","_tmpO","_f","_j","_mrkri"];
	_p=_this select 0;
	_s=if(count _this>1)then{_this select 1}else{false};
	_r=40;
	_x=_p select 0;
	_y=_p select 1;
	_o=objNull;
	_tmpO=objNull;
	_f=false;
	_dg=90;
	if(EXT_fl_debug)then{_mrkri=1;while{_mrkri<500}do{format["pos_%1",_mrkri] call EXT_fnc_hideMarker;_mrkri=_mrkri+1;}; _mrkri=1};
	_i=0;while {_i<_r && isNull _tmpO} do {
		_d=random 360;
		_j=0;
		while {_j<(360/_dg) && isNull _tmpO} do {
			_nO=nearestObject [_x+_i *sin(_d),_y+_i *cos(_d),25];
			if(!isNull _nO)then{
				_tO=typeOf _nO;
				if !(_tO in EXT_fl_nAIv)then{
					if(EXT_fl_debug)then{[format["pos_%1",_mrkri],getpos _nO,"dot","red",[2,2]] call EXT_fnc_showMarker;_mrkri=_mrkri+1};
					if(_nO!=_o && (speed _nO < 40))then{
						_tmpO=_nO;
						_f=[_nO] call EXT_fnc_isForestSimple;
						comment{player globalchat format["_f %1 %2 %3",_f,_no,getpos _no select 2]};
						if(_f)then{
							if(_s)then{
								_o=_nO;
							}else{
								_fc=_nO call EXT_fnc_isForestChunk;
								if(_fc select 0)then{
									_ft=_fc select 1;
									EXT_fl_logic setPos _p;
									_rd=[_nO,EXT_fl_logic] call EXT_fnc_relativeDirTo;
									if(_ft=="Sq")then{
										_o=_nO;
									}else{
										if(_rd<40 || _rd>230)then{
											_o=_nO;
										};
									};
									EXT_fl_logic setPos [0,0,0];
								};
							};
						};
					};
				};
			};
			_d=(_d+_dg) mod 360;
			_j=_j+1;
		};
		_i=_i+(_r/3);
	};
	if(EXT_fl_debug && !isNull _o)then{[format["pos_%1",_mrkri-1],getpos _o,"dot","green",[2,2]] call EXT_fnc_showMarker;};
	_o
};

comment{
IS FOREST CHUNK
	***	TO REVISE! ***
	***	!!! So far it only returns reliably chunks from Everon forests
	Requires: EXT_fnc_nearObjects
	
	Description:
	Checks if the terrain objects is a forest chunk.
	Sometimes forest chunks with trees placed too close might not be recognized as forests (usually happens with triangle chunks).
	
	Parameters:
		OBJECT - Terrain object to check

	Returns:
	BOOL
};
EXT_fnc_isForestChunk={
	private["_o","_i","_z","_p","_x","_y","_fa","_nP","_d","_fc","_t","_f","_fp","_fx","_fy","_cn","_tp","_rg","_lf","_bt","_tl","_tr","_bl","_br","_tmparr"];
	_o=_this;
	_p=getPos _o;
	_x=_p select 0;
	_y=_p select 1;
	_z=_p select 2;
	_fc=0;
	_t="";
	_cn=false;
	_tp=false;
	_rg=false;
	_lf=false;
	_bt=false;
	_tl=false;
	_tr=false;
	_bl=false;
	_br=false;
	if(EXT_fl_debug)then{_tmparr=[]};
	_fa=[_p,["forest"],60,["man","landvehicle"]] call EXT_fnc_nearObjects;
	if(count _fa>0)then{
		_i=0;while{_i<count _fa}do{
			_f=_fa select _i;
			if(EXT_fl_debug)then{[format["pos_%1",_mrkri],getpos _f,"dot","blue"] call EXT_fnc_showMarker;_mrkri=_mrkri+1};
			_fp=getPos _f;
			_fx=(_x-(_fp select 0));
			_fy=(_y-(_fp select 1));
			if(_fx==0 && _fy==0)then{_cn=true; _fc=_fc+1;};
			if((_fx>=-3.8 && _fx<=3.8) && (_fy>=-53.6 && _fy<-47))then{_tp=true; _fc=_fc+1;};
			if((_fx>=-3.8 && _fx<=3.8) && (_fy>=46.2 && _fy<=53.8))then{_bt=true; _fc=_fc+1;};
			if((_fx>=46.2 && _fx<=53.8) && (_fy>=-3.8 && _fy<=3.8))then{_lf=true; _fc=_fc+1;};
			if((_fx>=-53.6 && _fx<-47) && (_fy>=-3.8 && _fy<=3.8))then{_rg=true; _fc=_fc+1;};
			if((_fx>=46.2 && _fx<=53.8) && (_fy>=-53.6 && _fy<-47))then{_tl=true; _fc=_fc+1;};
			if((_fx>=-53.6 && _fx<-47) && (_fy>=-53.6 && _fy<-47))then{_tr=true; _fc=_fc+1;};
			if((_fx>=46.2 && _fx<=53.8) && (_fy>=46.2 && _fy<=53.8))then{_bl=true; _fc=_fc+1;};
			if((_fx>=-53.6 && _fx<-47) && (_fy>=46.2 && _fy<=53.8))then{_br=true; _fc=_fc+1;};
			_tmparr=_tmparr+[[_fx,_fy,_f]];
			_i=_i+1;
		};
	};
	comment{player globalchat format["%1",_tmparr]};
	if (_fc>1)then{
		if(
		(!_tp && !_tl && !_lf && _rg && _bt && _br && _bl && _tr) || 
		(!_tp && !_tr && !_rg && _lf && _bt && _bl && _br && _tl) || 
		(!_bt && !_bl && !_lf && _rg && _tp && _tr && _br && _tl) || 
		(!_bt && !_br && !_rg &&_lf && _tp && _tl && _bl && _tr)
		)then{
			_t="Tr";
		}else{
			_t="Sq";
		};
	};
	comment{player globalchat format["t:%1,b:%2,l:%3,r:%4,tl:%5,tr:%6,bl:%7,br:%8,t:%9,fc:%10",_tp,_bt,_lf,_rg,_tl,_tr,_bl,_br,_t,_fc]};
	if (_fc>1)then{[true,_t]}else{[false,""]}
};

comment{
IN SHORE
	Requires: EXT_fnc_getTerrainHeightASL
	
	Description:
	Returns true if position is considered a shore
	
	Parameters:
		ARRAY - Position to check

	Returns:
	BOOL
};
EXT_fnc_inShore = {
	private ["_e"];
	_e=_this call EXT_fnc_getTerrainHeightASL;
	if(_e>2.5 && _e<5)then{true}else{false}
};


comment{
IS ROAD
	Description:
	Returns the nearest road from the object's position
	The result might sometimes be a small object near the road, instead of the road itself
	
	Parameters:
		OBJECT - Object to check

	Returns:
	OBJECT - Road or objnull
};
EXT_fnc_isRoad={
	private ["_p","_o","_nO","_x","_y","_d","_tO","_fc","_ft","_rd","_i","_r","_dg","_tmpO","_j","_v","_z","_isMan"];
	_v=vehicle _this;
	_p=getPos _v;
	_isMan=if(("man" countType [_v])==0)then{true}else{false};
	_r=if(_isMan)then{50}else{10};
	_z=if(_isMan)then{-20}else{0};
	_x=_p select 0;
	_y=_p select 1;
	_o=objNull;
	_tmpO=objNull;
	_dg=if(_isMan)then{90}else{66};
	_i=0;while {_i<_r && isNull _tmpO} do {
		_d=getdir _v;
		_j=0;
		while {_j<(360/_dg) && isNull _tmpO} do {
			_nO=nearestObject [_x+_i *sin(_d),_y+_i *cos(_d),_z];
			if(!isNull _nO)then{
				_tO=typeOf _nO;
				if !(_tO in EXT_fl_nAIv)then{
					if(_nO!=_o && (speed _nO < 40))then{
						comment{player globalchat format["o %1 z:%2",_nO,getPos _nO select 2]};
						if((getPos _nO select 2)<=2 && _tO=="" && (_nO distance _v)<=30)then{
							_o=_nO;
						};
					};
				};
			};
			_d=(_d+_dg) mod 360;
			_j=_j+1;
		};
		_i=_i+(_r/3);
	};
	_o
};

comment{
ROAD AT
	Requires: EXT_fnc_isRoad
	
	Description:
	Returns road segment at a given position
	The result might sometimes be a small object near the road, instead of the road itself
	
	Parameters:
		ARRAY - Position to check

	Returns:
	OBJECT - Road segment or objNull if none is found
};
EXT_fnc_roadAt = {
	private["_r"];
	EXT_fl_logic setPos _this;
	_r=EXT_fl_logic call EXT_fnc_isRoad;
	comment{player globalchat format["_r:%1",_r]};
	EXT_fl_logic setpos [0,0,0];
	_r
};

comment{
IS ON ROAD
	Requires: EXT_fnc_isRoad, EXT_fnc_relativeDirTo
	
	Description:
	Checks if a given vehicle is on a road
	The result might sometimes be a small object near the road, instead of the road itself
	
	Parameters:
		OBJECT - Object to check

	Returns:
	BOOL
};
EXT_fnc_isOnRoad = {
	private["_o","_r","_v","_rd"];
	_v=vehicle _this;
	_o=(_v) call EXT_fnc_isRoad;
	_r=false;
	if!(isNull _o)then{
		_rd=[_o,_v] call EXT_fnc_relativeDirTo;
		comment{player globalchat format["_rd:%1",_rd]};
		comment{roadspot="danger" camcreate [(getpos _o) select 0, (getpos _o) select 1, 3]};
		if((_rd<38 || _rd>340) || (_rd>173 && _rd<190) || (_rd>281 && _rd<90) || (_rd>160 && _rd<210))then{
			_r=true;
		};
	};
	_r
};

comment{
NEAR ROADS
	Requires: EXT_fnc_nearObjects
	
	Description:
	Find the road segments within a given radius
	
	Parameters:
		0: ARRAY - Starting position
		1 (Optional): NUMBER - Radius (default: 1000)

	Returns:
	ARRAY - Road segments found (unsorted)
};
EXT_fnc_nearRoads = {
	private["_p","_r","_s"];
	_p=_this select 0;
	_r=if(count _this>1)then{_this select 1}else{1000};
	_s=if(count _this>2)then{_this select 2}else{15};
	[_p,["road"],_r,["man","landvehicle"],_s] call EXT_fnc_nearObjects
};

comment{
NEAREST ROAD
	Requires: EXT_fnc_nearestObject
	
	Description:
	Returns the closest road segment at a given position
	Unlike EXT_fnc_roadAt or EXT_fnc_isOnRoad this makes sure that the returned position is 100% a road segment
	
	Parameters:
		ARRAY - Position to check

	Returns:
	OBJECT - Closest road segment or objNull if none is found
};
EXT_fnc_nearestRoad = {
	[_this,"road",1000,["man","landvehicle"],15] call EXT_fnc_nearestObject
};

comment{
HIGHEST POSITION
	Requires: EXT_fnc_getTerrainHeightASL
	
	Description:
	Returns the highest terrain point in range ASL
	
	Parameters:
		0: ARRAY - Starting position
		1 (Optional): NUMBER - Radius (default: 100)
		2 (Optional): NUMBER - Step (default: 10)

	Returns:
	ARRAY - Position
};
EXT_fnc_highestPos = {
	private ["_p","_r","_s","_z","_zP","_i","_d","_nP","_nZ","_dg","_j","_mrkri","_x","_y"];
	_p=_this select 0;
	_r=if(count _this > 1)then{_this select 1}else{100};
	_s=if(count _this > 2)then{_this select 2}else{10};
	_x=_p select 0;
	_y=_p select 1;
	_z=_p call EXT_fnc_getTerrainHeightASL;
	_zP=_p;
	_dg=45;
	if(EXT_fl_debug)then{_mrkri=1;while{_mrkri<500}do{format["pos_%1",_mrkri] call EXT_fnc_hideMarker;_mrkri=_mrkri+1;}; _mrkri=1};
	_i=0;while {_i<_r} do {
		_d=random 360;
		_j=0;
		while {_j<(360/_dg)} do {
			_nP=[_x+_i *sin(_d),_y+_i *cos(_d),0];
			if(EXT_fl_debug)then{[format["pos_%1",_mrkri],_nP,"dot","blue"] call EXT_fnc_showMarker;_mrkri=_mrkri+1};
			_nZ= _nP call EXT_fnc_getTerrainHeightASL;
			if(_nZ>_z)then{_zP=_nP;_z=_nZ;};
			_d=(_d+_dg) mod 360;
			_j=_j+1;
		};
		_i=_i+_s;
	};
	if(EXT_fl_debug && count _zP>0)then{[format["pos_%1",_mrkri-1],_zP,"dot","green",[2,2]] call EXT_fnc_showMarker;};
	_zP
};

comment{
LOWEST POSITION
	Requires: EXT_fnc_getTerrainHeightASL
	
	Description:
	Returns the lowest terrain point in range ASL
	
	Parameters:
		0: ARRAY - Starting position
		1 (Optional): NUMBER - Radius (default: 100)
		2 (Optional): NUMBER - Step (default: 10)

	Returns:
	ARRAY - Position
};
EXT_fnc_lowestPos = {
	private ["_p","_r","_s","_z","_zP","_i","_d","_nP","_nZ","_sL","_dg","_j","_mrkri","_x","_y"];
	_p=_this select 0;
	_r=if(count _this > 1)then{_this select 1}else{100};
	_s=if(count _this > 2)then{_this select 2}else{10};
	comment{Sea level};
	_sL=5;
	_x=_p select 0;
	_y=_p select 1;
	_z=_p call EXT_fnc_getTerrainHeightASL;
	_zP=_p;
	_dg=45;
	if(EXT_fl_debug)then{_mrkri=1;while{_mrkri<500}do{format["pos_%1",_mrkri] call EXT_fnc_hideMarker;_mrkri=_mrkri+1;}; _mrkri=1};
	_i=0;while {_i<_r} do {
		_d=random 360;
		_j=0;
		while {_j<(360/_dg)} do {
			_nP=[_x+_i *sin(_d),_y+_i *cos(_d),0];
			if(EXT_fl_debug)then{[format["pos_%1",_mrkri],_nP,"dot","blue"] call EXT_fnc_showMarker;_mrkri=_mrkri+1};
			_nZ= _nP call EXT_fnc_getTerrainHeightASL;
			if(_nZ<_z && _nZ>_sL)then{_zP=_nP;_z=_nZ;};
			_d=(_d+_dg) mod 360;
			_j=_j+1;
		};
		_i=_i+_s;
	};
	if(EXT_fl_debug && count _zP>0)then{[format["pos_%1",_mrkri-1],_zP,"dot","green",[2,2]] call EXT_fnc_showMarker;};
	_zP
};

comment{
FIND WATER
	Requires: EXT_fnc_inWater
	
	Description:
	Returns a position where there's water or an empty array if no position is found.
	
	Parameters:
		0: ARRAY - Starting position
		1 (Optional): NUMBER - Radius (default: 1000)
		2 (Optional): NUMBER - Step (default: 50)

	Returns:
	ARRAY - Position
};
EXT_fnc_findWater = {
	private ["_p","_r","_d","_i","_nP","_x","_y","_w","_s","_j","_dg","_mrkri"];
	_p=_this select 0;
	_r=if(count _this > 1)then{_this select 1}else{1000};
	_s=if(count _this > 2)then{_this select 2}else{50};
	_x=_p select 0;
	_y=_p select 1;
	_dg=45;
	_nP=_p;
	_w=[];
	if(EXT_fl_debug)then{_mrkri=1;while{_mrkri<500}do{format["pos_%1",_mrkri] call EXT_fnc_hideMarker;_mrkri=_mrkri+1;}; _mrkri=1};
	_i=0;while {_i<_r && count _w<1} do {
		_d=random 360;
		_j=0;
		while {_j<(360/_dg) && count _w<1} do {
			_nP=[_x+_i *sin(_d),_y+_i *cos(_d),0];
			if(EXT_fl_debug)then{[format["pos_%1",_mrkri],_nP,"dot","blue"] call EXT_fnc_showMarker;_mrkri=_mrkri+1};
			if([_nP,2.33] call EXT_fnc_inWater)then{_w=_nP};
			_d=(_d+_dg) mod 360;
			_j=_j+1;
		};
		_i=_i+_s;
	};
	if(EXT_fl_debug && count _w>0)then{[format["pos_%1",_mrkri-1],_w,"dot","green",[2,2]] call EXT_fnc_showMarker;};
	_w
};

comment{
FIND FLAT AREA
	Requires: EXT_fnc_isFlat
	
	Description:
	Returns a position where the terrain is more or less flat or an empty array if no position is found.
	Returned position might be in a forest, building or other structures
	
	Parameters:
		0: ARRAY - Starting position
		1 (Optional): NUMBER - Radius (default: 250)
		2 (Optional): NUMBER - Step (default: 15)
		3 (Optional): NUMBER - Tolerance (default: 2.5)

	Returns:
	ARRAY - Position
};
EXT_fnc_findFlatArea = {
	private ["_p","_r","_d","_i","_nP","_x","_y","_fP","_s","_t","_dg","_mrkri","_j"];
	_p=_this select 0;
	_r=if(count _this > 1)then{_this select 1}else{250};
	_s=if(count _this > 2)then{_this select 2}else{15};
	_t=if(count _this > 3)then{_this select 3}else{2.5};
	_x=_p select 0;
	_y=_p select 1;
	_dg=45;
	_nP=_p;
	_fP=[];
	_i=0;if(EXT_fl_debug)then{_mrkri=1;while{_mrkri<500}do{format["pos_%1",_mrkri] call EXT_fnc_hideMarker;_mrkri=_mrkri+1;}; _mrkri=1};
	while {_i<_r && count _fP<1} do {
		_d=random 360;
		_j=0;
		while {_j<(360/_dg) && count _fP<1} do {
			_nP=[_x+_i *sin(_d),_y+_i *cos(_d)];
			if(EXT_fl_debug)then{[format["pos_%1",_mrkri],_nP,"dot","blue"] call EXT_fnc_showMarker;_mrkri=_mrkri+1};
			if([_nP,10,_t] call EXT_fnc_isFlat)then{_fP=_nP};
			_d=(_d+_dg) mod 360;
			_j=_j+1;
		};
		_i=_i+_s;
	};
	if(EXT_fl_debug && count _fP>0)then{[format["pos_%1",_mrkri-1],_fP,"dot","green",[2,2]] call EXT_fnc_showMarker;};
	_fP
};

comment{
FIND SHORE
	Requires: EXT_fnc_inShore
	
	Description:
	Returns a position along the shore or an empty array if no position is found.
	
	Parameters:
		0: ARRAY - Starting position
		1 (Optional): NUMBER - Radius (default: 1000)
		2 (Optional): NUMBER - Step (default: 30)

	Returns:
	ARRAY - Position
};
EXT_fnc_findShore = {
	private ["_p","_r","_d","_i","_nP","_x","_y","_c","_s","_j","_dg","_mrkri"];
	_p=_this select 0;
	_r=if(count _this > 1)then{_this select 1}else{1000};
	_s=if(count _this > 2)then{_this select 2}else{30};
	_x=_p select 0;
	_y=_p select 1;
	_dg=45;
	_nP=_p;
	_c=[];
	if(EXT_fl_debug)then{_mrkri=1;while{_mrkri<500}do{format["pos_%1",_mrkri] call EXT_fnc_hideMarker;_mrkri=_mrkri+1;}; _mrkri=1};
	_i=0;while {_i<_r && count _c<1} do {
		_d=random 360;
		_j=0;
		while {_j<(360/_dg) && count _c<1} do {
			_nP=[_x+_i *sin(_d),_y+_i *cos(_d),0];
			if(EXT_fl_debug)then{[format["pos_%1",_mrkri],_nP,"dot","blue"] call EXT_fnc_showMarker;_mrkri=_mrkri+1};
			if(_nP call EXT_fnc_inShore)then{_c=_nP};
			_d=(_d+_dg) mod 360;
			_j=_j+1;
		};
		_i=_i+_s;
	};
	if(EXT_fl_debug && count _c>0)then{[format["pos_%1",_mrkri-1],_c,"dot","green",[2,2]] call EXT_fnc_showMarker;};
	_c
};

comment{
FIND LAND
	Requires: EXT_fnc_inWater
	
	Description:
	Returns a position without water or an empty array if no position is found.
	
	Parameters:
		0: ARRAY - Starting position
		1 (Optional): NUMBER - Radius (default: 1000)
		2 (Optional): NUMBER - Step (default: 50)

	Returns:
	ARRAY - Position
};
EXT_fnc_findLand = {
	private ["_p","_r","_d","_i","_nP","_x","_y","_l","_s","_j","_dg","_mrkri"];
	_p=_this select 0;
	_r=if(count _this > 1)then{_this select 1}else{1000};
	_s=if(count _this > 2)then{_this select 2}else{50};
	_x=_p select 0;
	_y=_p select 1;
	_dg=45;
	_nP=_p;
	_l=[];
	if(EXT_fl_debug)then{_mrkri=1;while{_mrkri<500}do{format["pos_%1",_mrkri] call EXT_fnc_hideMarker;_mrkri=_mrkri+1;}; _mrkri=1};
	_i=0;while {_i<_r && count _l<1} do {
		_d=random 360;
		_j=0;
		while {_j<(360/_dg) && count _l<1} do {
			_nP=[_x+_i *sin(_d),_y+_i *cos(_d),0];
			if(EXT_fl_debug)then{[format["pos_%1",_mrkri],_nP,"dot","blue"] call EXT_fnc_showMarker;_mrkri=_mrkri+1};
			if!([_nP,7] call EXT_fnc_inWater)then{_l=_nP};
			_d=(_d+_dg) mod 360;
			_j=_j+1;
		};
		_i=_i+_s;
	};
	if(EXT_fl_debug && count _l>0)then{[format["pos_%1",_mrkri-1],_l,"dot","green",[2,2]] call EXT_fnc_showMarker;};
	_l
};

comment{
FIND SAFE POS
	Requires: EXT_fnc_getTerrainHeightASL
	
	Description:
	Generates a position that is considered safe, according to several given parameters

	Parameters:
		0: ARRAY - Center position
		1: NUMBER - Minimum distance from center (default: 0)
		2: NUMBER - Maximum distance from center (default: 300)
		3: NUMBER - Minimum distance from nearest object (default: 20)
		4: NUMBER - Water mode (default: 0)
					0: cannot be in water
					1: can either be in water or not
					2: must be in water
		5: NUMBER - Maximum terrain gradient (average altitude difference in meters) (default: 2)
		6: NUMBER - Shore mode (default: 0)
					0: does not have to be at a shore
					1: must be at a shore
		7: NUMBER - Forest mode (default: 0)
					0: cannot be in a forest
					1: can either be in a forest or not
					2: must be at a forest

	Returns:
	ARRAY
};
EXT_fnc_findSafePos = {
	private ["_p","_r1","_r2","_od","_w","_g","_sh","_f","_safe","_i","_j","_x","_y","_nP","_d","_dg","_flat","_water","_shore","_objs","_obj","_objFine","_forest","_dist","_s","_mrkri","_tmpOd","_k","_fli","_prevFlat"];
	_p=_this select 0;
	_r1=if(count _this>1)then{_this select 1}else{0};
	_r2=if(count _this>2)then{_this select 2}else{300};
	_od=if(count _this>3)then{_this select 3}else{20};
	_w=if(count _this>4)then{_this select 4}else{0};
	_g=if(count _this>5)then{_this select 5}else{2};
	_sh=if(count _this>6)then{_this select 6}else{0};
	_f=if(count _this>7)then{_this select 7}else{0};
	_x=_p select 0;
	_y=_p select 1;
	_safe=[];
	_dg=45;
	_prevFlat=[0,0,0];
	_s=if(_r1>0)then{(_r2/_r1)}else{_r2/3};
	if(EXT_fl_debug)then{_mrkri=1;while{_mrkri<500}do{format["pos_%1",_mrkri] call EXT_fnc_hideMarker;_mrkri=_mrkri+1;}; _mrkri=1};
	_i=_r1; while {_i<_r2 && count _safe<1} do {
		_d=random 360;
		_j=0;
		while {_j<(360/_dg) && count _safe<1} do {
			_nP=[_x+_i *sin(_d),_y+_i *cos(_d),_p select 2];
			_flat=[];
			_fli=0;while{_fli<1 && count _flat<1}do{
				_flat=[_nP,_r2,15,_g] call EXT_fnc_findFlatArea;
				if(EXT_fl_debug)then{[format["pos_%1",_mrkri],_nP,"dot","blue"] call EXT_fnc_showMarker;_mrkri=_mrkri+1};
				_fli=_fli+1;
			};
			if(count _flat > 0)then{
				if((_flat select 0)!=(_prevFlat select 0) && (_flat select 1)!=(_prevFlat select 1))then{
					_prevFlat=_flat;
					_nP=_flat;
					_water=[_nP] call EXT_fnc_inWater;
					if((_water && _w!=0) || (!_water && _w!=2))then{
						_shore=_nP call EXT_fnc_inShore;
						if((_shore && _sh==1) || (!_shore && _sh==0))then{
							_forest=false;
							if(_f==0)then{
								if([_nP,true] call EXT_fnc_inForest)then{_forest=true};
							};
							if(!_forest)then{
								_objFine=true;
								if(_od>0)then{
									_objs=([_nP,[],50] call EXT_fnc_nearObjects);
									_k=0;while{_k<count _objs && _objFine}do{
										_obj=_objs select _k;
										_dist=([getpos _obj, _nP] call EXT_fnc_vectorDistance);
										if(_dist<=_od)then{_objFine=false};
										_k=_k+1;
									};
								};
								if(_objFine)then{
									_safe=_nP;
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
	if(EXT_fl_debug && count _safe>0)then{[format["pos_%1",_mrkri-1],_safe,"dot","green",[2,2]] call EXT_fnc_showMarker;};
	_safe
};