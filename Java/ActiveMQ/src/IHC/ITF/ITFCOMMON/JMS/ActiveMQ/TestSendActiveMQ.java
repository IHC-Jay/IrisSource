package IHC.ITF.ITFCOMMON.JMS.ActiveMQ;
public class TestSendActiveMQ {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		try
    	{
			String str = "ISA*00*          *00*          *ZZ*HT000015-040   *ZZ*HT000015-004   *160610*0921*^*00501*720156951*0*P*:~GS*HS*HT000015-040*HT000015-004*20160610*0921*1*X*005010X279A1~ST*270*0001*005010X279A1~BHT*0022*13*00000014A*20160610*0921~HL*1**20*1~NM1*PR*2*SELECT HEALTH*****PI*HT000015-004~HL*2*1*21*1~NM1*1P*2*UTAH VALLEY HOSPITAL*****XX*1114025491~HL*3*2*22*1~NM1*IL*1******MI*800969082~HL*4*3*23*0~TRN*1*R8849237C2977315*9020698101~NM1*03*1*SHUMWAY*IVY~DMG*D8*19990116~DTP*291*D8*20160609~EQ*50~SE*15*0001~GE*1*1~IEA*1*720156951~";
		System.out.println( "Queue: " + args[1] + ", URL: " + args[0]);
		ActiveMQClass actObj = new ActiveMQClass(args[0], args[1], "c:\\Temp\\activeMQ.log", 1); // "tcp://lpv-itfmsgdev01.co.ihc.com:61616", "/queue/test");
		
		actObj.CreateProducer();
        // actObj.sendMsg(str);
        actObj.sendMsg(str.getBytes(), null);
      
     System.out.println( "Sent msg: " + str);
  	actObj.CloseActiveMQ();
    	} catch (Exception e) {
            e.printStackTrace();
        }
	}

}
