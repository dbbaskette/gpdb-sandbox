package io.pivotal.demo.sko.function;

import java.util.Properties;

import com.gemstone.gemfire.LogWriter;
import com.gemstone.gemfire.cache.Cache;
import com.gemstone.gemfire.cache.CacheFactory;
import com.gemstone.gemfire.cache.Declarable;
import com.gemstone.gemfire.cache.Region;
import com.gemstone.gemfire.cache.execute.FunctionService;
import com.gemstone.gemfire.cache.execute.RegionFunctionContext;

import io.pivotal.demo.sko.RegionName;
import io.pivotal.gemfire.gpdb.functions.GpdbShareFunction;
import io.pivotal.gemfire.gpdb.operations.ShareOperation;
import io.pivotal.gemfire.gpdb.service.GpdbService;
import io.pivotal.gemfire.gpdb.util.SingletonRegionFunctionAdapter;

public final class ShareAll extends SingletonRegionFunctionAdapter implements Declarable {

	private static final String ID = "ShareAll";

	@Override
	protected void executeSingleton(RegionFunctionContext context) {
		Cache cache = CacheFactory.getAnyInstance();
		LogWriter log = cache.getLogger();

		GpdbService gpdb = GpdbService.getInstance(cache);
		StringBuffer sb = new StringBuffer();
		sb.append("Linking GemFire & GPDB for region");
		for (RegionName n : RegionName.values()) {
			Region region = cache.getRegion(n.name());
			FunctionService.onRegion(region).withArgs(ShareOperation.Mode.READWRITE).execute(GpdbShareFunction.ID);
			sb.append(" : ");
			sb.append(region.getName());		
		}
		log.info(sb.toString());
		context.getResultSender().lastResult(sb.toString());

	}

	@Override
	public String getId() {
		return ID;
	}

	@Override
	public void init(Properties arg0) {
	}

	@Override
	public boolean isHA() {
		return false;
	}

	@Override
	public boolean hasResult() {
		return true;
	}

}
