package org.ihc.itf;

import java.util.Properties;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.rmi.PortableRemoteObject;

public class PhcWebEjb {

	/**
	 * @param args
	 */
	public static void main(String[] args) {

		String url = "t3://tacwebservices-dev.co.ihc.com:9103";
		System.out.println("Create SubscriptionServicePhcWebEjb");

		PhcWebEjb p = new PhcWebEjb();

		  System.out.println("SendData to url: " + url); 
		  try { boolean stat =
		  p.sendDataToSubscriptionService(556833599, 570083858, url);
		 System.out.println("Stat: " + stat); 
		 } 
		  catch (Exception e) {
		  
		  e.printStackTrace(); }
		 
		url = "t3://tacwebservices-test.co.ihc.com:9103";
		System.out.println("Create TelepatientPhcWebEjb");
		System.out.println("SendData to UTL: " + url);
		try {
			boolean stat = p.sendDataToTelepatient(556833599, 570083858, url);
			System.out.println("Stat: " + stat);
		} catch (Exception e) {
			e.printStackTrace();
		}

	}

	public Boolean sendDataToSubscriptionService(int val1, int val2, String url)
			throws Exception {
		boolean mergeStatus = false;
		Properties environment = new Properties();
		environment.put("java.naming.factory.initial",
				"weblogic.jndi.WLInitialContextFactory");

		environment.put("java.naming.provider.url", url);
		Context context;

		context = new InitialContext(environment);
		org.ihc.subscriptionservice.merge.MergeRemoteHome home = (org.ihc.subscriptionservice.merge.MergeRemoteHome) PortableRemoteObject
				.narrow(context
						.lookup("org.ihc.subscriptionservice.merge.MergeRemoteHome"),
						org.ihc.subscriptionservice.merge.MergeRemoteHome.class);
		if (home != null) {
			org.ihc.subscriptionservice.merge.MergeRemote remote = home
					.create();
			if (remote != null) {
				try {
					// System.out.println("Created MergeRemote");
					mergeStatus = remote.merge(new Integer(val1), new Integer(
							val2));
					// System.out.println("******* subscriptionservice merge complete *******" + mergeStatus);
				} catch (Exception e) {

					e.printStackTrace();
					throw e;
				}
			} else {
				throw new Exception(
						"Can't create org.ihc.telepatient.merge.MergeRemote: ");
			}
		} else {
			throw new Exception("org.ihc.telepatient.merge.MergeRemoteHome");
		}

		return mergeStatus;

	}

	public Boolean sendDataToTelepatient(int val1, int val2, String url)
			throws Exception {
		boolean mergeStatus = false;
		Properties environment = new Properties();
		environment.put("java.naming.factory.initial",
				"weblogic.jndi.WLInitialContextFactory");

		environment.put("java.naming.provider.url", url);
		Context context;

		context = new InitialContext(environment);
		org.ihc.telepatient.merge.MergeRemoteHome home = (org.ihc.telepatient.merge.MergeRemoteHome) PortableRemoteObject
				.narrow(context
						.lookup("org.ihc.telepatient.merge.MergeRemoteHome"),
						org.ihc.telepatient.merge.MergeRemoteHome.class);
		if (home != null) {
			org.ihc.telepatient.merge.MergeRemote remote = (org.ihc.telepatient.merge.MergeRemote) home
					.create();
			if (remote != null) {
				try {
					mergeStatus = remote.merge(new Integer(val1), new Integer(
							val2));
					// System.out.println("******* telepatient merge complete *******" + mergeStatus);
				} catch (Exception e) {

					e.printStackTrace();
					throw e;
				}
			} else {
				throw new Exception(
						"Can't create org.ihc.telepatient.merge.MergeRemote");
			}
		} else {
			throw new Exception("org.ihc.telepatient.merge.MergeRemoteHome");
		}

		return mergeStatus;

	}

}
