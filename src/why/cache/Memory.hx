package why.cache;

import why.Cache;

using tink.CoreApi;

class Memory<T> implements Cache<T> {
	
	final map:Map<String, T>;
	
	public function new() {
		map = [];
	}
	
	public function set(key:String, value:T):Promise<Noise> {
		map.set(key, value);
		return Promise.NOISE;
	}
	
	public function get(key:String):Promise<Null<T>> {
		return map.get(key);
	}
	
	public function remove(key:String):Promise<Noise> {
		map.remove(key);
		return Promise.NOISE;
	}
}