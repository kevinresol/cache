package;

import tink.testrunner.*;
import tink.unit.*;
import tink.Chunk;
import why.cache.*;

class RunTests {
	static function main() {
		why.cache.Redis;
		
		Runner.run(TestBatch.make([
			new CacheTest(new Redis(Options({host: 'localhost', port: 6379}), Chunk.ofString, chunk -> Success(chunk.toString()))),
			new CacheTest(new Memory()),
		])).handle(Runner.exit);
	}
}