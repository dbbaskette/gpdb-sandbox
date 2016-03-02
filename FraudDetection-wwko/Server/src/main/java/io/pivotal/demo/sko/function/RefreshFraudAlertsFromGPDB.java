package io.pivotal.demo.sko.function;

import io.pivotal.demo.sko.RegionName;
import io.pivotal.gemfire.gpdb.service.GpdbService;
import io.pivotal.gemfire.gpdb.util.RegionFunctionAdapter;

import java.util.Properties;

import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import com.gemstone.gemfire.cache.Cache;
import com.gemstone.gemfire.cache.CacheFactory;
import com.gemstone.gemfire.cache.Declarable;
import com.gemstone.gemfire.cache.execute.RegionFunctionContext;

public class RefreshFraudAlertsFromGPDB extends RegionFunctionAdapter implements
		Declarable {

	private static final Logger log = LogManager.getLogger();
	public static final String ID = "RefreshFraudAlertsFromGPDB";

	
	@Override
	public boolean isHA() {
		return false;
	}

	@Override
	public String getId() {
		return ID;
	}
	
	

	@Override
	public void init(Properties props) {
	}	
	

	@Override
	public void execute(RegionFunctionContext arg0) {

		// load data for fraudulent transactions
		try{
			Cache cache = CacheFactory.getAnyInstance();
			GpdbService gpdb = GpdbService.getInstance(cache);
			long count = gpdb.importRegion(cache.getRegion(RegionName.Suspect.name()));
			log.info("Loaded "+count+" rows from GPDB on region "+RegionName.Suspect.name());		
			arg0.getResultSender().lastResult("Loaded "+count+" entities");
		}
		catch(Exception e){
			e.printStackTrace();
			log.error(e.getMessage());
		}
	}



}
