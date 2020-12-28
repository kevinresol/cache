package;

import why.Cache;

@:asserts
class CacheTest {
	final cache:Cache<String>;
	
	public function new(cache) {
		this.cache = cache;
	}
	
	public function basic() {
		cache.set('key1', 'value1')
			.next(_ -> cache.get('key1'))
			.next(v -> asserts.assert(v == 'value1'))
			.next(_ -> cache.remove('key1'))
			.next(_ -> cache.get('key1'))
			.next(v -> asserts.assert(v == null))
			.handle(asserts.handle);
		
		return asserts;
	}
}