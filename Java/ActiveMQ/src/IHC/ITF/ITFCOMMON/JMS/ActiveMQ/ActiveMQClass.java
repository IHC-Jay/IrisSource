package IHC.ITF.ITFCOMMON.JMS.ActiveMQ;

import java.io.UnsupportedEncodingException;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Set;

import javax.jms.BytesMessage;
import javax.jms.Connection;
import javax.jms.DeliveryMode;
import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageConsumer;
import javax.jms.MessageProducer;
import javax.jms.Session;
import javax.jms.StreamMessage;
import javax.jms.TextMessage;

import org.apache.activemq.ActiveMQConnectionFactory;
import org.apache.activemq.ActiveMQSession;
import org.apache.activemq.command.ActiveMQBlobMessage;
import org.apache.log4j.BasicConfigurator;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import org.ihc.itf.util.ItfLogger;

public class ActiveMQClass {

	private ActiveMQConnectionFactory factory = null;
	private Connection connection = null;
	private ActiveMQSession session = null;
	private Destination destination = null;
	private MessageProducer producer = null;
	private MessageConsumer consumber = null;
	public static Logger log = null;
	private Message message = null;

	public ActiveMQClass(String url, String qName, String logFileNm, int debug)
			throws Exception {
		if(log == null)
		{
			log = ItfLogger.setLoggerProperties(logFileNm, (debug == 1) ? true
				: false);
		}
		log.debug("ItfLogger initialized: " + url);
		createActiveMQClass(url, qName);
	}

	public ActiveMQClass(String url, String qName) throws JMSException {

		log = Logger.getLogger(ActiveMQClass.class);
		BasicConfigurator.configure();
		log.setLevel(Level.DEBUG);
		createActiveMQClass(url, qName);
	}

	private void createActiveMQClass(String url, String qName)
			throws JMSException {

		try {
			// log.debug("createActiveMQClass");
			factory = new ActiveMQConnectionFactory(url);

			connection = factory.createConnection();
			connection.start();
			log.debug("Start factory connection to :" + url);

			session = (ActiveMQSession) connection.createSession(false,
					Session.CLIENT_ACKNOWLEDGE);
			// log.debug("Created a session");

			destination = session.createQueue(qName);
			log.debug("Created a queue for: " + qName);
		} catch (JMSException ex) {
			log.fatal("Exception: " + ex.getMessage());
			throw ex;
		}

	}
	
	public void sendMsg(byte[] msg, HashMap<String, String> hmap) throws JMSException {
		BytesMessage message = session.createBytesMessage();
		message.writeBytes(msg);
		if(hmap != null)
		{
			Set<Entry<String, String>> set = hmap.entrySet();
			Iterator<Entry<String, String>> iterator = set.iterator();
			while(iterator.hasNext()) {
	    	  Map.Entry<String, String> mentry = (Map.Entry<String, String>)iterator.next();
	    	  message.setStringProperty((String)mentry.getKey(), (String)mentry.getValue());
			}
		}
		producer.send(message);
		log.debug("Sent Bytes message");
	}

	public void CloseActiveMQ() throws JMSException

	{

		log.debug("CloseActiveMQ session isRunning " + session.isRunning() + ", session isClosed " + session.isClosed() + ", connection Client ID: " + connection.getClientID());

		if (producer != null) {
			producer.close();
		}
		if (consumber != null) {
			consumber.close();
		}
		session.close();
		connection.close();
		factory = null;
	}

	public ActiveMQSession GetActiveMQSession() throws JMSException {

		return session;

	}

	public void CreateConsumer() throws JMSException {

		consumber = session.createConsumer(destination);

	}

	public void CreateProducer() throws JMSException {

		producer = session.createProducer(destination);
		producer.setDeliveryMode(DeliveryMode.PERSISTENT);

	}

	public void sendMsg(String msg) throws JMSException {
		TextMessage message = session.createTextMessage();
		message.setText(msg);
		sendMsg(message);
	}

	public void sendMsg(TextMessage message) throws JMSException {

		if (session.isRunning()) {

			log.debug("Time to live: " + producer.getTimeToLive());
			producer.send(message);
			log.debug("Sent message");

		} else {
			CloseActiveMQ();
			throw new JMSException("Re initialize the JMS queue");
		}
	}
	
	
	
	public String recvMsg() throws JMSException, UnsupportedEncodingException {
		HashMap<String, byte[]> hmap = recvMsgWithProperties();
		String msg = new String(hmap.get("Message"));
		return (msg);
	}

	public HashMap<String, byte[]> recvMsgWithProperties() throws JMSException, UnsupportedEncodingException {

		
		HashMap<String, byte[]> hmap = new HashMap<String, byte[]>();

		byte[] byteArr = null;

		log.debug("In recvMsgWithProperties with receiveNoWait: " + session.isRunning());
		if (!session.isRunning()) {
			CloseActiveMQ();
			throw new JMSException("Re initialize the JMS queue");
		}
		message = consumber.receiveNoWait();
		
		if(message == null)
		{
			log.debug("consumber.receive(5000)");
			message = consumber.receive(5000);
			if(message == null)
			{
				log.debug("message is null");
				hmap.put("Message", null);
				return hmap;
			}
		}
		if(message != null)
		{
			// List all properties
			log.debug("Properties: ");
				Enumeration<String> e = (Enumeration<String>) message.getPropertyNames();
				
				while (e.hasMoreElements()) {
				  String name = e.nextElement();
				  hmap.put(name, message.getStringProperty(name).getBytes());
				  log.debug("Property: " + name + ", " + message.getStringProperty(name));
				}
		}
		if (message instanceof BytesMessage) {
			log.debug("BytesMessage message of length: " + (int)((BytesMessage) message).getBodyLength());
			byteArr = new byte[(int)((BytesMessage) message).getBodyLength()];
			((BytesMessage) message).readBytes(byteArr);
			log.debug("byte array:" + byteArr.length);
		}
		else if (message instanceof TextMessage) {
			log.debug("Received a TextMessage" );
			byteArr = ((TextMessage) message).getText().getBytes();
		} else if (message instanceof ActiveMQBlobMessage) {
			log.debug("Blob message");

			ActiveMQBlobMessage blobMessage = (ActiveMQBlobMessage) message;

			log.debug("URL: " + blobMessage.getRemoteBlobUrl());

		} else if (message instanceof StreamMessage) {
			log.debug("Stream message");
			byte[] buffer = new byte[2048];
			StreamMessage smsg = (StreamMessage) message;
			int c = smsg.readBytes(buffer);

			String tempStr = new String(buffer, 0, c);
			byteArr = tempStr.getBytes();

		}
		
		else
		{
			log.debug("Other message: " + message);
		
		}

		log.debug("Message length: " + byteArr.length);
		hmap.put("Message", byteArr);
		return hmap;
	}
	public void AckMsg() throws JMSException
	{
	   if (message != null)
	   {
		  log.debug("Ack message"); 
	      message.acknowledge();
	      message = null;
	      log.debug("Acked message"); 
	   }
	}


	public static void main(String[] args) throws Exception {

		try {
			// ActiveMQClass actObj = new ActiveMQClass(
			//		"tcp://webitfmsg-test.co.ihc.com:5671", "Q_IMH_SH_835_TransTracking", "c:\\Temp\\ActMQ.txt", 1);
			ActiveMQClass actObj = new ActiveMQClass(
					"tcp://webitfmsg-dev.co.ihc.com:61616", "test", "c:\\Temp\\ActMQ.txt", 1);
			actObj.CreateConsumer();
			// actObj.CreateProducer();

			// actObj.sendMsg("Hello ...This is a sample message 112..sending from FirstClient");
			// System.out.println( actObj.recvMsg());

			// actObj.sendBlob();
			// Thread.sleep(1000);
			// System.out.println( actObj.recvStreamMsg());
			int numMsg=0;
			while(true)
			{
				HashMap<String, byte[]> hm  = actObj.recvMsgWithProperties();
				log.debug("Main: Received Hash: " + hm.size());
				if(hm.get("Message") == null || hm.get("Message").length ==0)
				{
					break;
				}
				
				log.debug(numMsg++ + ". Received Msg length: " + hm.get("Message").length + new String(hm.get("Message")));
				if(hm != null)
				{
					actObj.AckMsg();
				}
			}
			
			actObj.CloseActiveMQ();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}
