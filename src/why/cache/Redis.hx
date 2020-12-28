package why.cache;

import redis.*;
import tink.Chunk;
import why.Cache;

using tink.CoreApi;

enum RedisKind {
	Instance(redis:ioredis.Redis);
	Options(options:ioredis.RedisOptions);
}

class Redis<T> implements Cache<T> {
	final redis:ioredis.Redis;
	final serialize:T->Chunk;
	final unserialize:Chunk->Outcome<T, Error>;
	
	public function new(redis:RedisKind, serialize, unserialize) {
		this.redis = switch redis {
			case Instance(inst): inst;
			case Options(opt): cast new Ioredis(opt);
		}
		this.serialize = serialize;
		this.unserialize = unserialize;
	}
	
	public function get(key:String):Promise<Null<T>> {
		return Promise.ofJsPromise(redis.getBuffer(key))
			.next(buffer -> buffer == null ? Promise.NULL : unserialize(Chunk.ofBuffer(cast buffer)));
	}
	
	public function set(key:String, value:T):Promise<Noise> {
		return Promise.ofJsPromise(redis.setBuffer(key, cast serialize(value).toBuffer()));
	}
	
	public function remove(key:String):Promise<Noise> {
		return Promise.ofJsPromise(redis.del(key));
	}
}