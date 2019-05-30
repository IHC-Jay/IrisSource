package org.ihc.itf.cdr;

public class CdrStringAddUpdate extends CdrTuxServices {

	
	public CdrStringAddUpdate(String applicationAddress, String serviceName) throws Exception
	{
		super(applicationAddress, serviceName);
	}
	
	public String callAddUpdate(String data) throws Exception {
	
		setRequestString(data);
		callService();
		return getResponseString();

		
	}
	
}
