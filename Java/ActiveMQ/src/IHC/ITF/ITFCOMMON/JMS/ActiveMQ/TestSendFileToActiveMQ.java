package IHC.ITF.ITFCOMMON.JMS.ActiveMQ;

import java.io.BufferedReader;
import java.io.FileReader;

import javax.jms.TextMessage;

public class TestSendFileToActiveMQ {

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		try {
			System.out.println("Queue: " + args[1] + ", URL: " + args[0]);
			ActiveMQClass actObj = new ActiveMQClass(args[0], args[1],
					"activeMQ.log", 1); 
			actObj.CreateProducer();
			BufferedReader br = new BufferedReader(new FileReader(args[2]));
			String sCurrentLine;
			TextMessage message = actObj.GetActiveMQSession()
					.createTextMessage();
			while ((sCurrentLine = br.readLine()) != null) {
				if (sCurrentLine.startsWith("PROPERTY:")) {
					String[] spArr = sCurrentLine.split(":");
					message.setStringProperty(spArr[1], spArr[2]);
				} else {
					message.setText(sCurrentLine);
				}

			}

			actObj.sendMsg(message);
			System.out.println("Sent: " + message.getText());

			br.close();

			actObj.CloseActiveMQ();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

}
