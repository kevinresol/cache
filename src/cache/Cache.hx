package cache;

import cache.Provider;

using tink.CoreApi;

class Cache implements Provider {
	
	var providers:Array<Provider>;
	
	public function new() {
		providers = [];
	}
	
	public function addProvider(provider:Provider) {
		if(providers.indexOf(provider) == -1) providers.push(provider);
	}
	
	public function set<T>(key:String, value:T, ?options:SetOptions):Surprise<Noise, Error> {
		
		return Future.ofMany([for(provider in providers) provider.set(key, value, options)]) >>
			function(outcomes:Array<Outcome<Noise, Error>>) {
				var success = null;
				var errors = [];
				for(o in outcomes) switch o {
					case Success(_): success = o;
					case Failure(err): errors.push(err);
				}
				return switch success {
					case null: Failure(Error.withData('error in set', errors));
					case v: v;
				}
			}
	}
	
	public function get<T>(key:String, ?options:GetOptions):Surprise<T, Error> {
	
		return Future.async(function(cb) {
			
			var iterator = providers.iterator();
			
			function handle(o) switch o {
				case Success(data): cb(o);
				case Failure(f): 
					if(iterator.hasNext())
						iterator.next().get(key, options).handle(handle);
					else
						cb(o);
			}
			
			iterator.next().get(key, options).handle(handle);
		});
	}
	
	public function increment(key:String, by = 1):Surprise<Int, Error> {
		return Future.ofMany([for(provider in providers) provider.increment(key, by)]) >>
			function(outcomes:Array<Outcome<Int, Error>>) {
				var success = null;
				var errors = [];
				for(o in outcomes) switch o {
					case Success(_): success = o;
					case Failure(err): errors.push(err);
				}
				return switch success {
					case null: Failure(Error.withData('error in increment', errors));
					case v: v;
				}
			}
	}
	
	public function exists(key:String):Surprise<Bool, Error> {
		throw 'not implemented';
	}
	
	public function remove(key:String):Surprise<Noise, Error> {
		return Future.ofMany([for(provider in providers) provider.remove(key)]) >>
			function(outcomes:Array<Outcome<Noise, Error>>) {
				var success = null;
				var errors = [];
				for(o in outcomes) switch o {
					case Success(_): success = o;
					case Failure(err): errors.push(err);
				}
				return switch success {
					case null: Failure(Error.withData('error in remove', errors));
					case v: v;
				}
			}
	}
	
}