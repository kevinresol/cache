package why;

using tink.CoreApi;

interface Cache<T> {
	function set(key:String, value:T):Promise<Noise>;
	function setIfNotExists(key:String, value:T):Promise<Bool>; // return: true if set; false if not set because key already existed
	function get(key:String):Promise<Null<T>>;
	function remove(key:String):Promise<Noise>;
	// function increment(key:String, by:Int = 1):Promise<Int>;
	// function exists(key:String):Promise<Bool>;
}
