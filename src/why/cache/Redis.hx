package why.cache;

import redis.*;
import tink.Chunk;
import why.Cache;
import tink.streams.Stream;
import tink.streams.RealStream;

using tink.CoreApi;

enum RedisKind {
	Instance(redis:ioredis.Redis);
	Options(options:ioredis.RedisOptions);
}

class Redis<T> implements Cache<T> {
	final redis:ioredis.Redis;
	final serialize:T->Chunk;
	final unserialize:Chunk->Outcome<T, Error>;
	final prefix:String;
	
	public function new(redis:RedisKind, serialize, unserialize, prefix = '') {
		this.redis = switch redis {
			case Instance(inst): inst;
			case Options(opt): cast new Ioredis(opt);
		}
		this.serialize = serialize;
		this.unserialize = unserialize;
		this.prefix = prefix;
	}
	
	public function list():RealStream<Pair<String, T>> {
		var cursor = null;
		
		return Stream.flatten(Generator.stream(function next(step) {
			Promise.ofJsPromise(redis.scan(cursor == null ? '0' : cursor, 'match', '$prefix*'))
				.next(tuple -> {
					if(cursor == '0') {
						(Promise.NULL:Promise<Pair<Array<String>, Array<String>>>);
					} else {
						cursor = tuple.element0;
						switch tuple.element1 {
							case []:
								Promise.resolve(new Pair([], []));
							case keys:
								Promise.ofJsPromise(redis.mget(keys)).next(values -> new Pair(tuple.element1, values));
						}
					}
				})
				.handle(function(o) switch o {
					case Success(null):
						step(End);
					case Success({a: keys, b: values}):
						final items = [for(i in 0...keys.length) unserialize(switch values[i] {
							case null: '';
							case v: v;
						}).map(v -> new Pair(keys[i], v))];
						
						step(Link(Stream.ofIterator(items.iterator()).map((outcome:Outcome<Pair<String, T>, Error>) -> outcome), Generator.stream(next)));
					case Failure(e):
						trace(e);
						step(Fail(e));
				});
		}));
	}
	
	public function get(key:String):Promise<Null<T>> {
		return Promise.ofJsPromise(redis.getBuffer(prefix + key))
			.next(buffer -> buffer == null ? (Promise.NULL:Promise<Null<T>>) : unserialize(Chunk.ofBuffer(cast buffer)));
	}
	
	public function set(key:String, value:T):Promise<Noise> {
		return Promise.ofJsPromise(redis.set(prefix + key, cast serialize(value).toBuffer()));
	}
	
	public function setIfNotExists(key:String, value:T):Promise<Bool> {
		return Promise.ofJsPromise(redis.setnx(prefix + key, cast serialize(value).toBuffer())).next(res -> res == 1);
	}
	
	public function remove(key:String):Promise<Noise> {
		return Promise.ofJsPromise(redis.del(prefix + key));
	}
}
