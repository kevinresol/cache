package why.cache;

import why.Cache;
import tink.streams.Stream;
import tink.streams.RealStream;

using tink.CoreApi;

class Memory<T> implements Cache<T> {
	
	final map:Map<String, T>;
	
	public function new() {
		map = [];
	}
	
	public function list():RealStream<Pair<String, T>> {
		return Stream.ofIterator([for(key => value in map) new Pair(key, value)].iterator());
	}
	
	public function set(key:String, value:T):Promise<Noise> {
		map.set(key, value);
		return Promise.NOISE;
	}
	
	public function setIfNotExists(key:String, value:T):Promise<Bool> {
		// TODO: not thread-safe
		return if(map.exists(key)) {
			false;
		} else {
			map.set(key, value);
			true;
		}
	}
	
	public function get(key:String):Promise<Null<T>> {
		return map.get(key);
	}
	
	public function remove(key:String):Promise<Noise> {
		map.remove(key);
		return Promise.NOISE;
	}
}