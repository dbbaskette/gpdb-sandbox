package io.pivotal.demo.sko;

import java.util.Properties;
import java.util.Random;

import com.gemstone.gemfire.cache.CacheWriterException;
import com.gemstone.gemfire.cache.Declarable;
import com.gemstone.gemfire.cache.EntryEvent;
import com.gemstone.gemfire.cache.util.CacheWriterAdapter;
import com.gemstone.gemfire.pdx.PdxInstance;

public class CheckTransactionLimitCacheWriter extends CacheWriterAdapter implements Declarable {

	static Random random = new Random();
	
	@Override
	public void beforeCreate(EntryEvent event) throws CacheWriterException {
		
		PdxInstance transaction = (PdxInstance)event.getNewValue();
		
		// randomly mark 0.2% of the transactions as suspicious
		if (random.nextDouble()<0.002){
			long transactionId;
			long deviceId;
			
			transactionId = ((Number)transaction.getField("id")).longValue();
			deviceId = ((Number)transaction.getField("deviceId")).longValue();
			
			Suspect suspect = new Suspect(transactionId, deviceId, System.currentTimeMillis(), "LIMIT");
			event.getRegion().getRegionService().getRegion(RegionName.Suspect.name()).put(transactionId, suspect);
			
		}
		
	}

	@Override
	public void init(Properties arg0) {
		// TODO Auto-generated method stub
		
	}

	
	
	
}
