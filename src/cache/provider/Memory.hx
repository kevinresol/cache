package cache.provider;

import haxe.Timer;
import cache.Provider;
using tink.CoreApi;

class Memory<T> implements Provider<T> {
	
	var map:Map<String, {value:T, expiry:Float}>;
	var noiseSurprise:Surprise<Noise, Error>;
	var trueSurprise:Surprise<Bool, Error>;
	var falseSurprise:Surprise<Bool, Error>;
	var clearInterval:Int;
	
	public function new(clearInterval = 1000) {
		map = new Map();
		noiseSurprise = Future.sync(Success(Noise));
		trueSurprise = Future.sync(Success(true));
		falseSurprise = Future.sync(Success(false));
		clearExpired();
	}
	
	public function set(key:String, value:T, ?options:SetOptions):Surprise<Noise, Error> {
		var expiry = options != null && options.expiry != null ? getTime() + options.expiry : null;
		map.set(key, {value: value, expiry: getTime() + options.expiry});
		return noiseSurprise;
	}
	
	public function get(key:String, ?options:GetOptions):Surprise<T, Error> {
		return Future.sync(Success(switch map.get(key) {
			case null: null;
			case v: v.value;
		}));
	}
	
	public function exists(key:String):Surprise<Bool, Error> {
		return map.exists(key) ? trueSurprise : falseSurprise;
	}
	
	public function remove(key:String):Surprise<Noise, Error> {
		map.remove(key);
		return noiseSurprise; 
	}
	
	function clearExpired() {
		var now = getTime();
		for(key in map.keys())
			if(now > map[key].expiry)
				map.remove(key);
		Timer.delay(clearExpired, clearInterval);
	}
	
	inline function getTime() {
		return Date.now().getTime();
	}
}