package cache;

import cache.Provider;

using tink.CoreApi;

class Cache<T> implements Provider<T> {
	
	var providers:Array<Provider<T>>;
	
	public function new() {
		providers = [];
	}
	
	public function addProvider(provider:Provider<T>) {
		if(providers.indexOf(provider) == -1) providers.push(provider);
	}
	
	public function set(key:String, value:T, ?options:SetOptions):Surprise<Noise, Error> {
		
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
	
	public function get(key:String, ?options:GetOptions):Surprise<T, Error> {
	
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