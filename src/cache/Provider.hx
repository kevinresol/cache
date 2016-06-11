package cache;

using tink.CoreApi;

interface Provider {
	function set<T>(key:String, value:T, ?options:SetOptions):Surprise<Noise, Error>;
	function get<T>(key:String, ?options:GetOptions):Surprise<T, Error>;
	function exists(key:String):Surprise<Bool, Error>;
	function remove(key:String):Surprise<Noise, Error>;
}

typedef GetOptions = Dynamic;
typedef SetOptions = {
	
	/** Expiry in milliseconds **/
	var expiry:Int;
};