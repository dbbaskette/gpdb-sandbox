package io.pivotal.demo.sko;

public class Suspect {

	private long transactionId;
	private long deviceId;
	private long markedSuspectMillis;
	private String reason;

	
	public Suspect(){		
	}
	
	public Suspect(long transactionId, long deviceId, long markedSuspectMillis,
			String reason) {
		super();
		this.transactionId = transactionId;
		this.deviceId = deviceId;
		this.markedSuspectMillis = markedSuspectMillis;
		this.reason = reason;
	}

	public String getReason() {
		return reason;
	}

	public void setReason(String reason) {
		this.reason = reason;
	}

	public long getTransactionId() {
		return transactionId;
	}

	public void setTransactionId(long transactionId) {
		this.transactionId = transactionId;
	}

	public long getMarkedSuspectMillis() {
		return markedSuspectMillis;
	}

	public void setMarkedSuspectMillis(long markedSuspectMillis) {
		this.markedSuspectMillis = markedSuspectMillis;
	}

	public long getDeviceId() {
		return deviceId;
	}

	public void setDeviceId(long deviceId) {
		this.deviceId = deviceId;
	}
	
	
	
	
}
