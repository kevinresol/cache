package cache.provider;

import js.redis.*;
import cache.Provider;
using tink.CoreApi;

class Redis implements Provider {
	
	var client:RedisClient;
	
	public function new(?url:String) {
		client = js.redis.Redis.createClient({url: url});
	}
	
	public function set<T>(key:String, value:T, ?options:SetOptions):Surprise<Noise, Error> {
		return Future.async(function(cb) {
			client.set(key, Std.string(value), function(err, _) cb(err == null ? Success(Noise) : Failure(Error.withData('Redis error', err))));
		});
	}
	
	public function get<T>(key:String, ?options:GetOptions):Surprise<T, Error> {
		return Future.async(function(cb) {
			client.get(key, function(err, val) cb(err == null ? Success(val) : Failure(Error.withData('Redis error', err))));
		});
	}
	
	public function exists(key:String):Surprise<Bool, Error> {
		return Future.async(function(cb) {
			client.exists(key, function(err, val) cb(err == null ? Success(val == 1) : Failure(Error.withData('Redis error', err))));
		});
	}
	
	public function remove(key:String):Surprise<Noise, Error> {
		return Future.async(function(cb) {
			client.del(key, function(err, _) cb(err == null ? Success(Noise) : Failure(Error.withData('Redis error', err))));
		});
	}
}