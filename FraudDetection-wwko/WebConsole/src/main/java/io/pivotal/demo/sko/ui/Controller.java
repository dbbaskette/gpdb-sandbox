package io.pivotal.demo.sko.ui;


import io.pivotal.demo.sko.util.GeodeClient;
import io.pivotal.demo.sko.util.TransactionsMap;

import org.springframework.stereotype.Component;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.RestController;

@Component
@RestController
@RequestMapping(value = "/controller")
public class Controller {
    
	static GeodeClient client;
	static{
        client = GeodeClient.getInstance();
        client.setup();
	}
	
    public Controller() {
    }
    
 
    @RequestMapping(value="/getTransactionsMap")
    public @ResponseBody TransactionsMap getDeviceMap(){

    	TransactionsMap latestTransactions = TransactionsMap.latestTransactions;
    	synchronized (latestTransactions) {
			TransactionsMap map = new TransactionsMap(latestTransactions.getTransactions());
			latestTransactions.clearAll();
	        return map;
		}
    	

    }    
    
    
    @RequestMapping(value="/getSuspeciousTransactionsMap")
    public @ResponseBody TransactionsMap getSuspeciousMap(){
    	TransactionsMap suspeciousTransactions = TransactionsMap.suspiciousTransactions;
    	synchronized (suspeciousTransactions) {
			TransactionsMap map = new TransactionsMap(suspeciousTransactions.getTransactions());
			suspeciousTransactions.clearAll();
	        return map;
		}

    }    
    

    @RequestMapping(value="/refreshFraudAlertsFromGPDB")
    public  void refreshFraudAlertsFromGPDB(){
    	GeodeClient.getInstance().refreshFraudAlertsFromGPDB();
    }    
       
    
    
    
}