package;

import buddy.*;
import cache.provider.Memory;
import haxe.Timer;

using tink.CoreApi;
using buddy.Should;

class TestMemory extends BuddySuite {
	public function new() {
		describe('Test Cache', {
			
			var cache = new Memory();
			
			it('Set', function(done) {
				cache.set('my key', 'my value', {expiry: 800}).handle(function(o) switch o {
					case Success(_): done();
					case Failure(err): fail(err);
				});
			});
			
			it('Get', function(done) {
				cache.get('my key').handle(function(o) switch o {
					case Success(v): (v:String).should.be('my value'); done();
					case Failure(err): fail(err);
				});
			});
			
			it('Increment', function(done) {
				cache.increment('inc').handle(function(o) switch o {
					case Success(v): v.should.be(1); done();
					case Failure(err): fail(err);
				});
			});
			
			it('Increment N', function(done) {
				cache.increment('inc', 5).handle(function(o) switch o {
					case Success(v): v.should.be(6); done();
					case Failure(err): fail(err);
				});
			});
			
			it('Expired', function(done) {
				Timer.delay(function() {
					cache.get('my key').handle(function(o) switch o {
						case Success(v): (v:String).should.be(null); done();
						case Failure(err): fail(err);
					});
				}, 1100);
			});
		});
	}
}