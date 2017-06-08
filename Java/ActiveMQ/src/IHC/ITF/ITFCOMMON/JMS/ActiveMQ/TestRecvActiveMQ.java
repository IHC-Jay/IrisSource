package IHC.ITF.ITFCOMMON.JMS.ActiveMQ;
public class TestRecvActiveMQ {

	public static void main(String[] args) {
		// TODO Auto-generated method stubQ_SH_RT_270_Inbound
		try
    	{
			ActiveMQClass actObj ;
		System.out.println(args.length + ", Queue: " + args[1] + ", URL: " + args[0]);
		if(args.length >= 3)
		{
			 actObj = new ActiveMQClass(args[0], args[1], args[2], 1);
		}
		else
		{
			 actObj = new ActiveMQClass(args[0], args[1]); 
		}
  	// System.out.println( actObj.recvStreamMsg());
      actObj.CreateConsumer();
      for(int i = 0; i < 20; i++)
      {
    	  String str = actObj.recvMsg();
    	  System.out.println( i + ". Received msg : " + str);
    	  if(str == null)
    	  {
	    	  try {
	    		  Thread.sleep(10000);                 //1000 milliseconds is one second.
	    	  } catch(InterruptedException ex) {
	    	    Thread.currentThread().interrupt();
	    	  }
    	  }
      }
  	actObj.CloseActiveMQ();
    	} catch (Exception e) {
            e.printStackTrace();
        }
	}

}
