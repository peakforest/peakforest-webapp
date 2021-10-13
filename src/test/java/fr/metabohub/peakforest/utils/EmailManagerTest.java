/**
 * 
 */
package fr.metabohub.peakforest.utils;

import javax.mail.MessagingException;
import javax.mail.internet.AddressException;

import org.apache.log4j.Logger;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

/**
 * @author Nils Paulhe
 * 
 */
public class EmailManagerTest {

	public Logger logger = Logger.getRootLogger();

	// not in the classpath
	// public static ResourceBundle mailConf = ResourceBundle.getBundle("web-application-conf", Locale.ROOT);

	/**
	 * @throws java.lang.Exception
	 */
	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
	}

	/**
	 * @throws java.lang.Exception
	 */
	@AfterClass
	public static void tearDownAfterClass() throws Exception {
	}

	/**
	 * @throws java.lang.Exception
	 */
	@Before
	public void setUp() throws Exception {
	}

	/**
	 * @throws java.lang.Exception
	 */
	@After
	public void tearDown() throws Exception {
	}

	/**
	 * @throws AddressException
	 * @throws MessagingException
	 */
	@Test
	public void sendEmailTest() throws AddressException, MessagingException {
		// display log
		logger.info("[junit test] sendEmailTest -> begin");
		long beforeTime = System.currentTimeMillis();

		EmailManager testEmailManager = new EmailManager("smtp.clermont.inra.fr", false, null, null);
		// testEmailManager.setFrom(mailConf.getString("email.from"));
		testEmailManager.setFrom("no-reply@clermont.inra.fr");
		testEmailManager
				.sendEmail(
						"nils.paulhe@clermont.inra.fr",
						"junit test",
						"<html><body>the <b>junit</b> test class <span style=\"color: green;\">works!</span></body></html>",
						true);

		// ApplicationContext context = new ClassPathXmlApplicationContext("email-confTest");
		// EmailManager mm = (EmailManager) context.getBean("emailManager");
		// mm.sendAccountCreationEmail(null, "nils.paulhe@clermont.inra.fr");

		double checkDuration = (double) (System.currentTimeMillis() - beforeTime) / 1000;
		logger.info("[junit test] sendEmailTest -> end, tested in " + checkDuration + " sec.");

	}

}
