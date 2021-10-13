package fr.metabohub.peakforest.utils;

import java.util.ResourceBundle;

import org.apache.log4j.Logger;
import org.junit.After;
import org.junit.AfterClass;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.rules.TestName;

import fr.metabohub.peakforest.security.model.User;
import fr.metabohub.peakforest.security.services.UserManagementService;
import junit.framework.Assert;

public class UsersToolsTest {

	@Rule
	public TestName name = new TestName();

	// logger
	public Logger logger = Logger.getLogger("logger");

	/**
	 * @throws java.lang.Exception
	 */
	@BeforeClass
	public static void setUpBeforeClass() throws Exception {
		Utils.setBundleConf(ResourceBundle.getBundle("confTest"));
	}

	@AfterClass
	public static void tearDownAfterClass() throws Exception {
	}

	@Before
	public void setUp() throws Exception {
	}

	@After
	public void tearDown() throws Exception {
	}

	@Test
	public void helpTest() {
		// init
		logger.info("[junit test] " + name.getMethodName() + " -> begin");
		long beforeTime = System.currentTimeMillis();
		String[] arvs = { "-h" };
		try {
			UsersTools.main(arvs);
		} catch (Exception e) {
			e.printStackTrace();
			Assert.fail("[error] test class " + name.getMethodName() + " failled");
		}

		String[] arvs2 = { "--help" };
		try {
			UsersTools.main(arvs2);
		} catch (Exception e) {
			e.printStackTrace();
			Assert.fail("[error] test class " + name.getMethodName() + " failled");
		}

		// end
		double checkDuration = (double) (System.currentTimeMillis() - beforeTime) / 1000;
		logger.info("[junit test] " + name.getMethodName() + " -> end, tested in " + checkDuration + " sec.");
	}

	@Test
	public void helpError() {
		// init
		logger.info("[junit test] " + name.getMethodName() + " -> begin");
		long beforeTime = System.currentTimeMillis();

		String[] arvs = { "-u" };
		try {
			UsersTools.main(arvs);
			Assert.fail("[error] test class " + name.getMethodName() + " failled");
		} catch (Exception e) {
			// e.printStackTrace();
		}

		String[] arvs2 = { "--username" };
		try {
			UsersTools.main(arvs2);
			Assert.fail("[error] test class " + name.getMethodName() + " failled");
		} catch (Exception e) {
			// e.printStackTrace();
		}

		String[] arvs3 = { "--username", "toto" };
		try {
			UsersTools.main(arvs3);
			Assert.fail("[error] test class " + name.getMethodName() + " failled");
		} catch (Exception e) {
			// e.printStackTrace();
		}

		String[] arvs4 = { "--email" };
		try {
			UsersTools.main(arvs4);
			Assert.fail("[error] test class " + name.getMethodName() + " failled");
		} catch (Exception e) {
			// e.printStackTrace();
		}

		String[] arvs5 = { "-e" };
		try {
			UsersTools.main(arvs5);
			Assert.fail("[error] test class " + name.getMethodName() + " failled");
		} catch (Exception e) {
			// e.printStackTrace();
		}

		// end
		double checkDuration = (double) (System.currentTimeMillis() - beforeTime) / 1000;
		logger.info("[junit test] " + name.getMethodName() + " -> end, tested in " + checkDuration + " sec.");
	}

	@Test
	public void addTest() throws Exception {
		// init
		logger.info("[junit test] " + name.getMethodName() + " -> begin");
		long beforeTime = System.currentTimeMillis();

		String[] arvs = { "-e", "user_" + beforeTime + "", "-p", "thisIsApassword", "-r", "USER" };
		try {
			UsersTools.main(arvs);
		} catch (Exception e) {
			e.printStackTrace();
			Assert.fail("[error] test class " + name.getMethodName() + " failled");
		}
		User u1 = UserManagementService.read("user_" + beforeTime);
		Assert.assertNotNull("test failled", u1);
		Assert.assertEquals("test failled", u1.isAdmin(), false);
		Assert.assertEquals("test failled", u1.isCurator(), false);
		Assert.assertEquals("test failled", u1.isConfirmed(), true);

		String[] arvs2 = { "--email", "user2_" + beforeTime + "", "--password", "thisIsApassword", "--rights",
				"CURATOR" };
		try {
			UsersTools.main(arvs2);
		} catch (Exception e) {
			e.printStackTrace();
			Assert.fail("[error] test class " + name.getMethodName() + " failled");
		}
		User u2 = UserManagementService.read("user2_" + beforeTime);
		Assert.assertNotNull("test failled", u2);
		Assert.assertEquals("test failled", u2.isAdmin(), false);
		Assert.assertEquals("test failled", u2.isCurator(), true);
		Assert.assertEquals("test failled", u2.isConfirmed(), true);

		String[] arvs3 = { "--email", "user2_" + beforeTime + "", "--password", "thisIsApassword", "--rights",
				"ADMIN" };
		try {
			UsersTools.main(arvs3);
		} catch (Exception e) {
			e.printStackTrace();
			Assert.fail("[error] test class " + name.getMethodName() + " failled");
		}
		User u3 = UserManagementService.read("user2_" + beforeTime);
		Assert.assertNotNull("test failled", u3);
		Assert.assertEquals("test failled", u3.isAdmin(), true);
		Assert.assertEquals("test failled", u3.isCurator(), true);
		Assert.assertEquals("test failled", u3.isConfirmed(), true);

		// end
		double checkDuration = (double) (System.currentTimeMillis() - beforeTime) / 1000;
		logger.info("[junit test] " + name.getMethodName() + " -> end, tested in " + checkDuration + " sec.");
	}

	// @Test
	// public void manualTest() throws Exception {
	// // init
	// logger.info("[junit test] " + name.getMethodName() + " -> begin");
	// long beforeTime = System.currentTimeMillis();
	//
	// String[] arvs = {};
	// try {
	// UsersTools.main(arvs);
	// } catch (Exception e) {
	// e.printStackTrace();
	// Assert.fail("[error] test class " + name.getMethodName() + " failled");
	// }
	//
	// // end
	// double checkDuration = (double) (System.currentTimeMillis() - beforeTime) / 1000;
	// logger.info("[junit test] " + name.getMethodName() + " -> end, tested in " + checkDuration + " sec.");
	// }

}
