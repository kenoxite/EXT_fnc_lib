comment{
Sanjo's SQF Library [ALPHA]
by
Sanjo

Description:
	A Library with helpful reusable SQF code written by me.
	Each component can be used independently from other components, if not stated otherwise.
	The code is licensed under the MIT license (see LICENSE file).
};

comment{
NEW
	Description:
	Returns a new empty dictionary.
	
	Returns:
		ARRAY
		
	Example 1:
	_myDictionary = call Dictionary_fnc_new
};
Dictionary_fnc_new={
	[
		[], // Keys
		[]  // Values
	]
};

comment{
GET
	Description:
	Returns the value of the key or objNull if the key doesn't exist.

	Parameters:
		0: ARRAY - Dictionary
		1: STRING - Key
		
	Returns:
		ANY
		
	Example 1:
	[_myDictionary, _myKey] call Dictionary_fnc_get
};
Dictionary_fnc_get={
	private ["_key", "_keys", "_values", "_keyIndex"];

	_key = _this select 1;
	_this = _this select 0;
	_keys = _this select 0;
	_values = _this select 1;

	_keyIndex = _keys find _key;

	if (_keyIndex == -1) then { objNull }
	else { _values select _keyIndex }
};

comment{
SET
	Description:
	Sets the key to a new value. Overwrites the previous value if the key already existed.

	Parameters:
		0: ARRAY - Dictionary
		1: ANY - New key
		2: ANY - New value
		
	Returns:
		
	Example 1:
	[_myDictionary, _myNewKey, _myNewValue] call Dictionary_fnc_set
};
Dictionary_fnc_set={
	private ["_key", "_value", "_keys", "_values", "_keyIndex"];

	_key = _this select 1;
	_value = _this select 2;
	_this = _this select 0;
	_keys = _this select 0;
	_values = _this select 1;

	_keyIndex = _keys find _key;
	if (_keyIndex == -1) then {
		_keysCount = count _keys;
		_keys set [_keysCount, _key];
		_values set [_keysCount, _value];
	} else {
		_values set [_keyIndex, _value];
	};
};

comment{
REMOVE
	Description:
	Removes a key from the dictionary.

	Parameters:
		0: ARRAY - Dictionary
		1: ANY - Key to remove
		
	Example 1:
	_oldValue = [_myDictionary, _keyToRemove] call Dictionary_fnc_remove
};
Dictionary_fnc_remove={
	private ["_key", "_keys", "_values", "_keyIndex"];

	_key = _this select 1;
	_this = _this select 0;
	_keys = _this select 0;
	_values = _this select 1;

	_keyIndex = _keys find _key;
	if (_keyIndex == -1) then {
		objNull
	} else {
		_value = _values select _keyIndex;
		_newKeys = [];
		_newValues = [];
		_newDictionaryLength = 0;
		for "_i" from 0 to (count _keys - 1) do
		{
			if (_i != _keyIndex) then
			{
				_newKeys set [_newDictionaryLength, _keys select _i];
				_newValues set [_newDictionaryLength, _values select _i];
				_newDictionaryLength = _newDictionaryLength + 1;
			};
		};
		_this set [0, _newKeys];
		_this set [1, _newValues];
		
		_value
	}
};

comment{
ISEMPTY
	Description:
	Returns true if the dictionary is empty.

	Parameters:
		ARRAY - Dictionary
		
	Returns:
		BOOL
		
	Example 1:
	_isDictionaryEmpty = _myDictionary call Dictionary_fnc_isEmpty
};
Dictionary_fnc_isEmpty={
	private ["_keys"];

	_keys = _this select 0;

	count _keys == 0
};

comment{
CONTAINSKEY
	Description:
	Returns true if the dictionary contains the key.

	Parameters:
		0: ARRAY - Dictionary
		1: ANY - Key
		
	Returns:
		BOOL
		
	Example 1:
	_dictionaryContainsKey = [_myDictionary, _myKey] call Dictionary_fnc_containsKey
};
Dictionary_fnc_containsKey={
	private ["_key", "_keys"];

	_key = _this select 1;
	_this = _this select 0;
	_keys = _this select 0;

	_key in _keys
};

comment{
CONTAINSVALUE
	Description:
	Returns true if the dictionary contains the value.

	Parameters:
		0: ARRAY - Dictionary
		1: ANY - Value
		
	Returns:
		BOOL
		
	Example 1:
	_dictionaryContainsValue = [_myDictionary, _myValue] call Dictionary_fnc_containsValue
};
Dictionary_fnc_containsValue={
	private ["_value", "_values"];

	_value = _this select 1;
	_this = _this select 0;
	_values = _this select 1;

	_value in _values
};

comment{
SIZE
	Description:
	Returns the number of elements in the dictionary.

	Parameters:
		ARRAY - Dictionary
		
	Returns:
		NUMBER
		
	Example 1:
	_count = _myDictionary call Dictionary_fnc_size
};
Dictionary_fnc_size={
	private ["_keys"];

	_keys = _this select 0;

	count _keys
};

comment{
KEYS
	Description:
	Returns the keys as an array.

	Parameters:
		ARRAY - Dictionary
		
	Returns:
		ARRAY
		
	Example 1:
	_keys = _myDictionary call Dictionary_fnc_keys
};
Dictionary_fnc_keys={
	private ["_keys"];

	_keys = _this select 0;

	+_keys
};

comment{
VALUES
	Description:
	Returns the values as an array.

	Parameters:
		ARRAY - Dictionary
		
	Returns:
		ARRAY
		
	Example 1:
	_values = _myDictionary call Dictionary_fnc_values
};
Dictionary_fnc_values={
	private ["_values"];

	_values = _this select 1;

	+_values
};