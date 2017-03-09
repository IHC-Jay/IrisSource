package IHC.ITF.ITFCOMMON.JMS.ActiveMQ;
public class TestSendActiveMQ {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		try
    	{
			String str = "Hello ...This is a sample message 2..sending from FirstClient";
		System.out.println( "Queue: " + args[1] + ", URL: " + args[0]);
		ActiveMQClass actObj = new ActiveMQClass(args[0], args[1], "activeMQ.log", 1); // "tcp://lpv-itfmsgdev01.co.ihc.com:61616", "/queue/test");
		
		actObj.CreateProducer();
        actObj.sendMsg(str);
      
     System.out.println( "Sent msg: " + str);
  	actObj.CloseActiveMQ();
    	} catch (Exception e) {
            e.printStackTrace();
        }
	}

}
