
comment{
TERRAIN GRAD ANGLE
	Description:
	Returns the gradient angle (in radians) of the terrain at a specified position and a compass direction. It is an angle of the slope of a tangent plane to the terrain at the specified position in the specified direction.

	Parameters:
		0: OBJECT or ARRAY - object or its position
		1: NUMBER - direction where should be gradient calculated (compass direction)
		2: NUMBER (optional) - which stepsize should be used

	Returns:
	NUMBER
	
	Example: [getPos player, getDir player] call EXT_fnc_terrainGradAngle
};
EXT_fnc_terrainGradAngle = {
	private["_p","_d","_s"];
	
	((_this select 0)select 2) atan2 ((_this select 1)select 2)
};


comment{
GET POSITION ASL
	Description:
	Returns the object position above sea level

	Parameters:
		OBJECT - Object to check
	
	Returns:
		ARRAY - Position converted to ASL
};
EXT_fnc_getPosASL={
	private["_p","_asl","_ss"];
	_p=getpos _this;
	_ss="EmptyDetector" camCreate [0,0,0];
	_ss setpos [_p select 0, _p select 1, 0];
	_asl=[_p select 0, _p select 1, (_p select 2)-(getpos _ss select 2)];
	camdestroy _ss;
	_asl
};

comment{
SET POSITION ASL
	Description:
	Sets the object position height above sea level

	Parameters:
		0: OBJECT - Object to set
		1: ARRAY - New position
};
EXT_fnc_setPosASL={
	private["_p1","_p2","_o","_asl","_ss"];
	_o=_this select 0;
	_p1=_this select 1;
	_ss="EmptyDetector" camCreate [0,0,0];
	_ss setpos _p1;
	_p2=_ss call EXT_fnc_getPosASL;
	_asl=[_p2 select 0, _p2 select 1, (_p2 select 2)];
	camdestroy _ss;
	_o setPos _asl;
};


EXT_fnc_nearestObjects={
	private ["_p","_o","_nO","_x","_y","_z","_i","_d","_dg","_r","_t","_j","_t1","_tO","_e","_k","_tmpO"];
	_p=_this select 0;
	_t=_this select 1;
	_r=if(count _this>2)then{_this select 2}else{25};
	_e=if(count _this>3)then{_this select 3}else{[]};
	_dg=45;
	_x=_p select 0;
	_y=_p select 1;
	_z=_p select 2;
	_o=[];
	_i=0;while {_i<_r} do {
		_d=0;
		while {_d<360} do {
			_nO=nearestObject [_x+_i *sin(_d),_y+_i *cos(_d),7];
			if(!isNull _nO)then{
				_tO=typeOf _nO;
				if !(_tO in EXT_fl_nAIv)then{
					_tmpO=objNull;
					if(!(_nO in _o) && (speed _nO<40))then{
						if(count _t>0)then{
							_j=0;
							while {_j<count _t} do {
								_t1=_t select _j;
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
								_j=_j+1;
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
								_o=_o+[_tmpO];
							};
						};
					};
				};
			};
			_d=_d+_dg;
		};
		_i=_i+(_r/3);
	};
	if(count _o>1)then{[_o,_p] call EXT_fnc_sortByDistance}else{_o}
};