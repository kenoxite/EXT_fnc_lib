
EXT_fnc_inForest_test = {
	private["_p","_r"];
	_p=_this select 0;
	_r=if(count _this>1)then{_this select 1}else{10};
	!(isNull(_p call EXT_fnc_nearestForest))
};
EXT_fnc_isForestSimple_test={
	private["_f","_o","_i","_z"];
	_f=false;
	_i=0;
	while {_i<count _this && !_f} do {
		_o=_this select _i;
		_z=getPos _o select 2;
		if((typeOf _o)=="" && ((_z >= 18.0418 && _z <= 23.1900) || (_z >= 25.8946 && _z <= 28.5844) || (_z >= 23.4063 && _z <= 24.344) || (_z >= 11.6016 && _z <= 12.7339)))then{_f=true};
		_i=_i+1;
	};
	_f
};

EXT_fnc_nearestObject_test={
	private ["_p","_o","_nO","_x","_y","_i","_d","_s","_r","_t","_tmpO","_dist","_tmpDist","_tO","_dg"];
	_p=_this select 0;
	_t=_this select 1;
	_r=if(count _this>2)then{_this select 2}else{25};
	_dg=45;
	_x=_p select 0;
	_y=_p select 1;
	_o=objNull;
	_dist=9999;
	_i=0;
	while {_i<_r} do {
		_d=0;
		while {_d<360} do {
			_nO=nearestObject [_x+_i *sin(_d),_y+_i *cos(_d),7];
			_tO=typeOf _nO;
			_tmpO=objNull;
			_tmpDist=-1;
			if(_nO!=_o && (speed _nO < 40) && !(_tO in EXT_fl_nAIv))then{
				if(_t=="forest")then{
					if([_nO] call EXT_fnc_isForestSimple)then{
						_tmpO=_nO;
					};
				}else{
					if(_t=="road")then{
						if((getPos _nO select 2)<=0 && _tO=="")then{
							_tmpO=_nO;
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
			};
			if(!isNull _tmpO)then{
				_tmpDist=[getpos _tmpO,_p] call EXT_fnc_vectorDistance;
				if (_tmpDist<_dist)then{
					_dist=_tmpDist;
					_o=_tmpO;
				};
			};
			_d=_d+_dg;
		};
		_i=_i+(_r/3);
	};
	_o
};