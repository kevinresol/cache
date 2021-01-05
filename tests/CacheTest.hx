package;

import why.Cache;

using tink.CoreApi;

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
	
	public function list() {
		Promise.inSequence([for(i in 0...10) cache.set('key$i', 'value$i')])
			.next(_ -> cache.list().collect())
			.next(list -> {
				list.sort((v1, v2) -> Reflect.compare(v1.a, v2.a));
				for(i in 0...10) {
					asserts.assert(list[i].a == 'key$i');
					asserts.assert(list[i].b == 'value$i');
				}
				asserts.assert(list.length == 10);
			})
			.handle(asserts.handle);
		
		return asserts;
	}
}