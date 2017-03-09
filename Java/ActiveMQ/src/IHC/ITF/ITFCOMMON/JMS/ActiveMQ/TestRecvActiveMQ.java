package IHC.ITF.ITFCOMMON.JMS.ActiveMQ;
public class TestRecvActiveMQ {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
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
     String str = actObj.recvMsg();
     System.out.println( "Received msg: " + str);
  	actObj.CloseActiveMQ();
    	} catch (Exception e) {
            e.printStackTrace();
        }
	}

}
